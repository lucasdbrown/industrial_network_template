#!/usr/bin/env python3
"""
Create all external:true Docker networks required by a compose project.

Usage:
    python setup_external_networks.py --compose-dir <folder>
Options:
    --compose-dir   Path that contains docker-compose.yml
Env:
    USER_SUBNET_MAP  Optional path to .yml file mapping network_name -> subnet
                     (defaults to .ci/networks.yml at repo root)
"""
import argparse, hashlib, os, subprocess, sys, yaml, ipaddress, pathlib, textwrap

def sh(cmd, **kw):
    kw.setdefault("check", True)
    return subprocess.run(cmd, text=True, capture_output=False, **kw)

def choose_subnet(name, ips, used, user_map):
    """Return a /24 subnet that doesn't overlap anything in `used`."""
    # 1- explicit mapping wins
    if name in user_map:
        return user_map[name]

    # 2- derive from static IPs if present
    if ips:
        octets = [list(map(int, ip.split("."))) for ip in ips]
        a, b, c, _ = octets[0]
        same24 = all(o[:3] == [a, b, c] for o in octets)
        if same24:
            subnet = f"{a}.{b}.{c}.0/24"
            if subnet not in used:
                return subnet
        # fall through to hash
    # 3- deterministic hash inside 192.168.X.0/24 (X = 10-254)
    for _ in range(245):                               # 245 unique /24s
        h = (hash(name) & 0xFFFF_FFFF) % 245 + 10      # 10-254
        subnet = f"192.168.{h}.0/24"
        if subnet not in used:
            return subnet
        name += "x"  # perturb hash

def parse_args():
    p = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter,
                                description=__doc__)
    p.add_argument("--compose-dir", required=True)
    return p.parse_args()

def main():
    args = parse_args()
    compose_dir = pathlib.Path(args.compose_dir).resolve()
    os.chdir(compose_dir)

    repo_root = pathlib.Path.cwd()
    while repo_root.parent != repo_root and not (repo_root/".git").exists():
        repo_root = repo_root.parent

    user_map_file = os.getenv("USER_SUBNET_MAP", repo_root/".ci/networks.yml")
    user_map = {}
    if pathlib.Path(user_map_file).exists():
        user_map = yaml.safe_load(open(user_map_file)) or {}

    # Compose files (base + optional CI override)
    compose_files = ["docker-compose.yml"]
    if (compose_dir / "docker-compose.ci.override.yml").exists():
        compose_files += ["docker-compose.ci.override.yml"]

    cmd = ["docker", "compose"]
    for f in compose_files:
        cmd += ["-f", f]
    cmd += ["config"]

    merged_yaml = sh(cmd, capture_output=True).stdout
    data = yaml.safe_load(merged_yaml) or {}
    nets_cfg  = data.get("networks", {}) or {}
    services  = data.get("services", {}) or {}

    externals = {}
    for key, cfg in nets_cfg.items():
        if isinstance(cfg, dict) and cfg.get("external"):
            externals[cfg.get("name", key)] = {"ips": set()}

    # collect static IPs
    for scfg in services.values():
        nets = scfg.get("networks", {}) or {}
        if isinstance(nets, list):
            nets = {n:{} for n in nets}
        for n_key, n_opts in nets.items():
            if n_key in nets_cfg and nets_cfg[n_key].get("external"):
                name = nets_cfg[n_key].get("name", n_key)
                ip = isinstance(n_opts, dict) and n_opts.get("ipv4_address")
                if ip:
                    externals[name]["ips"].add(ip)

    # gather already-defined subnets to avoid overlap
    used_subnets = set()
    for n in nets_cfg.values():
        if isinstance(n, dict):
            ipam = n.get("ipam", {})
            if ipam and "config" in ipam:
                for seg in ipam["config"]:
                    if "subnet" in seg:
                        used_subnets.add(seg["subnet"])

    # also record any existing Docker networks on runner
    existing = subprocess.check_output(["docker", "network", "ls",
                                        "--format", "{{.Name}}"]).decode().splitlines()
    for net in existing:
        inspect = subprocess.check_output(["docker", "network", "inspect", net,
                                           "--format", "{{(index .IPAM.Config 0).Subnet}}"]).decode().strip()
        if inspect:
            used_subnets.add(inspect)

    # create each external network if missing
    for name, meta in externals.items():
        if sh(["docker", "network", "inspect", name], check=False).returncode == 0:
            print(f"{name}: already exists")
            continue
        subnet = choose_subnet(name, meta["ips"], used_subnets, user_map)
        print(f"{name}: creating with subnet {subnet}")
        sh(["docker", "network", "create", "--subnet", subnet, name])
        used_subnets.add(subnet)

if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as e:
        sys.stderr.write(f"❌  {e}\n")
        sys.exit(e.returncode)