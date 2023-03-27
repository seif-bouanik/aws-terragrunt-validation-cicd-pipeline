#-------------------------------------
# GENERAL
#-------------------------------------
# S3 Bucket
data "aws_s3_bucket" "artifacts_bucket" {
  bucket = var.ARTIFACTS_BUCKET
}
# Eventbridge IAM Role
resource "aws_iam_role" "eventbridge_role" {
  name        = "eventbridge_role"
  description = "PR Validation Eventbridge Role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Effect : "Allow",
        Principal : {
          Service : "events.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "StartCodebuildProjects"

    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : [
            "codebuild:StartBuild"
          ],
          Resource : [aws_codebuild_project.pr_validation.arn, aws_codebuild_project.sync_infrastructure.arn]
        }
      ]
    })
  }
}
#-------------------------------------
# VALIDATE PULL REQUEST
#-------------------------------------
# CodeBuild IAM Role
resource "aws_iam_role" "pr_validation_codebuild" {
  name        = "PR_Validation_Codebuild_Role"
  description = "PR Validation CodeBuild Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "PR_Validation_Codebuild_Policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action = ["ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetRepository",
          "codecommit:GitPull",
          "codecommit:ListBranches",
          "codecommit:ListRepositories",
          "codecommit:PostCommentForPullRequest",
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"],
        Effect   = "Allow",
        Resource = "*"
      }]
    })
  }
}

# CodeBuild Project
resource "aws_codebuild_project" "pr_validation" {
  name           = "validate-pull-requests-project"
  description    = "CodeBuild project to validate PRs"
  build_timeout  = "15"
  service_role   = aws_iam_role.pr_validation_codebuild.arn
  source_version = var.BUILDSPEC_SOURCE_BRANCH
  source {
    type            = "CODECOMMIT"
    location        = var.REPOSITORY_URL
    git_clone_depth = 0
    buildspec       = var.BUILDSPEC_PR_VALIDATION
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.DOCKER_IMAGE
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "S3_BUCKET"
      value = var.ARTIFACTS_BUCKET
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "ARTIFACTS_PREFIX"
      value = var.ARTIFACTS_PATH_PR_VALIDATION
      type  = "PLAINTEXT"
    }
  }

  artifacts {
    type                   = "S3"
    location               = var.ARTIFACTS_BUCKET
    bucket_owner_access    = "READ_ONLY"
    path                   = var.ARTIFACTS_PATH_PR_VALIDATION 
    namespace_type         = "NONE"
    packaging              = "NONE"
    encryption_disabled    = "true"
    override_artifact_name = "true"
  }
  logs_config {
    cloudwatch_logs {
      group_name = var.CLOUDWATCH_LOG_GROUP_PR_VALIDATION
    }
  }
}
# Eventbridge Rule
resource "aws_cloudwatch_event_rule" "pr_validation" {
  name        = "validate-pull-requests-rule"
  description = "Capture open Pull Requests updates"
  event_pattern = jsonencode(
    {
      detail : {
        repositoryNames : var.REPOSITORY_NAME,
        event : ["pullRequestCreated", "pullRequestSourceBranchUpdated", "pullRequestStatusChanged"],
        pullRequestStatus : ["Open"],
        destinationReference : var.DESTINATION_BRANCHES
    } }
  )
}

resource "aws_cloudwatch_event_target" "pr_validation" {
  target_id      = "SendToCodebuild"
  rule           = aws_cloudwatch_event_rule.pr_validation.name
  arn            = aws_codebuild_project.pr_validation.arn
  role_arn       = aws_iam_role.eventbridge_role.arn
  event_bus_name = "default"
  input_transformer {
    input_paths = {
      pullRequestId     = "$.detail.pullRequestId",
      repositoryName    = "$.detail.repositoryNames[0]",
      sourceBranch      = "$.detail.sourceReference",
      destinationBranch = "$.detail.destinationReference",
      sourceCommit      = "$.detail.sourceCommit",
      destinationCommit = "$.detail.destinationCommit",
      account           = "$.account"
    }
    input_template = var.EVENTBRIDGE_INPUT_TEMPLATE
  }
}
#-------------------------------------
# APPLY INFRASTRUCTURE CHANGES
#-------------------------------------
# CodeBuild IAM Role
resource "aws_iam_role" "sync_infrastructure_codebuild" {
  name        = "Sync_Infrastructure_Codebuild_Role"
  description = "Sync Infrastructure Codebuild Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Sid    = "SyncInfrastructureCodebuildPolicy",
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "Sync_Infrastructure_Codebuild_Policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action   = ["*"],
        Effect   = "Allow",
        Resource = "*"
      }]
    })
  }
}
# CodeBuild Project
resource "aws_codebuild_project" "sync_infrastructure" {
  name           = "sync-infrastructure-project"
  description    = "CodeBuild project to sync terrafrom infrastructure changes introduced by merged PRs"
  build_timeout  = "15"
  service_role   = aws_iam_role.sync_infrastructure_codebuild.arn
  source_version = var.BUILDSPEC_SOURCE_BRANCH
  source {
    type            = "CODECOMMIT"
    location        = var.REPOSITORY_URL
    git_clone_depth = 0
    buildspec       = var.BUILDSPEC_INFRASTRUCTURE_SYNC
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.DOCKER_IMAGE
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "S3_BUCKET"
      value = var.ARTIFACTS_BUCKET
      type  = "PLAINTEXT"
    }
    environment_variable {
      name  = "ARTIFACTS_PREFIX"
      value = var.ARTIFACTS_PATH_INFRASTRUCTURE_SYNC
      type  = "PLAINTEXT"
    }
  }

  artifacts {
    type                   = "S3"
    location               = var.ARTIFACTS_BUCKET
    bucket_owner_access    = "READ_ONLY"
    path                   = var.ARTIFACTS_PATH_INFRASTRUCTURE_SYNC
    namespace_type         = "NONE"
    packaging              = "NONE"
    encryption_disabled    = "true"
    override_artifact_name = "true"
  }
  logs_config {
    cloudwatch_logs {
      group_name = var.CLOUDWATCH_LOG_GROUP_INFRASTRUCTURE_SYNC
    }
  }
}
# Eventbridge Rule
resource "aws_cloudwatch_event_rule" "sync_infrastructure" {
  name        = "infrastructure-sync-rule"
  description = "Capture merged Pull Requests updates"
  event_pattern = jsonencode(
    {
      detail : {
        repositoryNames : var.REPOSITORY_NAME,
        event : ["pullRequestMergeStatusUpdated"],
        pullRequestStatus : ["Closed"],
        isMerged : ["True"],
        destinationReference : var.DESTINATION_BRANCHES
    } }
  )
}
resource "aws_cloudwatch_event_target" "sync_infrastructure" {
  target_id      = "SendToCodebuild"
  rule           = aws_cloudwatch_event_rule.sync_infrastructure.name
  arn            = aws_codebuild_project.sync_infrastructure.arn
  role_arn       = aws_iam_role.eventbridge_role.arn
  event_bus_name = "default"
  input_transformer {
    input_paths = {
      pullRequestId     = "$.detail.pullRequestId",
      repositoryName    = "$.detail.repositoryNames[0]",
      sourceBranch      = "$.detail.sourceReference",
      destinationBranch = "$.detail.destinationReference",
      sourceCommit      = "$.detail.sourceCommit",
      destinationCommit = "$.detail.destinationCommit",
      account           = "$.account"
    }
    input_template = var.EVENTBRIDGE_INPUT_TEMPLATE
  }
}