#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/modem_4g_setup.log"
MAX_ATTEMPTS=15
SLEEP_TIME=2

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
  local pkgs=(usb-modeswitch modemmanager ppp)
  for pkg in "${pkgs[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      log "Instalando $pkg..."
      apt install -y "$pkg"
    else
      log_success "$pkg já instalado."
    fi
  done
}

list_usb() {
  log "Dispositivos USB conectados:"
  lsusb | tee -a "$LOG_FILE"
}

detect_modem() {
  local modems
  modems=$(lsusb 2>/dev/null | grep -Ei "zte|huawei" || true)
  if [[ -z "$modems" ]]; then
    log_warn "Nenhum modem ZTE ou Huawei detectado via USB."
    echo
    read -p "Deseja tentar novamente? (s/n): " opcao
    if [[ "$opcao" =~ ^[sS]$ ]]; then
      list_usb
      echo -e "${YELLOW}Conecte o modem e pressione Enter para continuar...${NC}"
      read
      exec "$0"
    else
      log_error "Encerrando configuração do modem por ausência de hardware."
      exit 0
    fi
  fi
  log "Modems detectados:"
  echo "$modems" | tee -a "$LOG_FILE"
  echo "$modems" | head -n1
}

wait_for_modem() {
  local attempt=1
  while (( attempt <= MAX_ATTEMPTS )); do
    local modem_path
    modem_path=$(mmcli -L | grep -oE '/org/freedesktop/ModemManager1/Modem/[0-9]+' || true)
    if [[ -n "$modem_path" ]]; then
      echo "$modem_path"
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
  PS3="Digite o número da operadora e pressione Enter: "
  select op in Vivo Claro Tim Oi; do
    case $op in
      Vivo) OPERADORA="Vivo"; APN="zap.vivo.com.br"; break ;;
      Claro) OPERADORA="Claro"; APN="claro.com.br"; break ;;
      Tim) OPERADORA="Tim"; APN="tim.br"; break ;;
      Oi) OPERADORA="Oi"; APN="gprs.oi.com.br"; break ;;
      *) echo "Opção inválida. Tente novamente." ;;
    esac
  done
}

check_connection_status() {
  mmcli -m "$MODEM_PATH" | grep -i "status:" | awk '{print $2}' || echo "unknown"
}

try_connect() {
  local apn=$1
  log "Tentando conectar com APN: $apn"
  if ! mmcli -m "$MODEM_PATH" --simple-connect="apn=$apn"; then
    log_warn "Falha ao conectar. Possivelmente já conectado ou porta ocupada."
    return 1
  fi
  return 0
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

main() {
  touch "$LOG_FILE"
  chmod 644 "$LOG_FILE"
  log "Iniciando configuração do modem 4G"

  check_root
  log "Atualizando sistema..."
  apt update && apt upgrade -y
  install_packages
  list_usb

  modem_line=$(detect_modem)

  if [[ $modem_line =~ ID[[:space:]]([0-9a-f]{4}):([0-9a-f]{4}) ]]; then
    VENDOR_ID="${BASH_REMATCH[1]}"
    PRODUCT_ID="${BASH_REMATCH[2]}"
    log "Modem detectado (VID:PID=$VENDOR_ID:$PRODUCT_ID)"
  else
    log_error "Não foi possível extrair VID:PID do modem."
    exit 1
  fi

  # Força usb_modeswitch se for um ID conhecido de modo CD-ROM
  KNOWN_STORAGE_IDS=("19d2:0031" "19d2:2000" "12d1:1f01")
  USB_ID="${VENDOR_ID}:${PRODUCT_ID}"
  if [[ " ${KNOWN_STORAGE_IDS[*]} " == *"$USB_ID"* ]]; then
    log_warn "Modem $USB_ID está em modo de armazenamento. Forçando usb_modeswitch..."

    if [[ "$USB_ID" == "19d2:0031" ]]; then
      usb_modeswitch -v 0x19d2 -p 0x0031 -i 2 -W -M "5553424312345678000000000000061b000000020000000000000000000000"
    else
      usb_modeswitch -v 0x$VENDOR_ID -p 0x$PRODUCT_ID -M "5553424312345678000000000000061b000000020000000000000000000000"
    fi

    sleep 5
  else
    log_success "Modem parece já estar no modo modem."
  fi

  MODEM_PATH=$(wait_for_modem) || {
    log_error "Modem não detectado após múltiplas tentativas."
    exit 1
  }
  log "Modem disponível em: $MODEM_PATH"

  select_operadora
  log "Operadora selecionada: $OPERADORA"
  log "APN selecionada: $APN"

  status=$(check_connection_status)
  if [[ "$status" == "connected" ]]; then
    log_success "Modem já conectado."
  else
    if ! try_connect "$APN"; then
      log_warn "Tentativa de conexão falhou, testando internet..."
    fi
  fi

  test_internet
  log_success "Configuração concluída."
}

main "$@"

