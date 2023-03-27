#-------------------------------------
# METADATA VARIABLES
#-------------------------------------
AWS_REGION   =
AWS_PROFILE  =
DEPLOYMENT   =
PROJECT_NAME =
AUTHOR       =
#-------------
# GENERAL VARIABLES
#-------------------------------------
REPOSITORY_NAME            =
REPOSITORY_URL             =
BUILDSPEC_SOURCE_BRANCH    =
DOCKER_IMAGE               =
ARTIFACTS_BUCKET           = 
EVENTBRIDGE_INPUT_TEMPLATE = <<EOF
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
DESTINATION_BRANCHES       = 
#-------------------------------------
# VALIDATE PULL REQUEST
#-------------------------------------
ARTIFACTS_PATH_PR_VALIDATION       = 
CLOUDWATCH_LOG_GROUP_PR_VALIDATION = 
BUILDSPEC_PR_VALIDATION            = 
#-------------------------------------
# APPLY INFRASTRUCTURE CHANGES
#-------------------------------------
ARTIFACTS_PATH_INFRASTRUCTURE_SYNC       = 
CLOUDWATCH_LOG_GROUP_INFRASTRUCTURE_SYNC = 
BUILDSPEC_INFRASTRUCTURE_SYNC            = 