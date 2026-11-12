# Sistema de Gestão e Controle de EPIs (api_epi & app_epi)

Sistema integrado para controle, conformidade regulamentadora (NR-06 / NR-35) e empréstimos de Equipamentos de Proteção Individual (EPIs), composto por uma API RESTful em **Spring Boot** e um aplicativo móvel em **Flutter**.

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
2. Crie o banco `epi_db` no MySQL e ajuste `src/main/resources/application.properties` se necessário.
3. No diretório raiz do projeto:
   ```bash
   ./mvnw spring-boot:run
   ```
4. A API estará acessível em `http://localhost:8080`.

> A coluna `validade_meses` é criada automaticamente pelo Hibernate (`ddl-auto=update`).

### Aplicativo Móvel (`app_epi`)

1. No diretório `app_epi`:
   ```bash
   flutter pub get
   flutter run
   ```

> **Plugins no Windows:** o Flutter exige suporte a symlink. Se aparecer *"Building with plugins requires symlink support"*, ative o **Modo de Desenvolvedor** em `start ms-settings:developers`.

> **Emulador Android:** `localhost` não aponta para a máquina host. Ajuste `lib/services/api_config.dart` para `http://10.0.2.2:8080`.

---

## 🔑 Observações de Uso

- O perfil do funcionário deve estar exatamente como `Admin` (a comparação ignora maiúsculas/minúsculas).
- Para testar o **vencimento**, cadastre um treinamento com `validadeMeses` baixo (ex.: `1`) e ajuste a `data_conclusao` no banco.
- O parâmetro `adminId` vem da URL, não de autenticação real (token/sessão). Em produção, o id do usuário deve vir do token — hoje qualquer pessoa que saiba o id de um admin consegue cadastrar treinamentos.
- **Reinicie o backend** depois de atualizar: o `Dashboard.fromJson` agora espera `funcionariosCadastrados` e `estoqueBaixo`; sem reiniciar, o painel recebe `null` e dá erro de tipo.
- O `DashboardService` exige o perfil **`ADMIN` exato** (como no material), enquanto o `AutorizacaoService` aceita `Admin`/`ADMIN` sem diferenciar maiúsculas. Se o banco gravar `Admin`, o painel responde `403` e os endpoints de aprovar/devolver funcionam — alinhar o `DashboardService` ao `AutorizacaoService` resolve.
- Aprovar baixa 1 unidade e devolver soma 1, mas a solicitação **não reserva** estoque: vários pedidos pendentes podem passar do disponível até a aprovação.

---

## ✅ Verificação

| Item | Resultado |
|---|---|
| `./mvnw compile` | BUILD SUCCESS |
| `dart analyze lib` | No issues found |
| POST /treinamentos com admin | `201 Created` |
| POST /treinamentos com não-admin | `403 Forbidden` |
| POST /treinamentos sem título | `400 Bad Request` |
| Treinamento vencido | Exibe "Vencido – refazer" e permite refazer |
| GET /dashboard (admin) | `200` com 8 indicadores — validar no Postman |
| GET /dashboard (não-admin) | `403` — validar no Postman |
| PUT aprovar / devolver | `200` — validar no Postman |
