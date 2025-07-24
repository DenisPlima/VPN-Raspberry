#!/bin/bash
set -euo pipefail

# === CONFIG ===
WORKDIR="/tmp/sanfer_installer"
LOG_DIR="$WORKDIR/logs"
COLOR_BLUE='\033[1;34m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m'

check_root() {
  if [[ "$EUID" -ne 0 ]]; then
    echo -e "${COLOR_RED}Este script deve ser executado como root.${COLOR_NC}"
    exit 1
  fi
}

pause() {
  echo -e "${COLOR_YELLOW}"
  read -p "Pressione Enter para continuar..." key
  echo -e "${COLOR_NC}"
}

check_dependencies() {
  local deps=(bash iptables curl tar base64 ping)
  for cmd in "${deps[@]}"; do
    if ! command -v "$cmd" >/dev/null; then
      echo -e "${COLOR_RED}Dependência ausente: $cmd${COLOR_NC}"
      exit 1
    fi
  done
}

check_connectivity() {
  if ! ping -c1 -W1 8.8.8.8 >/dev/null 2>&1; then
    echo -e "${COLOR_RED}Sem conexão com a internet.${COLOR_NC}"
    exit 1
  fi
}

extract_scripts() {
  echo -e "${COLOR_BLUE}🔍 Extraindo scripts para $WORKDIR...${COLOR_NC}"
  mkdir -p "$WORKDIR" "$LOG_DIR"
  tail -n +73 "$0" | base64 -d | tar -xz -C "$WORKDIR"
  chmod +x "$WORKDIR"/*.sh
}

run_script() {
  local name=$1
  echo -e "${COLOR_GREEN}▶ Executando $name...${COLOR_NC}"
  bash "$WORKDIR/$name" | tee "$LOG_DIR/${name%.sh}.log"
  echo -e "${COLOR_GREEN}✔ $name finalizado.${COLOR_NC}"
  pause
}

menu() {
  while true; do
    clear
    echo -e "${COLOR_BLUE}=========== INSTALADOR SANFER - MENU ===========${COLOR_NC}"
    echo "  ✔ Setup completo para Raspberry Pi via terminal"
    echo "-----------------------------------------------"
    echo "1) Habilitar SSH"
    echo "2) Configurar Modem 4G"
    echo "3) Instalar e configurar Tailscale"
    echo "4) Configurar Rotas IP Duplas com Tailscale"
    echo "5) Executar instalação completa (todas etapas)"
    echo "0) Sair"
    echo -n "Escolha uma opção: "
    read opt

    case "$opt" in
      1) run_script enable_ssh.sh ;;
      2) run_script modem_4g_setup.sh ;;
      3) check_connectivity; run_script install_configure_tailscale.sh ;;
      4) run_script setup_dual_routes_tailscale.sh ;;
      5)
        run_script enable_ssh.sh
        run_script modem_4g_setup.sh
        check_connectivity
        run_script install_configure_tailscale.sh
        run_script setup_dual_routes_tailscale.sh
        ;;
      0) echo "Saindo..."; exit 0 ;;
      *) echo -e "${COLOR_RED}Opção inválida.${COLOR_NC}"; pause ;;
    esac
  done
}

# Execução principal
check_root
check_dependencies
extract_scripts
menu

exit 0

# === ARQUIVOS EMBUTIDOS ===
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
