Pre Requisite
-
* make necessary changes in **providers.tf** file. Change the credential location file location.

Selecting Workspace/Environment
-
- To list terraform workspaces/environments:
> terraform workspace list

- To create new terraform workspace/environment:
> terraform workspace new {workspace_name/environment}

- To select terraform workspace/environment:
> terraform workspace select {workspace_name/environment}

Initialising Project
-
- Run _terraform init_

Validate Template File
-
* Run _terraform validate_
* This will check if there are any syntax error with the template files in all the modules.

Pre Resource Deployment Step
-
* Run _terraform plan_
* creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure.

Deployment Step
-
* Run _terraform apply_ or _terraform apply --auto-approve_
* These commands will create the resources as per the template.

Destroy Deployment Step
-
* Run _terraform destroy_ or _terraform destroy --auto-approve_
* These commands will destroy the resources that has been created by the templates.
* Incase the commands don't fully destroy the resources it may be because of manually adding resources in the infrastructure the template is managing.


Changing Worker Count
-
Config in the file **_html_parser_worker.tf_** needs to be modified.

* html_parser_worker.tf
  * change _count_
  * example: if you want 1 worker the value for the above would be 1. This is because webserver & scheduler takes 1 EC2 instance as per the current design.
