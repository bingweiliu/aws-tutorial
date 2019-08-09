# aws-tutorial
This repo is for the aws tutorial at IEEE Cloud Summit 2019. Open the tutorial book provided by the instructer for more detailed instructions.

## Prerequisite

- You should have an aws account already or create one. There won't be any cost for your aws account for this tutorial, but you do need to put your creditcard in yor aws account.

- Check your aws account number 
- Create an admin user if you don't have one. 
- Obtain an user name on cloud summit aws account
- You'll be give user name, password, ip address to login to cloud summit ec2 instance.


## Create resources on your aws account

1. Clone the git repo
    ```bash
    git clone https://github.com/bingweiliu/aws-tutorial.git
    cd aws-tutorial/terraform/create-user-account-resources
    ```

2. Change the follow values in the file **terraform.tfvars**

    ```bash
    account_id = {
    dev = "<your aws account number>"
    }
    admin_arn = {
    dev = "arn:aws:iam::<your aws account number>:user/<admin user name>"
    }
    admin_user_name = "<admin user name>"
    bucket_name = "cloudsummit-bucket-<your aws account number>"
    ```
    Save the file and exit
3. Initialize terraform
    ```bash
    terraform init
    ```

4. Plan terraform 
    ```bash
    terraform plan
    ```

5. Create the resources
    ```bash
    terraform apply
    ```
    Type yes when you are asked if the resources should be created. You'll need to write down the KMS key id, external role arn from the output.


## Steps for external account
### Login to cloud summit EC2
Cloud Summit has created an EC2 instance for you to use. 

- Get an ssh client for your laptop. 
  - Mac: Just use terminal
  - Windows: putty
- SSH to the EC2 instance with provided username, password and IP

    ```bash
    ssh <username>@<ip>
    ```
- Check if aws command is available
    ```bash
    aws --version
    ```
- Configure AWS default profile
    ```bash
    aws configure
    ```
- Configure assume role profile

  Edit the file **~/.aws/config**
  ```bash
  [profile tutorial-assume]
  region = us-east-1
  output = json
  role_arn = arn:aws:iam::<>:role/<>
  external_id = <>
  source_profile = default
  ```
- Create a dummy file to be uploaded to the s3 bucket
- Upload the file using aws command line
    ```bash
    aws s3 cp <file name> s3://<bucket name>/<new file name> --profile tutorial-assume --sse aws:kms --sse-kms-key-id arn:aws:kms:us-east-1:<aws account number>:key/<kms key id>
    ```


## When tutorial ends
Terminate all resources you created

```bash
terraform destroy
```