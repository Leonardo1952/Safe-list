# Safe List

Safe List é uma aplicação Flutter criada como estudo sobre como proteger dados gravados localmente em apps móveis. Em muitos cenários, credenciais, licenças de uso e informações pessoais acabam sendo persistidas em `SharedPreferences` ou em bancos SQLite sem nenhum tipo de proteção, abrindo brecha para engenharia reversa ou acesso indevido. O projeto demonstra como adicionar uma camada de criptografia para mitigar esse risco.

## Funcionalidades principais

- **Licenciamento protegido**: armazena uma chave de licença no `SharedPreferences`, criptografada com AES. Simula a necessidade de validar o acesso ao app sem expor o valor original.
- **Lista de tarefas segura**: persiste ToDos em um banco SQLite utilizando criptografia, evitando que os títulos fiquem em texto puro.

## Tecnologias utilizadas

- Flutter (Dart)
- sqflite_sqlcipher
- encrypt
- shared_preferences

## Como executar o projeto

1. Clone o repositório: `git clone <URL-do-repo>`
2. Entre na pasta: `cd safe_list`
3. Instale as dependências: `flutter pub get`
4. Execute a aplicação: `flutter run`

## Objetivo educacional

O foco do projeto é mostrar padrões básicos de criptografia em duas frentes comuns de armazenamento local (preferências e banco de dados). A interface foi mantida simples de propósito: o objetivo é facilitar a inspeção do código e a replicação das abordagens em outros projetos.
