#!/bin/bash
set -euo pipefail

echo "=== Configuração de Roteamento Duplo com Tailscale e IPs Persistentes ==="

# [1] Dados da sub-rede industrial
read -p "Digite a sub-rede INDUSTRIAL (ex: 192.168.0.0/24): " REDE_INDUSTRIAL
read -p "Digite o final do IP da Raspberry nessa rede (ex: 250): " FINAL_IP_INDUSTRIAL

# [2] Dados da sub-rede com Internet
read -p "Digite a sub-rede INTERNET (ex: 192.168.1.0/24): " REDE_INTERNET
read -p "Digite o final do IP da Raspberry nessa rede (ex: 251): " FINAL_IP_INTERNET
read -p "Digite o GATEWAY da rede de INTERNET (ex: 192.168.1.1): " GATEWAY
read -p "Digite os DNS (ex: 8.8.8.8 1.1.1.1): " DNS

# [3] Interface de rede
read -p "Digite o nome da interface de rede (padrão: eth0): " INTERFACE
INTERFACE=${INTERFACE:-eth0}

# [4] Calcula os IPs
BASE_INDUSTRIAL=$(echo "$REDE_INDUSTRIAL" | cut -d'/' -f1 | awk -F. '{print $1"."$2"."$3}')
BASE_INTERNET=$(echo "$REDE_INTERNET" | cut -d'/' -f1 | awk -F. '{print $1"."$2"."$3}')
MASK_INDUSTRIAL=$(echo "$REDE_INDUSTRIAL" | cut -d'/' -f2)
MASK_INTERNET=$(echo "$REDE_INTERNET" | cut -d'/' -f2)
IP1="$BASE_INDUSTRIAL.$FINAL_IP_INDUSTRIAL"
IP2="$BASE_INTERNET.$FINAL_IP_INTERNET"

echo "✅ IP Industrial: $IP1/$MASK_INDUSTRIAL"
echo "✅ IP Internet: $IP2/$MASK_INTERNET (com gateway $GATEWAY)"

# [5] Configura IP principal no /etc/dhcpcd.conf
echo "🔧 Configurando IP da Internet em /etc/dhcpcd.conf..."
sudo sed -i "/^interface $INTERFACE/,+5d" /etc/dhcpcd.conf
echo "
interface $INTERFACE
static ip_address=$IP2/$MASK_INTERNET
static routers=$GATEWAY
static domain_name_servers=$DNS
" | sudo tee -a /etc/dhcpcd.conf

# [6] Cria script para aplicar IP secundário no boot
echo "🛠 Criando script de boot para IP secundário ($IP1/$MASK_INDUSTRIAL)..."
BOOT_SCRIPT="/usr/local/bin/set_secondary_ip.sh"
echo "#!/bin/bash
ip addr add $IP1/$MASK_INDUSTRIAL dev $INTERFACE
" | sudo tee "$BOOT_SCRIPT"
sudo chmod +x "$BOOT_SCRIPT"

# [7] Ativa script no @reboot (crontab root)
echo "⏱ Adicionando script ao crontab do root para rodar no boot..."
(sudo crontab -l 2>/dev/null | grep -v "$BOOT_SCRIPT"; echo "@reboot $BOOT_SCRIPT") | sudo crontab -

# [8] Ativa IP forwarding
echo "🔄 Ativando roteamento IP..."
sudo sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# [9] Configura NAT
echo "🌐 Configurando NAT entre redes..."
sudo iptables -t nat -A POSTROUTING -o "$INTERFACE" -j MASQUERADE
sudo apt-get install -y iptables-persistent
sudo netfilter-persistent save
sudo netfilter-persistent reload

# [10] Instala Tailscale se necessário
if ! command -v tailscale &> /dev/null; then
    echo "⬇️ Instalando Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
fi

# [11] Sobe o Tailscale com rotas
echo "🚀 Subindo Tailscale com rotas para:"
echo "🔹 $REDE_INDUSTRIAL"
echo "🔹 $REDE_INTERNET"
sudo tailscale up --advertise-routes="$REDE_INDUSTRIAL","$REDE_INTERNET" --accept-dns=false

echo "✅ Finalizado!"
echo "Acesse https://login.tailscale.com/admin/machines e aprove as rotas anunciadas."
echo "ℹ️ Reinicie a Raspberry para aplicar as mudanças de IP."
