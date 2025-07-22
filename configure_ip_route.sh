#!/bin/bash

set -e

# === [1/8] Solicita a sub-rede ao usuário ===
read -p "Digite a sub-rede local a ser roteada (ex: 192.168.1.0/24): " REDE_LOCAL

# Validação simples da entrada
if [[ ! "$REDE_LOCAL" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
    echo "❌ Sub-rede inválida. Use o formato CIDR (ex: 192.168.1.0/24)."
    exit 1
fi

# === [2/8] Solicita o nome da interface ou usa padrão ===
read -p "Digite o nome da interface Ethernet (padrão: eth0): " INTERFACE
INTERFACE=${INTERFACE:-eth0}

echo "✅ Sub-rede definida como: $REDE_LOCAL"
echo "✅ Interface de rede: $INTERFACE"

# === [3/8] Extrai base do IP e máscara ===
IP_BASE=$(echo "$REDE_LOCAL" | cut -d'/' -f1)
MASK=$(echo "$REDE_LOCAL" | cut -d'/' -f2)
IP_PREFIX=$(echo "$IP_BASE" | awk -F. '{print $1"."$2"."$3}')
IP_ETH0="${IP_PREFIX}.250"

# === [4/8] Força a troca de IP na interface ===
echo "=== Configurando IP estático ${IP_ETH0}/${MASK} na interface $INTERFACE ==="
sudo dhclient -r $INTERFACE || true         # Libera DHCP se estiver em uso
sudo ip addr flush dev $INTERFACE           # Remove IPs anteriores
sudo ip addr add ${IP_ETH0}/${MASK} dev $INTERFACE
sudo ip link set $INTERFACE up              # Garante que a interface está ativa

# === [5/8] Habilita IP forwarding ===
echo "=== Habilitando IP forwarding ==="
sudo sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# === [6/8] Garante que o Tailscale está instalado ===
echo "=== Verificando instalação do Tailscale ==="
if ! command -v tailscale &> /dev/null; then
    echo "Tailscale não encontrado. Instalando..."
    curl -fsSL https://tailscale.com/install.sh | sh
else
    echo "Tailscale já está instalado."
fi

# === [7/8] Sobe o Tailscale com a rota anunciada ===
echo "=== Subindo o Tailscale com rota para $REDE_LOCAL ==="
sudo tailscale up --advertise-routes=$REDE_LOCAL --accept-dns=false

# === [8/8] Instrução final ===
echo "=== Rota anunciada! ==="
echo "Acesse https://login.tailscale.com/admin/machines e APROVE a rota $REDE_LOCAL."
echo "✅ Configuração completa!"
echo "Interface $INTERFACE agora está com o IP ${IP_ETH0}/${MASK} e a rota foi anunciada ao Tailscale."