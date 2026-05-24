# ============================================================
# Galaxis POC v1.1 — Caddyfile TIER APP
# Frontal HTTPS du tier applicatif (réseau galaxis-app-net)
# - /api/* → reverse proxy FastCGI vers app-php (Laravel)
# - /*    → file_server du build React (volume galaxis-frontend-build)
# TLS terminé ici via CA locale Caddy (tls internal)
# ============================================================

{
	auto_https disable_redirects
	local_certs
	log {
		output stdout
		format json
		level INFO
	}
}

# ----------------------------------------------------------------
# Hôte canonique : galaxis-app (interne)
# + alias localhost (vu depuis le navigateur du laptop via tunnel SSH)
# ----------------------------------------------------------------
galaxis-app:443, localhost:443 {
	tls internal

	encode gzip zstd

	header {
		X-Content-Type-Options "nosniff"
		X-Frame-Options "SAMEORIGIN"
		Referrer-Policy "strict-origin-when-cross-origin"
		-Server
	}

	# Endpoint CA local (import navigateur)
	handle /_ca.crt {
		root * /data/caddy/pki/authorities/local
		rewrite * /root.crt
		file_server
	}

	# ------------------------------------------------------------
	# /api/* → Backend Laravel via FastCGI direct sur PHP-FPM
	# (les fichiers PHP vivent dans /srv/api monté en RO)
	# ------------------------------------------------------------
	handle_path /api/* {
		root * /srv/api/public
		# Laravel attend tout sur index.php (front controller)
		rewrite * /index.php
		php_fastcgi app-php:9000 {
			# Préserve l'URI originale dans REQUEST_URI
			env REQUEST_URI /api{uri}
			env SCRIPT_NAME /api/index.php
		}
	}

	# Variante simple si l'environnement préfère un sous-arbre direct
	# (gardée commentée pour référence) :
	# handle /api/* {
	#     root * /srv/api/public
	#     php_fastcgi app-php:9000
	# }

	# ------------------------------------------------------------
	# / → Frontend React (SPA) servi depuis le volume nommé
	# Fallback /index.html pour les routes client (react-router)
	# ------------------------------------------------------------
	handle {
		root * /srv/frontend
		try_files {path} /index.html
		file_server
	}
}
