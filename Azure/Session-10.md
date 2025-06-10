## Session 10 - VNG (Virtual Network Gateway)

### VNet Peering Limitations:
- Same Cloud (Cannot connect anything outside the cloud)  
- No Encryption  
- Not transitive

### VNG
- Overcomes all limitations of VNet peering
- Must be established over the internet  
- P2S (Point-to-Site: Single Laptop to Azure VNet, e.g., WFH)  
- S2S (Site-to-Site: On-Prem to VNet)  

### VNG VNet peering comparison

> | VNG|VNet Peering|
> |-|-|
> |Connects Azure VNet to external environments|Within Azure cloud|
> |Uses internet|Uses backbone|
> |Secured - with encryption|Secured being on backbone, No encryption|
> |Moderate Latency|Low latency|
> |Speed may vary|Faster and reliable|

### VNG types
>|VPN|Express Route|
>|-|-|
>|Over internet|Over dedicated cable from ISP to On Prem, ISP to Azure DC is already established|

| Feature                      | **VPN Gateway**                           | **ExpressRoute Gateway**                                        |
| ---------------------------- | ----------------------------------------- | --------------------------------------------------------------- |
| Cross-Subscription Supported | ✅ Yes                                     | ✅ Yes                                                           |
| Cross-Tenant Supported       | ✅ Yes (with permissions / guest accounts) | ✅ Yes (but more complex, requires ExpressRoute circuit sharing) |
| Public IP Used               | ✅ Yes (required)                          | ❌ No (private peering via Microsoft backbone)                   |
| Uses Microsoft Backbone      | ✅ For VNet-to-VNet with gateway           | ✅ Always (ExpressRoute always uses MS backbone)                 |
| Encryption                   | ✅ IPsec/IKE encryption                    | ❌ Not by default (optional via MACsec or IPsec overlay)         |
| Transitive Routing           | ✅ With BGP                                | ✅ With BGP and Route Server                                     |
| Peering Model                | VNet Gateway to VNet Gateway via IPsec    | Circuit → ExpressRoute Gateway → VNet(s)                        |
| Resource ID Linking          | ❌ No (for VPN)                            | ✅ Yes (if using ExpressRoute Circuit Authorization)             |


### VNG S2S Components
- VNG on Azure side
- LNG on on-prem side
- PiP on VNG
- PiP for LNG
- Dedicated subnet for VNG (GatewaySubnet cidr > 27)
- LNG and VNG encrypt and decrypt data just before transmission and just after transmission
- Encryption Protocol :
  - For S2S : IKE and Ipsec protocols used for encryption and Key (Internet Key Exchange and Internet Protocol Security) : IEK establishes the secure tunnel, IPSec encrypts, transmits and decrypts the data 
  - For P2S : ISE2/SSTP/Open VPN
- SKU (Stock keeping unit) : decides the performance of the tunnel
- VNG is deployed for VNet, so all subnets and resources in those subnets can access VNG, by default.
- This can be curbed using NSG and UDR; NSG filters using IP and Port, UDR decides which resource can route the traffic to other side of the VNG
- BGP (Optional) : Border gateway protocol - find shortest path to destination
  

### Possible use cases
| Scenario                     | What it Means                                        | Example                                  |
| ---------------------------- | ---------------------------------------------------- | ---------------------------------------- |
| Site-to-site (On-Premises)   | Permanent VPN tunnel between on-prem network & Azure | HQ network connects to Azure VNet        |
| Point-to-site                | Individual device VPN to Azure                       | Work laptop connects from home           |
| VNet-to-VNet                 | Encrypted tunnel between two Azure VNets             | Connect East US VNet to West Europe VNet |
| Site-to-site (VNet-to-VNet)  | Site-to-site type connection for VNets + on-prem     | One gateway manages multiple tunnels     |
| ExpressRoute + VPN Gateway   | VPN as backup to ExpressRoute                        | Backup path if ExpressRoute fails        |
| ExpressRoute + VPN for sites | Mix of ExpressRoute and VPN connections              | HQ on ExpressRoute, branches on VPN      |

### Observations
 - VNet -VNet though takes PiP, it uses PiPs for initial hand shake but <a href="https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/vnet-peering#comparison-of-virtual-network-peering-and-vpn-gateway">tunnel is established using Azure Backbone.</a> 
 - In parlance, VPN Gateway = Virtual Network Gateway of VPN type; other one being Express Route which uses "Private Circuit Connection" which is dedicated wired connection, not internet; On-Prem -> DC -> VNet
 - One needs Network Contributor rights in each subscriptions while setting up VPN Gateway between two VNets.
    - This is different in Express Router, in that, the owner of the Route shares a Authorization Key.

### Try
- Establish VNet peering with encryption
- Try VNG with region different from VNet
- Test transitivity of VPN Gateway (BGP must be enabled)