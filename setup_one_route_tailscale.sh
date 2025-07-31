#!/bin/bash
set -euo pipefail

echo "=== Configuração de Rede Industrial com Tailscale (sem gateway) ==="

# [1] Dados da sub-rede industrial
read -p "Digite a sub-rede INDUSTRIAL (ex: 192.168.0.0/24): " REDE_INDUSTRIAL
read -p "Digite o final do IP da Raspberry nessa rede (ex: 250): " FINAL_IP_INDUSTRIAL

# [2] Interface de rede
read -p "Digite o nome da interface de rede (padrão: eth0): " INTERFACE
INTERFACE=${INTERFACE:-eth0}

# [3] Cálculo do IP
BASE_INDUSTRIAL=$(echo "$REDE_INDUSTRIAL" | cut -d'/' -f1 | awk -F. '{print $1"."$2"."$3}')
MASK_INDUSTRIAL=$(echo "$REDE_INDUSTRIAL" | cut -d'/' -f2)
IP1="$BASE_INDUSTRIAL.$FINAL_IP_INDUSTRIAL"

echo "✅ IP Industrial: $IP1/$MASK_INDUSTRIAL"

# [4] Configurar IP fixo via dhcpcd.conf (sem gateway)
echo "🔧 Configurando IP fixo via /etc/dhcpcd.conf (sem gateway)..."
if [[ -f /etc/dhcpcd.conf ]]; then
  sudo sed -i "/^interface $INTERFACE/,+5d" /etc/dhcpcd.conf
  echo "
interface $INTERFACE
static ip_address=$IP1/$MASK_INDUSTRIAL
nogateway
" | sudo tee -a /etc/dhcpcd.conf > /dev/null
  echo -e "\033[0;32m✅ IP fixo salvo com sucesso no dhcpcd.conf\033[0m"
else
  echo -e "\033[0;31m[ERRO] Arquivo /etc/dhcpcd.conf não encontrado.\033[0m"
  exit 1
fi

# [5] Ativar roteamento IP (caso use Tailscale para acesso à rede industrial)
echo "🔄 Ativando roteamento IP (ip_forward)..."
sudo sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf > /dev/null
sudo sysctl -p

# [6] Instalar Tailscale (se necessário)
if ! command -v tailscale &> /dev/null; then
  echo "⬇️ Instalando Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh
fi

# [7] Subir Tailscale com rota anunciada
echo "🚀 Subindo Tailscale com anúncio da rota: $REDE_INDUSTRIAL"
sudo tailscale up --advertise-routes="$REDE_INDUSTRIAL" --accept-dns=false

echo -e "\033[0;32m✅ Configuração finalizada com sucesso!\033[0m"
echo "Acesse https://login.tailscale.com/admin/machines para aprovar a rota anunciada."
echo "ℹ️ Reinicie a Raspberry Pi para aplicar a nova configuração de IP."
