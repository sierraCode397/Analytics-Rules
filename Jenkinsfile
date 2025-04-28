pipeline {
  agent any
  environment { TF_IN_AUTOMATION = 'true' }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Debug Workspace') {
      steps {
        sh '''
          echo "Current directory:"
          pwd
          echo "Files in workspace:"
          ls -R .
        '''
      }
    }

    stage('Terraform Init → Plan → Apply') {
      steps {
        withCredentials([
          string(credentialsId: 'ARM-CLIENT-ID',       variable: 'ARM_CLIENT_ID'),
          string(credentialsId: 'ARM-CLIENT-SECRET',   variable: 'ARM_CLIENT_SECRET'),
          string(credentialsId: 'ARM-TENANT-ID',       variable: 'ARM_TENANT_ID'),
          string(credentialsId: 'ARM-SUBSCRIPTION-ID', variable: 'ARM_SUBSCRIPTION_ID')
        ]) {
          sh '''
            set -eux

            # If Terraform is in a subfolder, change to it
            if [ -d "terraform" ]; then cd terraform; fi


            # (Optional) Azure CLI login if you need 'az' elsewhere:
            # az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"
            # az account set --subscription "$ARM_SUBSCRIPTION_ID"

            # Terraform will pick up the ARM_* vars automatically
            terraform init -input=false -reconfigure -backend-config="subscription_id=$ARM_SUBSCRIPTION_ID"


            terraform plan -input=false -out=tfplan.binary

            # apply after manual approval
            terraform apply -input=false -auto-approve tfplan.binary
          '''
        }
      }
    }
  }

  post {
    always {
      sh 'az logout || true'
    }
  }
}
