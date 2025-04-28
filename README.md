# DevOps CI/CD Infrastructure-as-Code project for cloud security automation.

## Prerequisites

### Create SSH Key
- Create a SSH key named `user1` and save it in this path `~/.ssh/user1`
- You need to be sure you have:
  - `user1.pub`
  - `user1.pem`
- Add this key to your ssh:
  ```bash
  ssh-add ~/.ssh/user1.pem
  ```

## AWS Account

An AWS account and a IAM user with enough permission to perform the creation of:
- VPC
- Subnets  
- Access control list
- Internet Gateway
- NAT gateway
- Route tables
- Security groups
- EC2 instances

**Important**: Create access key and SecretKey of this user for Terraform to deploy all successfully.

## Azure Account

You need to have:
- A personal Azure account (A tenant) 
- A subscription that allows you to use these services:
  - Storage account
  - Key vault
  - Create and delete resources groups
  - Log Analytics workspace
  - Microsoft Entra ID
  - App registration
  - Assign and remove roles
  - Microsoft Sentinel

### Initial Resource Setup

Before any other step, you need to have these resources running:

1. A resource group
2. Inside it:
   - A storage account
   - A keyvault

**Save these for future steps**:
- The vaultURL
- The name of the storage account
- The keyvault resource name

### App Registration

1. Create an app register in Microsoft Entra ID
2. At the subscription level, assign these roles to the service principal:
   - Log Analytics Contributor
   - Microsoft Sentinel Contributor

### Service Principal Configuration

After registration, save this data:

  - SUBSCRIPTION_ID:
  - Client_id:
  - Client_secret:
  - Tenant_id: 

And set those values in your Key vault as secrets with this names 

  - ARM-CLIENT-ID: Client_id
  - ARM-CLIENT-SECRET: Client_secret
  - ARM-SUBSCRIPTION-ID: SUBSCRIPTION_ID
  - ARM-TENANT-ID: Tenant_id

> **Note**: Carefully check this step of permissions

## Finish Prerequisites

# Stage 1

Once you have all of those Prerequisites, go back to this repository which is the source Repository with the analytics rules for Sentinel.

## Azure CLI Installation

You need to install the "Azure CLI" to have:
- The resource group
- The Log Analytics workspace
- The Log Analytics workspace onboarding in your Azure account

**Important security note**:  
Don't skip this step and don't pass the values in your key vault directly in the code.

Run these commands to install `az cli`:

```bash
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list'
rm microsoft.gpg

sudo apt-get update
sudo apt-get install azure-cli
```

## Azure Login

Then loggin into your azure account 

```bash
az login --tenant Your-tenant_id --use-device-code
```

Then run this command to set permmision to this file and recover the secrets from your key vault 

```bash
sudo chmod +x set-key-values.sh
./set-key-values.sh
```

## Configuration Update

Then you only need to update this part of the code in the `main.tf` file of this project with the name of your Storage Account and resource group:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = ""  # <== Update this
    storage_account_name = ""  # <== Update this
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
```

## Terraform Execution

After updating the configuration, you will be able to run Terraform to install the resources for the analytics rules in Azure. Execute these commands in order:

```hcl
terraform init
terraform plan
terraform apply
```

## Next Steps

Once everything is set up and running, proceed to the other repository: `Project_Terraform_CI-CD`

This repository will:

- Create two instances

- Run one Docker container on each instance:

   - First container: Jenkins

   - Second container: GitLab


## AWS Configuration

1. Get the access key and SecretKey of your newly created IAM User in AWS
2. Export those values as environment variables:

```bash
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```
## Terraform Execution

Run the Terraform project with these commands:

```hcl
terraform init
terraform plan
terraform apply
```
## Accessing Your Instances

This will display the outputs of public IPs and the public DNS of your instances. **Save these values**.

# Stage 2 Gitlab

### Web Interface Access
In your browser, access both services using:
- Jenkins: `http://<public_ip-Jenkins-instance>:8080`
- GitLab: `http://<public_ip-Gitlab-instance>`

This will open the web interface for each service.

### SSH Access
Back in your terminal, connect to your instances using SSH. You'll need the public DNS of both instances:

```bash
# Connect to Jenkins instance
ssh -i "~/.ssh/user1.pem" ubuntu@<public_dns-Jenkins-instance>

# Connect to GitLab instance
ssh -i "~/.ssh/user1.pem" ec2-user@<public_dns-Gitlab-instance>
```

### Retrieving GitLab Password

Once connected to the GitLab instance terminal, get the GitLab initial password by running:

```bash
sudo cat /srv/gitlab/config/initial_root_password
```

**Note**: This password is only available for 24 hours after installation. Make sure to change it after first login.

## GitLab Initial Setup

### Login and Repository Creation
1. In your browser's GitLab interface:
   - Use the password obtained from the terminal
   - Set username as `root`
2. After logging in as root user:
   - Create a new repository
   - Make it **public**
   - **Do not** initialize with a README.md file
   - Save the project URL for future use

### API Token Creation
1. Go to project settings
2. Create a GitLab API token with:
   - **Developer** role
   - Permissions: 
     - All API access
     - Read and write access
3. **Important**: Save the token secret for future steps

