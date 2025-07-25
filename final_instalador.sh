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

log() {
  echo -e "${COLOR_BLUE}[INFO] $*${COLOR_NC}"
}

log_success() {
  echo -e "${COLOR_GREEN}[OK] $*${COLOR_NC}"
}

log_warn() {
  echo -e "${COLOR_YELLOW}[AVISO] $*${COLOR_NC}"
}

log_error() {
  echo -e "${COLOR_RED}[ERRO] $*${COLOR_NC}" >&2
}

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

test_internet() {
  log "Testando conectividade (ping para 8.8.8.8)..."
  if ! ping -c 4 8.8.8.8 &>/dev/null; then
    log_error "Falha no ping para IP."
    return 1
  fi
  log_success "Ping para IP OK."

  log "Testando resolução DNS (ping para google.com)..."
  if ! ping -c 4 google.com &>/dev/null; then
    log_warn "Falha na resolução DNS."
    return 1
  fi
  log_success "Resolução DNS OK."
  return 0
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
  tail -n +100 "$0" | base64 -d | tar -xz -C "$WORKDIR"
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
    echo "Setup completo para Raspberry Pi via terminal"
    echo "-----------------------------------------------"
    echo "1) Habilitar SSH"
    echo "2) Configurar Modem 4G"
    echo "3) Instalar e configurar Tailscale"
    echo "4) Configurar Rotas IP Duplas com Tailscale"
    echo "5) Executar instalação completa (todas etapas)"
    echo "6) Checar conectividade"
    echo "0) Sair"
    echo -n "Escolha uma opção: "
    read -r opt

    case "$opt" in
      1) run_script enable_ssh.sh ;;
      2) run_script modem_4g_setup.sh ;;
      3) 
        check_connectivity
        run_script install_configure_tailscale.sh
        ;;
      4) run_script setup_dual_routes_tailscale.sh ;;
      5)
        run_script enable_ssh.sh
        run_script modem_4g_setup.sh
        check_connectivity
        run_script install_configure_tailscale.sh
        run_script setup_dual_routes_tailscale.sh
        ;;
      6) test_internet; pause ;;
      0)
        echo "Saindo..."
        exit 0
        ;;
      *)
        echo -e "${COLOR_RED}Opção inválida.${COLOR_NC}"
        pause
        ;;
    esac
  done
}

# Execução principal
check_root
check_dependencies
#extract_scripts
menu

exit 0


