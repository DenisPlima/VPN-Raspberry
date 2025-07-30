#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/modem_qualcomm_networkmode.log"
MAX_ATTEMPTS=15
SLEEP_TIME=2

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

log() { echo -e "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"; }
log_warn() { log "${YELLOW}⚠ $1${NC}"; }
log_error() { log "${RED}✖ $1${NC}"; }
log_success() { log "${GREEN}✔ $1${NC}"; }

check_dependencies() {
  log "Verificando pacotes necessários..."
  sudo apt-get update -qq
  sudo apt-get install -y usbutils iproute2 dhcpcd5
}

wait_for_interface() {
  log "Aguardando interface de rede do modem (wwan0, usb0, etc)..."
  for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
    IFACE=$(ip -brief link | awk '{print $1}' | grep -E '^wwan[0-9]+|^usb[0-9]+' || true)
    if [[ -n "$IFACE" ]]; then
      log_success "Interface detectada: $IFACE"
      return
    fi
    log "Tentativa $attempt/$MAX_ATTEMPTS..."
    sleep "$SLEEP_TIME"
  done
  log_error "Nenhuma interface de rede do modem foi detectada."
  exit 1
}

start_connection() {
  log "Solicitando IP via DHCP para interface $IFACE..."
  sudo dhclient -v "$IFACE" || {
    log_warn "Falha ao obter IP. Tentando continuar assim mesmo..."
  }
}

test_connection() {
  log "Testando ping para 8.8.8.8..."
  if ping -c 3 -W 2 8.8.8.8 >/dev/null; then
    log_success "Conexão com a internet OK via IP."
  else
    log_warn "Sem resposta de 8.8.8.8."
  fi

  log "Testando DNS (google.com)..."
  if ping -c 2 -W 2 google.com >/dev/null; then
    log_success "Resolução DNS OK."
  else
    log_warn "Falha na resolução de DNS."
  fi
}

main() {
  log "🟢 Iniciando conexão com modem Qualcomm via interface de rede..."
  check_dependencies
  wait_for_interface
  start_connection
  test_connection
  log_success "Script finalizado."
}

main
