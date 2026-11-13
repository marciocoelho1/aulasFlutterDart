# Sistema de Gestão e Controle de EPIs (api_epi & app_epi)

Sistema integrado para controle, conformidade regulamentadora (NR-06 / NR-35) e empréstimos de Equipamentos de Proteção Individual (EPIs), composto por uma API RESTful em **Spring Boot** e um aplicativo móvel em **Flutter**.

---

## 📅 Atualizações de 13/11/2026 — Correções gerais e CRUD de Funcionários

### 🛠️ Correções

- **Android**: permissão `INTERNET` também no manifest principal e HTTP local liberado para desenvolvimento (`usesCleartextTraffic`), com `<queries>` para abrir PDFs no Android 11+.
- **Endereço da API**: `10.0.2.2` no emulador Android, `localhost` no desktop/web e `--dart-define=API_BASE_URL` para aparelho físico; timeout de 10 s e mensagens de erro amigáveis.
- **PDFs**: `dds.pdf` e `uso-epis.pdf` incluídos em `src/main/resources/static/arquivos` (antes estavam vazios/ausentes).
- **Dashboard**: usa o `AutorizacaoService`; `treinamentosPendentes` conta pares (funcionário, treinamento) distintos e não fica negativo.
- **Treinamentos**: o histórico mantém o registro mais recente; a barra de progresso fica entre 0 e 100%; `diasParaVencer` agora é `null` quando o treinamento não vence.
- **Painel do funcionário**: conta treinamentos distintos.
- **Login**: Enter na matrícula ou na senha aciona o botão "Entrar".
- **Listas**: `FutureBuilder` não refaz a requisição a cada rebuild; os cards "CA vencidos" e "Estoque baixo" abrem a lista já filtrada.
- **Testes**: `flutter test` com 4 testes e `mvn test` com 14 (H2 em memória, sem depender do MySQL).
- **Repositório**: `node_modules` e `repomix-output.xml` removidos do Git; dados de exemplo em `database/seed.sql`.

### 👥 Funcionários (novo)

- **Adicionar funcionário**: botão na tela de Funcionários, com matrícula, nome, setor, perfil e senha (`POST /funcionarios?adminId=...`).
- **Excluir funcionário**: ícone de lixeira em cada item; a exclusão só é liberada após digitar `EXCLUIR` no diálogo de confirmação (`DELETE /funcionarios/{id}?adminId=...`).
- A tela, o item do menu lateral e os endpoints são **exclusivos de ADMIN**; a exclusão é bloqueada para o próprio usuário e para quem possui empréstimos ou treinamentos.

---

## 📅 O que foi feito hoje (11/11/2026) — Aula 7: Dashboard do Técnico

Painel inicial que reúne os indicadores de EPI em uma única tela, mais a tela de **Solicitações** que faltava no material da aula e os três exercícios da página 18.

### ⚙️ Backend (Spring Boot - `api_epi`)

1. **Consultas de contagem nos repositórios** (contar no banco, não no app):
   - `EmprestimoRepository.countByStatus(status)` — empréstimos por situação.
   - `EpiRepository.countByValidadeCaBefore(data)` — EPIs com CA vencido.
   - `EpiRepository.countByQuantidadeDisponivelLessThanEqual(limite)` — exercício 2 (estoque baixo).

2. **`DashboardService.indicadores(adminId)`**:
   - Devolve `Map<String, Long>` (`LinkedHashMap`, mantém a ordem do JSON) com **8 indicadores**: `episCadastrados`, `episEmprestados`, `episDevolvidos`, `caVencidos`, `solicitacoesPendentes`, `treinamentosPendentes`, `funcionariosCadastrados` (exercício 1) e `estoqueBaixo` (exercício 2).
   - `treinamentosPendentes = funcionários × treinamentos − realizados` (simplificação: todos fazem todos).
   - `verificarAdmin()` barra quem não é ADMIN (`SecurityException`).

3. **`DashboardController`**: `GET /dashboard?adminId={id}` → `200` com os números ou `403` ("Apenas administradores podem ver o painel").

