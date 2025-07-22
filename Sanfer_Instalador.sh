#!/bin/bash

set -e

# Cores para saída
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sem cor

pause() {
  echo -e "${YELLOW}"
  read -p "Pressione Enter para continuar para o próximo passo..." key
  echo -e "${NC}"
}

check_script_exists() {
  if [[ ! -x "$1" ]]; then
    echo -e "${RED}Erro: Script '$1' não encontrado ou sem permissão de execução.${NC}"
    exit 1
  fi
}

echo -e "${BLUE}========================================"
echo -e "  SANFER - INSTALADOR AUTOMÁTICO"
echo -e "  Setup completo para Raspberry Pi"
echo -e "========================================${NC}"

# Verificar se está como root
if [[ "$EUID" -ne 0 ]]; then
  echo -e "${RED}Este script deve ser executado como root. Use: sudo ./sanfer_instalador.sh${NC}"
  exit 1
fi

echo -e "${GREEN}✔ Verificação de permissões OK.${NC}"

# Verificar scripts dependentes
check_script_exists "./enable_ssh.sh"
check_script_exists "./modem_4g_setup.sh"
check_script_exists "./install_configure_tailscale.sh"

echo
echo -e "${BLUE}🔧 Etapa 1: Habilitar o SSH no Raspberry Pi${NC}"
bash ./enable_ssh.sh

echo -e "${GREEN}✅ SSH configurado com sucesso.${NC}"
pause

echo
echo -e "${BLUE}🌐 Etapa 2: Configurar modem 4G com escolha da operadora${NC}"
bash ./modem_4g_setup.sh

echo -e "${GREEN}✅ Modem 4G configurado com sucesso.${NC}"
pause

echo
echo -e "${BLUE}🔒 Etapa 3: Instalar e configurar VPN Tailscale${NC}"
bash ./install_configure_tailscale.sh

echo -e "${GREEN}✅ Tailscale instalado e configurado com sucesso.${NC}"

echo
echo -e "${BLUE}🚀 Instalação finalizada com sucesso!"
echo -e "Todos os sistemas foram configurados e estão prontos para uso.${NC}"
