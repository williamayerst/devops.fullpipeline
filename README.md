# devops.fullpipeline
Full pipeline using NodeJS, Packer, Terraform and Jenkins. This is a skeleton NodeJS application which was created within the repo after installing `nodejs` and `npm`. The files were created by running `express node-app`, and then `npm install` (ensure the .gitignore is set to ignore the `./node-app/node_modules` folder!

# The build process
When a build is triggered in Jenkins (webhook, scheduled, manual, etc.), an automatic process is kicked off which performs the following steps in order (more details below):

* Download a custom docker container used for building the environment
* NPM is run inside the container to get modules downloaded for the application
* Packer copies the application to a commercial AMI and makes it ready for deployment
* Terraform is called to create a load-balanced website behind an ELB using the custom AMI

## Jenkins
Jenkins must be configured with a new pipeline project, pointed to the git repo containing this information. There are two prerequisites
* `docker` must be available on the Jenkins server, and the `jenkins` user must be a member of the `docker` group so it has permissions to start and stop the build container. 
* Your terraform AWS credentials must be stored in the Jenkins global credential vault, in order that they can be passed through during the pipeline process using the `WithCredential(x)` function.

## Docker
The dockerfile is located in `./Docker/` and details the steps to get a standard node docker image equipped with Packer and Terraform. This could be achieved with separate images (such as `hashicorp\terraform`) but for simplicity my own image was easier to handle. If you want to use my exact dockerfile, you can pull from `williamayerst/getupandgo` instead of building your own.

## Packer
The packer files are located on `./packer/` and consist of three steps to be executed after the machine image has started:
* To install Ansible
* To create a folder under the default user's home directory called `/home/ubuntu/code`
* To stage the files from this repository into that folder
* To run `Ansible` (see below)
Once this is complete, the image is uploaded back to Amazon and named uniquely via timestamp.

## Ansible
The Ansible configuration performs a couple of simple steps to make the application 'live' instead of just plain files:
* Install NodeJS (GPG keys, etc.)
* Install PM2 and set it as an auto-starting service, pointed at the `/home/ubuntu/code` folder

## Terraform
When/if Packer is successful, the next step is a Terraform deployment of a load-balanced server pair using the custom AMI that Packer registered. The `./terraform/` folder contains the manifest files. `AWS_ACCESS_KEY_ID` and `AWS_SECRET_KEY_ID` need to be passed to the environment that is running Terraform (this is budgeted for within the `Jenkinsfile` already).

When the AMI is updated, the 'latest' version changes which prompts terraform to implement a blue/green deployment. Changes to the AMI have a cascading effect which updates the launch configuration and auto-scaling group. As long as at least one of the new AMIs registers with the ELB, then Terraform will start destroying the old configuration.

The state is saved to S3 so that it is not neccesary to reupload the .tfstate into git to avoid a mismatch between TF and the cloud provider.

## Completion
Upon the completion of the deployment, the ELB DNS name is exported by Terraform. *A more elegant way of handling this would be to pass it through to a Slack channel/etc.*
