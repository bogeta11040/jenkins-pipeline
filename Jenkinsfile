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
                sh "sudo yum -y install httpd"
                sh "sudo systemctl start httpd"
                sh "sudo git clone https://github.com/bogeta11040/todolist-app.git /var/www/html/app"

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
        stage('SonarQube') {
            steps {
                // Set up SonarQube environment variables
                //withSonarQubeEnv('My SonarQube Server') {
                    // Run SonarQube analysis and coverage checks
                //    withSonarQubeScanner {
                 //       sh 'sonar-scanner'
                 //   }
                 echo "SonarQube"
                //}
            }
        }

  
        stage('Deploy to Dev') {
              steps {
                  // Deploy to the Dev environment
                  script {
                      withAWS(region: 'eu-central-1', credentials: 'aws-jenkins') {
                          sh 'aws s3 sync /var/www/html/app s3://todoapp-bogeta-dev --delete'
                      }
              }
          }
        }
  
  stage('Deploy to Test') {
              steps {
                  script {
                      def proceed = true
                      try {
                          timeout(time: 20, unit: 'SECONDS') {
                              input "Deploy to Test?"
                          }
                      } catch (err) {
                          proceed = false
                      }
                      if(proceed) {
                          script {
                      withAWS(region: 'eu-central-1', credentials: 'aws-jenkins') {
                          sh 'aws s3 sync /var/www/html/app s3://todoapp-bogeta-qa --delete'
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
                      if(proceed) {
                          script {
                      withAWS(region: 'eu-central-1', credentials: 'aws-jenkins') {
                          sh 'aws s3 sync /var/www/html/app s3://todoapp-bogeta --delete'
              }
          }
          }
          }
  }
  }    


}
    }
