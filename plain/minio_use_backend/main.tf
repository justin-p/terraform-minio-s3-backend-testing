terraform {
    backend "s3" {
        bucket = "terraform-states-minio-testing"                  # Name of the S3 bucket
        endpoints = {
            s3 = "http://minio.domain.tld/"   # Minio endpoint
        }
        key = "terraform.tfstate"        # Name of the tfstate file

        access_key="terraform-states-minio-testing"           # Access and secret keys
        secret_key="VcfsT1IZ4UGCDDCCgilyij3ED4To4wHPUqHG8Xccbm_h5wtnIXhiLA=="

        region = "eu-west-1"                     # Region validation will be skipped
        skip_credentials_validation = true  # Skip AWS related checks and validations
        skip_requesting_account_id = true
        skip_metadata_api_check = true
        skip_region_validation = true
        use_path_style = true             # Enable path-style S3 URLs (https://<HOST>/<BUCKET> https://developer.hashicorp.com/terraform/language/settings/backends/s3#use_path_style
    }
}

terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = ">= 2.0.0"
    }
  }
}

provider "minio" {
  minio_server   = "minio.domain.tld"
  minio_region   = "eu-west-1"
  minio_user     = "terraform-states-minio-terraform-bucket"
  minio_password = "0IMFziLidVVkaW6KN5KKtTm3dnuYq_-1UWc89Gok21XStRFArkUwEA=="
}

resource "random_pet" "name" {
  count = 2
}