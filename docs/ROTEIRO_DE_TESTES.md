# Roteiro de testes: Conecta+

**Ambiente:** Flutter 3.50.0 · Navegador Chrome · Supabase (projeto próprio)
**Pré-requisito:** `supabase/schema.sql` executado e confirmação de e-mail desligada.
**Usuários de teste:** A (janela normal) e B (janela anônima).

Legenda: ✅ passou · ❌ falhou · ➖ não aplicável

## 1. Autenticação

| ID | Cenário | Passos | Resultado esperado | Status |
|---|---|---|---|---|
| A1 | Cadastro válido | Preencher nome, e-mail e senha (6+) e criar a conta | Mensagem verde e redirecionamento à Home | ☐ |
| A2 | Cadastro com campos vazios | Tocar em "Criar conta" sem preencher | Erro de validação em cada campo | ☐ |
| A3 | E-mail inválido | Digitar `abc` no e-mail | "E-mail inválido" | ☐ |
| A4 | Senha curta | Digitar 3 caracteres | "A senha deve ter pelo menos 6 caracteres" | ☐ |
| A5 | Senhas diferentes | Confirmar senha diferente | "As senhas não conferem" | ☐ |
| A6 | E-mail já cadastrado | Cadastrar o e-mail do usuário A de novo | "Este e-mail já está cadastrado." | ☐ |
| A7 | Login válido | Entrar com e-mail e senha corretos | Home | ☐ |
| A8 | Login com senha errada | Entrar com senha incorreta | "E-mail ou senha incorretos." | ☐ |
| A9 | Logout | Perfil → "Sair da conta" | Tela de login | ☐ |
| A10 | Persistência da sessão | Logado, recarregar a página (F5) | Continua logado | ☐ |
| A11 | Perfil criado pelo trigger | Table Editor → `profiles` | Linha com o nome digitado no cadastro | ☐ |
| A12 | Dados do perfil | Abrir Perfil | Nome e e-mail reais, inicial no avatar | ☐ |

## 2. Proteção de rotas

| ID | Cenário | Passos | Resultado esperado | Status |
|---|---|---|---|---|
| R1 | Deslogado acessa tela interna | Sem login, abrir `/#/events` | Redireciona ao login | ☐ |
| R2 | Logado acessa o login | Logado, abrir `/#/login` | Redireciona à Home | ☐ |
| R3 | Rota inexistente | Abrir `/#/qualquer-coisa` | "Página não encontrada" | ☐ |
| R4 | Navegação | Percorrer as 5 abas e abrir/voltar de detalhes | Sem erros; botão voltar funciona | ☐ |

## 3. Eventos

| ID | Cenário | Passos | Resultado esperado | Status |
|---|---|---|---|---|
| E1 | Validação do formulário | Cadastrar sem preencher | Erros em todos os campos obrigatórios | ☐ |
| E2 | Cadastrar | Preencher tudo, incluindo data e hora | Mensagem verde; card na lista | ☐ |
| E3 | Seletores em português | Abrir calendário e relógio | Textos em português | ☐ |
| E4 | Detalhes | Abrir o evento | Todos os campos exibidos | ☐ |
| E5 | Editar | Alterar o título e salvar | Detalhes e lista atualizados | ☐ |
| E6 | Excluir (cancelar) | Excluir e cancelar | Nada é apagado | ☐ |
| E7 | Excluir (confirmar) | Excluir e confirmar | Mensagem verde; some da lista e do banco | ☐ |
| E8 | Ordenação | Ter eventos futuros e passados | Futuros primeiro, passados depois | ☐ |
| E9 | Lista vazia | Sem eventos | Estado vazio com botão de cadastro | ☐ |

## 4. Rede de apoio

| ID | Cenário | Passos | Resultado esperado | Status |
|---|---|---|---|---|
| I1 | Cadastrar sem site | Deixar o site em branco | Salva; detalhes sem a linha de site | ☐ |
| I2 | Cadastrar com site | Informar `@perfil` | Detalhes mostram o site; texto selecionável | ☐ |
| I3 | Apagar o site ao editar | Esvaziar o campo e salvar | Coluna `website` vira `NULL` no banco | ☐ |
| I4 | Editar e excluir | Alterar e excluir | Funcionam, com confirmação | ☐ |
| I5 | Ordenação | Cadastrar nomes diferentes | Ordem alfabética | ☐ |

