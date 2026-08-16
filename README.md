# Docker App Skeleton

開発用のシンプルな Docker ベース環境です。  
PHP（php-fpm）・nginx・MySQL・Redis を含む基本構成を提供し、  
任意の PHP フレームワーク（Laravel / Slim / Plain PHP など）を `src/` に配置して利用できます。

このリポジトリは、自分用の開発テンプレートとして作成したものです。

---

## セットアップ

インストールは以下のようにします。

```bash
composer create-project gallu/docker-app-skeleton [my-app-name]
```

---

## 構成

```
/
├─ docker-compose.yml
├─ .env.sample
├─ docker/
│   ├─ nginx/
│   │   ├─ Dockerfile
│   │   └─ default.conf
│   ├─ php/
│   │   ├─ Dockerfile
│   │   └─ php.ini
│   └─ mysql/
│       └─ init/
│           └─ init.sql
├─ storage/
│   ├─ db/          # bind mount に切り替えたときに使用
│   └─ logs/
├─ src/
│   └─ public/
│        └─ index.php
└─ scripts/
    └─ setup.sh
```

MySQL / Redis は公式イメージを compose の `image:` で使います。PHP / nginx だけ Dockerfile があります。

---

## セットアップ手順

### 1. 初期ディレクトリ作成

```
sh ./scripts/setup.sh
```

### 2. 環境変数ファイルの作成

```
cp .env.sample .env
```

`.env` の `COMPOSE_PROJECT_NAME` と `WEB_PORT` を、必要に応じて変更してください。  
`WEB_PORT` が未設定だと `docker compose` はエラーになります。

### 3. 例えば Laravel を使う場合

`src/` 配下に Laravel をインストールする例です。

```
cd src
composer create-project laravel/laravel .
```

その後、`src/public/` が Web root として nginx から参照されます。

アプリ側の接続例（Laravel の `.env` など）:

- `DB_HOST=mysql`
- `DB_DATABASE=app`
- `DB_USERNAME=app`
- `DB_PASSWORD=app`
- `REDIS_HOST=redis`
- `APP_URL=http://localhost:<WEB_PORT>`

テスト用 DB は `app_testing` です。`DB_USERNAME=app` / `DB_PASSWORD=app` で入れます。

---

## 起動

```
docker compose up --build -d
```

または `make up`。

## 停止

```
docker compose down
```

または `make down`。named volume `mysql_data` は消えません。

## PHP へのアクセス

```
http://localhost:<WEB_PORT>/
```

`<WEB_PORT>` は `.env` で設定した値です。

---

## MySQL

```
docker compose exec mysql bash
mysql -u root -p
```

root のパスワードは `root` です。アプリから繋ぐ場合は `app` / `app` を使ってください。

通常の DB は `app`、テスト用 DB は `app_testing` です。  
`app_testing` は named volume が空の **初回起動時** に `docker/mysql/init/init.sql` で作成します。公式イメージは datadir が空のときだけ `/docker-entrypoint-initdb.d` を実行します。コンテナを作り直すたびに走るわけではありません。

既存の volume がある環境では、次を一度だけ実行してください。

```bash
docker compose exec mysql mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS app_testing; GRANT ALL PRIVILEGES ON app_testing.* TO 'app'@'%';"
```

---

## PHP → MySQL 接続例

src/public/test_mysql.php:

```php
<?php

try {
    $pdo = new PDO(
        'mysql:host=mysql;dbname=app;charset=utf8mb4',
        'app',
        'app',
        [ PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION ]
    );

    echo "OK: Connected to MySQL\n";
} catch (PDOException $e) {
    echo "NG: " . $e->getMessage();
}
```

---

## Redis

```php
<?php
$redis = new Redis();
$redis->connect('redis', 6379);
echo "PING: " . $redis->ping();
```

---

## Makefile Commands

開発環境の操作を簡略化するため、いくつかのコマンドを Makefile として提供しています。
以下は各コマンドの動作内容と注意点です。

### up
コンテナ群をバックグラウンドで起動します。必要に応じてビルドも実行します。

    make up

### down
現在の docker-compose プロジェクトで起動中のコンテナを停止し、ネットワークを削除します。
named volume `mysql_data` は削除しません。

`make down` のあとに `docker volume prune` を実行すると、未使用になった `mysql_data` は消えることがあります。

    make down

### clean
この docker-compose プロジェクトで生成されたリソースのみを削除します。
以下が削除対象です：
- コンテナ
- ネットワーク
- このプロジェクト内でビルドされたイメージ
- このプロジェクト内で作成されたボリューム（named volume `mysql_data` を含む）

他プロジェクトには影響しません。

    make clean

### all-clean
Docker 全体に対して `docker system prune -f` を実行します。
以下が削除されます：
- 停止中のすべてのコンテナ
- 未使用のネットワーク
- 参照されていないイメージ
- Build キャッシュ

ボリュームは削除しません。複数の Docker プロジェクトを扱っている場合は注意してください。

    make all-clean

### disintegrate
Docker 全体に対して最も強力なクリーンアップを実行します。
以下が削除対象です：
- 停止中のすべてのコンテナ
- 未使用のネットワーク
- 未使用のイメージ（すべて）
- 未使用のボリューム（すべて、named volume `mysql_data` を含む）

Docker のあらゆる不要データを削除しますが、他プロジェクトのデータも含めて完全に消去されます。
慎重に利用してください。

    make disintegrate

---

## Composer 実行時の「detected dubious ownership」について

このプロジェクトでは、Docker コンテナ内で `composer` を実行すると、次のエラーが表示される場合があります。

    fatal: detected dubious ownership in repository at '/var/www/html'
    To add an exception for this directory, call:
        git config --global --add safe.directory /var/www/html

### 解決方法（Git が公式に提示している対処法）

Git がメッセージ内で指示しているとおり、次のコマンドをコンテナ内で実行してください。

    git config --global --add safe.directory /var/www/html

これにより、Git が `/var/www/html` を “安全なディレクトリ” と認識し、エラーが解消されます。

### なぜ発生するのか

Git には「所有者が異なるディレクトリを安全とみなさない」仕様があります。  
Docker の bind mount を利用している場合、ホスト側とコンテナ側で UID/GID が異なるため、Git が `/var/www/html` を “safe” と判断しません。

これは Git 自身の仕様であり、Docker bind mount を使う環境では一般的に発生します。

参考：
- `git help safe.directory` に Docker bind mount の例示があります。
- Docker bind mount は UID/GID を変換しません（Docker 公式ドキュメント）。

### 補足：Composer の挙動について

`composer.lock` が存在しない場合、Composer は `install` を実行しても内部的に `update` を実行します（Composer 公式ドキュメントによる仕様）。  
そのため、最初に `composer install` を実行した際は `update` と同様の動作になります。

---

## 注意事項

- `src/` は .gitignore 対象です。任意のアプリケーションを配置してください。
- 既定の DB 置き場は named volume `mysql_data` です。`storage/` はログ等です。既定では DB ファイルを置きません。
- bind mount（`./storage/db`）に戻す手順:
  1. `docker-compose.yml`: `./storage/db:/var/lib/mysql` のコメントを外し、`mysql_data:/var/lib/mysql` をコメントアウトする。末尾の `volumes: mysql_data` も使わない。
  2. `scripts/setup.sh`: `mkdir -p storage/db` のコメントを外す。
  3. `.gitignore` の `/storage/db/` ルールはそのまま。
- 切替時、named volume の中身は `storage/db` に自動移行しません。
- bind mount に戻すと `make clean` でも `storage/db` は残ります。
