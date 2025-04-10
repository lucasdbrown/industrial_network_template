# The Routers

List of the Routers (functions as router):
- enterprise_router
- idmz_router
- industrial_core_switch
- assembly_switch 
- utilities_switch 
- packaging_switch 

## Testing functionality of Routers and Switches

Have to run `vtysh` first for the other commands to work. It should give you a message like this after running `vtysh`:
```yaml
% Can't open configuration file /etc/frr/vtysh.conf due to 'No such file or directory'.

Hello, this is FRRouting (version 8.4_git).
Copyright 1996-2005 Kunihiro Ishiguro, et al.
```

```bash
vtysh 

show ip route

show ip ospf neighbor

show ip ospf interface
```
