#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/modem_4g_setup.log"
MAX_ATTEMPTS=15
SLEEP_TIME=2

# Cores para saída
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
  modems=$(lsusb | grep -Ei "zte|huawei" || true)
  if [[ -z "$modems" ]]; then
    log_error "Nenhum modem ZTE ou Huawei detectado."
    exit 1
  fi
  log "Modems detectados:"
  echo "$modems" | tee -a "$LOG_FILE"
  echo "$modems" | head -n1
}

get_interface_class() {
  local vid=$1
  local pid=$2
  local iface_class
  iface_class=$(lsusb -v -d ${vid}:${pid} 2>/dev/null | grep -m1 bInterfaceClass | awk '{print $2}')
  if [[ -z "$iface_class" ]]; then
    log_warn "Não foi possível obter classe da interface USB, assumindo modo modem."
    echo "ff"
  else
    echo "$iface_class"
  fi
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

  iface_class=$(get_interface_class "$VENDOR_ID" "$PRODUCT_ID")
  log "Classe USB da interface: $iface_class"

  if [[ "$iface_class" == "08" ]]; then
    log "Modem está em modo armazenamento, executando usb_modeswitch..."
    usb_modeswitch -v 0x$VENDOR_ID -p 0x$PRODUCT_ID -V 0x$VENDOR_ID -P 0x$PRODUCT_ID -M "5553424312345678000000000000061b000000020000000000000000000000"
    sleep 5
  else
    log_success "Modem já no modo modem, pulando usb_modeswitch."
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

  if test_internet; then
    log_success "Internet conectada com sucesso via $OPERADORA"
  else
    log_error "Falha na conexão com a internet."
    exit 1
  fi

  log_success "Configuração concluída."
}

main "$@"
### [AUTO RECONNECT SETUP] ###
echo "🔁 Instalando reconexão automática do modem via systemd..."

# Copia o script atual para ser usado como reconector
cp "$0" /usr/local/bin/modem_4g_setup.sh
chmod +x /usr/local/bin/modem_4g_setup.sh

# Cria wrapper de reconexão
echo '#!/bin/bash
# Script reconector de modem - reutiliza lógica do modem_4g_setup
/usr/local/bin/modem_4g_setup.sh >> /var/log/modem_4g_reconnect.log 2>&1
' | tee /usr/local/bin/conectar_modem.sh > /dev/null
chmod +x /usr/local/bin/conectar_modem.sh

# Cria unidade systemd
echo '[Unit]
Description=Conectar Modem 4G automaticamente
After=network.target

[Service]
ExecStart=/usr/local/bin/conectar_modem.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
' | tee /etc/systemd/system/modem-reconnect.service > /dev/null

# Ativa serviço
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable modem-reconnect.service
systemctl restart modem-reconnect.service

echo "✅ Serviço de reconexão automática instalado como 'modem-reconnect.service'."