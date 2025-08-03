#!/usr/bin/env python3
"""
Create all external:true Docker networks required by a compose project,
choosing unique /24 subnets and avoiding overlaps with built-ins.
"""
import argparse, hashlib, os, subprocess, sys, yaml, pathlib

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--compose-dir", required=True)
    return p.parse_args()

def run(cmd, **kw):
    return subprocess.run(cmd, text=True, capture_output=kw.pop("capture_output", False), **kw)

def main():
    args = parse_args()
    cd = pathlib.Path(args.compose_dir)
    os.chdir(cd)

    # load optional user map
    root = cd
    while root.parent != root and not (root/".git").exists():
        root = root.parent
    mapfile = os.getenv("USER_SUBNET_MAP", str(root/".ci/networks.yml"))
    user_map = {}
    if os.path.exists(mapfile):
        user_map = yaml.safe_load(open(mapfile)) or {}

    # merge compose files
    files = ["docker-compose.yml"]
    if os.path.exists("docker-compose.ci.override.yml"):
        files.append("docker-compose.ci.override.yml")
    cmd = ["docker","compose"] + sum([["-f",f] for f in files],[]) + ["config"]
    merged = subprocess.check_output(cmd, text=True)
    data = yaml.safe_load(merged) or {}
    nets_cfg = data.get("networks",{}) or {}
    services = data.get("services",{}) or {}

    # find externals and any static IPs
    externals = {}
    for key,cfg in nets_cfg.items():
        if isinstance(cfg,dict) and cfg.get("external"):
            name = cfg.get("name",key)
            externals[name] = set()
    for svc in services.values():
        nets = svc.get("networks",{}) or {}
        if isinstance(nets,list):
            nets = {n:{} for n in nets}
        for nkey,nopts in nets.items():
            if nkey in nets_cfg and nets_cfg[nkey].get("external"):
                name = nets_cfg[nkey].get("name",nkey)
                ip = isinstance(nopts,dict) and nopts.get("ipv4_address")
                if ip:
                    externals[name].add(ip)

    # collect used subnets from compose ipam
    used = set()
    for cfg in nets_cfg.values():
        if isinstance(cfg,dict):
            ipam = cfg.get("ipam",{}).get("config",[])
            for seg in ipam:
                s = seg.get("subnet")
                if s: used.add(s)

    # also collect existing Docker networks (skip built-ins)
    builtin = {"bridge","host","none"}
    existing = subprocess.check_output(
        ["docker","network","ls","--format","{{.Name}}"],
        text=True
    ).splitlines()
    for net in existing:
        if net in builtin: continue
        try:
            sub = subprocess.check_output(
                ["docker","network","inspect", net,
                 "--format","{{(index .IPAM.Config 0).Subnet}}"],
                text=True, stderr=subprocess.DEVNULL
            ).strip()
            if sub: used.add(sub)
        except subprocess.CalledProcessError:
            continue

    # helper to pick unique /24
    def choose(name, ips):
        if name in user_map: return user_map[name]
        if ips:
            # if all ips in same /24, use that
            octs = [list(map(int,i.split("."))) for i in ips]
            a,b,c,_ = octs[0]
            if all(o[:3]==[a,b,c] for o in octs):
                return f"{a}.{b}.{c}.0/24"
        # hash into 192.168.10-254.x
        for i in range(10,255):
            if i>=10:
                sub = f"192.168.{i}.0/24"
                if sub not in used:
                    return sub
        raise RuntimeError("Ran out of subnets!")

    # create each external network
    for name, ips in externals.items():
        res = run(["docker","network","inspect",name], check=False)
        if res.returncode==0:
            print(f"{name}: exists")
            continue
        subnet = choose(name, ips)
        print(f"{name}: creating {subnet}")
        run(["docker","network","create","--subnet",subnet,name], check=True)

if __name__=="__main__":
    try:
        main()
    except Exception as e:
        print("❌", e, file=sys.stderr)
        sys.exit(1)