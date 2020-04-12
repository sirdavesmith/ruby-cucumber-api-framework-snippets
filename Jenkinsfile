#!groovy​
pipeline {
	agent {
		dockerfile {
			args '-u root:root'
		}
	}
	environment{
		CLIENT_ID         = "App-KEY"
		CLIENT_SCOPES     = "<scopes>"
		DEFAULT_COMPANY   = "QE Integration Org"
		ORG_ID            = "id@Org"
		SFTP_KEY          = credentials('AUTOMATION-QE-SFTP_KEY')
		USERNAME          = "automation@acme.com"
		USERPASS          = credentials('AUTOMATION-QE-USERPASS')
		AUTOMATION_RUNNER = "runner.sh jenkins -t @smoke || true"
		AUTOMATION_CLEAN  = "runner.sh jenkins --feature cleanup || true"
	}

	stages {
		stage('AUTOMATION runner for QE env'){
			when{ environment name: 'TARGET_ENV', value: 'QE' }
			environment{
				CLIENT_SECRET       = credentials('AUTOMATION-QE-CLIENT_SECRET')
				LOGIN_SERVICE_HOST  = "https://qe.acme.com"
				ROOT_URL            = "https://qe.acme.io"
			}
			steps{
				sh 'id'
				sh 'printenv'
				sh '$WORKDIR/$AUTOMATION_RUNNER'
				sh '$WORKDIR/$AUTOMATION_CLEAN'
			}
		}

		stage('Automation runner for STAGE env'){
			when{ environment name: 'TARGET_ENV', value: 'STAGE' }
			environment{
				CLIENT_SECRET       = credentials('AUTOMATION-STAGE-CLIENT_SECRET')
				LOGIN_SERVICE_HOST  = "https://stage.acme.com"
				ROOT_URL            = "https://stage.acme.io"
			}
			steps{
				sh 'id'
				sh 'printenv'
				sh '$WORKDIR/$AUTOMATION_RUNNER'
				sh '$WORKDIR/$AUTOMATION_CLEAN'
			}
		}

		stage('Automation runner for INTEGRATION env'){
			when{ environment name: 'TARGET_ENV', value: 'INTEGRATION' }
			environment{
				CLIENT_SECRET       = credentials('AUTOMATION-INT-CLIENT_SECRET')
				LOGIN_SERVICE_HOST  = "https://int.acme.com"
				ROOT_URL            = "https://int.acme.io"
			}
			steps{
				sh 'id'
				sh 'printenv'
				sh '$WORKDIR/$AUTOMATION_RUNNER'
				sh '$WORKDIR/$AUTOMATION_CLEAN'
			}
		}

		stage('Automation runner for PROD env'){
			when{ environment name: 'TARGET_ENV', value: 'PROD' }
			environment{
				CLIENT_SECRET       = credentials('AUTOMATION-PROD-CLIENT_SECRET')
				LOGIN_SERVICE_HOST  = "https://prod.acme.com"
				ROOT_URL            = "https://prod.acme.io"
			}
			steps{
				sh 'id'
				sh 'printenv'
				sh '$WORKDIR/$AUTOMATION_RUNNER'
				sh '$WORKDIR/$AUTOMATION_CLEAN'
			}
		}

		// for cucumber report plugin. cucumber should use -f json
		stage('Cucumber report'){
			steps{
				cucumber buildStatus: 'UNSTABLE', fileIncludePattern: '**/*.json', jsonReportDirectory: 'results'
			}
		}

		stage('Cleanup'){
			steps{
			    cleanWs()
			}
		}
	}
}
