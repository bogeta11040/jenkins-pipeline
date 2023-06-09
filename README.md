[![Watch on Youtube](https://raw.githubusercontent.com/bogeta11040/docs/main/docs/jenkinsvid.jpg)](https://youtu.be/7QIVqJQpv6k)

## Workflow

+ Developers commit code changes to GitHub: This is the first step in the pipeline, where developers push their code changes to the main branch of the Git repository.

+ Jenkins detects the change and performs code checkout: Jenkins, through a Webhook, detects the change and pulls the latest code from the Git repository, followed by performing a code checkout.

+ After the code checkout, Jenkins performs a code analysis using SonarQube.

+ Unit tests and integration testing are done on INT environment: Jenkins runs automated unit tests and integration tests on the code.

+ Code changes are deployed to the DEV environment: If the tests pass, Jenkins deploys the code changes to the Development (DEV) environment.

+ When QA team members decide they manually deploy a release to the UAT (staging) environment (Once the code is deployed to the DEV environment, the QA team performs manual testing on it. If the code is deemed ready for deployment, it is then deployed to the User Acceptance Testing (UAT) or Staging environment for further testing.)

+ Finally, the release is manually promoted to the Production environment when the team is satisfied with its quality.

<i>In this context, "manual deploy" refers to input steps defined in our pipeline script. While anyone can deploy to the staging environment, only authorized personnel are permitted to deploy to production. Specifically, the 'submitter' parameter in the script specifies that only the user with the username 'admin' is authorized to initiate the deployment. If the authorized user does not submit the input, the deployment to both UAT and PROD is skipped after a timeout. We simulated the development, testing, and production environments using S3 buckets on AWS.</i>

## Note

For this exercise, I used [simple JavaScript To-Do app](https://github.com/bogeta11040/todolist-app) that I built several years ago. Since it only consists of JS/HTML/CSS and doesn't require Node.js, we were able to perform a code checkout by cloning the existing GitHub repository without any additional build commands. We hosted Jenkins on an AWS EC2 instance running CentOS, and our testing stages included both unit and integration tests. Additionally, we deployed the app to an S3 bucket in AWS. We configured GitHub WebHooks to trigger the job, which only begins deployment upon successful integration test confirmation. Throughout this exercise, I gained valuable knowledge about configuring Jenkins, working with loggers, webhooks, code analysis tools, build agents, Linux, and Cloud services.

## Pipeline script

```
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

    stage('SonarQube') {
      steps {
        script {
          withSonarQubeEnv('sqserver') {
            def SCANNER_HOME = tool 'sqscanner'
            // Start the SonarQube server
            sh " ${SCANNER_HOME}/bin/sonar-scanner \
                    -Dsonar.projectKey=todoapp \
                    -Dsonar.sources=. "
            echo "SonarQube server started"
            // Stop the SonarQube server
            sh 'sudo /opt/sonarqube/bin/linux-x86-64/sonar.sh stop'
            echo "SonarQube server stopped"
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
```
