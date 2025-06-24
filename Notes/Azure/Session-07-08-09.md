## Session 07,08 - NSG

### Drawbacks of VNet Peering
- No encryption  
- Cannot connect to on-prem network  
- Does not support transitive traffic by default  

### NSG
- Regional + VNet level service  
- Basic, stateful, packet-level firewall (IP, Port, Protocol)  
- Just a rule book of who is allowed/not; no routing  
- Can be attached to a VM or subnet only in the same region  
- When attached to a subnet and VM (actually NIC) inside, works as layered defense  
- It’s a stateful firewall – checks only the request, not the reply/response  
  - Stateless firewall checks both  
  - To control/check response as well (if stateless protection is needed), use Azure Firewall service, LB, WAF. They also offer DDoS protection.  
- AWS supports stateless firewall  
- Works at Layer 3 and 4 (IP, Port, and Protocol)  
- Free  
- Ideal for internal traffic control within a VNet or to/from specific VMs  
- One NIC/Subnet can have only one NSG; one NSG can be attached to multiple NICs or subnets  

> If PIP is basic, all traffic is open; if PIP is standard, all traffic is closed.

> Destination = Any for inbound rule and Source = Any for outbound rule would mean all resources the NSG is protecting (so all VMs in subnet if NSG is attached to the subnet / the only VM in case NSG is attached to its NIC).

Each NSG rule is defined with:
- Name  
- Direction  
- Action  
- Priority  
- Source IP/CIDR  
- Source port  
- Destination IP/CIDR  
- Destination port  

> By default, NSG provides 3 inbound and 3 outbound rules, which cannot be deleted but can be overridden.

Rules are evaluated in ascending order of priority; the smallest priority dictates the outcome.

#### 3 Inbound Rules
- `AllowVNet : 65000` - Allow all VNet (VNet.AllPorts → VNet.AllPorts) [Used in VNet peering]  
- `AllowLB : 65001` - Allow all LBs (LB → Any)  
- `DenyAll : 65500` - Deny any inbound (Any → Any)  

#### 3 Outbound Rules
- `AllowVNet : 65000` - Allow all VNet (VNet.AllPorts → VNet.AllPorts) [Used in VNet peering]  
- `AllowInternet : 65001` - Allow Internet (Any → Internet)  
- `DenyAll : 65500` - Deny any outbound (Any → Any)  

---

### Try

#### Done 1. Remove NIC NSG and allow subnet to control it
- Create NIC with NSG (Allow 22)  
- Test VM connection  
- Remove NIC NSG  
- Attach the NSG to Subnet  
- Test VM connection  

#### Done 2. Create NIC without NSG
- Test VM connection  
- Attach NSG (allow 22) to Subnet  
- Test VM connection  

#### Done 3. Advanced NSG at VM creation
- Create NSG (Allow 22)  
- Create VM with Advanced (use already created NSG, or create a new one)  
- Test connection  

#### Done 4. Conflicting NSGs
- Two rules in NSG for NIC: [30 - allow 22, 35 - deny 22]  
- Test connection  
- Change priority: [35 - allow 22, 30 - deny 22]  
- Test connection: Established connection remains operational; new connection is refused  
- Subnet allow 22, NIC deny 22 and vice versa  
- Test connection  

#### No
