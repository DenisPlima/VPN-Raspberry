# 🚀 Raspberry Pi Setup Scripts - Sanfer VPN

Bem-vindo ao repositório com scripts essenciais para configurar seu **Raspberry Pi** com foco em **acesso remoto seguro** e **conectividade 4G**.  
Automatize tarefas críticas como habilitar SSH, configurar modem 4G e instalar a VPN Tailscale, tudo de forma simples e segura! 🎉

---

## 📂 Conteúdo dos Scripts

### 1️⃣ `enable_ssh.sh` — Habilitar SSH

🔐 Facilita o acesso remoto ao Raspberry Pi via SSH.

- ✅ Verifica se o serviço SSH está instalado e habilitado  
- ✅ Habilita e inicia o SSH se necessário  
- ✅ Confirma que o SSH está ativo e pronto para uso

---

### 2️⃣ `modem_4g_setup.sh` — Configurar modem 4G

📡 Automatiza a detecção, configuração e conexão de modems 4G USB.

- 🛠️ Instala dependências essenciais (`usb-modeswitch`, `modemmanager`, `ppp`)  
- 🔎 Detecta modems Huawei ou ZTE conectados  
- 🔄 Realiza o switch de modo USB para modo modem, se necessário  
- 📱 Permite seleção interativa da operadora com configuração automática do APN  
- 🌐 Testa a conectividade com internet (ping IP e DNS)  
- 📋 Gera logs detalhados em `/var/log/modem_4g_setup.log`

---

### 3️⃣ `install_configure_tailscale.sh` — Instalar e configurar Tailscale VPN

🔒 Instala e configura o Tailscale para acesso VPN seguro.

- 🔄 Atualiza repositórios e instala o Tailscale  
- 🚀 Habilita e inicia o serviço Tailscale automaticamente  
- 🔗 Facilita a autenticação inicial via link gerado  
- 🗓️ Agenda atualizações semanais automáticas via cron  
- 📈 Permite monitorar o status da VPN facilmente

---

## 🛠️ Requisitos

- Raspberry Pi com sistema baseado em Debian (ex: Raspberry Pi OS)  
- Privilégios administrativos (sudo) para executar scripts  
- Modem 4G USB compatível (para `modem_4g_setup.sh`)  
- Conexão ativa à internet para instalação e autenticação

---

## ⚡ Como usar

### 1️⃣ Habilitar SSH

```bash
sudo bash enable_ssh.sh
