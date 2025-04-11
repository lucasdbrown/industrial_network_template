# What would you have to do if you wanted to make your Competition Network Accessible to Competitors?
1. Expose the ports of the Services you want to be reachable by competitors
2. Setup a WireGuard VPN Server
3. Send a VPN configuration file to each competitor telling them how to set it up.

### How to Setup a WireGuard VPN Client
- Windows and MacOS Tutorials: https://www.tp-link.com/no/support/faq/3989/ 
- Linux Distro Installation Instructions in this link: https://www.wireguard.com/install/
- On a Linux Distro, move the VPN configuration file to /etc/wireguard/wg0.conf then run "wg-quick up wg0". To take the tunnel down, run "wg-quick down wg0". 
