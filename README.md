# 🧰 VPN Raspberry Pi Setup

Automatize a configuração de Raspberry Pi para aplicações remotas com conectividade 4G e gerenciamento via Tailscale. Este repositório foi desenvolvido para acelerar o comissionamento de dispositivos de campo, reduzindo erros manuais e padronizando o processo.

---
## 📦 O que este projeto faz

Este repositório fornece:

- ✅ Ativação segura do serviço SSH  
- ✅ Configuração automática de modems 4G USB (Huawei e ZTE)  
- ✅ Instalação e ativação do Tailscale para VPN zero-config  
- ✅ Atualizações automáticas semanais do Tailscale via cron  
- ✅ Interface interativa para o usuário, com instruções em cada etapa  

---
## 📁 Estrutura dos arquivos

| Script                  | Descrição                                                  |
|-------------------------|------------------------------------------------------------|
| `01_habilitar_ssh.sh`       | Verifica e habilita o serviço SSH no Raspberry Pi.        |
| `02_configurar_modem.sh`     | Detecta, ativa e configura modems 4G automaticamente.      |
| `03_instalar_tailscale.sh`   | Instala o Tailscale, inicia a autenticação e agenda atualizações. |
| `sanfer_instalador.sh`        | Instalador interativo que executa os três scripts anteriores na ordem. |

---
## ⚙️ Pré-requisitos

Antes de começar, você precisa de:

- ✅ Raspberry Pi com Raspberry Pi OS (Lite ou Desktop)  
- ✅ Acesso à internet para baixar pacotes  
- ✅ Acesso sudo (root) ao terminal  
- ✅ Um modem 4G USB (compatível com ZTE ou Huawei) ou Ethernet/Wi-Fi 
- ✅ Conta no Tailscale  

---
## 🚀 Instalação passo a passo

1. Clone o repositório:
    ```bash
    git clone https://github.com/sanfer-automacao/pi-setup.git
    cd pi-setup
    chmod +x *.sh
    ```
2. Execute o instalador:
    ```bash
    sudo ./sanfer_instalador.sh
    ```

3. Durante a instalação:
    - 🔹 O instalador exibirá mensagens e solicitará sua confirmação antes de cada etapa.  
    - 🔹 Durante a instalação do Tailscale, será fornecido um link de autenticação. Abra-o em um navegador e faça login.  
    - 🔹 O modem será automaticamente configurado e testado (conexão PPP criada e rota verificada).  

---
## 🔍 Diagnóstico e Logs

- Log da configuração do modem: `/var/log/modem_4g_setup.log`
Verifique o status do Tailscale a qualquer momento com:

```bash
sudo tailscale status
```

## 🔄 Atualizações Automáticas

O script `03_instalar_tailscale.sh` configura um cron para atualizar o Tailscale semanalmente:

- 🕒 Todos os domingos às 03:00  
- 📝 Log da atualização: `/var/log/tailscale_update.log`  

---
## 🧩 Rodando scripts individualmente

Caso prefira executar manualmente cada etapa:

```bash
sudo ./01_habilitar_ssh.sh
sudo ./02_configurar_modem.sh
sudo ./03_instalar_tailscale.sh
````

## 🧑‍💻 Contribuindo

Contribuições são muito bem-vindas!

1. Faça um fork deste repositório.  
2. Crie uma branch com sua funcionalidade:  
   ```bash
   git checkout -b minha-funcionalidade
---
   
## 🐛 Relatar problemas / Sugestões

Se encontrar algum problema, por favor abra uma Issue descrevendo o erro, como reproduzi-lo e sugestões de correção (se possível).  
Também aceitamos sugestões de melhoria, novos modems a suportar, ou novas funcionalidades.

---
## 📄 Licença

Distribuído sob a Licença MIT.  
Consulte o arquivo LICENSE para mais detalhes.

---

Desenvolvido com 💻, ☕ e muito cuidado.





