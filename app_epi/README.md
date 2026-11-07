# app_epi - Aplicativo Móvel de Controle de EPIs

Aplicativo Flutter integrado à API REST `api_epi` para consulta, solicitação e acompanhamento de Equipamentos de Proteção Individual (EPIs).

---

## 📱 Funcionalidades

- **Autenticação de Usuários**: Login de funcionários com matrícula e senha, decodificação em UTF-8 e controle de sessão.
- **Catálogo de EPIs**: Lista de equipamentos com imagens, status de conformidade do CA (Certificado de Aprovação) e alerta de validade.
- **Detalhes e Solicitação de Empréstimo (`EpiDetalheScreen`)**:
  - Exibição de ficha técnica, CA, validade e quantidade disponível.
  - Bloqueio de solicitações caso o CA esteja vencido ou o estoque zerado (conforme NR-06).
  - Formulário com validação para inclusão de justificativa/observação.
  - Diálogo de confirmação (`AlertDialog`) antes do envio.
- **Meus Empréstimos (`MeusEmprestimosScreen`)**:
  - Histórico de solicitações e empréstimos ativos do funcionário logado.
  - Badges com cores dinâmicas por status (`SOLICITADO` em laranja, `EMPRESTADO` em verde, `DEVOLVIDO` em cinza).
  - Datas formatadas no padrão brasileiro (`DD/MM/AAAA`).
- **Navegação Lateral (`Drawer`)**: Acesso centralizado ao Início, EPIs, Meus Empréstimos, Funcionários e Logout.

---

## 🚀 Como Executar

1. Navegue até o diretório do aplicativo:
   ```bash
   cd app_epi
   ```
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Execute o aplicativo em um emulador ou dispositivo físico:
   ```bash
   flutter run
   ```
