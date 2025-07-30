#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/modem_qualcomm_setup.log"
SLEEP_TIME=2
MAX_ATTEMPTS=10

# Cores
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

log() { echo -e "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"; }
log_success() { echo -e "${GREEN}[$(date '+%H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"; }
log_warn() { echo -e "${YELLOW}[$(date '+%H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"; }
log_error() { echo -e "${RED}[$(date '+%H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"; }

check_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
    log_error "Execute o script como root (sudo)."
    exit 1
  fi
}

install_packages() {
  local pkgs=(usb-modeswitch modemmanager)
  for pkg in "${pkgs[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      log "Instalando $pkg..."
      apt install -y "$pkg"
    else
      log_success "$pkg já instalado."
    fi
  done
}

apply_modeswitch() {
  log "Executando usb_modeswitch para 05c6:f00e (Qualcomm)..."
  usb_modeswitch -v 0x05c6 -p 0xf00e \
    -M "5553424312345678000000000000061b000000020000000000000000000000" -W
  sleep 10
}

wait_for_modem() {
  local attempt=1
  while (( attempt <= MAX_ATTEMPTS )); do
    local modem
    modem=$(mmcli -L | grep -oE '/org/freedesktop/ModemManager1/Modem/[0-9]+' || true)
    if [[ -n "$modem" ]]; then
      echo "$modem"
      return 0
    fi
    log_warn "Tentativa $attempt/$MAX_ATTEMPTS: aguardando modem aparecer..."
    sleep "$SLEEP_TIME"
    ((attempt++))
  done
  return 1
}

select_operadora() {
  echo "Selecione sua operadora:"
  PS3="Digite o número da operadora: "
  select op in Vivo Claro Tim Oi; do
    case $op in
      Vivo) APN="zap.vivo.com.br"; break ;;
      Claro) APN="claro.com.br"; break ;;
      Tim) APN="tim.br"; break ;;
      Oi) APN="gprs.oi.com.br"; break ;;
      *) echo "Opção inválida." ;;
    esac
  done
}

connect_modem() {
  log "Tentando conectar com APN: $APN"
  if mmcli -m "$MODEM_PATH" --simple-connect="apn=$APN"; then
    log_success "Conexão realizada com sucesso."
  else
    log_warn "Falha ao conectar. Verifique sinal ou chip."
  fi
}

test_connection() {
  log "Testando ping para 8.8.8.8..."
  if ping -c 3 8.8.8.8 &>/dev/null; then
    log_success "Conectividade IP OK."
  else
    log_warn "Ping para IP falhou."
  fi

  log "Testando DNS (ping para google.com)..."
  if ping -c 3 google.com &>/dev/null; then
    log_success "Resolução DNS OK."
  else
    log_warn "Falha na resolução DNS."
  fi
}

main() {
  touch "$LOG_FILE"
  chmod 644 "$LOG_FILE"

  check_root
  install_packages
  apply_modeswitch

  MODEM_PATH=$(wait_for_modem)
  if [[ -z "$MODEM_PATH" ]]; then
    log_error "Modem não detectado após usb_modeswitch. Encerrando."
    exit 1
  fi

  log_success "Modem detectado em $MODEM_PATH"

  select_operadora
  connect_modem
  test_connection

  log_success "Configuração concluída."
}

main "$@"
