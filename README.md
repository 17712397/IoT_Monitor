# 手順
- PCシステム環境変数の設定 `FLASK_APP: superset`, `SUPERSET_CONFIG_PATH: 「superset_config.py格納のパス」`

### 残課題
・DBの日本語文字化け（seed_data.sql）

### 手順
- db/schema.sqlの構築
- db/seed_data.sqlの構築
- cmd `create database iot_monitor;`
- cmd `\c iot_monitor;`
- PS `psql -U postgres -d iot_monitor -f db/schema.sql`
- PS `psql -U postgres -d iot_monitor -f db/seed.sql`
