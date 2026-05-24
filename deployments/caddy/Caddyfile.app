# ============================================================
# Galaxis POC v1.2 — Caddyfile TIER APP
# Frontal HTTP du tier applicatif (réseau galaxis-app-net)
# - /api/* → reverse proxy FastCGI vers app-php (Laravel)
# - /*    → file_server du build React (volume galaxis-frontend-build)
# ============================================================

{
	auto_https off
	log {
		output stdout
		format json
		level INFO
	}
}

:80 {
	encode gzip zstd

	header {
		X-Content-Type-Options "nosniff"
		X-Frame-Options "SAMEORIGIN"
		Referrer-Policy "strict-origin-when-cross-origin"
		-Server
	}

	handle /api/* {
		reverse_proxy app-php:9000 {
			transport fastcgi {
				root /var/www/html/public
				split .php
				env SCRIPT_FILENAME /var/www/html/public/index.php
				env SCRIPT_NAME /index.php
			}
		}
	}

	handle {
		root * /srv/frontend
		try_files {path} /index.html
		file_server
	}
}
