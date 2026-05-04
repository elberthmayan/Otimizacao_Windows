# 🚀 Limpeza e Otimização de Sistema (Pós-Formatação)

Script em PowerShell focado em remover bloatware do Windows, reduzir telemetria e otimizar o sistema logo após uma instalação limpa.

Ideal para quem quer um ambiente leve, rápido e pronto pra produtividade ou desenvolvimento.

---

## 🛠️ Funcionalidades

- 🔪 **Remoção de Bloatware**
  - Remove apps UWP desnecessários (Xbox, Clima, Mapas, etc.)
  - Elimina apps patrocinados e pré-instalados

- ☁️ **Remoção do OneDrive**
  - Finaliza processos
  - Desinstala completamente do sistema

- 📄 **Bloqueio do Edge como padrão**
  - Impede que o Edge assuma PDFs automaticamente via Registro

- 🕵️ **Desativação de Telemetria**
  - Reduz coleta de dados em segundo plano

- 🧹 **Limpeza de arquivos temporários**
  - Remove cache e arquivos temporários do sistema
  - Não mexe em arquivos pessoais ou Lixeira

---

## ⚡ Execução Rápida (Sem baixar nada)

1. Abra o menu Iniciar
2. Digite **PowerShell**
3. Execute como **Administrador**
4. Cole o comando abaixo:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; irm "[https://raw.githubusercontent.com/elberthmayan/otimizacao_windows/main/Otimizar_Sistema.ps1](https://raw.githubusercontent.com/elberthmayan/otimizacao_windows/main/Otimizar_Sistema.ps1)" | iex
