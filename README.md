# hestiacp-varnish

A bash script to integrate Varnish Cache with HestiaCP servers, automating the setup of:

```
Internet → Nginx (SSL termination on 80/443) → Varnish (6081) → Hestia Nginx backend (8080)
```

## Prerequisites

* Debian or Ubuntu (tested on Debian 11 / Ubuntu 22.04)
* HestiaCP v1.9+ with Nginx + PHP-FPM
* Root or sudo access
* Git installed

## Installation

```bash
# Clone the repository and make the installer executable
git clone https://github.com/<your-org>/hestiacp-varnish.git
cd hestiacp-varnish
chmod +x add_varnish_hestiacp.sh

# Run the installer as root or with sudo
sudo ./add_varnish_hestiacp.sh
```

## Usage

1. Assign the `varnish` templates in Hestia web UI or via CLI:

   ```bash
   v-change-web-domain-tpl       <user> <domain> varnish
   v-change-web-domain-proxy-tpl <user> <domain> varnish
   v-change-web-domain-backend-tpl <user> <domain> default yes
   v-rebuild-web-domains         <user> yes
   ```

2. Verify that Varnish is handling requests:

   ```bash
   curl -I http://your-domain.com | grep -Ei 'Via|X-Varnish'
   curl -I https://your-domain.com | grep -Ei 'Via|X-Varnish'
   ```

## Contributing

1. Fork the repository and create a feature branch
2. Commit your changes
3. Open a pull request for review

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.
