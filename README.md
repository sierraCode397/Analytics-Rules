# DevOps CI/CD Infrastructure-as-Code project for cloud security automation.

This solution is built on two dedicated Git repositories—**Project_Terraform_CI-CD** and **Analytics-Rules**—that together enable fully automated, end-to-end security enforcement across your cloud environments.  

## 1. Purpose & Scope

**Why this exists**  
Security controls in the cloud can quickly become complex and hard to manage at scale. This project codifies your security posture as reusable Terraform modules and CI/CD pipelines, ensuring that every change is:

- **Consistent**: Infrastructure and security configurations are defined in code and applied the same way every time.  
- **Traceable**: All changes flow through version-controlled pipelines with clear audit trails.  
- **Automated**: From spinning up resources to updating detection rules, everything happens with zero manual intervention once you hit “deploy.”  

**What it delivers**  
1. **Infrastructure provisioning** via Terraform, including secure networking, IAM policies, and logging.  
2. **Security analytics rules** (e.g. in Sentinel or SIEM) maintained in the `Analytics-Rules` repo.  
3. **CI/CD pipelines** that validate, plan, and apply changes across both AWS and Azure, complete with automated testing and approval gates.  

By the end of this project, you’ll have a repeatable, auditable framework that keeps your cloud security posture enforced and up to date—without lifting a finger.  

### This project `Analytics-Rules` created the follow:

