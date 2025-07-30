#!/bin/bash
set -e

RULE_FILE="/etc/udev/rules.d/40-zte-modeswitch.rules"
VENDOR_ID="19d2"
PRODUCT_ID="0031"
MESSAGE="5553424312345678000000000000061b000000020000000000000000000000"

echo "[INFO] Criando regra udev para usb_modeswitch do modem ZTE (${VENDOR_ID}:${PRODUCT_ID})..."

sudo bash -c "cat > ${RULE_FILE}" <<EOF
SUBSYSTEM=="usb", ATTR{idVendor}=="${VENDOR_ID}", ATTR{idProduct}=="${PRODUCT_ID}", RUN+="/usr/sbin/usb_modeswitch -v 0x${VENDOR_ID} -p 0x${PRODUCT_ID} -M '${MESSAGE}' -I -W"
EOF

echo "[INFO] Regra criada em: ${RULE_FILE}"
echo "[INFO] Recarregando regras udev..."
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "[INFO] Tudo pronto. Agora remova e reconecte o modem ZTE."
echo "Depois execute: lsusb | grep ${VENDOR_ID} para verificar se o ID mudou de 0031 para algo como 2000."
