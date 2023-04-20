#-------------------------------------
# META VARIABLES
#-------------------------------------
variable "AWS_REGION" {
  type    = string
  default = "eu-north-1"
}
variable "AWS_PROFILE" {
  type    = string
  default = "default"
}
variable "DEPLOYMENT" {
  type = string
}
variable "PROJECT_NAME" {
  type = string
}
variable "AUTHOR" {
  type = string
}
#-------------------------------------
# GENERAL VARIABLES
#-------------------------------------
variable "REPOSITORY_NAME" {
  type    = list(any)
  description = "Repository name"
  default = ["default"]
}
variable "REPOSITORY_URL" {
  type    = string
  description = "Repository name"
  default = "default"
}
variable "BUILDSPEC_SOURCE_BRANCH" {
  type    = string
  description = "Which branch contains the pipeline buildspecs"
  default = "default"
}
variable "DOCKER_IMAGE" {
  type    = string
  description = "Should include the repository, image name and tag"
  default = "default"
}
variable "ARTIFACTS_BUCKET" {
  type    = string
  description = "S3 bucket that will store the artifacts"
  default = "default"
}
variable "EVENTBRIDGE_INPUT_TEMPLATE" {
  type    = string
  default = <<EOF
{"environmentVariablesOverride": [
    {
      "name": "PULL_REQUEST_ID",
      "value": <pullRequestId>,
      "type": "PLAINTEXT"
    },
    {
      "name": "REPOSITORY_NAME",
      "value": <repositoryName>,
      "type": "PLAINTEXT"
    },
    {
      "name": "SOURCE_COMMIT",
      "value": <sourceCommit>,
      "type": "PLAINTEXT"
    },
    {
      "name": "DESTINATION_COMMIT",
      "value": <destinationCommit>,
      "type": "PLAINTEXT"
    },
    {
      "name": "SOURCE_BRANCH",
      "value": <sourceBranch>,
      "type": "PLAINTEXT"
    },
    {
      "name": "DESTINATION_BRANCH",
      "value": <destinationBranch>,
      "type": "PLAINTEXT"
    },
    {
      "name": "ACCOUNT",
      "value": <account>,
      "type": "PLAINTEXT"
    }
    ]}
EOF
}
variable "DESTINATION_BRANCHES" {
  type    = list(any)
  description = "Should be in the format: refs/heads/<branch>"
  default = ["refs/heads/master"]
}
#-------------------------------------
# VALIDATE PULL REQUEST
#-------------------------------------
variable "ARTIFACTS_PATH_PR_VALIDATION" {
  type    = string
  description = "The folder name of the Pull Request validation build artifacts"
  default = "default"
}
variable "CLOUDWATCH_LOG_GROUP_PR_VALIDATION" {
  type    = string
  default = "default"
}
variable "BUILDSPEC_PR_VALIDATION" {
  type    = string
  description = "The relative path where the buildpsec file for the Pull Request validation codebuild project is stored (including the extension)"
  default = ""
}
#-------------------------------------
# APPLY INFRASTRUCTURE CHANGES
#-------------------------------------
variable "ARTIFACTS_PATH_INFRASTRUCTURE_SYNC" {
  type    = string
  description = "The folder name of the infrastructure sync build artifacts"
  default = "default"
}
variable "CLOUDWATCH_LOG_GROUP_INFRASTRUCTURE_SYNC" {
  type    = string
  default = "default"
}
variable "BUILDSPEC_INFRASTRUCTURE_SYNC" {
  type    = string
  description = "The relative path where the buildpsec file for the infrastructure sync codebuild project is stored (including the extension)"
  default = ""
}