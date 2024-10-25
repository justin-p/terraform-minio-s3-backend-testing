terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = ">= 2.0.0"
    }
  }
##
## enable this after setting up the bucket to move this state to minio
## then run terraform init -migrate-state
##
#  backend "s3" {
#    bucket = "terraform-states-minio-terraform-bucket"
#    endpoints = {
#      s3 = "http://minio.domain.tld/"
#    }
#    key = "terraform.tfstate"
#
#    access_key = "terraform-states-minio-terraform-bucket"
#    secret_key = "vMF_DbRfrUiYE7x0OZJL1c6JGQICVVyvz0OsRn7OV-btNxYKa4qtbA=="
#
#    region                      = "eu-west-1"
#    skip_credentials_validation = true
#    skip_requesting_account_id  = true
#    skip_metadata_api_check     = true
#    skip_region_validation      = true
#    use_path_style              = true
#  }
}
 
provider "minio" {
  minio_server   = "minio.domain.tld"
  minio_region   = "eu-west-1"
  minio_user     = "minioadmin"
  minio_password = "minioadmin"
}

resource "minio_s3_bucket" "state_terraform_s3_bucket" {
  bucket         = "terraform-states-minio-terraform-bucket"
  acl            = "private"
  object_locking = true
}

data "minio_iam_policy_document" "terraform_state_policy_document" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }


  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::terraform-states-minio-terraform-bucket",
      "arn:aws:s3:::terraform-states-minio-terraform-bucket/*",
    ]
  }
}

resource "minio_iam_policy" "terraform_state_policy" {
  name   = "terraform-states-minio-terraform-bucket"
  policy = data.minio_iam_policy_document.terraform_state_policy_document.json

}

resource "minio_iam_user" "terraform_user" {
  name = "terraform-states-minio-terraform-bucket"

}

resource "minio_iam_user_policy_attachment" "terraform_user_policy_attachment" {
  user_name   = minio_iam_user.terraform_user.id
  policy_name = minio_iam_policy.terraform_state_policy.id
}

output "user_minio_user" {
  value = minio_iam_user.terraform_user.id
}

output "minio_user_status" {
  value = minio_iam_user.terraform_user.status
}

output "minio_user_secret" {
  value     = nonsensitive(minio_iam_user.terraform_user.secret)
  sensitive = false
}
