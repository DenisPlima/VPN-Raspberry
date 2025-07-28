
<h1 align="center">🛠️ Instalador Completo - Raspberry Pi com VPN, 4G, VNC e SSH</h1>

<p align="center">
  Scripts automatizados para transformar seu Raspberry Pi em um gateway remoto com acesso por SSH, VPN Tailscale, VNC e conectividade via modem 4G.
</p>

---

## 📦 Funcionalidades Principais

- ✅ Habilitação de **SSH** para acesso remoto via terminal
- 🌐 Conexão de internet por **modem 4G USB** (Huawei, ZTE)
- 🔐 Instalação e autenticação com **VPN Tailscale**
- 🔁 Configuração de **roteamento IP duplo** (Internet + Rede Industrial)
- 🖥️ Acesso remoto via **VNC (RealVNC)** com interface gráfica

---

## 📁 Scripts incluídos

| Script                           | Descrição                                                                 |
|----------------------------------|---------------------------------------------------------------------------|
| `final_instalador.sh`            | Menu principal com todas as opções de instalação                         |
| `enable_ssh.sh`                  | Habilita e inicia o serviço SSH                                          |
| `modem_4g_setup.sh`              | Configura e conecta modems 4G compatíveis                                |
| `install_configure_tailscale.sh` | Instala e ativa o Tailscale com autenticação e cron de atualização       |
| `setup_dual_routes_tailscale.sh` | Configura IPs fixos, NAT, roteamento e rotas via Tailscale               |
| `install_configure_vnc.sh`       | Instala e ativa o RealVNC Server para acesso à interface gráfica         |

---

## ✅ Requisitos

- Raspberry Pi com **Raspberry Pi OS** (com desktop para uso com VNC)
- Acesso como `root` ou `sudo`
- Conexão com a internet (temporária ou via modem 4G)
- Todos os scripts `.sh` devem estar na mesma pasta

---

## 🚀 Como instalar e usar

```bash
# 1. Torne todos os scripts executáveis
chmod +x *.sh

# 2. Execute o instalador principal
sudo ./final_instalador.sh
```

Menu principal exibido:

```
=========== INSTALADOR SANFER - MENU ===========
1) Habilitar SSH
2) Configurar Modem 4G
3) Instalar e configurar Tailscale
4) Configurar Rotas IP Duplas com Tailscale
5) Instalar e configurar VNC (RealVNC)
6) Executar instalação completa (todas etapas)
7) Checar conectividade
0) Sair
```

---

## 🔍 O que cada script faz

### `enable_ssh.sh`
- Ativa e inicia o serviço SSH para acesso remoto

### `modem_4g_setup.sh`
- Instala dependências (`usb-modeswitch`, `modemmanager`, `ppp`)
- Detecta modems 4G compatíveis via USB
- Realiza conexão com a operadora (Vivo, Claro, Tim, Oi)
- Testa a conectividade via `ping` e DNS

### `install_configure_tailscale.sh`
- Instala o Tailscale via script oficial
- Ativa o serviço `tailscaled`
- Executa `tailscale up` para autenticação via navegador
- Cria um cron semanal para atualizar o Tailscale

### `setup_dual_routes_tailscale.sh`
- Configura IP fixo para rede com Internet e IP secundário para rede industrial
- Habilita NAT e IP forwarding
- Cria script de boot para IP secundário
- Anuncia as rotas via `tailscale up --advertise-routes`

### `install_configure_vnc.sh`
- Instala `realvnc-vnc-server` e `realvnc-vnc-viewer`
- Ativa e inicia o serviço VNC
- Permite conexão remota à interface gráfica com usuário e senha do sistema

---

## 🧪 Testes de conectividade

Use a opção 7 no menu para testar:

- `ping 8.8.8.8` → Testa conectividade IP
- `ping google.com` → Testa resolução DNS

---

## 💡 Dicas úteis

- Use `sudo tailscale up` caso a autenticação automática falhe
- Aprove as rotas anunciadas em: [https://login.tailscale.com/admin/machines](https://login.tailscale.com/admin/machines)
- Reinicie o Raspberry após configurar rotas IP duplas
- Acesse a área gráfica via **RealVNC Viewer** com IP + usuário/senha

---

## ♻️ Reset / Limpeza

```bash
sudo tailscale down
sudo systemctl disable --now tailscaled
sudo rm -f /usr/local/bin/set_secondary_ip.sh
sudo crontab -e  # Remova o @reboot manualmente
sudo raspi-config nonint do_vnc 1
sudo systemctl stop vncserver-x11-serviced.service
sudo systemctl disable vncserver-x11-serviced.service
```

---

## 👨‍💻 Autor

Desenvolvido por **Denis**  
Para dúvidas ou suporte técnico, entre em contato com a equipe Sanfer.

---

## 🤝 Contribuições

Contribuições são bem-vindas!

- Melhorias no menu ou scripts
- Suporte a mais modems
- Automação de etapas
- Correções de bugs
- Melhoria deste README

```bash
# Exemplo de contribuição
git checkout -b minha-melhoria
git commit -am "Minha melhoria"
git push origin minha-melhoria
# Abra um Pull Request 🚀
```
