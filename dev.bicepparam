// ──────────────  Development (runs on every branch)  ──────────────
using 'main.bicep'

param env          = 'dev'            // the app will read ENV=development
param location     = 'westeurope'     // keep in sync with RG
param dbAdminUser  = 'iebankdbadmin'  // ← whatever name you used
