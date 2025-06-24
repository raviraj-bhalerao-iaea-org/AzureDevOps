### Network Address Translation gateway
- Regional, VNet level service
- Acts at L3 of OSI, manages routing and translation of outbound packets
- Performs SNAT - source network address translation (replacing private ips with pip)

### Components
- PiP 
- PiP prefix (to avoid SNAT port exhaustion)


### Observations
- Supports only TCP and UDP
- *Precedence order* :
  - UDR to next hop Virtual appliance or virtual network gateway >> NAT gateway >> Instance-level public IP address on a virtual machine >> Load balancer outbound rules >> default system route to the internet.
- NAT Gateway can not be assigned to Gateway Subnet
- **Azure maintains default nat gateway** (one with second ip in the reserved ip range) at regional level, its used for VMs without NAT
  > | IP Position    | Purpose                                                |
  > | -------------- | ------------------------------------------------------ |
  > | First IP (.0)  | Network address                                        |
  > | Second IP (.1) | Reserved for Azure default gateway                     |
  > | Third IP (.2)  | Reserved (DNS or future use)                           |
  > | Fourth IP (.3) | Reserved                                               |
  > | Last IP (.255) | Broadcast address (though Azure doesn't use broadcast) |



### Try
Done - Analyse NSG flow logs :
  - Created Storage Account
  - Created Log Analytics Workspace
  - Configured NSG flow logging
  - Generated traffic from VMS
    - curl to outside internet : Allow
    - Ping VM (private/public ip) : Deny
    - curl to VM's PiP using http
  - Viewed insights-logs-networksecuritygroupfloweven container
  - Looked at json and understood the structure and contents with help of Chatgpt
Done - Analyse NAT gateway resource metrics :
  - Looked various metrics like SNat connection count, dropped packets, etc.
Done - Analyse NAT gateway diagnostic logs
  - There are no NAT Gateway diagnostic logs; however configured VNet flow logs. Flow logs can be configured only for NSG and VNet (which include NIC, Subnet and VNet itself)
Done - NAT Gateway to multiple subnets
Done - NAT gateway with ip address prefix
Done - Assign a PiP to VM and NAT to its subnet; run check my PiP in browser. : NAT PiP takes precedence
Done - Check effective routes on NIC
- TODO : Try with Hub and SPOKE
- TODO : Check the default gateway address in ipconfig with NAT Gateway : Its always first usable ip in subnet private ip range. This gateway is different from the azure nat gateway used for SNAT'ing outbound request.