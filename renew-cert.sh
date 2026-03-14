#!/bin/bash

set -e

# 証明書更新スクリプト
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "証明書更新スクリプト"
echo "=========================================="
echo ""

# 現在の証明書情報を表示
CERTS_DIR="./certs"
DOMAIN_DIR="example.com"

if [ -f "$CERTS_DIR/$DOMAIN_DIR.crt" ]; then
    echo "現在の証明書情報:"
    openssl x509 -in "$CERTS_DIR/$DOMAIN_DIR.crt" -noout -dates -subject
    echo ""
fi

# 新しい証明書を生成
echo "新しい証明書を生成しています..."
./generate-cert.sh

echo ""
echo "Docker を再起動しています..."
docker compose restart nginx

echo ""
echo "=========================================="
echo "証明書更新完了！"
echo "=========================================="
echo ""

# 更新後の証明書情報を表示
echo "更新後の証明書情報:"
openssl x509 -in "$CERTS_DIR/$DOMAIN_DIR.crt" -noout -dates -subject
