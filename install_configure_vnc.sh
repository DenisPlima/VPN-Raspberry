#!/bin/bash

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Sem cor

echo -e "${YELLOW}🔄 Atualizando lista de pacotes...${NC}"
sudo apt-get update -y

echo -e "${GREEN}📦 Instalando RealVNC Server (se não estiver instalado)...${NC}"
sudo apt-get install -y realvnc-vnc-server realvnc-vnc-viewer

echo -e "${GREEN}⚙️ Ativando VNC via raspi-config...${NC}"
sudo raspi-config nonint do_vnc 0

echo -e "${GREEN}🚀 Habilitando e iniciando o serviço VNC...${NC}"
sudo systemctl enable vncserver-x11-serviced.service
sudo systemctl start vncserver-x11-serviced.service

echo -e "${GREEN}🔍 Verificando status do serviço VNC...${NC}"
sudo systemctl status vncserver-x11-serviced.service --no-pager

echo -e "${GREEN}✅ VNC instalado e configurado! Use seu usuário e senha do Raspberry Pi para acessar.${NC}"
