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
  type    = string
}
variable "PROJECT_NAME" {
  type    = string
}
variable "Author" {
  type    = string
}
#-------------------------------------
# GENERAL VARIABLES
#-------------------------------------
variable "REPOSITORY_NAME" {
  type        = list(any)
  default     = ["default"]
}
variable "REPOSITORY_URL" {
  type        = string
  default     = "default"
}
variable "BUILDSPEC_SOURCE_BRANCH" {
  type        = string
  default     = "default"
}
variable "DOCKER_IMAGE" {
  type        = string
  default     = "default"
}
variable "ARTIFACTS_BUCKET" {
  type        = string
  default     = "default"
}
variable "EVENTBRIDGE_INPUT_TEMPLATE" {
  type        = string
  default     = ""
}
variable "ECR_REPOSITORY_NAME" {
  type        = string
  default     = ""
}
variable "ECR_IMAGE_TAG" {
  type        = string
  default     = ""
}
variable "DESTINATION_BRANCHES" {
  type        = list(any)
  default     = ["refs/heads/master"]
}
#-------------------------------------
# VALIDATE PULL REQUEST
#-------------------------------------
variable "ARTIFACTS_PATH_PR_VALIDATION" {
  type        = string
  default     = "default"
}
variable "CLOUDWATCH_LOG_GROUP_PR_VALIDATION" {
  type        = string
  default     = "default"
}
variable "BUILDSPEC_PR_VALIDATION" {
  type        = string
  default     = ""
}
#-------------------------------------
# APPLY INFRASTRUCTURE CHANGES
#-------------------------------------
variable "ARTIFACTS_PATH_INFRASTRUCTURE_SYNC" {
  type        = string
  default     = "default"
}
variable "CLOUDWATCH_LOG_GROUP_INFRASTRUCTURE_SYNC" {
  type        = string
  default     = "default"
}
variable "BUILDSPEC_INFRASTRUCTURE_SYNC" {
  type        = string
  default     = ""
}