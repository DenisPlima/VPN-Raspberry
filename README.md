<div align="center">
🚀 Sanfer VPN Setup - Raspberry Pi
🔐 Instalação assistida de SSH, Modem 4G e VPN Tailscale para comunicação segura e remota com o Raspberry Pi.

</div>
📂 Visão Geral
Este repositório contém três scripts principais que automatizam a configuração de um Raspberry Pi com:

🔌 SSH habilitado

📶 Modem 4G com escolha da operadora

🛡️ VPN Tailscale instalada e configurada

Além disso, há um script mestre (sanfer_instalador.sh) que executa os três passos em sequência com ajuda interativa ao usuário.

📦 Conteúdo do Repositório
Arquivo	Descrição
enable_ssh.sh	Ativa e inicia o serviço SSH no Raspberry Pi
modem_4g_setup.sh	Auxilia na escolha da operadora e cria conexão via modem 4G
install_configure_tailscale.sh	Instala e configura o Tailscale, criando VPN segura
sanfer_instalador.sh	Script principal para rodar os 3 scripts acima de forma guiada

🧰 Pré-requisitos
Raspberry Pi com Raspberry Pi OS (Debian-based)

Acesso root (sudo) no terminal

Conexão inicial com teclado/monitor ou via rede local

🧭 Como Usar
✅ Modo automático (recomendado)
Clone o repositório:

bash
Copiar
Editar
git clone https://github.com/seu-usuario/sanfer-vpn-setup.git
cd sanfer-vpn-setup
Dê permissão de execução aos scripts:

bash
Copiar
Editar
chmod +x *.sh
Execute o instalador como root:

bash
Copiar
Editar
sudo ./sanfer_instalador.sh
Siga as instruções na tela.
O instalador pausará entre as etapas para confirmar o andamento.

⚙️ Modo manual (avançado)
Você também pode executar cada script separadamente, por exemplo:

bash
Copiar
Editar
sudo ./enable_ssh.sh
sudo ./modem_4g_setup.sh
sudo ./install_configure_tailscale.sh
🔐 Segurança
A VPN Tailscale utiliza criptografia de ponta-a-ponta.

Os scripts não armazenam senhas e usam fontes oficiais.

🤝 Contribuição
Pull requests e melhorias são bem-vindos. Sinta-se à vontade para clonar, modificar e propor mudanças!

🧑‍💻 Autor
Denis Lima
Sanfer Tecnologia
