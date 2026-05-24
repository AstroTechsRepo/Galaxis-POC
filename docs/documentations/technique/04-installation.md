# 04 — Installation from scratch

> **Audience** : admin sys, devops · **Prérequis** : VM Debian 12/13 vierge, accès SSH root ou sudoer

Ce chapitre décrit l'installation **manuelle** du POC sur une VM Debian vierge. Si vous voulez déployer via Ansible, allez plutôt voir le [chapitre 05](./05-deploiement-ansible.md) — ce chapitre vous aide à comprendre ce que les playbooks font sous le capot.

---

## ⚠️ Avant de commencer

- Vous avez une VM Debian 12 ou 13 **fraîchement installée** (2 vCPU, 4 GB RAM, 30 GB disque)
- Vous avez un **utilisateur sudoer** (pas root direct) — appelons-le `deploy`
- La VM est accessible en **SSH par clé** depuis votre poste opérateur
- Aucun port n'est ouvert en entrée sauf `22/tcp` (SSH)

---

## 1) Pré-requis VM

Connectez-vous à la VM et lancez :

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
  ca-certificates curl gnupg lsb-release git ufw fail2ban \
  unattended-upgrades htop jq
```

### 1.a — Firewall UFW

Le POC n'expose **rien** en entrée publique. Seul SSH est ouvert, le port `8080` reste sur `127.0.0.1` (loopback).

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw enable
sudo ufw status verbose
```

### 1.b — Swap (recommandé pour 4 GB RAM)

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile && sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 1.c — Fail2ban (anti-brute-force SSH)

```bash
sudo systemctl enable --now fail2ban
sudo fail2ban-client status sshd
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
sudo mkdir -p /opt/galaxis
sudo chown $USER:$USER /opt/galaxis
git clone https://github.com/<org>/Galaxis-POC.git /opt/galaxis
cd /opt/galaxis
```

---

## 4) Configurer `.env`

```bash
cp .env.example .env
$EDITOR .env
```

⚠️ **Tous les `change-me-*` DOIVENT être remplacés.** Générez des mots de passe solides :

```bash
# 5 mots de passe forts
for var in KC_BOOTSTRAP_ADMIN_PASSWORD KC_DB_PASSWORD APP_DB_PASSWORD \
           REDIS_PASSWORD NEXTCLOUD_DB_PASSWORD NEXTCLOUD_ADMIN_PASSWORD; do
  echo "$var=$(openssl rand -base64 24)"
done

# Token admin Vaultwarden (chaîne longue)
echo "VAULTWARDEN_ADMIN_TOKEN=$(openssl rand -base64 48)"

# APP_KEY (sera regénérée à l'init Laravel si manquante)
echo "APP_KEY=base64:$(openssl rand -base64 32)"
```

Copiez les valeurs dans le `.env`.

---

## 5) Démarrer la stack

Première fois :

```bash
make demo
```

Ce que ça fait :
1. `docker compose up -d --build` — construit l'image Laravel et l'image React, démarre les 10 services
2. Attend que Keycloak passe en `/iam/health/ready`
3. Lance `./infrastructure/scripts/configure-keycloak.sh` qui crée le realm, le client PKCE, les users démo

Au bout de **~3 minutes** (premier build), le portail est disponible sur `127.0.0.1:8080` sur la VM.

---

## 6) Tester depuis le laptop

Sur votre laptop :

```bash
ssh -L 8080:127.0.0.1:8080 deploy@<vm-ip-ou-fqdn>
```

Puis, dans un navigateur sur le laptop :
- Ouvrir `http://localhost:8080`
- Cliquer **Se connecter**
- S'identifier `lucas-test` / `demo`
- Vous arrivez sur le **dashboard** avec les claims JWT décodés

✅ Si vous voyez ça, c'est fini.

---

## 7) Vérifications post-install

```bash
# Tous les conteneurs sont healthy ?
docker compose ps

# Les 3 réseaux Docker sont bien créés ?
docker network ls | grep galaxis

# La sonde API répond ?
curl -fsS http://127.0.0.1:8080/api/health | jq .

# Keycloak est UP ?
curl -fsS http://127.0.0.1:8080/iam/health/ready
```

Résultat attendu :

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

## 8) Arrêt / redémarrage

```bash
make down       # arrête tous les conteneurs, garde les volumes
make up         # redémarre sans rebuild
make restart    # down + up
make logs       # suit les logs (Ctrl+C pour quitter)
make ps         # statut des conteneurs
make clean      # ⚠️ SUPPRIME LES DONNÉES (volumes wipe)
```

---

## ⚠️ Pièges fréquents

| Symptôme | Cause | Fix |
|---|---|---|
| `make demo` se bloque sur Keycloak | Keycloak peut prendre 60s à démarrer la première fois | Attendre, surveiller `docker logs galaxis-keycloak` |
| `Connection refused` sur `:8080` | Tu as oublié de monter le tunnel SSH | `ssh -L 8080:127.0.0.1:8080 user@vm` |
| Tu vois `Bad Gateway` en cliquant Se connecter | Le port `/iam` ne ressort pas car `KC_HTTP_RELATIVE_PATH` mal configuré | Vérifie `docker compose config keycloak` |
| Permissions storage Laravel | UID www-data différent | `docker exec galaxis-app-php chown -R www-data:www-data storage bootstrap/cache` |
| Nextcloud "trusted domains" | Premier accès depuis nouvelle URL | Le `.env` doit avoir `PUBLIC_HOST=localhost:8080` |

---

## 9) Désinstallation propre

```bash
cd /opt/galaxis
make clean                 # arrête + supprime volumes
sudo rm -rf /opt/galaxis   # supprime le code
# (Docker reste installé, à toi de voir)
```

---

## Liens internes
- Déploiement automatique : [05-deploiement-ansible.md](./05-deploiement-ansible.md)
- Configuration Keycloak : [06-iam-keycloak.md](./06-iam-keycloak.md)
- Exploitation continue : [10-exploitation.md](./10-exploitation.md)
