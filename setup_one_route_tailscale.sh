#!/bin/bash
set -euo pipefail

echo "=== Configuração de Rede Industrial com Tailscale ==="

# [1] Dados da sub-rede industrial
read -p "Digite a sub-rede INDUSTRIAL (ex: 192.168.0.0/24): " REDE_INDUSTRIAL
read -p "Digite o final do IP da Raspberry nessa rede (ex: 250): " FINAL_IP_INDUSTRIAL

# [2] Interface de rede
read -p "Digite o nome da interface de rede (padrão: eth0): " INTERFACE
INTERFACE=${INTERFACE:-eth0}

# [3] Cálculo do IP industrial
BASE_INDUSTRIAL=$(echo "$REDE_INDUSTRIAL" | cut -d'/' -f1 | awk -F. '{print $1"."$2"."$3}')
MASK_INDUSTRIAL=$(echo "$REDE_INDUSTRIAL" | cut -d'/' -f2)
IP1="$BASE_INDUSTRIAL.$FINAL_IP_INDUSTRIAL"

echo "✅ IP Industrial: $IP1/$MASK_INDUSTRIAL"

# [4] Criar script de boot para aplicar IP fixo
echo "🛠 Criando script de boot para IP fixo..."
BOOT_SCRIPT="/usr/local/bin/set_industrial_ip.sh"
echo "#!/bin/bash
ip addr add $IP1/$MASK_INDUSTRIAL dev $INTERFACE
" | sudo tee "$BOOT_SCRIPT" > /dev/null
sudo chmod +x "$BOOT_SCRIPT"

# [5] Adicionar ao crontab do root (@reboot)
echo "⏱ Garantindo entrada @reboot no crontab..."
CRONTAB_LINE="@reboot $BOOT_SCRIPT"
( sudo crontab -l 2>/dev/null | grep -Fxv "$CRONTAB_LINE" || true ; echo "$CRONTAB_LINE" ) | sudo crontab -

# [6] Ativar IP forwarding (caso necessário para acesso remoto à rede industrial)
echo "🔄 Ativando roteamento IP..."
sudo sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# [7] Instalar Tailscale (se necessário)
if ! command -v tailscale &> /dev/null; then
    echo "⬇️ Instalando Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
fi

# [8] Subir Tailscale com anúncio da rota industrial
echo "🚀 Subindo Tailscale com rota para: $REDE_INDUSTRIAL"
sudo tailscale up --advertise-routes="$REDE_INDUSTRIAL" --accept-dns=false

echo -e "\033[0;32m✅ Configuração finalizada!\033[0m"
echo "Acesse https://login.tailscale.com/admin/machines para aprovar a rota."
echo "ℹ️ Reinicie a Raspberry Pi para aplicar totalmente a configuração."
