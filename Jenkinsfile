pipeline {
  agent {
    docker {
      image 'williamayerst/getupandgo'
    }
  }
  stages {
    stage('Build') {
      steps {
        sh '''
           cd ./node-app
           npm install
           cd ../
        '''
      }
    }
    stage('Create Packer AMI') {
        steps {
          withCredentials([
            usernamePassword(credentialsId: '51f1fe89-b3cf-4328-be58-237861d91dd4', passwordVariable: 'AWS_SECRET', usernameVariable: 'AWS_KEY')
          ]) {
            sh 'packer build -var aws_access_key=${AWS_KEY} -var aws_secret_key=${AWS_SECRET} packer/packer.json'
        }
      }
    }
    stage('AWS Deployment') {
      steps {
          withCredentials([
            usernamePassword(credentialsId: '51f1fe89-b3cf-4328-be58-237861d91dd4', passwordVariable: 'AWS_SECRET', usernameVariable: 'AWS_KEY'),
          ]) {
            sh '''
               cd ./terraform
               terraform init
               terraform apply -auto-approve -var access_key=${AWS_KEY} -var secret_key=${AWS_SECRET}
               cd ../
            '''
        }
      }
    }
  }
  environment {
    npm_config_cache = 'npm-cache'
  }
}
