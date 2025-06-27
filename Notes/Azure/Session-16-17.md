### Azure Firewall
### Session 16 - Theory

### Firewall NSG comparison
| Feature                          | **Network Security Group (NSG)**      | **Azure Firewall**                                             |
| -------------------------------- | ------------------------------------- | -------------------------------------------------------------- |
| **Purpose**                      | Basic traffic filtering (ACL-style)   | Advanced, centralized traffic control and logging              |
| **Layer**                        | Layer 3 & 4 (IP & Port)               | Layer 3, 4, and 7 (includes FQDN, protocols, TLS inspection)   |
| **Granularity**                  | Source/Destination IP, Port, Protocol | Same as NSG + FQDNs, URL filtering, TLS termination (Premium)  |
| **Stateful?**                    | ✅ Yes                                | ✅ Yes                                                        |
| **Rule Types**                   | Allow/Deny (no NAT or app rules)      | Network rules, Application rules, NAT rules                    |
| **Application Awareness (FQDN)** | ❌ No                                 | ✅ Yes (e.g., `*.microsoft.com`)                              |
| **NAT Support**                  | ❌ No                                  | ✅ Yes (DNAT/SNAT)                                           |
| **Logging and Analytics**        | Basic NSG flow logs                   | Deep logging to Log Analytics, diagnostics, metrics            |
| **Cost**                         | Free                                  | **Paid** — per-hour + per-GB fees                              |
| **Use Case**                     | VM/subnet-level access control        | Centralized filtering for hybrid, internet-bound, inter-subnet |
| **Deployment Scope**             | Applied to NICs or Subnets            | Deployed as a central resource in a VNet                       |

### Firewall rules to NSG rules

- Firewall defines rules in the form of Rules Collections and Rules inside the Rules Collection.
  Rules collections have priorities just like NSG rules as well as action as Allow/Deny
  Lower the priority number higher is the priority
  Inside the rule collection, each rule has only one result match or not. The rules are evaluated in sequence and evaluation stops at first matched rule.

```
[ Rule Collection Group ]
    └── Rule Collection (Priority: <number>, Action: Allow/Deny)
          ├── Rule 1 ← evaluated first
          ├── Rule 2
          ├── Rule 3
```

  - e.g. Rule Collection: BlockMalwareSites
    Priority: 100
    Action: Deny
    Rules:
    - Name: BlockBadSite1
    - Target FQDN: badsite.com
    - Name: BlockBadSite2
    - Target FQDN: evil.net

#### **Firewall/NSG rules comparison**
| Feature / Aspect        | **Azure Firewall Rules**                       | **NSG Rules**                            |
| ----------------------- | ---------------------------------------------- | ---------------------------------------- |
| **Scope**               | Centralized, network-wide (often in hub/spoke) | Subnet or NIC level                      |
| **OSI Layer**           | Layer 4 (TCP/UDP) and Layer 7 (HTTP/S)         | Layer 3 & 4 (IP, Port, Protocol)         |
| **Statefulness**        | **Stateful**                                   | **Stateful**                             |
| **Rule Types**          | Application (L7), Network (L3/L4), NAT         | Inbound/Outbound (L3/L4)                 |
| **Supports FQDNs**      | ✅ Yes (e.g. `*.microsoft.com`)                 | ❌ No (only IP-based)                     |
| **Threat Intelligence** | ✅ Yes – blocks traffic from malicious sources  | ❌ No                                     |
| **Logging & Analytics** | Advanced via Azure Monitor & Log Analytics     | Basic logs, can be enabled               |
| **Cost**                | **Paid service**                               | **Free**                                 |
| **Typical Use Case**    | Central firewall in **hub network**, DNAT/SNAT | Basic isolation in **subnet or VM NICs** |
| **Rule Granularity**    | Granular control over L3–L7                    | Basic allow/deny at L3–L4                |

##### **Key Points**
- 🧱 NSG Rules
> Enforced at the subnet or network interface (NIC) level.

> Good for basic traffic filtering, e.g., allow port 443 from internet.

> Can't inspect application-level data (e.g., URLs, domains).

> Example:

> Allow TCP 443 inbound from Internet to subnet.

> Deny all RDP (TCP 3389) from all IPs.

- 🔥 Azure Firewall Rules – Key Points
> Designed for centralized control of network traffic.

> Supports FQDNs, URL-based filtering, and protocol inspection.

> Ideal for hub-and-spoke or shared services architectures.

> Example:

> Allow HTTP(S) to *.windowsupdate.com.

> DNAT public IP port 80 to internal web server.

- 🧠 Use Them Together (Best Practice)
> Use NSGs to protect individual subnets/VMs from unauthorized access.

> Use Azure Firewall for:

> Outbound filtering (e.g., restrict internet access),

> Inbound access via DNAT,

> Centralized rule management across VNets.

