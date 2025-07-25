#!/usr/bin/env bash
set -euo pipefail

# 1. Backup existing configs
cp -a /etc/nginx /etc/nginx.bak-$(date +%F)      # :contentReference[oaicite:10]{index=10}
cp -a /etc/varnish /etc/varnish.bak-$(date +%F)

# 2. Install Varnish
apt update
apt install varnish -y                            # :contentReference[oaicite:11]{index=11}

# 3. Configure Varnish default.vcl
cat > /etc/varnish/default.vcl <<'EOF'
vcl 4.0;

backend default {
    .host = "127.0.0.1";
    .port = "8080";
}

sub vcl_recv {
    if (req.url ~ "\.(png|jpg|css|js|svg)$") {
        unset req.http.Cookie;
    }
}
EOF

# 4. Override systemd service to listen on 6081
mkdir -p /etc/systemd/system/varnish.service.d
cat > /etc/systemd/system/varnish.service.d/override.conf <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/sbin/varnishd \
  -a :6081 \
  -T localhost:6082 \
  -f /etc/varnish/default.vcl \
  -s malloc,256m
EOF
systemctl daemon-reload
systemctl enable --now varnish

# 5. Prepare Hestia Nginx templates
TEMPL_DIR="/usr/local/hestia/data/templates/web/nginx/php-fpm"
cp "$TEMPL_DIR/default.tpl"  "$TEMPL_DIR/varnish.tpl"   # :contentReference[oaicite:12]{index=12}
cp "$TEMPL_DIR/default.stpl" "$TEMPL_DIR/varnish.stpl"

# 6. Update templates to proxy to varnish
for f in varnish.tpl varnish.stpl; do
  sed -i 's|proxy_pass http://127.0.0.1:8080;|proxy_pass http://127.0.0.1:6081;|' \
      "$TEMPL_DIR/$f"
  sed -i 's|proxy_set_header X-Forwarded-Proto.*|proxy_set_header X-Forwarded-Proto $scheme;|' \
      "$TEMPL_DIR/$f"
done

# 7. Rebuild all domains
for user in $(v-list-users plain | cut -f1); do
  v-rebuild-web-domains "$user" yes                   # :contentReference[oaicite:13]{index=13}
done

echo "Varnish has been installed and Hestia templates updated. Please assign the 'varnish' template to your domains."
