// ── Parameters ─────────────────────────────────────────────
@allowed([
  'dev'
  'uat'
])
param env string                              // dev | uat  (controls SKUs & names)
param location string  = resourceGroup().location

// passwords are fed by pipeline as secure parameters
@secure()
param dbAdminPassword string
@secure()
param dbAdminUser string      // must be provided securely at deployment

// ── Naming helpers ─────────────────────────────────────────
var prefix        = 'iebank-${env}'           // iebank-dev / iebank-uat
var postgresName  = '${prefix}-pgsql'
var planName      = '${prefix}-plan'
var feSiteName    = '${prefix}-fe'
var beSiteName    = '${prefix}-be'

// ── SKUs per environment ───────────────────────────────────
var pgSku  = (env == 'uat')
  ? 'Standard_B1ms'   // 1 vCPU, 2 GiB  (assignment spec)
  : 'Burstable_B0'

var appSku = (env == 'uat')
  ? {
      tier:  'Basic'
      size:  'B1'
    }
  : {
      tier:  'Free'
      size:  'F1'
    }

// ── Resources ──────────────────────────────────────────────
resource postgres 'Microsoft.DBforPostgreSQL/flexibleServers@2022-01-20-preview' = {
  name:   postgresName
  location: location
  properties: {
    administratorLogin:         dbAdminUser
    administratorLoginPassword: dbAdminPassword
    version:                    '15'
    storage: {
      storageSizeGB: 32
    }
  }
  sku: {
    name: pgSku
    tier: 'Burstable'
  }
}

resource appPlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: planName
  location: location
  kind: 'linux'
  sku: appSku
  properties: {
    reserved: true            // Linux
  }
}

resource feSite 'Microsoft.Web/sites@2022-09-01' = {
  name: feSiteName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appPlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|18-lts'
    }
  }
}

resource beSite 'Microsoft.Web/sites@2022-09-01' = {
  name: beSiteName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appPlan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
      appSettings: [
        {
          name:  'DBHOST'
          value: postgres.properties.fullyQualifiedDomainName
        }
        {
          name:  'DBUSER'
          value: dbAdminUser
        }
        {
          name:  'DBPASS'
          value: dbAdminPassword
        }
      ]
    }
  }
}

// ── Outputs (handy in portal) ──────────────────────────────
output frontEndUrl string = 'https://${feSiteName}.azurewebsites.net'
output backEndUrl string = 'https://${beSiteName}.azurewebsites.net'