#### **Protocols support**
| Protocol        | NSG Support                    | Azure Firewall Support          |
| --------------- | ------------------------------ | ------------------------------- |
| **TCP**         | Yes                            | Yes (Network, NAT, Application) |
| **UDP**         | Yes                            | Yes (Network, NAT)              |
| **Any**         | Yes                            | Yes (TCP/UDP only)              |
| **HTTP/S**      | No (cannot filter by protocol) | Yes (Application rules)         |
| **MSSQL**       | No                             | Yes (Application rules)         |
| **ICMP**        | Yes (Allow only)               | No                              |
| **ESP (IPsec)** | Yes                            | No                              |
| **AH (IPsec)**  | Yes                            | No                              |



### Other points to consider/observed

- Firewall integrates with MS threat intelligence and MS Malicious IP Addresses db
- Works at OSI layer 3, 4, 7 (FQDN)
- Force tunnelling on firewall
  - Setup VNG to e,g, on-prem
  - Setup Firewall
  - Change workload udr to route outbound to Firewall private ip : Unless its done, default pip is picked from azure default nat gateway and not from firewall
  - Change firewall subnet udr to route the outbound to VNG private ip
  - VNG will automatically route to on-prem/NVA
```plaintext
Workloads → UDR → Azure Firewall → UDR → VNG → On-Premises
```
  - To connect to zone-redundant VM and to use Zone-Redundant PiP, firewall must be zone-redundant too, which can be created either with VNet or if VNet already exist, **must be created using PS**.
  - In network rules Source IP or Destination IP can be comma separated list or * or IP Group but not address prefix.
  - DNAT rule gets automatically translated into N/W rule but not visible in the list there.
  - Rule collections are evaluated in following order - DNAT, Network and then Application rule collection. Any point in time a match is found, remaining rule collections are evaluated.

#### UDR
- Attached to Subnet  (1 subnet :: 1 UDR)
- Each subnet has by default system routes
- Acts on layer 3 of OSI (no ports used)
- More specific rules take precedence over generic rules and its done by the UDR service automatically
  - if a packet is being sent to 45.25.65.32 and if you have following 3 rules
    - 45.25.65.32/25 -> 1.2.3.4, 45.25.65.32/32 -> 5.6.7.8, 0.0.0.0/0 -> 10.5.0.4 then UDR will send the packet to 5.6.7.8, 45.25.65.32/32 being more specific rule for 45.25.65.32 destination
- Difference between UDR and DNAT/SNAT
```PlainText
| Feature   | UDR                        | DNAT                           | SNAT                          |
| --------- | -------------------------- | ------------------------------ | ----------------------------- |
| Works on  | Routing decision/ Layer 3  | Destination IP/Port / Layer 3  | Source IP                     |
| Modifies? | ❌ No (just forwards)      | ✅ Yes                        | ✅ Yes                        |
| Direction | Outbound                   | Inbound                        | Outbound                      |
| Use Case  | Force routing to appliance | Expose internal service        | Egress via firewall/public IP |

```
  

### Try 
Done - Ping firewall private ip from VM (all firewall private ips)

Done - Check effective routes for firewall? : Cannot be, as firewall's Nic is not exposed.

Done - Add DNAT to firewall, test if VM can be connected with SSH without NSG : Can not be connected

Done - Add a NAT Gateway to firewall subnet : *Nat Gateway PiP* is assigned to outbound packet

Done - Try to change the CIDR of AzureFirewallSubnet : Can not change, its fixed to /26 ~ 64 addresses

Done - Try service Tags and FQDN tags: These tags are predefined e.g. FQDN Tags - WindowsUpdate, AzureActiveDirectory; Service Tags - VirtualNetwork, Internet, AzureCloud, Storage etc.

Done - Assign PiP prefix to firewall PiP : Not supported

TODO - De-allocate/allocate firewall and check IP configuration : P Script

Done - Allocate the VM a PiP, configure DNat for the VM's private ip, connect to VM using its's PiP and firewall's pip/port : If UDR is configured connection to VM with PiP fails. The communication to VM with PiP works but outbound comm is routed to firewall and it fails.
```PlainText
    🚧 What Happens Internally:
        Your SSH/RDP request enters Azure → hits the VM's public IP

        The VM receives the packet and wants to respond (return traffic)

        But your UDR says "Send all outbound (0.0.0.0/0) via the firewall"

        So return traffic takes a different path (through firewall)

        🔥 Azure sees that inbound and outbound paths are different

        ❌ Azure drops the session as a security measure

        This is not configurable — even Azure Firewall rules cannot fix this.
```
TODO: - Test using VNG and Firewall

Done - Use IP group to allow/deny FQDN

### Session 17 - Lab

### Local machine and default gateway
- Each machine's OS, when connected to a n/w, sends a request to DHCP; DHCP responds with ip address, default gateway ip, Subnet mask, DNS server. Each n/w is configured with firewall/nva ip as default gateway. Thats how each device when gets connected to n/w, gets all the details.
- 
