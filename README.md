# 🧰 Sanfer Raspberry Pi Setup

Automatize a configuração de Raspberry Pi para aplicações remotas com conectividade 4G e gerenciamento via Tailscale. Este repositório foi desenvolvido para acelerar o comissionamento de dispositivos de campo, reduzindo erros manuais e padronizando o processo.

---

## 📦 O que este projeto faz

Este repositório fornece:

✅ Ativação segura do serviço SSH  
✅ Configuração automática de modems 4G USB (Huawei e ZTE)  
✅ Instalação e ativação do Tailscale para VPN zero-config  
✅ Atualizações automáticas semanais do Tailscale via `cron`  
✅ Interface interativa para o usuário, com instruções em cada etapa

---

## 📁 Estrutura dos arquivos

| Script                     | Descrição                                                                 |
|---------------------------|---------------------------------------------------------------------------|
| `01_habilitar_ssh.sh`     | Verifica e habilita o serviço SSH no Raspberry Pi.                       |
| `02_configurar_modem.sh`  | Detecta, ativa e configura modems 4G automaticamente.                    |
| `03_instalar_tailscale.sh`| Instala o Tailscale, inicia a autenticação e agenda atualizações.        |
| `sanfer_instalador.sh`    | Instalador interativo que executa os três scripts anteriores na ordem.   |

---

## ⚙️ Pré-requisitos

Antes de começar, você precisa de:

- ✅ Raspberry Pi com Raspberry Pi OS (Lite ou Desktop)
- ✅ Acesso à internet para baixar pacotes
- ✅ Acesso `sudo` (root) ao terminal
- ✅ Um modem 4G USB (compatível com ZTE ou Huawei)
- ✅ Conta no [Tailscale](https://tailscale.com)

---

## 🚀 Instalação passo a passo

### 1. Clone o repositório:

```bash
git clone https://github.com/SEU_USUARIO/sanfer-raspberry-setup.git
cd sanfer-raspberry-setup
chmod +x *.sh
