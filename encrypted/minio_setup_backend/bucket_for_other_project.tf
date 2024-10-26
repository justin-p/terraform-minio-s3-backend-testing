variable "terraform_states_other_project_name" {
  default = "terraform-states-other-project"
}

resource "minio_s3_bucket" "terraform_states_other_project" {
  bucket         = var.terraform_states_other_project_name
  acl            = "private"
  object_locking = true
}

data "minio_iam_policy_document" "terraform_states_other_project" {
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
      "arn:aws:s3:::${var.terraform_states_other_project_name}",
      "arn:aws:s3:::${var.terraform_states_other_project_name}/*",
    ]
  }
}

resource "minio_iam_policy" "terraform_states_other_project" {
  name   = var.terraform_states_other_project_name
  policy = data.minio_iam_policy_document.terraform_states_other_project.json

}

resource "minio_iam_user" "terraform_states_other_project" {
  name = var.terraform_states_other_project_name
}

resource "minio_iam_user_policy_attachment" "terraform_states_other_project" {
  user_name   = minio_iam_user.terraform_states_other_project.id
  policy_name = minio_iam_policy.terraform_states_other_project.id
}

output "terraform_states_other_project_user_name" {
  value = minio_iam_user.terraform_states_other_project.id
}

output "terraform_states_other_project_user_secret" {
  value     = nonsensitive(minio_iam_user.terraform_states_other_project.secret)
  sensitive = false
}