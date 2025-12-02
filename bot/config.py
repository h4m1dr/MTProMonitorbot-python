token = os.getenv("BOT_TOKEN", "")
owner = int(os.getenv("OWNER_ID", "0"))
admin_ids = os.getenv("ADMIN_IDS")
...
service = os.getenv("MTPROXY_SERVICE_NAME", "MTProxy")
db_path = os.getenv("DB_PATH") or BASE_DIR/data/mtproxy-bot.db
