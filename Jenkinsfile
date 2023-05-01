pipeline {
  agent any

  triggers {
    // "GitHub hook trigger for GITScm polling" build trigger
    githubPush()
    // Run the build at midnight UTC time
    cron('H 0 * * *')
  }

  stages {
    stage('Checkout') {
      steps {
        // Checkout the code and build the application
        sh "sudo rm -rf /var/www/html"
        sh "sudo git clone https://github.com/bogeta11040/todolist-app.git /var/www/html"
        script {
          withAWS(region: 'eu-central-1', credentials: 'aws-jenkins') {
            sh 'aws s3 sync /var/www/html s3://todoapp-bogeta-int --delete'
          }
        }
      }
    }

    stage('Unit Test') {
      steps {
        // Run the unit tests
        // sh 'npm run test:unit'
        echo "unit test"
      }
    }
    stage('Integration Test') {
      steps {
        // Run the integration tests
        // sh 'npm run test:integration'
        echo "integration"
      }
    }
    stage('Code Coverage Analysis') {
      steps {
        // Set up SonarQube environment variables
        def scannerHome = tool 'sqscanner';
        withSonarQubeEnv('sonarqube-server') {
        // Run SonarQube analysis and coverage checks
        sh '${scannerHome}/bin/sonar-scanner'
        echo "SonarQube"
        }
      }
    }

    stage('Deploy to Dev') {
      steps {
        // Deploy to the Dev environment
        script {
          withAWS(region: 'eu-central-1', credentials: 'aws-jenkins') {
            sh 'aws s3 sync /var/www/html s3://todoapp-bogeta-dev --delete'
          }
        }
      }
    }

    stage('Deploy to Staging') {
      steps {
        script {
          def proceed = true
          try {
            timeout(time: 20, unit: 'SECONDS') {
              input message: 'Deploy to Staging?', submitter: 'admin'
            }
          } catch (err) {
            proceed = false
          }
          if (proceed) {
            script {
              withAWS(region: 'eu-central-1', credentials: 'aws-jenkins') {
                sh 'aws s3 sync /var/www/html s3://todoapp-bogeta-uat --delete'
              }
            }
          }
        }
      }
    }

    stage('Deploy to Prod') {
      steps {
        script {
          def proceed = true
          try {
            timeout(time: 20, unit: 'SECONDS') {
              input message: 'Deploy to Production?', submitter: 'admin'
            }
          } catch (err) {
            proceed = false
          }
          if (proceed) {
            script {
              withAWS(region: 'eu-central-1', credentials: 'aws-jenkins') {
                sh 'aws s3 sync /var/www/html s3://todoapp-bogeta --delete'
              }
            }
          }
        }
      }
    }

  }
}
