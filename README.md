# Degreed-project
                  ┌────────────────────────────┐
                  │        Azure Front Door     │
                  │ (Global entry & failover)   │
                  └─────────────┬───────────────┘
                                │
              ┌─────────────────┴─────────────────┐
              │                                   │
┌─────────────▼─────────────┐       ┌─────────────▼─────────────┐
│  App Service (West US)     │       │  App Service (East US)    │
│  - Linux Plan              │       │  - Linux Plan             │
│  - Private Endpoint        │       │  - Private Endpoint       │
│  - VNet Integration        │       │  - VNet Integration       │
└─────────────┬──────────────┘       └─────────────┬────────────┘
              │                                   │
     ┌────────▼──────────┐             ┌───────────▼──────────┐
     │  SQL Server (Pri) │◄───────────►│  SQL Server (Sec)    │
     │  - Primary DB     │  Failover   │  - Geo-replica DB    │
     └────────┬──────────┘   Group     └──────────┬───────────┘
              │                                   │
              ▼                                   ▼
     ┌────────────────────────────────────────────────────┐
     │   Private DNS Zones (privatelink.*.windows.net)     │
     │   linked to both VNets for private name resolution   │
     └────────────────────────────────────────────────────┘


1. Resource Group Module

Created a tagged, environment-specific resource group.

2. Virtual Network Module

One VNet per region (West US 2 and West US 3)

Subnets for:

integration (App Service VNet integration)

pep (Private Endpoints)

NSGs with optional attachment.

3. Private DNS Zone Module

Creates required Private DNS zones:

privatelink.database.windows.net

privatelink.azurewebsites.net

Links zones to both VNets for cross-region name resolution.

4. Azure SQL Database Module

Deploys an Azure SQL Server and Database.

Supports both primary and secondary configurations:

create_mode = "Default" → Primary DB

create_mode = "Secondary" → Geo-replica DB

Uses Failover Group for automatic cross-region failover.

Private Endpoint enabled for secure connectivity.

5. App Service Module

Linux App Service Plan (P1v4)

App Service configured for:

Private Endpoint (inbound)

VNet integration (outbound)

System-assigned managed identity

Health checks and TLS enforcement.

Uses app settings:

Quotes__SqlServer

Quotes__Database

ConnectionStrings__Mode = ManagedIdentity

6. Azure Front Door Module

Global entry point for the web app.

Routes traffic to both App Services.

Provides high availability and failover between regions.

Supports HTTPS with certificate name checks.

7. SQL Failover Group

Enables transparent connection failover between regions.

Keeps database names identical for seamless connection strings.

Automatic failover policy with 60-minute grace period.

8. VNet Peering Module

Establishes bidirectional peering between West US 2 and West US 3 vnets.