![AWS Academy Cloud Architecting](https://imgur.com/lf3vSB0.png)

## Prerequisites

### Create SSH Key
- Create a SSH key named `user1`
  ```bash
  ssh-keygen -t rsa -b 4096 -f user1
  ```
 and save it in this path `~/.ssh/user1`

- Convert the private key to PEM format:

  ```bash
  openssl rsa -in user1 -outform PEM -out user1.pem
  ```

- You need to be sure you have:
  - `user1.pub`
  - `user1.pem`

- Start the SSH Agent

  ```bash
  eval "$(ssh-agent -s)"
  ```

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
  - Create a container inside the storage account
  - Key vault
  - Create and delete resources groups
  - Log Analytics workspace
  - Microsoft Entra ID
  - App registration
  - Assign and remove roles
  - Microsoft Sentinel
  - Create secrets in keyvault

### Initial Resource Setup

Before any other step, you need to have these resources running:

1. A resource group
2. Inside it:
   - A storage account, with a container on it, save the name of the container for future steps
   - A keyvault

**Save these for future steps**:
- The vaultURL
- The name of the storage account
- The keyvault resource name

### App Registration

1. Create an app register in Microsoft Entra ID

### Service Principal Configuration

After registration, save this data:

  - SUBSCRIPTION_ID:
  - Client_id:
  - Client_secret: (For this, select the Service Principal and in "Manager" select "Certificates & secrets" get the "Client secret")
  - Tenant_id: 

At the subscription level, assign two roles to the service principal:
   - Key Vault Secrets Officer

and the other in the submenu select "Privileged administrator roles" choose:
   - Contributor

> **Note**: You will remove this role at the end, when you already have all the resources for the first time

And set those values in your Key vault as secrets with this names 

  - ARM-CLIENT-ID: Client_id
  - ARM-CLIENT-SECRET: Client_secret
  - ARM-SUBSCRIPTION-ID: SUBSCRIPTION_ID
  - ARM-TENANT-ID: Tenant_id

> **Note**: Carefully check this step of permissions

### These are the resources in azure and the scope of this project

![AWS Academy Cloud Architecting](https://imgur.com/C43APnH.png)

# Least privilege

### After your first deployment of all the project, Delete the `Contributor` role from the subscription level.  Then you need to grant specific roles at different scopes. Follow these steps:

1. **Storage Account (Terraform backend state)**
   - **Scope**: Your Storage Account resource  
   - **Role**: `Storage Account Key Operator Service Role`  
   - **Why**: gives exactly the `listKeys` (and regenerate) permission without granting full management-plane rights.

2. **Key Vault (ARM credentials)**

   - **Scope**: Your Key Vault resource
   - **Role**: `Key Vault Secrets Officer`
   - **Why**: Grants permission to read, list, and manage secrets—so your scripts or pipelines can fetch credentials like `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, etc.

3. **Resource Group for Sentinel**

   - **Scope**: The Resource Group where Microsoft Sentinel will be deployed (e.g. `Sentinel`)
   - **Roles (both required)**:`Log Analytics Contributor`, `Microsoft Sentinel Contributor`  
   - **Why**: Manages the Log Analytics workspace itself—configuring data collection, retention, and workspace settings.
   - **Why**: Onboards the workspace to Sentinel and allows creation, update, and deletion of Sentinel artifacts such as analytics rules, playbooks, workbooks, and incidents.

### At the end of all this project you must to have something like this:

![AWS Academy Cloud Architecting](https://imgur.com/Fn3REB3.png)

## Finish Prerequisites

# Stage 1

Once you have all of those Prerequisites, go back to this repository which is the source Repository with the analytics rules for Sentinel.

**Important security note**:  
Don't pass the values in your key vault directly in the code.

## Configuration Update

You only need to update this part of the code in the root `main.tf` file of this project with the name of your Storage Account, container name and resource group:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = ""  # <== Update this
    storage_account_name = ""  # <== Update this
    container_name       = ""  # <== Update this
    key                  = "terraform.tfstate"
  }
}
```

## Next Steps

Once everything is set up, proceed to the other repository: `Project_Terraform_CI-CD`

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

**Note**: This password is only available for 24 hours after installation.

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
2. Create a GitLab API token only for this repository (Not a personal token) with:
   - **Developer** role
   - Permissions: 
     - All API access
     - Read and write access
3. **Important**: Save the token secret for future steps

> **Note**: This lets you work with both public and private repositories and automatically detects any changes made by your coworkers. Just make sure everyone who needs access has been invited to the repo.

## Jenkins Integration Setup

### Project Settings Configuration
1. In project settings, go to "Integration" section
2. Find and select "Jenkins"
3. Configure connection:
   - Set a **connection name** (remember this for Jenkins job creation)
   - Allow the three triggers: Push, Tag and merge
   - Jenkins server URL: `http://<public_ip-Jenkins-instance>:8080`
   - Credentials:
     - Username: `admin`
     - Password: `This entry can't be empty so put a random text only, don't matter what`

### Important Notes:

- The test connection may fail initially (expected behavior) because you already don't have the jenkins job but it will work. Save the integration (Connection)

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

Remember add this key to your ssh:
  ```bash
  ssh-add ~/.ssh/user1.pem
  ```

Set the remote URL in your local repository:

```bash
git remote add origin ssh://git@Your_IP_OF_gitlab_instance:2424/Your_User_gitlab/your_repository_name.git
```

Change your branch to main:
```bash
git branch -M main
```

And push your Repo:

```bash
git push --set-upstream origin main
```

# Stage 3: Jenkins Setup

## Accessing Jenkins

1. In your browser, access Jenkins using:

`http://<public_ip-Jenkins-instance>:8080`

# Stage 3: Jenkins Configuration

## Credentials Setup
You need to create some credentials, In **Manage Jenkins** > **Credentials**:
1. **Username and Password**:

- **Username**: root
- **Password**: "The gitlab api token you created in previous steps"
- **ID**: "what you want"

2. **Azure Service Principal**

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
2. Name this job with the same name you set in the GitLab connection ([Stage 2 Gitlab](#jenkins-integration-setup))
3. Select **Pipeline** option
4. Configure job:
- **GitLab Connection**: Select your connection
- **Triggers** Select these:
  - Build when a change is pushed to GitLab Webhook URL: `http://Your_IP_OF_jenkins_instance:8080/project/CICD-jenkins`
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

### Run the Job

## Final Verification
Repeat this step to ensure proper setup:

- [So far if you test the connection it will fail because you already don't have the jenkins job but it will work. Save the integration (Connection)](#important-notes)

- [Make sure you grant only the least privilege with the roles](#least-privilege)

## Completion
The CI/CD pipeline is now fully configured. Changes pushed to your source repository will automatically update Microsoft Sentinel analytics rules.

## Deleting Analytics rules 

To remove existing analytics rules from your workload, follow these steps:

Locate and remove the rule entry from the `locals.tf` file. Rules are defined inside a JSON-style list. For example:

```bash
locals {
  # Security rules

  # VM activity rules
  rules_vm_activity = [
    {
      name         = "vm-creation-success"
      display_name = "VM Created Successfully"
      severity     = "High"
      query        = <<QUERY
AzureActivity |
  where OperationName == "Create or Update Virtual Machine" or OperationName =="Create Deployment" |
  where ActivityStatus == "Succeeded"
QUERY
    },
  ]
}
```

Delete the specific rule block you no longer need

Also, remove the corresponding rule from the main.tf file, specifically in the module `sentinel_rules` block:

```bash
  for_each = {
    for idx, rule in flatten([
      local.rules_vm_activity,
    ]) : "${rule.name}-${idx}" => rule
  }
```

Make sure the rule you removed in `locals.tf` is not referenced here.

To add new rules, follow the same structure and update the same files as shown in the deletion steps above. 

> **Note**: When creating an analytics rule, avoid reusing a name you've used before—even if you delete the rule, it can take some time for that name to become available again.
