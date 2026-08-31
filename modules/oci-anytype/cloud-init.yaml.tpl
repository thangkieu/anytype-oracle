#cloud-config
package_update: true

packages:
  - ca-certificates
  - curl
  - gnupg
  - ufw

runcmd:
  # --- Install Docker ---
  - curl -fsSL https://get.docker.com | sh
  - systemctl enable docker
  - systemctl start docker

  # --- Local firewall (mirrors the OCI security list rules) ---
  - ufw allow 22/tcp
  - ufw allow 33010/tcp
  - ufw allow 33020/udp
  - ufw --force enable

  # --- Resolve external address (use configured domain if set, otherwise detect public IP) ---
  - export EXTERNAL_ADDR="${any_sync_bundle_external_addr != "" ? any_sync_bundle_external_addr : "$(curl -s ifconfig.me)"}"
  - mkdir -p /opt/any-sync-bundle/data

  # --- Run any-sync-bundle (all-in-one, embedded DB, no external Mongo/Redis) ---
  - |
    docker run -d \
      --name any-sync-bundle \
      --restart unless-stopped \
      -e ANY_SYNC_BUNDLE_INIT_EXTERNAL_ADDRS="$EXTERNAL_ADDR" \
      -p 33010:33010 \
      -p 33020:33020/udp \
      -v /opt/any-sync-bundle/data:/data \
      ghcr.io/grishy/any-sync-bundle:${any_sync_bundle_version}

  # --- Write a marker file so you know cloud-init finished ---
  - 'echo "any-sync-bundle bootstrap complete: $(date)" > /var/log/anytype-bootstrap-done.log'