4. **Tela de Solicitações — endpoints que faltavam** (o material da Aula 7 cita "aprove um pedido", mas a API só tinha criar e listar por funcionário):
   - `GET /emprestimos` — todas as solicitações, mais recentes primeiro.
   - `PUT /emprestimos/{id}/aprovar?adminId={id}` — `SOLICITADO` → `EMPRESTADO`, baixando 1 de `quantidadeDisponivel`.
   - `PUT /emprestimos/{id}/devolver?adminId={id}` — `EMPRESTADO` → `DEVOLVIDO`, devolvendo 1 ao estoque e gravando `dataDevolucao`.
   - Acesso verificado pelo **`AutorizacaoService`** (`exigirAdmin`), com `403` para não-admin.

### 📱 Frontend (Flutter - `app_epi`)

1. **`models/dashboard.dart`** — mesmas chaves do `Map` do Java, com os 8 campos.
2. **`services/dashboard_service.dart`** — `GET /dashboard?adminId=` e erro com a mensagem do backend.
3. **`widgets/indicador_card.dart`** — Card reutilizável (ícone em círculo colorido, número grande e título); usado 8 vezes no grid.
4. **`screens/dashboard_screen.dart`** — painel **sem `Scaffold`** (vive dentro do `body` da `MainScreen`):
   - `FutureBuilder` + `RefreshIndicator` (puxar para atualizar) + botão "Atualizar" no rodapé.
   - Alerta vermelho **só quando** existe CA vencido.
   - `GridView.count` responsivo: 2 colunas no celular, 3 acima de 700 px.
   - `abrir()` com `.then((_) => recarregar())`: ao voltar de outra tela, os números se atualizam.
