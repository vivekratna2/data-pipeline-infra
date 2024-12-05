
## Environment
* dev
* uat
* prod

## Pre Requisite
* have the necessary aws access keys in the _~/.aws/credentials_ file.

## Initialising Project
* Run _terraform init_

## Select Environment
* Run _terraform workspace select dev_

## Validate Template File
* Run _terraform validate_
* This will check if there are any syntax error with the template files in all the modules.

## Pre Resource Deployment Step
* Run _terraform plan_
* creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure.

## Deployment Step
* Run _terraform apply_ or _terraform apply -auto-approve_
* These commands will create the resources as per the template.

## Destroy Deployment Step
* Run _terraform destroy_ or _terraform destroy -auto-approve_
* These commands will destroy the resources that have been created by the templates.
* Incase the commands don't fully destroy the resources it may be because of manually adding resources in the infrastructure the template is managing.

## Changing Worker Count in ECS
Configs in two files will need to be changed.

* airflow > 03-autoscaling-group.tf
  * change _desired_capacity_ & _min_size_
  * example: if you want 1 worker the value for the above would be 2. This is because webserver & scheduler takes 1 EC2 instance as per the current design.

* airflow > 09-airflow-worker.tf
  * change _aws_ecs_service.desired_count_ to the total number workers you want.
