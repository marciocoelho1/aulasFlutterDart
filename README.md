# Sistema de Gestão e Controle de EPIs (api_epi & app_epi)

Sistema integrado para controle, conformidade regulamentadora (NR-06) e empréstimos de Equipamentos de Proteção Individual (EPIs), composto por uma API RESTful em **Spring Boot** e um aplicativo móvel em **Flutter**.

---

## 📅 O que foi feito hoje (06/11/2026)

Nesta data foi implementado o fluxo completo de **Solicitação e Gestão de Empréstimos de EPIs**, cobrindo regras de negócio regulamentares no backend e interface interativa no aplicativo Flutter:

### ⚙️ Backend (Spring Boot - `api_epi`)

1. **Controller de Empréstimos (`EmprestimoController`)**:
   - `POST /emprestimos`: Endpoint para solicitação de EPI por funcionários. Retorna status `201 Created` com os dados persistidos ou `400 Bad Request` com a mensagem da regra violada.
   - `GET /emprestimos/funcionario/{id}`: Endpoint para listar histórico e solicitações ativas vinculadas ao funcionário logado.

2. **Regras de Negócio e Serviço (`EmprestimoService`)**:
   - **Conformidade NR-06**: Validação impeditiva de empréstimo caso o Certificado de Aprovação (CA) esteja vencido (`epi.isCaVencido()`).
   - **Controle de Estoque**: Validação impedindo solicitação de EPI sem saldo disponível (`quantidadeDisponivel <= 0`).
   - **Prevenção de Duplicidade**: Bloqueio de novas solicitações caso o funcionário já tenha um pedido com status `SOLICITADO` para o mesmo item.
   - **Desafio Extra Concluído**: Bloqueio de novo empréstimo se o funcionário já estiver com o EPI com status `EMPRESTADO` (ainda não devolvido).
   - **Integridade dos Dados**: O backend atribui a data da solicitação (`LocalDate.now()`), status inicial `"SOLICITADO"`, devolução `null` e valida os IDs de funcionário e EPI diretamente no banco de dados.

3. **Atualizações de Entidades**:
   - `Emprestimo`: Inclusão do campo `observacao` (`@Column(length = 200)`) para justificativa do pedido.
   - `Epi`: Ajuste no tipo de `quantidadeDisponivel` para `Integer`.

---

### 📱 Frontend (Flutter - `app_epi`)

1. **Modelo de Dados (`Emprestimo`)**:
   - Modelagem com deserialização JSON e getter `dataFormatada` convertendo data de `AAAA-MM-DD` para `DD/MM/AAAA`.

2. **Serviço de Comunicação (`EmprestimoService`)**:
   - Integração com os endpoints `POST /emprestimos` e `GET /emprestimos/funcionario/{id}` com tratamento de respostas e decodificação UTF-8.

3. **Tela de Detalhes e Solicitação (`EpiDetalheScreen`)**:
   - Visualização dos detalhes do EPI (imagem, nome, descrição, CA, validade e estoque).
   - Bloqueio e alertas visuais quando o EPI estiver com CA vencido ou sem estoque.
   - Formulário com validação de campo de observação/motivo.
   - **Exercício 2**: `AlertDialog` de confirmação antes do envio da solicitação.
   - Feedback em tempo real com `SnackBar` (verde no sucesso, vermelho capturando mensagem de erro da API).

4. **Tela de Histórico (`MeusEmprestimosScreen`)**:
   - **Exercício 3**: Badges de status com cores dinâmicas:
     - 🟠 **SOLICITADO**: Laranja
     - 🟢 **EMPRESTADO**: Verde
     - ⚪ **DEVOLVIDO**: Cinza
   - Visualização de cards com data formatada e motivo da solicitação.

5. **Menu e Navegação (`MainScreen` e `EpiScreen`)**:
   - Adição do acesso rápido a **"Meus Empréstimos"** no menu lateral (`Drawer`).
   - Exibição de avatar com inicial estilizada e perfil do usuário logado.
   - Toque no card de EPI na `EpiScreen` redirecionando para a tela de detalhes com o contexto do usuário.
   - Correção no `AuthService` com suporte a acentuação (UTF-8).

---

## 🛠️ Tecnologias Utilizadas

- **Backend**:
  - Java 17 / Spring Boot 3
  - Spring Data JPA / Hibernate
  - Banco de Dados Relacional (H2 / MySQL)
  - Lombok
- **Frontend**:
  - Flutter / Dart
  - Pacote `http` para consumo de APIs REST
  - Material Design 3

---

## 🚀 Como Executar

### Backend (`api_epi`)
1. Certifique-se de ter o JDK 17+ instalado.
2. No diretório raiz do projeto:
   ```bash
   ./mvnw spring-boot:run
   ```
3. A API estará acessível em `http://localhost:8080`.

### Aplicativo Móvel (`app_epi`)
1. No diretório `app_epi`:
   ```bash
   flutter pub get
   flutter run
   ```
