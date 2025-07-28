# 🛠️ Instalador VPN – Raspberry Pi

Este projeto contém um conjunto de **scripts shell organizados** para configurar rapidamente um Raspberry Pi com:

- Acesso remoto via **SSH**  
- Conexão de internet por **modem 4G**  
- Instalação e configuração da **VPN Tailscale**  
- Roteamento IP duplo para redes industrial/internet  
- Instalação e configuração do **VNC (RealVNC)** para acesso remoto à área de trabalho

---

## 📁 Arquivos incluídos

| Script                         | Função                                               |
|-------------------------------|-----------------------------------------------------|
| `final_instalador.sh`          | Menu interativo principal                            |
| `enable_ssh.sh`                | Habilita e inicia o SSH                              |
| `modem_4g_setup.sh`            | Configura e conecta um modem 4G via USB             |
| `install_configure_tailscale.sh` | Instala e configura o Tailscale                      |
| `setup_dual_routes_tailscale.sh` | Configura IP fixo duplo e roteamento IP              |
| `setup_vnc.sh`                 | Instala, ativa e configura o VNC (RealVNC)          |

---

## ✅ Requisitos

- Raspberry Pi com Raspberry Pi OS (Debian-based, com interface gráfica para VNC)  
- Acesso como `root` (ou `sudo`)  
- Conexão com internet (exceto para modem, que será configurado)  
- Scripts na mesma pasta (`*.sh`)  

---

## 🚀 Instalação e uso

### 1. Dê permissão de execução a todos os scripts:

```bash
chmod +x *.sh
2. Execute o instalador principal:
bash
Copiar
Editar
sudo ./final_instalador.sh
Você verá um menu com opções como:

java
Copiar
Editar
=========== INSTALADOR SANFER - MENU ===========
1) Habilitar SSH
2) Configurar Modem 4G
3) Instalar e configurar Tailscale
4) Configurar Rotas IP Duplas com Tailscale
5) Instalar e configurar VNC (RealVNC)
6) Executar instalação completa (todas etapas)
7) Checar conectividade
0) Sair
Escolha conforme sua necessidade.

📦 Detalhes de cada script
enable_ssh.sh
Verifica se o serviço SSH existe

Habilita e inicia o serviço

Exibe status final

modem_4g_setup.sh
Instala usb-modeswitch, modemmanager, ppp

Detecta modem ZTE ou Huawei

Realiza usb_modeswitch se necessário

Permite escolha da operadora (Vivo, Claro, Tim, Oi)

Realiza conexão com APN adequada

Testa internet (ping e DNS)

install_configure_tailscale.sh
Instala Tailscale via script oficial

Ativa serviço e realiza autenticação

Cria cron para atualizar semanalmente

Exibe status da VPN

setup_dual_routes_tailscale.sh
Solicita informações da rede INDUSTRIAL e INTERNET

Configura IP fixo principal via /etc/dhcpcd.conf

Adiciona IP secundário via script de boot com @reboot

Habilita roteamento IP (sysctl)

Configura NAT via iptables e salva via netfilter-persistent

Anuncia rotas via Tailscale

setup_vnc.sh
Atualiza pacotes

Instala RealVNC Server e Viewer

Ativa e inicia o serviço VNC nativo do Raspberry Pi

Exibe status do serviço VNC

Permite acesso remoto via VNC usando usuário e senha do sistema

🔧 Testes de conectividade
Você pode verificar a conectividade a qualquer momento usando a opção 7 - Checar conectividade no menu principal, que realiza:

ping 8.8.8.8 (teste de IP)

ping google.com (teste de DNS)

👨‍🔧 Dicas
Use sudo tailscale up caso o script falhe na autenticação automática.

Após configurar rotas no Tailscale, acesse https://login.tailscale.com/admin/machines para aprovar as rotas anunciadas.

Reinicie o Raspberry após executar o script de rotas duplas para aplicar IPs persistentes.

Para acessar a área de trabalho remotamente, use o cliente RealVNC Viewer no seu computador, conectando ao IP do Raspberry Pi e autenticando com o usuário/senha do sistema.

🧼 Para reiniciar do zero
Se necessário, execute:

bash
Copiar
Editar
sudo tailscale down
sudo systemctl disable --now tailscaled
sudo rm -rf /usr/local/bin/set_secondary_ip.sh
sudo crontab -e  # e remova o @reboot manualmente
sudo raspi-config nonint do_vnc 1
sudo systemctl stop vncserver-x11-serviced.service
sudo systemctl disable vncserver-x11-serviced.service
📣 Autor
Desenvolvido por Denis
Para suporte, entre em contato com a equipe técnica.

🤝 Como contribuir
Contribuições são muito bem-vindas!

Você pode ajudar de diversas formas:

Sugerindo melhorias no menu ou interface

Criando suporte a novos modems ou operadoras

Automatizando mais etapas (ex: verificação de IPs)

Enviando correções de bugs

Melhorando este README

Enviando sua contribuição
Faça um fork do repositório

Crie uma branch (git checkout -b sua-melhoria)

Faça commit das alterações (git commit -am 'Minha contribuição')

Faça push para a branch (git push origin sua-melhoria)

Abra um Pull Request

🐞 Reportar problemas (issues)
Se você encontrou algum bug ou comportamento inesperado:

Verifique se já existe uma issue aberta sobre isso

Se não, abra uma nova em formato claro e objetivo:

Descreva o problema

Inclua mensagens de erro se houver

Informe seu sistema, modelo do modem e versão do Raspberry Pi OS

Exemplo de título:
[BUG] Erro ao instalar e ativar VNC no Raspberry Pi

