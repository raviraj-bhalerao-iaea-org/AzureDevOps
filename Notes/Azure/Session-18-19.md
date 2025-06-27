### Hub-Spoke

### Observations/Notes
- Firewalls are more expensive than VNG
  - Firewall VNG differences/similarities
```Plaintext
| Feature / Function                    | Azure Firewall                           | VPN Gateway (VNG)                                      |
| ------------------------------------- | ---------------------------------------- | ------------------------------------------------------ |
| 🔗 Primary Role                       | Security + traffic filtering (L3–L7)    | Hybrid connectivity to on-prem via VPN or ExpressRoute  |
| 🔒 Traffic Filtering                  | ✅ Yes – Network and Application rules  | ❌ No filtering — it’s a tunnel endpoint               |
| 🌐 Public Internet Access             | ✅ Can inspect/route internet traffic   | ❌ No — not used for internet access                   |
| 🔄 Routing                            | ✅ Acts like a virtual router/firewall  | ✅ Routes traffic to/from on-prem                      |
| 🔁 Transitive Routing                 | ✅ Yes (with UDRs)                      | ❌ No (not directly — but enables BGP routes)          |
| 🧠 Supports BGP                       | ❌ No                                   | ✅ Yes                                                 |
| 🚪 Supports NAT (Network Translation) | ✅ Yes (SNAT/DNAT)                      | ❌ No                                                  |
| 🔌 Peering with Spokes                | ✅ Yes (via UDRs)                       | ✅ Yes (via gateway transit & BGP)                     |
| 🔐 TLS/SSL Inspection                 | ✅ Yes (with Premium SKU)               | ❌ No                                                  |
| 💰 Billing model                      | Per GB processed + fixed hourly          | Per tunnel + GB (VPN) or port (ER) usage               |
| 🧭 Deployment in hub-spoke            | ✅ Central firewall with UDR routing    | ✅ Central gateway to connect on-prem                  |


| Feature                      | VPN Gateway (VNG) | Azure Firewall             |
| ---------------------------- | --------------------- | ------------------------------ |
| OSI Layers                   | L3 & L4               | L3 → L7                        |
| Protocols                    | IPsec, IKE, BGP       | Any TCP/UDP, HTTP/S, DNS, etc. |
| Route Learning (BGP)         | ✅ Yes               | ❌ No                           |
| Traffic Inspection/Filtering | ❌ No                | ✅ Yes                          |
| NAT                          | ❌ No                | ✅ Yes (SNAT/DNAT)              |


```




### Try
- Hub Spoke with Firewall, UDR and VNet peering
  - Access VMs with Firewall PiP
  - Transitive nature
  - Check firewall logs
  - with UDR routing within-VNet communication thru firewall, check if system route takes precedence using Firewall logging
  - Check effective routes on VNet/SubNet

- Hub Spoke with VNG (with BGP) and VNet peering
  - Try the setup without UDR
  - Try the setup with UDR
  - Check effective routes on VNet/SubNet

- 2 Hubs 2 Spoke with VNG (with BGP) and VNet peering
  - Spoke 1 peered with Hub1 and Hub2 (with Remote allow)
  - Spoke 2 peered with Hub2