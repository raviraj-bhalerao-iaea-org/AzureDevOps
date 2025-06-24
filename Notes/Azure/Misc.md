### Subnet properties
#### **Virtual Network service endpoints** 
- It allows resources in the subnet to access azure resources using MS backbone
``` Plaintext
🔍 In Simple Terms:
By default, when a resource (like a VM or App Service) in your VNet accesses an Azure PaaS service (like Azure Storage or Azure SQL), it goes over the public internet, even if it’s secure (HTTPS).

Service endpoints change that by linking the Azure service directly to your VNet, so traffic:

Stays within Azure’s private network

Never traverses the public internet

Can be restricted to only selected VNets or subnets

🧱 How It Works:
You enable a service endpoint on a subnet in your VNet.

You specify which Azure service(s) it applies to (e.g., Microsoft.Storage, Microsoft.Sql).

On the Azure service side (e.g., a storage account), you set up a virtual network rule allowing access only from that subnet.

Now, any resource in that subnet accesses the service privately and securely via the Azure backbone.

✅ Key Benefits:
Improved security: No internet exposure.

Simplified firewall rules: Azure services can restrict access to specific VNets.

Optimized routing: Traffic stays on the Azure backbone.

No need for NAT or public IPs for access to PaaS services.
```
#### **Subnet delegation####
- In Azure, Subnet Delegation is a feature that allows you to assign a specific Azure service to manage a subnet. This means you explicitly tell Azure that a particular subnet is meant to host a specific PaaS (Platform as a Service) resource — and only that type of resource.
``` Plaintext
🔍 In Simple Terms:
Subnet Delegation is like saying:

"This subnet is only for Azure App Service, or only for Azure Container Instances, or only for Azure Bastion."

Azure will then enforce this, and only allow the designated service to deploy into that subnet.

✅ Why Use Subnet Delegation?
Required for certain PaaS services
Some services (like Azure App Service with VNet integration, or Azure Bastion) require subnet delegation to function.

Tighter control
Prevents accidental or unauthorized use of a subnet for the wrong type of resource.

Enables Azure to configure and manage network settings
Delegated subnets allow the Azure platform to create required resources (like NICs, routes) in your VNet securely.

🛑 Important Notes:
A delegated subnet can only be used by the specified service — you can’t deploy VMs or other unrelated resources there.

You can only delegate a subnet to one service at a time.

Not all services support subnet delegation — but more PaaS services are adopting it.
```
### Default gateway
- Default gateway for a subnet is its first usable address ( first IP is network address e.g. in 10.0.0.0/24 10.0.0.0 is network address where as 10.0.0.1 is default gateway)
- Host sends packets to default gateway for all unresolved/unmatched specific routes.
- Default gateway (0.0.0.0/0) is Networks default gateway that represents any ip address.