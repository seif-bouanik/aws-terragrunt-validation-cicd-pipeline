AWS-native pipeline to validate terragrunt code changes (can be adjusted to Terraform as well) and apply the changes to your infrastructure.  
    
    
The workflow:  
1. Users creates/updates a Pull Request with one of the target branches as a destination. _**(Workflow step 1)**_  
2. The Pull Request will trigger an EventBridge rule. _**(Workflow step 2)**_  
3. EventBridge will trigger the first CodeBuild project target and send trandformed data about the Pull Request. _**(Workflow step 3)**_  
4.  CodeBuild will pull a Docker image from ECR to execute the build stages on. _**(Workflow step 4)**_  
5.  CodeBuild will check out the Pull Request code (i.e. PR source branch code) and perform code checking using Python scripts. _**(Workflow step 4)**_  
6.  CodeBuild will store the code analysis artifacts in S3 bucket in a path specific to the build & Pull Request. _**(Workflow step 4)**_  
7.  CodeBuild will add comments to the Pull Request with: _**(Workflow step 4)**_   
    - Build starting  
    - Build results  
    - Artifacts url  
8.  User merges the Pull Request after reviewing _**(Workflow step 5)**_  
9.  The Pull Request merge will trigger a second EventBridge rule _**(Workflow step 6)**_  
10.  EventBridge will trigger the first CodeBuild project target and send trandformed data about the Pull Request. _**(Workflow step 7)**_  
11.  CodeBuild will pull the same Docker image from ECR to execute the build stages on _**(Workflow step 8)**_   
12.  CodeBuild will check out the merged Pull Request code (i.e. PR destination branch code) and apply the infrastructure changes. _**(Workflow step 8)**_  
13.  CodeBuild will save the outputs of the infrastructure changes to a file and upload it to S3 in a path specific to the build & Pull Request _**(Workflow step 8)**_  
14.  CodeBuild will add comments to the Pull Request with: _**(Workflow step 8)**_      
    - Build starting  
    - Build results  
    - Artifacts url  
  

![architecture graph](https://jiraprod.aptiv.com/secure/attachment/2396764/2396764_IaC_CICD_Pipeline+%285%29.jpg "pipeline-architecture")