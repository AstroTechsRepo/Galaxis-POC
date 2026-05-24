# 04 — Installation from scratch

> **Audience** : admin sys, devops · **Prerequis** : VM Debian 12/13 vierge, acces SSH root ou sudoer

Ce chapitre decrit l'installation **manuelle** du POC sur une VM Debian vierge. Si vous voulez deployer via Ansible, allez plutot voir le [chapitre 05](./05-deploiement-ansible.md).

---

## Avant de commencer

- VM Debian 12 ou 13 **fraichement installee** (2 vCPU, 4 GB RAM, 30 GB disque)
- Un **utilisateur sudoer** (pas root direct) — appelons-le `user`
- La VM est accessible en **SSH par cle** depuis votre poste operateur
- Aucun port n'est ouvert en entree sauf `22/tcp` (SSH)

---

## 1) Pre-requis VM

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
  ca-certificates curl gnupg lsb-release git ufw fail2ban \
  unattended-upgrades htop jq
```

### 1.a — Firewall UFW

Le POC n'expose **rien** en entree publique. Seul SSH est ouvert, les ports applicatifs restent sur `127.0.0.1` (loopback).

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw enable
```

### 1.b — Swap (recommande pour 4 GB RAM)

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile && sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 1.c — Fail2ban (anti-brute-force SSH)

```bash
sudo systemctl enable --now fail2ban
```

---

## 2) Docker Engine + Compose plugin

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker
docker --version && docker compose version
```

---

## 3) Cloner le projet

```bash
git clone https://github.com/<org>/Galaxis-POC.git ~/Galaxis-POC
cd ~/Galaxis-POC
```

---

## 4) Configurer `.env`

```bash
cp .env.example .env
nano .env
```

Tous les `change-me-*` DOIVENT etre remplaces. Generez des mots de passe :

```bash
for var in KC_ADMIN_PASSWORD KC_DB_PASSWORD APP_DB_PASSWORD \
           REDIS_PASSWORD NEXTCLOUD_DB_PASSWORD NEXTCLOUD_ADMIN_PASSWORD; do
  echo "$var=$(openssl rand -base64 24)"
done
echo "VAULTWARDEN_ADMIN_TOKEN=$(openssl rand -base64 48)"
echo "APP_KEY=base64:$(openssl rand -base64 32)"
```

Copiez les valeurs dans le `.env`.

---

## 5) Demarrer la stack

```bash
make demo
```

Ce que ca fait, dans l'ordre :

1. **`make up`** — `docker compose up -d --build` construit les images custom (Laravel + React), demarre les 11 services
2. **`make bootstrap`** — enchaine :
   - Attend que Keycloak soit healthy (~60s au premier boot)
   - `configure-keycloak.sh` : cree le realm `galaxis`, le client public PKCE, les roles, et **5 users de demo**. Idempotent.
   - `php artisan migrate` : cree les tables Laravel
   - `DemoSeeder` : 5 users + ~24 audit_logs sur les 7 derniers jours

Au bout de **~3 minutes** (premier build), le portail est disponible.

`make demo` est **idempotent** : on peut le relancer autant de fois que necessaire.

---

## 6) Tester depuis le laptop

Sur votre laptop, ouvrir un terminal :

```bash
ssh -L 8080:127.0.0.1:8080  \
    -L 9080:127.0.0.1:9080  \
    -L 10180:127.0.0.1:10180 \
    -L 11180:127.0.0.1:11180 \
    user@<vm-ip>
```

Laisser ce terminal ouvert. Puis, dans un navigateur :

| Service | URL |
|---|---|
| **Portail Galaxis** | http://localhost:9080 |
| **Keycloak admin** | http://localhost:8080 |
| **Vaultwarden** | http://localhost:10180 |
| **Nextcloud** | http://localhost:11180 |

Cliquer **Se connecter** → s'identifier **`marc`** / **`Demo2026!`** → dashboard avec "Bienvenue Marc".

### Les 5 comptes disponibles

| Username | Role | Mot de passe |
|---|---|---|
| `marc`   | admin | `Demo2026!` |
| `sophie` | user  | `Demo2026!` |
| `julien` | user  | `Demo2026!` |
| `chloe`  | user  | `Demo2026!` |
| `admin`  | admin | `Demo2026!` |

---

## 7) Verifications post-install

```bash
# Tous les conteneurs sont healthy ?
docker compose ps

# Les 3 reseaux Docker sont bien crees ?
docker network ls | grep galaxis

# La sonde API repond ?
curl -s http://127.0.0.1:9080/api/health | jq .
```

Resultat attendu :

```json
{
  "service": "galaxis-backend",
  "status": "ok",
  "checks": {
    "db":    { "ok": true },
    "redis": { "ok": true },
    "jwks":  { "ok": true }
  }
}
```

---

## 8) Arret / redemarrage

```bash
make down       # arrete tous les conteneurs, garde les volumes
make up         # redemarre sans rebuild
make restart    # down + up
make logs       # suit les logs (Ctrl+C pour quitter)
make ps         # statut des conteneurs
make nuke       # SUPPRIME LES DONNEES (volumes wipe)
```

### Apres un reboot de la VM

Les conteneurs sont configures `restart: unless-stopped` donc ils redemarrent automatiquement. Si ce n'est pas le cas :

```bash
cd ~/Galaxis-POC
make up
```

Pas besoin de relancer `make demo` (les donnees persistent dans les volumes). Seul `make up` suffit.

---

## Pieges frequents

| Symptome | Cause | Fix |
|---|---|---|
| `make demo` se bloque sur Keycloak | Premier demarrage, ~60s pour init | Attendre, surveiller `docker logs keycloak` |
| `Connection refused` sur un port | Tunnel SSH pas monte ou conteneur pas pret | Verifier `docker compose ps` + refaire le tunnel SSH |
| Login echoue | `make seed` n'a pas tourne | Relancer `make seed` |
| Port "restricted" dans Firefox | Firefox bloque certains ports (10080, 6000...) | Utiliser les ports configures : 8080, 9080, 10180, 11180 |
| Permissions storage Laravel | UID www-data different | `docker compose exec app-php chown -R www-data:www-data storage bootstrap/cache` |

---

## 9) Desinstallation propre

```bash
cd ~/Galaxis-POC
make nuke                  # arrete + supprime volumes
cd ~ && rm -rf Galaxis-POC # supprime le code
```

---

## Liens internes
- Deploiement automatique : [05-deploiement-ansible.md](./05-deploiement-ansible.md)
- Configuration Keycloak : [06-iam-keycloak.md](./06-iam-keycloak.md)
- Exploitation continue : [10-exploitation.md](./10-exploitation.md)
