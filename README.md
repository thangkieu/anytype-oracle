# any-sync-bundle on Oracle Cloud Always Free — Terragrunt

Same infra as the plain-Terraform version, reorganized so the reusable
module lives separately from environment-specific config:

```
oci-anytype-terragrunt/
├── terragrunt.hcl                        # root — generates local backend
├── modules/oci-anytype/                  # the actual Terraform module
│   ├── versions.tf  variables.tf  network.tf  instance.tf  outputs.tf
│   └── cloud-init.yaml.tpl
└── live/singapore/anytype-server/
    └── terragrunt.hcl                    # this unit's inputs
```

Adding another VM/environment later is just another folder under `live/`
pointing `source` at the same module — no duplicated `.tf` files.

## 1. Generate an API signing key (one-time, in the OCI Console)

Profile icon → User Settings → API Keys → Add API Key → Generate → Download
the private key → Add. The console shows `tenancy_ocid`, `user_ocid`,
`fingerprint`, `region` after adding the key.

## 2. Export auth as environment variables (not committed to any file)

```bash
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..xxxx"
export TF_VAR_user_ocid="ocid1.user.oc1..xxxx"
export TF_VAR_fingerprint="xx:xx:xx:...:xx"
export TF_VAR_private_key_path="$HOME/.oci/oci_api_key.pem"
export TF_VAR_compartment_ocid="$TF_VAR_tenancy_ocid"   # root compartment
```

The module declares these as variables, and Terraform reads `TF_VAR_*`
automatically regardless of Terragrunt — this keeps secrets out of every
`.hcl`/`.tfvars` file entirely. Put the export lines in a local shell
script that's gitignored (or a tool like `direnv`) so you don't retype
them every session.

Non-secret settings (region, instance size, SSH key path,
`ssh_allowed_cidr`) live in `live/singapore/anytype-server/terragrunt.hcl` —
edit that file directly instead of using environment variables for those.

## 3. Run it

```bash
cd live/singapore/anytype-server
terragrunt init
terragrunt plan
terragrunt apply
```

## 4. About "out of host capacity" errors

Same caveat as the plain-Terraform version — Terragrunt doesn't add retry
logic either. Wrap the apply:

```bash
until terragrunt apply -auto-approve; do
  echo "Capacity error, retrying in 60s..."
  sleep 60
done
```

## 5. After apply

```bash
terragrunt output instance_public_ip
terragrunt output ssh_command
```

SSH in after a minute or two, check `/var/log/anytype-bootstrap-done.log`
and `docker ps` to confirm any-sync-bundle is running, then pull the client
config (`terragrunt output client_config_fetch_command`) and import it into
Anytype on your devices.

## 6. Tearing down

```bash
terragrunt destroy
```

## Adding a second environment later

Copy `live/singapore/anytype-server/` to e.g. `live/singapore/staging/`,
change `instance_display_name` and any other inputs, then
`terragrunt run-all apply` from `live/` applies everything, or target the
one unit as usual from inside its folder.
