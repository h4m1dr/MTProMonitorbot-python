# MTPro-Py — Python MTProxy Manager Bot

MTPro-Py is a fully shell-managed, environment-based, Python-powered MTProxy manager bot.  
It allows you to install MTProxy, manage secrets, create proxy links, and run the Telegram bot—all from a single terminal menu.

No coding is required for the end-user.  
Everything is automated through `main.sh`.

---

## 🚀 Features

- Clean **Python bot** (python-telegram-bot v20+)
- Works via **systemd services**
- MTProxy installation via **official core installer wrapper**
- `.env` configuration (no JSON, no hardcoding)
- SQLite database (`data/mtproxy-bot.db`)
- Interactive terminal menu for:
  - Installing dependencies  
  - Installing MTProxy  
  - Installing the bot  
  - Viewing logs  
  - Backups  
- Easy folder-based cleanup  
- Fully isolated installation inside a single directory

---

## 📦 Installation (Server)

### 1️⃣ Create isolated folder

```bash
sudo mkdir -p /opt/MTPro-Py
cd /opt/MTPro-Py
````

### 2️⃣ Clone your GitHub repository

Replace `YOUR_USERNAME/YOUR_REPO` with your repo:

```bash
sudo git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git .
```

### 3️⃣ Make launcher executable and run it

```bash
sudo chmod +x main.sh
sudo ./main.sh
```

`main.sh` will automatically:

* Prepare executable scripts
* Load the manager
* Open the interactive installation menu

---

## 📁 Project Structure

```
MTPro-Py/
  .env
  .gitignore
  main.sh
  mtpro_py_manager.sh
  mtproxy.sh
  prereq.sh
  pybot.sh
  system.sh
  README.md

  bot/
    bot.py
    config.py
    db.py
    mtproxy_manager.py
    utils.py
    __init__.py

  scripts/
    install_mtproxy_core.sh
    setup_pybot.sh

  data/
    mtproxy-bot.db   (ignored in Git)
```

---

## ⚙️ Configuration — `.env`

The project uses an environment file for all configuration.

Example:

```env
BOT_TOKEN=123456:ABC-your-bot-token
OWNER_ID=123456789
ADMIN_IDS=123456789,987654321

MTPROXY_SERVICE_NAME=MTProxy
MTPROXY_PORT=443
MTPROXY_TLS_DOMAIN=mydomain.com

DB_PATH=data/mtproxy-bot.db
```

### Explanation:

| Variable               | Description                          |
| ---------------------- | ------------------------------------ |
| `BOT_TOKEN`            | Bot token from BotFather             |
| `OWNER_ID`             | Telegram numeric ID of the bot owner |
| `ADMIN_IDS`            | Comma-separated admin IDs            |
| `MTPROXY_SERVICE_NAME` | systemd service name for MTProxy     |
| `MTPROXY_PORT`         | MTProxy port                         |
| `MTPROXY_TLS_DOMAIN`   | Optional TLS domain (can be empty)   |
| `DB_PATH`              | SQLite DB file used by the bot       |

If `.env` does not exist, `setup_pybot.sh` will generate a template automatically.

---

## 🖥️ Using the Menu

Any time you want to manage the bot or MTProxy:

```bash
cd /opt/MTPro-Py
sudo ./main.sh
```

### Available Menu Options (current version)

* **[1] Install prerequisites**
  Installs Python3, venv, pip3, git, curl, etc.

* **[2] Show prerequisites status**

* **[3] Install MTProxy**
  Runs the official MTProxy installer wrapper.

* **[4] Show MTProxy status**

* **[5] Install/Update Python bot**
  Creates venv, installs dependencies, configures systemd.

* **[6] Show Python bot status**

* **[7] Logs (bot / MTProxy)**

* **[8] Backup (`.env` + DB)**

* **[0] Exit**

Future versions will include:

* Advanced Bot Menu
* Proxy Settings Menu
* Cleanup Menu

---

## 🔄 Updating from GitHub

Whenever you push updates to your repo:

```bash
cd /opt/MTPro-Py
sudo git pull --ff-only
sudo chmod +x main.sh
sudo ./main.sh
```

Or use:

```bash
sudo ./system.sh update-repo
```

(if the directory is a git repo)

---

## 🧹 Cleanup / Uninstall (Manual for Now)

Full automated uninstall will be added later.
For now, to remove everything:

### 1️⃣ Stop and disable bot:

```bash
sudo systemctl stop mtprobot
sudo systemctl disable mtprobot
```

### 2️⃣ Stop & disable MTProxy (optional):

```bash
sudo systemctl stop MTProxy
sudo systemctl disable MTProxy
```

### 3️⃣ Delete the entire folder:

```bash
sudo rm -rf /opt/MTPro-Py
```

Everything is isolated inside this directory, so deleting it removes the entire installation cleanly.

---

## 🛣 Roadmap

* Rewrite `config.py` to fully support `.env` (in progress)
* Advanced interactive Telegram UI ( buttons, pagination, tags )
* Owner/Admin management system
* Proxy list UI improvements
* Full Cleanup Menu (automated uninstall)
* Multi-server support

---

## 📝 License

This project is provided for educational and personal management use.

---
