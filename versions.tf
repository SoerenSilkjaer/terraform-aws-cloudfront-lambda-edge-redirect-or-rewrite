terraform {
  required_version = ">= 1.0.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.34.0"
      configuration_aliases = [aws.us-east-1]
    }
  }
}
