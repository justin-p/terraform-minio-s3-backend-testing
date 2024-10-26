# MinIO Backend for Terraform

This project sets up a MinIO backend for storing Terraform state files. It uses Docker Compose to run a MinIO cluster and Terraform to configure the necessary buckets and permissions.

## Project Structure

- `docker-compose.yaml`: Defines the MinIO cluster setup
- `minio_setup_backend/`: Contains Terraform configurations for setting up MinIO buckets
- `minio_use_backend/`: Contains an example of how to use the MinIO backend in a Terraform project

## Prerequisites

- Docker and Docker Compose
- Terraform (version compatible with providers used)
- MinIO client (mc) for health checks
- Host file/dns that points `minio.domain.tld` and `minioadmin.domain.tld` to 127.0.0.1

## Setup

1. Start the MinIO cluster:

```bash
docker-compose up -d
```

2. Set up the MinIO buckets and permissions:

```bash
cd minio_setup_backend
terraform init
terraform apply
```

Note down the outputted credentials.

3. Move the Terraform backend to MinIO:

- Open `main.tf` and uncomment the `backend "s3"` configuration block by removing the `#` symbols and set the correct `access_key` and `secret_key`.

- (Re)initialize Terraform and migrate the existing state to MinIO:

```bash
terraform init -migrate-state
```

4. Congratulations! Your Terraform configuration for creating MinIO buckets to be used by Terraform for state management is now set up to use it's own created bucket to store its state. Refer to the example in `minio_use_backend/main.tf` for configuring your Terraform backend with MinIO in other projects. The current example has already setup a bucket and account for this in `minio_setup_backend/bucket_for_other_project.tf`

## Configuration

### MinIO Cluster

The MinIO cluster is configured in the `docker-compose.yaml` file. It sets up:

- 4 MinIO server instances
- Traefik as a reverse proxy
- Accessible at `http://minio.domain.tld` for s3 interactions and the admin interface at `http://minioadmin.domain.tld`

## Security Note

The example configurations contain hardcoded and default credentials. In a production environment, use secure methods to manage and inject secrets.
This example does not have a KMS setup to enable encryption in the buckets. As Terraform states can include secrets it is highly recommended to ensure buckets can be encrypted.
