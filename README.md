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
├─ docker/
│   ├─ nginx/
│   │   ├─ Dockerfile
│   │   └─ default.conf
│   ├─ php/
│   │   └─ Dockerfile
│   ├─ mysql/
│   │   └─ Dockerfile（必要に応じて配置）
│   └─ redis/
│       └─ Dockerfile（必要に応じて配置）
├─ storage/
│   ├─ db/
│   └─ logs/
├─ src/
│   └─ public/
│        └─ index.php
└─ scripts/
    └─ setup.sh
```

---

## セットアップ手順

### 1. 初期ディレクトリ作成

```
sh ./scripts/setup.sh
```

### 2. 例えば Laravel を使う場合

`src/` 配下に Laravel をインストールする例です。

```
cd src
composer create-project laravel/laravel .
```

その後、`src/public/` が Web root として nginx から参照されます。

---

## 起動

```
docker compose up --build -d
```

## 停止

```
docker compose down
```

## PHP へのアクセス

```
http://localhost:8080/
```

---

## MySQL

```
docker compose exec mysql bash
mysql -u root -p
```

---

## PHP → MySQL 接続例

src/public/test_mysql.php:

```php
<?php

try {
    $pdo = new PDO(
        'mysql:host=mysql;dbname=app;charset=utf8mb4',
        'root',
        'rootpassword',
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
永続化ボリュームは削除しません。

    make down

### clean
この docker-compose プロジェクトで生成されたリソースのみを削除します。
以下が削除対象です：
- コンテナ
- ネットワーク
- このプロジェクト内でビルドされたイメージ
- このプロジェクト内で作成されたボリューム

他プロジェクトには影響しません。

    make clean

### all-clean
Docker 全体に対して `docker system prune -f` を実行します。
以下が削除されます：
- 停止中のすべてのコンテナ
- 未使用のネットワーク
- 参照されていないイメージ
- Build キャッシュ

複数の Docker プロジェクトを扱っている場合は注意してください。

    make all-clean

### disintegrate
Docker 全体に対して最も強力なクリーンアップを実行します。
以下が削除対象です：
- 停止中のすべてのコンテナ
- 未使用のネットワーク
- 未使用のイメージ（すべて）
- 未使用のボリューム（すべて）

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
- `storage/` は永続化領域です（DB・ログなど）。
