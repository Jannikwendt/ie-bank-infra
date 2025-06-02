// ──────────────  UAT (runs on pull-request → main)  ───────────────
using 'main.bicep'

param env          = 'uat'
param location     = 'westeurope'
param dbAdminUser  = 'iebankdbadmin'
