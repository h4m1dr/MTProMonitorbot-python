# comments MUST be English only
import os
from dataclasses import dataclass
from typing import List


@dataclass
class Config:
    bot_token: str
    owner_id: int
    allowed_admin_ids: List[int]
    db_path: str
    mtproxy_service_name: str
    mtproxy_config_path: str

    @classmethod
    def from_env(cls) -> "Config":
        # BOT_TOKEN is required
        bot_token = os.getenv("BOT_TOKEN", "").strip()
        if not bot_token:
            raise RuntimeError("BOT_TOKEN is not set in environment (.env)")

        # OWNER_ID is required (Telegram numeric id)
        owner_str = os.getenv("OWNER_ID", "").strip()
        if not owner_str.isdigit():
            raise RuntimeError("OWNER_ID is not a valid integer in .env")
        owner_id = int(owner_str)

        # OPTIONAL: extra admin IDs, comma-separated
        raw_admins = os.getenv("ADMIN_IDS", "").strip()
        allowed_admin_ids: List[int] = []
        if raw_admins:
            for part in raw_admins.split(","):
                part = part.strip()
                if part.isdigit():
                    allowed_admin_ids.append(int(part))

        # always include owner in allowed list
        if owner_id not in allowed_admin_ids:
            allowed_admin_ids.append(owner_id)

        db_path = os.getenv("DB_PATH", "./data/mtproxy-bot.db").strip()
        mtproxy_service_name = os.getenv("MTPROXY_SERVICE_NAME", "MTProxy.service").strip()
        mtproxy_config_path = os.getenv("MTPROXY_CONFIG_PATH", "/opt/MTProxy/objs/bin/mtconfig.conf").strip()

        return cls(
            bot_token=bot_token,
            owner_id=owner_id,
            allowed_admin_ids=allowed_admin_ids,
            db_path=db_path,
            mtproxy_service_name=mtproxy_service_name,
            mtproxy_config_path=mtproxy_config_path,
        )
