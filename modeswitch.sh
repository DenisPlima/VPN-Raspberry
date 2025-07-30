#!/bin/bash
set -euo pipefail

# ID do modo de armazenamento
ORIGINAL_ID="19d2:0031"
MODESWITCH_DELAY=8

# Comandos de usb_modeswitch testados
declare -a SWITCH_CMDS=(
  "usb_modeswitch -v 0x19d2 -p 0x0031 -M 5553424312345678000000000000061b000000020000000000000000000000"
  "usb_modeswitch -v 0x19d2 -p 0x0031 -i 2 -M 5553424312345678000000000000061b000000020000000000000000000000"
  "usb_modeswitch -v 0x19d2 -p 0x0031 -H 1"
)

# Funções de log
log() { echo -e "[\e[1;36mINFO\e[0m] $1"; }
success() { echo -e "[\e[1;32mOK\e[0m] $1"; }
error() { echo -e "[\e[1;31mERRO\e[0m] $1"; }

# Função para obter o ID atual do modem (ZTE)
get_current_id() {
  lsusb | grep -i "zte" | awk '{print $6}' | head -n1
}

# Função de teste de troca de modo
start_test() {
  local cmd
  for cmd in "${SWITCH_CMDS[@]}"; do
    log "Executando: $cmd"
    eval "$cmd" || log "Comando terminou com erro (ignorado)."

    log "Aguardando ${MODESWITCH_DELAY}s para mudança de modo..."
    sleep "$MODESWITCH_DELAY"

    current_id=$(get_current_id)

    if [[ "$current_id" != "$ORIGINAL_ID" && -n "$current_id" ]]; then
      success "Modem mudou de modo! Novo ID: $current_id"
      return 0
    else
      log "Sem mudança de modo (ID atual: $current_id)"
    fi
  done

  error "Nenhuma tentativa teve sucesso. Tente reinserir o modem fisicamente e reexecutar."
  return 1
}

# Execução principal
log "Iniciando diagnóstico de usb_modeswitch para ZTE 19d2:0031"
start_test
