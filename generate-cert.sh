#!/bin/bash

# 証明書生成スクリプト
DOMAIN="*.example.com"
DOMAIN_DIR="example.com"
CERTS_DIR="./certs"
DAYS=365
CONFIG_FILE="/tmp/cert.conf"

# ディレクトリが存在しない場合は作成
mkdir -p "$CERTS_DIR"

# 既存の証明書があればバックアップ
if [ -f "$CERTS_DIR/$DOMAIN_DIR.crt" ]; then
    echo "既存の証明書をバックアップしています..."
    mv "$CERTS_DIR/$DOMAIN_DIR.crt" "$CERTS_DIR/$DOMAIN_DIR.crt.bak"
    mv "$CERTS_DIR/$DOMAIN_DIR.key" "$CERTS_DIR/$DOMAIN_DIR.key.bak"
fi

# OpenSSL 設定ファイルを生成
cat > "$CONFIG_FILE" << EOFCONFIG
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = JP
ST = Tokyo
L = Tokyo
O = Organization
CN = $DOMAIN

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = *.example.com
DNS.2 = example.com
DNS.3 = growi.example.com
EOFCONFIG

# 自己署名ワイルドカード証明書を生成（SAN付き）
echo "自己署名ワイルドカード証明書を生成しています..."
openssl req -x509 -newkey rsa:2048 -keyout "$CERTS_DIR/$DOMAIN_DIR.key" -out "$CERTS_DIR/$DOMAIN_DIR.crt" \
    -days "$DAYS" -nodes -config "$CONFIG_FILE" -extensions v3_req

# 設定ファイルを削除
rm -f "$CONFIG_FILE"

echo "ワイルドカード証明書を生成しました:"
echo "  証明書: $CERTS_DIR/$DOMAIN_DIR.crt"
echo "  秘密鍵: $CERTS_DIR/$DOMAIN_DIR.key"
echo "  対象: $DOMAIN"
echo "  有効期限: $DAYS 日"
echo ""
echo "SAN 設定:"
openssl x509 -in "$CERTS_DIR/$DOMAIN_DIR.crt" -noout -text | grep -A 2 "Subject Alternative Name"