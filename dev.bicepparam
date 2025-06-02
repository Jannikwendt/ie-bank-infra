
using './main.bicep'

param env              = 'dev'
param dbAdminUser      = ''   // TODO: set the database admin username
param dbAdminPassword  = ''   // will be overridden by workflow
