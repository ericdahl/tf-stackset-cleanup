provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name       = "tf-stackset-cleanup"
      Repository = "https://github.com/ericdahl/tf-stackset-cleanup"
    }
  }
}