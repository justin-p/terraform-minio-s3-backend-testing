terraform {
    backend "s3" {
        bucket = "terraform-states-other-project"
        endpoints = {
            s3 = "http://minio.domain.tld/"
        }
        key = "terraform.tfstate"

        access_key="terraform-states-other-project"
        secret_key="YXUp7RNLnQWF78Oo4hGhbPIrvg1A7babIjMqIcbcYjolG9xRdlou9g=="

        region = "eu-west-1"
        skip_credentials_validation = true
        skip_requesting_account_id = true
        skip_metadata_api_check = true
        skip_region_validation = true
        use_path_style = true
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

resource "random_pet" "name" {
  count = 2
}