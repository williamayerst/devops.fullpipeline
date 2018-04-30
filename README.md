# devops.fullpipeline
Full pipeline using NodeJS, Packer, Terraform and Jenkins. This is a skeleton NodeJS application which was created within the repo after installing `nodejs` and `npm`. The files were created by running `express node-app`, and then `npm install` (ensure the .gitignore is set to ignore the `./node-app/node_modules` folder!

# The build process
When changes are commited, a build (probably) is triggered in Jenkins. The Jenkins Pipeline performs the following steps in order (more details below):

* Download a custom docker container used for building the environment
* NPM is run inside the container to get modules downloaded
* Packer is called to create a custom AWS AMI from this repo into the machine
* Terraform is called to create a load-balanced website behind an ELB using the custom AMI

## Docker
The dockerfile is located in `./Docker/` and details the steps to get a standard node docker image equipped with Packer and Terraform. This needs to be pushed to the docker registry for use, I have done this as `williamayerst/getupandgo`

## Packer
The packer files are located on `./packer/` and consist of three steps to be executed after the machine image has started:
* Install Ansible
* Create a folder under the default user's home directory called 'node-app'
* Stage the files from this repository into that folder

## Terraform
When/if Packer is successful, the next step is a terraform deployment of a load-balanced server pair using the custom AMI that Packer registered. Changes to the 'latest' AMI have a cascading effect which updates the image, launch configuration and auto-scaling group. As long as at least one of the new AMIs registers with the ELB, then Terraform will start destroying the old configuration.

The state is saved to S3 so that it is not neccesary to reupload the .tfstate into git to avoid a mismatch between TF and the cloud provider.

## Ansible
The Ansible configuration performs a couple of steps:
* Install NodeJS (GPG keys, etc.)
* Install PM2 and set it as an auto-starting service
