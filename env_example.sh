# script to load Prod vars for automation
# keys for sftp- and login_service, etc.
# example, env-qe.sh, env-integration.sh, env-prod.sh, env.local.sh (see runner.sh)

#example
export DEFAULT_COMPANY="Automation Test Company - $(date +%d' '%b' '%Y' '%H:%M)"
export ROOT_URL="https://qe.acme.io"

# These Values are to support authentication
export LOGIN_SERVICE_HOST="https://auth.acme.com"
export USERNAME="automation@acme.com"
export USERPASS="<UserPass>"
export CLIENT_ID="X-App-KEY"
export CLIENT_SECRET="<secret>"
export CLIENT_SCOPES="<scopes>"

# This key is for the QE Environment
export SFTP_KEY=""
