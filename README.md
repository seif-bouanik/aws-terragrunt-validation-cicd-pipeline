### General
AWS-native pipeline to validate terragrunt code changes (can be adjusted to Terraform as well) and apply the changes to your infrastructure.  
<br/><br/><br/>

### Content
* Infrastructure Terraform code (minus ECR and S3).  
* Buildspec files.  
* Dockerfile for CodeBuild the environment.  
* Tflint config file 
<br/><br/><br/>

### Workflow:
1. Users create/update a Pull Request with one of the target branches as a destination. _**(step 1)**_
2. The Pull Request will trigger an EventBridge rule. _**(step 2)**_
3. EventBridge will trigger the first CodeBuild project target and send trandformed data about the Pull Request. _**(step 3)**_
4.  CodeBuild will pull a Docker image from ECR to execute the build stages on. _**(step 4)**_
5.  CodeBuild will check out the Pull Request code (i.e. PR source branch code) and perform code checking using Python scripts. _**(step 4)**_
6.  CodeBuild will store the code analysis artifacts in S3 bucket in a path specific to the build# & Pull Request. _**(step 4)**_
7.  CodeBuild will add comments to the Pull Request with: _**(step 4)**_
    - Build starting
    - Build results
    - Artifacts url
8.  Users merge the Pull Request after reviewing _**(step 5)**_
9.  The Pull Request merge will trigger a second EventBridge rule _**(step 6)**_
10.  EventBridge will trigger the first CodeBuild project target and send trandformed data about the Pull Request. _**(step 7)**_
11.  CodeBuild will pull the same Docker image from ECR to execute the build stages on _**(step 8)**_
12.  CodeBuild will check out the merged Pull Request code (i.e. PR destination branch code) and apply the infrastructure changes. _**(step 8)**_
13.  CodeBuild will provision the new infrastructure and upload the outputs to S3 in a path specific to the build# & Pull Request id _**(step 8)**_
14.  CodeBuild will add comments to the Pull Request with: _**(step 8)**_  
        - Build starting  
        - Build results  
        - Artifacts url   
  <br/><br/><br/>


### How-to-use
In order to use this pipeline with your terragrunt project:  
1. Copy the buildspec files found in pipeline BUILDSPECS folder to your project code.  
2. Fill out Terrafrom variables according to your project.  
3. Copy the tflint config file to your project and specify which path by changing the buildpsec environment variable "CONFIG_FILES_PATH"  
4. Checkov and TFSec are running without config files, if you need to add them, you will need to adjust the buildspec commands  
5. Pass your relative Terragrunt code folder and the specific terragrunt envrionment folder to the following environment variables in the builspec files (TERRAGRUNT_DIR & TERRAGRUNT_ENVIRONMENT)    
6. Provision the pipeline using Terraform  
7. Create a pull request to your specified target branch(es)  
 <br/><br/><br/>

### Architecture  

![architecture](./pipeline-architecture.jpg?raw=true "pipeline-architecture")
