pipeline {
    agent any

    triggers {
        // "GitHub hook trigger for GITScm polling" build trigger
        githubPush()
        // Run the build at midnight UTC time
        cron('H 0 * * *')
    }

    stages {
        stage('Build') {
            steps {
                // Checkout the code and build the application
                sh "sudo yum -y install httpd"
                sh "sudo systemctl start httpd"
                sh "sudo git clone https://github.com/bogeta11040/todolist-app.git /var/www/html/"

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
        stage('Deploy') {
            steps {
                // Deploy the application to S3 bucket
                // Get AWS credentials
                echo "deploy"
                script {
                    withAWS(region: 'eu-central-1', credentials: 'aws-jenkins') {
                        sh 'aws s3 sync /var/www/html s3://todoapp-bogeta --delete'
                    }
                }
            }
        }
    }
}