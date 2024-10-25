resource "minio_s3_bucket" "terraform-states-minio-testing" {
  bucket         = "terraform-states-minio-testing"
  acl            = "private"
  object_locking = true
}

data "minio_iam_policy_document" "terraform_state_policy_document_2" {
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
      "arn:aws:s3:::terraform-states-minio-testing",
      "arn:aws:s3:::terraform-states-minio-testing/*",
    ]
  }
}

resource "minio_iam_policy" "terraform_state_policy_2" {
  name   = "terraform-states-minio-testing"
  policy = data.minio_iam_policy_document.terraform_state_policy_document_2.json

}

resource "minio_iam_user" "terraform_user_2" {
  name = "terraform-states-minio-testing"

}

resource "minio_iam_user_policy_attachment" "terraform_user_policy_attachment_2" {
  user_name   = minio_iam_user.terraform_user_2.id
  policy_name = minio_iam_policy.terraform_state_policy_2.id
}

output "user_minio_user_2" {
  value = minio_iam_user.terraform_user_2.id
}

output "minio_user_status_2" {
  value = minio_iam_user.terraform_user_2.status
}

output "minio_user_secret_2" {
  value     = nonsensitive(minio_iam_user.terraform_user_2.secret)
  sensitive = false
}