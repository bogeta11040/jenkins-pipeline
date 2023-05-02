VIDEO

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

For this exercise, I used a simple JavaScript To-Do app that I built several years ago. Since it only consists of JS/HTML/CSS and doesn't require Node.js, we were able to perform a code checkout by cloning the existing GitHub repository without any additional build commands. We hosted Jenkins on an AWS EC2 instance running CentOS, and our testing stages included both unit and integration tests. Additionally, we deployed the app to an S3 bucket in AWS. We configured GitHub WebHooks to trigger the job, which only begins deployment upon successful integration test confirmation. Throughout this exercise, I gained valuable knowledge about configuring Jenkins, working with loggers, webhooks, code analysis tools, build agents, Linux, and Cloud services.

## Pipeline script

```
```
