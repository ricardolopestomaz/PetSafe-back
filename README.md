<a id="readme-top"></a>
<div align="center">
  <img src="https://github.com/ricardolopestomaz/DriverLux/blob/main/public/assets/img/marcaUFT_vertical.png" width="100"/>
  <h3>Universidade Federal do Tocantins (UFT)</h3>
  <p>
    <b>Curso:</b> Bacharelado em Ciência da Computação<br/>
    <b>Professores:</b> Jackson Souza e Edeilson Milhomem da Silva<br/>
    <b>Disciplina:</b> Desenvolvimento Web/Mobile e Projeto de Sistemas
  </p>
</div>
<br/>
<!-- PROJECT SHIELDS -->
<div align="center">
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
</div>
<!-- PROJECT LOGO -->
<br/>
<div align="center">
  <h2 align="center">🐾 PetSafe — Backend</h2>
  <p align="center">
    API do PetSafe: medalha inteligente para pets com identificação passiva via QR Code/NFC + reencontro em tempo real.
    <br/>
    Este repositório contém apenas o <b>backend</b> (API Node.js + Supabase) do projeto.
    <br/>
    <br/>
  </p>
</div>

<!-- STACK -->
## 🛠️ Stack

- **Node.js + Express** — servidor e rotas da API
- **Supabase** — banco de dados (PostgreSQL) + autenticação
- Arquitetura em padrão **MVC** (Model / View / Controller)

<!-- GETTING STARTED -->
## 🚀 Como Começar

Siga os passos abaixo para rodar a API localmente.

### Pré-requisitos

- Node.js (LTS) e npm instalados
  ```sh
  npm install npm@latest -g
  ```
- Acesso ao projeto Supabase do time (URL + chave da API)

### Instalação

1. Clone o repositório
   ```sh
   git clone https://github.com/ricardolopestomaz/PetSafe-back.git
   cd PetSafe-back
   ```
2. Instale as dependências
   ```sh
   npm install
   ```
3. Crie o arquivo `.env` na raiz do projeto com as credenciais do Supabase:
   ```
   SUPABASE_URL=https://seu-projeto.supabase.co
   SUPABASE_KEY=sua-chave-aqui
   ```
   > Peça a URL e a chave para quem já tem acesso ao projeto Supabase do time. Esse arquivo **nunca** deve ser commitado (já está no `.gitignore`).
4. Inicie o servidor
   ```sh
   node index.js
   ```
5. A API estará rodando em: `http://localhost:3000`

<!-- ESTRUTURA -->
## 📁 Estrutura de Pastas

```
PetSafe-back/
├── app/
│   ├── controller/     → lógica das rotas (recebe requisição, chama o banco, devolve resposta)
│   ├── model/           → conexão com o banco e regras/validação dos dados
│   └── view/            → formatação da resposta antes de devolver ao cliente
├── node_modules/        → dependências (não versionado)
├── .env                 → credenciais do Supabase (não versionado)
├── .gitignore
├── index.js             → arquivo principal que sobe o servidor
├── package.json
└── README.md
```

