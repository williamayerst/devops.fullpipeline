FROM node:8.9.4

# Make sure unzip is up to date and installed
RUN apt-get update
RUN apt-get install unzip -y


#######################
# Packer and Terraform
#######################

# Comment Create a folder for Packer to be downloaded into and change to it
RUN mkdir /root/packer
WORKDIR /root/packer

# Download the packer and terraform binaries directly from Hashicorp
RUN wget https://releases.hashicorp.com/packer/1.1.3/packer_1.1.3_linux_amd64.zip
RUN wget https://releases.hashicorp.com/terraform/0.11.1/terraform_0.11.1_linux_amd64.zip

# Unzip the packer and terraform binaries
RUN unzip packer_1.1.3_linux_amd64.zip
RUN unzip terraform_0.11.1_linux_amd64.zip

# Move the binares to a preexisting PATH and clean up
RUN mv packer /usr/local/bin/packer
RUN mv terraform /usr/local/bin/terraform
RUN rm packer_1.1.3_linux_amd64.zip
RUN rm terraform_0.11.1_linux_amd64.zip

#######################
# Git
#######################

# No longer required due to remote back-end on Terraform