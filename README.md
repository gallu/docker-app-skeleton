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

## 注意事項

- `src/` は .gitignore 対象です。任意のアプリケーションを配置してください。
- `storage/` は永続化領域です（DB・ログなど）。