## 5. Iniciativas

| ID | Cenário | Passos | Resultado esperado | Status |
|---|---|---|---|---|
| N1 | Cadastrar sem contato | Deixar o contato em branco | Salva; detalhes sem a linha de contato | ☐ |
| N2 | Editar e excluir | Alterar e excluir | Funcionam, com confirmação | ☐ |
| N3 | Ordenação | Cadastrar duas iniciativas | A mais nova no topo | ☐ |

## 6. Permissões (usuário B, janela anônima)

| ID | Cenário | Passos | Resultado esperado | Status |
|---|---|---|---|---|
| P1 | Leitura geral | B abre as listas | Vê os registros de A nos 3 módulos | ☐ |
| P2 | Botões ocultos | B abre um detalhe de A | Não aparecem Editar nem Excluir | ☐ |
| P3 | Edição por URL (eventos) | B abre `/#/events/<id-de-A>/edit` | "Você só pode editar eventos cadastrados por você." | ☐ |
| P4 | Edição por URL (instituições) | Idem em `/#/institutions/<id>/edit` | Mensagem equivalente | ☐ |
| P5 | Edição por URL (iniciativas) | Idem em `/#/initiatives/<id>/edit` | Mensagem equivalente | ☐ |
| P6 | Cadastro próprio | B cadastra um registro | Funciona; `user_id` é o de B | ☐ |
| P7 | Políticas no banco | `select count(*) from pg_policies where schemaname = 'public';` | 17 | ☐ |
| P8 | RLS ativo | `select tablename, rowsecurity from pg_tables where schemaname = 'public';` | `true` nas 5 tabelas | ☐ |

## 7. Favoritos

| ID | Cenário | Passos | Resultado esperado | Status |
|---|---|---|---|---|
| F1 | Favoritar | Tocar no coração de um evento | Coração preenchido e mensagem verde | ☐ |
| F2 | Desfavoritar | Tocar de novo | Coração vazio | ☐ |
| F3 | Persistência | Reabrir o item | Coração continua preenchido | ☐ |
| F4 | Lista de favoritos | Favoritar um item de cada módulo | Os 3 aparecem, mais recente primeiro | ☐ |
| F5 | Atualização entre abas | Favoritar e ir à aba Favoritos | Lista atualizada sem recarregar | ☐ |
| F6 | Privacidade | B abre a aba Favoritos | Vazia, mesmo A tendo favoritos | ☐ |
| F7 | Mesmo item, dois usuários | A e B favoritam o mesmo evento | Duas linhas em `favorites`, com `user_id` diferentes | ☐ |
| F8 | Exclusão em cascata | Excluir um item favoritado | Some também dos favoritos | ☐ |

## 8. Home

| ID | Cenário | Passos | Resultado esperado | Status |
|---|---|---|---|---|
| H1 | Destaques | Abrir a Home com cadastros | Até 5 itens, misturados, mais novos primeiro | ☐ |
| H2 | Atualização | Cadastrar algo e tocar na aba Início | Item novo nos destaques | ☐ |
| H3 | Atalhos | Tocar nos 3 atalhos | Abrem as abas corretas | ☐ |

## 9. Interface e tratamento de erros

| ID | Cenário | Passos | Resultado esperado | Status |
|---|---|---|---|---|
| U1 | Janela estreita | Reduzir a janela para ~360 px | Sem textos cortados ou *overflow* | ☐ |
| U2 | Janela larga | Maximizar | Conteúdo centralizado e limitado | ☐ |
| U3 | Carregamento | Observar login, listas e salvamentos | Indicadores visíveis; botões desabilitados | ☐ |
| U4 | Mensagens | Provocar sucesso e erro | Verde-água para sucesso, vermelho para erro | ☐ |
| X1 | Sem conexão | DevTools (F12) → Network → *Offline*; abrir uma lista | "Falha de conexão..." com "Tentar novamente" | ☐ |
| X2 | Recuperação | Voltar *Online* e tocar em "Tentar novamente" | Lista carrega | ☐ |

## Defeitos encontrados

| ID do teste | Descrição | Correção aplicada |
|---|---|---|
| | | |