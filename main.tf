# Define the required providers for this configuration.
# We need 'aws' to manage the resources and 'random' to generate unique names.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# -----------------------------------------------------------------------------
# 1. AWS Provider Configuration
# -----------------------------------------------------------------------------
provider "aws" {
  # You can change the region here if needed, but us-east-1 is a good default.
  region = "us-east-1"
  # Credentials must be configured in the Terraform Cloud workspace 
  # or in your local environment for this to run.
}

# -----------------------------------------------------------------------------
# 2. Helper Resource for Unique Naming
# -----------------------------------------------------------------------------
# Generates a unique, readable name (e.g., "fast-fox-25"). This is critical 
# for resources that require globally unique names, like S3 buckets, 
# and prevents test conflicts.
resource "random_pet" "unique_name" {
  length = 2
  separator = "-"
}

# -----------------------------------------------------------------------------
# 3. Resource 1: AWS S3 Bucket (Simple Storage)
# -----------------------------------------------------------------------------
# This resource creates a simple S3 bucket in the specified region.
resource "aws_s3_bucket" "test_bucket" {
  # Bucket name must be globally unique. We use the random_pet resource.
  bucket = "tfcloud-test-bucket-${random_pet.unique_name.id}"

  # Ensure the bucket blocks public access, which is a modern security best practice.
  tags = {
    Name        = "TFCloudTestBucket"
    Environment = "Testing"
  }
}

# -----------------------------------------------------------------------------
# 4. Resource 2: AWS SQS Queue (Messaging Service)
# -----------------------------------------------------------------------------
# This resource creates a standard SQS queue.
resource "aws_sqs_queue" "test_queue" {
  # Queue names need to be unique within a region.
  name                       = "tfcloud-test-queue-${random_pet.unique_name.id}"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 30
}

# -----------------------------------------------------------------------------
# 5. Outputs (Verification)
# -----------------------------------------------------------------------------
# These outputs allow you to verify the successful creation and key properties 
# of the resources after the 'terraform apply' completes.

output "s3_bucket_name" {
  description = "The globally unique name of the created S3 bucket."
  value       = aws_s3_bucket.test_bucket.id
}

output "sqs_queue_url" {
  description = "The URL required to send/receive messages from the SQS queue."
  value       = aws_sqs_queue.test_queue.url
}
