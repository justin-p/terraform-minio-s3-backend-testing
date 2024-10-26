provider "vault" {
  # It is strongly recommended to configure this provider through the
  # environment variables:
  #    - VAULT_ADDR
  #    - VAULT_TOKEN
  #    - VAULT_CACERT
  #    - VAULT_CAPATH
  #    - etc.  
  address = "http://vault.domain.tld"
  token   = "hvs.U5RqbTpqsbgktUyURVn8BUfm"
}

resource "vault_mount" "kes-kv" {
  path = "minio-kes-kv"
  type = "kv"
  options = {
    version = "2"
  }
}

resource "vault_policy" "kes_policy" {
  name   = "kes-policy"
  policy = <<EOF
path "minio-kes-kv/data/*" {
  capabilities = [ "create", "read" ]
}

path "minio-kes-kv/metadata/*" {
  capabilities = [ "list", "delete" ]
}
EOF
}

resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "kes_role" {
  backend            = vault_auth_backend.approle.path
  role_name          = "kes-server"
  secret_id_num_uses = 0
  token_num_uses     = 0
  token_ttl          = 300
  token_max_ttl      = 300
  token_policies     = [vault_policy.kes_policy.name]
}

output "kes_role_id" {
  value = vault_approle_auth_backend_role.kes_role.id
}

resource "vault_approle_auth_backend_role_secret_id" "kes_role_secret_id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.kes_role.role_name
}

output "kes_secret_id" {
  value = nonsensitive(vault_approle_auth_backend_role_secret_id.kes_role_secret_id.secret_id)
}
