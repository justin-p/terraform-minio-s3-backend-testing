terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = ">= 2.0.0"
    }
  }
##
## enable this after setting up the buckets to move this state to minio
## then run terraform init -migrate-state
##
#  backend "s3" {
#    bucket = "terraform-states-minio-terraform-buckets"
#    endpoints = {
#      s3 = "http://minio.domain.tld/"
#    }
#    key = "terraform.tfstate"
#
#    access_key = "terraform-states-minio-terraform-buckets"
#    secret_key = "pUgtURQ6L6_uc55Fx7S1fH4Pxxv7ocNJUXziO35OGw1AHB5ylvPnSQ=="
#
#    region                      = "eu-west-1"
#    skip_credentials_validation = true
#    skip_requesting_account_id  = true
#    skip_metadata_api_check     = true
#    skip_region_validation      = true
#    use_path_style              = true
#  }
}

variable "terraform_states_minio_states_name" {
  default = "terraform-states-minio-terraform-buckets"
}

provider "minio" {
  minio_server   = "minio.domain.tld"
  minio_region   = "eu-west-1"
  minio_user     = "minioadmin"
  minio_password = "minioadmin"
}

resource "minio_s3_bucket" "terraform_states_minio_terraform_buckets" {
  bucket         = var.terraform_states_minio_states_name
  acl            = "private"
  object_locking = true
}

data "minio_iam_policy_document" "terraform_states_minio_terraform_buckets" {
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
      "arn:aws:s3:::${var.terraform_states_minio_states_name}",
      "arn:aws:s3:::${var.terraform_states_minio_states_name}/*",
    ]
  }
}

resource "minio_iam_policy" "terraform_state_minio_terraform_buckets" {
  name   = var.terraform_states_minio_states_name
  policy = data.minio_iam_policy_document.terraform_states_minio_terraform_buckets.json

}

resource "minio_iam_user" "terraform_states_minio_terraform_buckets" {
  name = var.terraform_states_minio_states_name
}

resource "minio_iam_user_policy_attachment" "terraform_states_minio_terraform_buckets" {
  user_name   = minio_iam_user.terraform_states_minio_terraform_buckets.id
  policy_name = minio_iam_policy.terraform_state_minio_terraform_buckets.id
}

output "terraform_states_minio_terraform_buckets_user_name" {
  value = minio_iam_user.terraform_states_minio_terraform_buckets.id
}

output "terraform_states_minio_terraform_buckets_user_secret" {
  value     = nonsensitive(minio_iam_user.terraform_states_minio_terraform_buckets.secret)
  sensitive = false
}
