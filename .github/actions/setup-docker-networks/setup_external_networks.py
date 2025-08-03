import subprocess

SUBNET_FILE = ".github/actions/setup-docker-networks/subnets.txt"

def create_network(name, subnet):
    print(f"🔧 Creating network {name} with subnet {subnet}")
    cmd = [
        "docker", "network", "create",
        "--driver", "bridge",
        "--subnet", subnet,
        name
    ]
    subprocess.run(cmd, check=True)

def main():
    with open(SUBNET_FILE, "r") as f:
        for line in f:
            name, subnet = line.strip().split("\t")
            try:
                create_network(name, subnet)
            except subprocess.CalledProcessError as e:
                print(f"⚠️ Network {name} may already exist or failed to create: {e}")

if __name__ == "__main__":
    main()