5. **`screens/solicitacoes_screen.dart`** — lista todas as solicitações com status, funcionário, data e motivo; botões **Aprovar**/**Devolver** conforme o status, com `SnackBar` e recarga automática.
6. **`screens/painel_funcionario_screen.dart`** — exercício 3: no lugar da mensagem de boas-vindas, dois `IndicadorCard` ("Meus EPIs em uso" e "Meus treinamentos pendentes"), calculados no app com `EmprestimoService` e `TreinamentoService`.
7. **`main_screen.dart`** — o `body` escolhe por perfil: `ADMIN` → painel; `FUNCIONARIO` → painel do funcionário; demais → mensagem de boas-vindas.
8. **`models/emprestimo.dart` / `services/emprestimo_service.dart`**:
   - Campo `funcionario` (a listagem do painel mostra de quem é o pedido).
   - Métodos `buscarTodos()`, `aprovar()` e `devolver()`.
   - **Bug corrigido:** a data usava `'\${partes[2]}/...'` (escape), exibindo o texto literal em vez de DD/MM/AAAA.

### ✅ Exercícios da página 18

1. **Funcionários cadastrados** — `funcionarioRepository.count()`; card com `Icons.people` que abre a `FuncionarioScreen`.
2. **Estoque baixo** — `countByQuantidadeDisponivelLessThanEqual(2)`; card com `Icons.production_quantity_limits` que abre a lista de EPIs.
3. **Painel do funcionário** — dois cards reaproveitando `IndicadorCard`, sem endpoint novo.

---

## 📅 Aula 6 — Treinamentos de Segurança (09/11/2026)

Nesta data foi implementado o módulo de **Treinamentos de Segurança**, com controle de acesso por perfil, histórico de conclusão por funcionário e reciclagem periódica.

### ⚙️ Backend (Spring Boot - `api_epi`)

1. **Centralização da Regra de Acesso (`AutorizacaoService`)** — ⭐ resposta do "Para pensar":
   - O método `verificarAdmin()` foi **extraído do `TreinamentoService` para um componente único**, injetado como dependência.
   - Expõe `exigirAdmin(usuarioId)` (lança `SecurityException`) e `isAdmin(usuarioId)` (versão booleana).
   - **Motivo:** antes, cada Service teria sua própria cópia da regra. Se ela mudasse (novo perfil "Gestor", permissão por setor, troca de `String` para `enum`), seria necessário alterar todas as cópias — e esquecer uma geraria uma brecha de segurança silenciosa.
   - **Bug corrigido:** a comparação usava `"Admin".equals(perfil)`, mas o banco grava `ADMIN`. Agora usa `equalsIgnoreCase` + `trim()`, aceitando `Admin`, `ADMIN`, `admin` ou `Admin `.

2. **Controller de Treinamentos (`TreinamentoController`)**:
   - `GET /treinamentos`: lista todos os treinamentos (ordem alfabética).
   - `GET /treinamentos/{id}`: busca um treinamento específico (`404` se não existir).
   - `POST /treinamentos?adminId={id}`: cadastra treinamento. Retorna `201 Created`, `403 Forbidden` (não-admin) ou `400 Bad Request` (dados inválidos).
   - `POST /treinamentos/{id}/concluir?funcionarioId={id}`: registra a conclusão do treinamento.
   - `GET /treinamentos/realizados/funcionario/{id}`: histórico de treinamentos concluídos.

3. **Regras de Negócio (`TreinamentoService`)**:
   - Título é obrigatório e limitado a 120 caracteres.
   - **Reciclagem:** bloqueia nova conclusão se o treinamento já foi concluído e **ainda não venceu**.
   - **Refazer quando vencido:** se o certificado venceu, o funcionário pode (e deve) refazer o treinamento.
   - O backend atribui `dataConclusao = LocalDate.now()`, nunca o cliente.

4. **Desafio Extra — `validadeMeses`**:
   - Novo campo `validadeMeses` (`Integer`, coluna `validade_meses`) em `Treinamento`. `null` = nunca vence.
   - Novo **`TreinamentoRealizadoDTO`** calcula no servidor: `dataVencimento`, `vencido`, `podeRefazer` e `diasParaVencer`.
   - **Por que no backend:** a regra de vencimento fica em um só lugar, sem duplicar em cada cliente (Flutter, web).

5. **Arquivos estáticos (`WebConfig`)**:
   - `/imagens/**` → `classpath:/static/imagens/`
   - `/arquivos/**` → `classpath:/static/arquivos/`
   - PDFs servidos: `nr06.pdf`, `nr35.pdf`, `dds.pdf`, `uso-epis.pdf`.

---

### 📱 Frontend (Flutter - `app_epi`)

1. **Tela "Cadastrar Treinamento" (`CadastrarTreinamentoScreen`)** — exclusiva do administrador:
   - Formulário com **título (obrigatório)**, descrição, nome do arquivo e **validade em meses** (opcional).
   - Envia `POST /treinamentos?adminId={usuario.id}` com o id do **usuário logado**.
   - O nome digitado (`nr06.pdf`) é convertido automaticamente para `/arquivos/nr06.pdf`.
   - Erros `403`/`400` do backend exibidos em `SnackBar`.

2. **Treinamentos concluídos por funcionário (`TreinamentosDoFuncionarioScreen`)**:
   - Ao tocar em um funcionário na tela de Funcionários, abre o histórico consumindo `GET /treinamentos/realizados/funcionario/{id}`.
   - Cores por situação: 🟢 em dia, 🟠 vence em até 30 dias, 🔴 **vencido**.
   - Botão para abrir o PDF do material via `url_launcher`.

3. **Tela de Treinamentos (`TreinamentosScreen`)**:
   - **`AlertDialog` de confirmação** antes de registrar: *"Confirma que você leu o material e concluiu o treinamento?"*.
   - Badge **"Vencido – refazer"** e botão **"Refazer treinamento"** quando a validade passou.
   - Indicação de reciclagem ("Reciclagem a cada N meses") e progresso de conclusões.

4. **Menu condicional (`MainScreen`)**:
   - Item **"Cadastrar Treinamento"** só aparece para administradores (mesmo padrão da Aula 5).
   - Comparação de perfil com `trim().toLowerCase() == 'admin'`.

5. **Modelos e Serviços**:
   - `Treinamento` ganhou `validadeMeses` e `toJson()` para envio ao backend.
   - `TreinamentoRealizado` foi refeito para o novo DTO, **mantendo compatibilidade** com o formato antigo (objeto `treinamento` aninhado).
   - `TreinamentoService` (Dart) ganhou o método `cadastrar()`.

---

## 🛠️ Tecnologias Utilizadas

- **Backend**:
  - Java 17 / Spring Boot 4.1
  - Spring Data JPA / Hibernate
  - MySQL
  - Lombok
- **Frontend**:
  - Flutter / Dart
  - Pacote `http` para consumo de APIs REST
  - Pacote `url_launcher` para abrir PDFs
  - Material Design 3

---

## 🚀 Como Executar

### Backend (`api_epi`)

1. Certifique-se de ter o **JDK 17+** instalado e configurado no `JAVA_HOME`.
   > ⚠️ Com JDK 11 o build falha com `release version 17 not supported`.
2. Crie o banco `epi_db` no MySQL. A URL/usuário/senha podem ser trocados pelas
   variáveis de ambiente `DB_URL`, `DB_USER` e `DB_PASSWORD` (os padrões estão em
   `src/main/resources/application.properties`).
3. Rode o backend uma vez para o Hibernate criar as tabelas e, se quiser os dados
   de exemplo (3 funcionários, 8 EPIs, 4 treinamentos e empréstimos), importe:
   ```bash
   mysql -u root epi_db < database/seed.sql
   ```
   Usuários de exemplo: matrículas `1001` (ADMIN), `1002` e `1003` (FUNCIONARIO),
   todas com a senha `1234`.
4. No diretório raiz do projeto:
   ```bash
   ./mvnw spring-boot:run
   ```
5. A API estará acessível em `http://localhost:8080`.

> A coluna `validade_meses` é criada automaticamente pelo Hibernate (`ddl-auto=update`).

### Aplicativo Móvel (`app_epi`)

1. No diretório `app_epi`:
   ```bash
   flutter pub get
   flutter run
   ```

> **Plugins no Windows:** o Flutter exige suporte a symlink. Se aparecer *"Building with plugins requires symlink support"*, ative o **Modo de Desenvolvedor** em `start ms-settings:developers`.

> **Endereço da API:** o app usa `http://10.0.2.2:8080` automaticamente no emulador Android e `http://localhost:8080` no desktop/web. Em aparelho físico, rode com `flutter run --dart-define=API_BASE_URL=http://IP_DO_PC:8080`. O `AndroidManifest.xml` já declara a permissão `INTERNET` e libera HTTP em texto puro para desenvolvimento.

> **Enter no login:** pressionar Enter em qualquer um dos campos (matrícula ou senha) aciona o botão "Entrar".

---

## 🔑 Observações de Uso

- O perfil é comparado sem diferenciar maiúsculas/minúsculas em todas as camadas
  (`Admin`, `ADMIN`, `admin`); os dados de exemplo usam `ADMIN` e `FUNCIONARIO`.
- Para testar o **vencimento**, cadastre um treinamento com `validadeMeses` baixo (ex.: `1`) e ajuste a `data_conclusao` no banco.
- O parâmetro `adminId` vem da URL, não de autenticação real (token/sessão). Em produção, o id do usuário deve vir do token — hoje qualquer pessoa que saiba o id de um admin consegue cadastrar treinamentos.
- **Reinicie o backend** depois de atualizar: o `Dashboard.fromJson` agora espera `funcionariosCadastrados` e `estoqueBaixo`; sem reiniciar, o painel recebe `null` e dá erro de tipo.
- O `DashboardService` usa o **`AutorizacaoService`** para checar o perfil, a mesma regra de aprovar/devolver/cadastrar. O cálculo de `treinamentosPendentes` conta pares (funcionário, treinamento) distintos e nunca fica negativo.
- A lista de funcionários (`GET /funcionarios?adminId=...`) e o item "Funcionários" do menu lateral são exclusivos do perfil ADMIN; funcionários recebem `403`.
- O ADMIN pode **adicionar funcionário** (botão na tela de Funcionários) e **excluir** (ícone de lixeira). A exclusão exige digitar `EXCLUIR` no diálogo de confirmação e é bloqueada para o próprio usuário e para quem possui empréstimos ou treinamentos.
- Aprovar baixa 1 unidade e devolver soma 1, mas a solicitação **não reserva** estoque: vários pedidos pendentes podem passar do disponível até a aprovação.

---

## ✅ Verificação

| Item | Resultado |
|---|---|
| `./mvnw compile` | BUILD SUCCESS |
| `./mvnw test` | 14 testes, 0 falhas (usa H2 em memória) |
| `flutter analyze` | No issues found |
| `flutter test` | 4 testes, 0 falhas |
| POST /treinamentos com admin | `201 Created` |
| POST /treinamentos com não-admin | `403 Forbidden` |
| POST /treinamentos sem título | `400 Bad Request` |
| Treinamento vencido | Exibe "Vencido – refazer" e permite refazer |
| GET /dashboard (admin) | `200` com 8 indicadores |
| GET /dashboard (não-admin) | `403` |
| POST /funcionarios (admin) | `201 Created` |
| DELETE /funcionarios/{id} (admin) | `204 No Content` |
| POST/DELETE /funcionarios (não-admin) | `403 Forbidden` |
| Exclusão de funcionário com vínculos | `400 Bad Request` |
| PDFs `/arquivos/*.pdf` | `200` com o arquivo completo |