## Jenkins Integration Setup

### Project Settings Configuration
1. In project settings, go to "Integration" section
2. Find and select "Jenkins"
3. Configure connection:
   - Set a **connection name** (remember this for Jenkins job creation)
   - Jenkins server URL: `http://<public_ip-Jenkins-instance>:8080`
   - Credentials:
     - Username: `admin`
     - Password: `<jenkins-instance-password>`

### Obtaining Jenkins Password
To get the Jenkins admin password, run in your Jenkins instance terminal:
```bash
sudo docker exec -it jenkins bash -c 'cat "${JENKINS_HOME:-/var/jenkins_home}"/secrets/initialAdminPassword'
```

### Important Notes:

- Save this Jenkins password for future steps

- The test connection may fail initially (expected behavior) So far if you test the connection it will fail because you already don't have the jenkins job but it will work. Save the integration (Connection)

- The integration will work after Jenkins job creation

- Ensure connection name matches future Jenkins job name

- Save the integration/connection after configuration

## GitLab SSH Configuration

### Add SSH Key to GitLab Account
1. Go to your account settings in GitLab
2. Add your SSH public key:
   - On your local machine run:
     ```bash
     cat ~/.ssh/user1.pub
     ```
   - Copy the output and paste it in GitLab's SSH key section
3. Save the key

### Configure Git Repository Remote
1. In GitLab, go to your project
2. Get the SSH repository link (format will be similar to):
   ```bash
   ssh://git@Your_IP_OF_gitlab_instance:2424/Your_User_gitlab/your_repository_name.git
   ```
### Push to Repository

Set the remote URL in your local repository:

```bash
git remote set-url origin ssh://git@Your_IP_OF_gitlab_instance:2424/Your_User_gitlab/your_repository_name.git
```

And push your Repo:

```bash
git push --set-upstream origin main
```

# Stage 3: Jenkins Setup

## Accessing Jenkins

1. In your browser, access Jenkins using:

`http://<public_ip-Jenkins-instance>:8080`

2. Enter the password obtained from previous steps (retrieve it by running in your Jenkins instance terminal):
```bash
sudo docker exec -it jenkins bash -c 'cat "${JENKINS_HOME:-/var/jenkins_home}"/secrets/initialAdminPassword'
```

Could you convert this text to a .md format? Distinguishes between titles, subtitles, notes, highlight the key aspects or values, tips, and code with .md attributes, but you shouldn't change any of the original information.

# Stage 3: Jenkins Configuration

## Initial Setup
- Skip the user creation step
- Allow installation of recommended plugins

## Plugin Installation
In Jenkins main dashboard:
1. Go to **Manage Jenkins** > **Plugins**
2. Install these 4 plugins:
   - GitLab
   - Azure Credentials
   - Azure CLI
   - Azure KeyVault

## Credentials Setup
In **Manage Jenkins** > **Credentials**:
1. **Username and Password**:

- **Username**: root
- **Password**: "The gitlab api token you create in previous steps"
- **ID**: "what you want"


2. **Azure Credentials**

- SUBSCRIPTION_ID:
- Client_id:
- Client_secret:
- Tenant_id:
- **ID**: "what you want"


3. **GitLab API Token**

- **API Token**: "The gitlab api token you create in previous steps"
- **ID**: "what you want"


## System Configuration
In the **Manage Jenkins** menu, under the **System** menu:

### GitLab Connection
- Go to **GitLab** in this submenu
- Give a name to this connection
- Pass the URL of the GitLab server (e.g., `http://<public_ip-Gitlab-instance>`)
- Use the "gitlab api token" credentials

### Azure KeyVault Connection
- Search for the "azure keyvault connection" to get the "azure secret" for terraform
- Pass the **Key-vaultURL** (from Prerequisites step) in the first form
- Set the "azure credentials" you previously created
- Test the connection (you will get 4 values)

## Pipeline Job Creation
1. Go to the main dashboard and select **New Item** or **Create a job**
2. Name this job with the same name you set in the GitLab connection (from previous steps)
3. Select **Pipeline** option
4. Configure job:
- **GitLab Connection**: Select your connection
- **Triggers**:
  - Build when a change is pushed to GitLab
  - Webhook URL: `http://54.161.1.6:8080/project/CICD-jenkins`
  - Selected events:
    - Push Events
    - Push Events on branch delete
    - Build only if new commits in Merge Request
    - Accepted Merge Request Events
  - Change "Rebuild open Merge Requests" to "On push to source branch"
5. **Pipeline Configuration**:
- Definition: **Pipeline script from SCM**
- SCM: **Git**
- Repository URL: `http://Your_IP_OF_gitlab_instance:2424/Your_User_gitlab/your_repository_name.git`
- Credentials: `root` with GitLab token
- Branch Specifier: `*/main`
- Repository browser: **gitlab**
- Script Path: `Jenkinsfile`
6. Save the job

## Final Verification
Repeat this step to ensure proper setup:

[So far if you test the connection it will fail because you already don't have the jenkins job but it will work. Save the integration (Connection)](#important-notes)

## Completion
The CI/CD pipeline is now fully configured. Changes pushed to your source repository will automatically update Microsoft Sentinel analytics rules.
