#!/bin/bash

set -e

echo "=== Instalando e configurando o Tailscale no Raspberry Pi ==="

# Verificar se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "Este script deve ser executado como root. Use: sudo $0"
  exit 1
fi

# Atualizar apenas os índices de pacotes
echo "Atualizando lista de pacotes..."
apt update

# Verificar se o Tailscale já está instalado
if command -v tailscale >/dev/null 2>&1; then
  echo "Tailscale já está instalado. Pulando a instalação."
else
  echo "Instalando o Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh
fi

# Ativar o serviço do Tailscale
echo "Habilitando o serviço do Tailscale..."
systemctl enable --now tailscaled

# Iniciar o Tailscale com autenticação (necessária apenas na primeira vez)
echo "Iniciando o Tailscale (pode ser necessário abrir o link de autenticação)..."
tailscale up

# Mostrar o status atual
echo "Verificando o status do Tailscale..."
tailscale status

# Criar um cron job para atualizar o Tailscale semanalmente
echo "Configurando atualização semanal automática do Tailscale via cron..."

# Adiciona cron no root para atualizar e registrar em log
CRON_JOB="0 3 * * 0 /usr/bin/apt update && /usr/bin/apt install --only-upgrade -y tailscale >> /var/log/tailscale_update.log 2>&1"
(crontab -l 2>/dev/null | grep -v 'tailscale_update' ; echo "$CRON_JOB # tailscale_update") | crontab -

echo "Tailscale instalado e configurado com sucesso!"
echo "Atualizações semanais programadas aos domingos às 3h da manhã."
echo "Você pode verificar o status com: sudo tailscale status"
