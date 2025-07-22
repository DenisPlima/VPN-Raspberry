#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # Sem cor

echo "=== Habilitando o SSH no Raspberry Pi - Sanfer VPN ==="

# Verificar se o serviço SSH existe
if ! systemctl list-unit-files | grep -q '^ssh.service'; then
    echo -e "${RED}Serviço SSH não encontrado no sistema. Abortando.${NC}"
    exit 1
fi

# Verificar se o SSH está habilitado
if systemctl is-enabled ssh --quiet; then
    echo -e "${GREEN}O SSH já está habilitado no sistema.${NC}"
else
    echo "SSH não está habilitado. Habilitando agora..."

    # Habilitar o serviço SSH
    systemctl enable ssh

    # Iniciar o serviço SSH
    systemctl start ssh

    echo -e "${GREEN}SSH foi habilitado e iniciado com sucesso!${NC}"
fi

# Verificar o status do SSH
echo "Verificando o status do SSH..."
if systemctl is-active ssh --quiet; then
    echo -e "${GREEN}SSH está ativo.${NC}"
else
    echo -e "${RED}SSH não está ativo.${NC}"
fi

# Confirmar a conexão SSH
echo "Você pode acessar o Raspberry Pi via SSH utilizando o IP local ou Tailscale."

