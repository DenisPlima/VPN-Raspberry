# 📦 VPN Raspberry Installer - Empacotamento Manual

Este documento explica como **gerar um único instalador `.sh` autoexecutável**, com todos os scripts embutidos via `base64 + tar.gz`.

---

## 🛠 Etapas para empacotar

1. **Crie uma pasta temporária com todos os scripts que deseja embutir**:
```bash
mkdir sanfer_scripts
cp *.sh sanfer_scripts/
```

2. **Empacote tudo em um `.tar.gz` comprimido e codifique em base64**:
```bash
tar -cz sanfer_scripts | base64 > scripts.b64
```

3. **Abra o arquivo `final_instalador.sh` em um editor de texto**  
   Vá até o final do arquivo e **substitua o conteúdo existente após a linha `# === ARQUIVOS EMBUTIDOS ===`** pelo conteúdo de `scripts.b64`.

4. **Atenção ao número da linha para extração correta**  
   No `final_instalador.sh`, localize esta linha no início da função `extract_scripts()`:

```bash
tail -n +73 "$0" | base64 -d | tar -xz -C "$WORKDIR"
```

Se o conteúdo de `final_instalador.sh` aumentar ou diminuir, **atualize o `+73` para refletir a primeira linha base64 real**.  
Use `wc -l final_instalador.sh` antes de inserir o base64 e `wc -l` depois, para calcular a linha correta de início.

---

## ▶️ Como usar o instalador autoexecutável

Após empacotar corretamente:

```bash
chmod +x final_instalador.sh
sudo ./final_instalador.sh
```

Isso irá:

- Criar a pasta `/tmp/sanfer_installer`
- Extrair os scripts embutidos para ela
- Rodar um menu interativo passo-a-passo

---

## 🧪 Dica

Você pode testar o `.sh` final rodando:
```bash
tail -n +73 final_instalador.sh | base64 -d | tar -tz
```

---

## ✅ Concluído

Agora você tem um único script autoexecutável `.sh` com tudo empacotado para uso offline ou em campo.

---

Desenvolvido por Sanfer.
