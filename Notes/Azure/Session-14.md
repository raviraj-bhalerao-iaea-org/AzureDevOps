
### Session 14 - Point to Site

### There are 3 ways for clients to authenticate with Site
- Certificate (root's public key with VNetGateway, client private key on client)
- Radius Server (on-prem AD domain integration)
- MS Entra ID (App Id, Audience Value)
- One can configure multiple authentication types, the vpn client must support at least one
  
### Tunnel types 
- OpenVPN
- SSTP
- IKEv2
- IKEv2 and OpenVPN
- IKEv2 and SSTP

There are considerations based on the authentication mechanism selected and client device OS.

### Try
Done - Check if VMs Ip Address is allocated from GatewaySubnet series. : No, from P2S configuration
- Check if on-prem machine is ping`able from VM

### Lessons
- Always create object, set its properties and then set that object to Azure object's property.
- Sometimes portal does not show the real value if its set using powershell, try to print the value of that object using Powershell to verify.
- To find sku for a VM use Get-AzVMImagePublisher, Get-AzVMImageOffer, Get-AzVMImageSku