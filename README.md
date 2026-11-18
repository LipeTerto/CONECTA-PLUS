# Conecta+

> Plataforma mobile de conexão, informação e acolhimento voltada à comunidade LGBTQIA+.

Projeto acadêmico desenvolvido na **Fatec**, curso de **Desenvolvimento de Software Multiplataforma - DSM**, disciplina de **Programação de Dispositivos Móveis II**, **5º Semestre**.

**Autor:** Filipe Teixeira Terto · **Orientação:** Elias Carneiro de Oliveira

## Sumário

1. [Sobre o projeto](#1-sobre-o-projeto)
2. [Objetivo e problema](#2-objetivo-e-problema)
3. [Funcionalidades](#3-funcionalidades)
4. [Tecnologias](#4-tecnologias)
5. [Instalação das dependências](#5-instalação-das-dependências)
6. [Configuração do Supabase](#6-configuração-do-supabase)
7. [Execução](#7-execução)
8. [Autenticação](#8-autenticação)
9. [Testes](#9-testes)

---

## 1. Sobre o projeto

O **Conecta+** é um aplicativo mobile que funciona como um **catálogo colaborativo** para a comunidade LGBTQIA+. Qualquer pessoa cadastrada pode consultar eventos, instituições de apoio e projetos sociais, e também contribuir indicando novos cadastros.

O projeto tem finalidade social: facilitar o acesso à informação e fortalecer a conexão entre pessoas, organizações e iniciativas da comunidade.

## 2. Objetivo e problema

**Problema:** informações sobre eventos, espaços de acolhimento, ONGs e projetos voltados à comunidade LGBTQIA+ costumam estar dispersas em redes sociais, grupos de mensagens e sites diversos, o que dificulta encontrá-las, especialmente por quem está começando a buscar apoio.

**Objetivo:** reunir essas informações em um único aplicativo, organizado por categorias e alimentado pela própria comunidade, em que cada pessoa controla apenas o que cadastrou.

**Privacidade:** o app não pede informações sensíveis, como orientação sexual ou identidade de gênero. O cadastro exige apenas nome, e-mail e senha.

## 3. Funcionalidades

- **Autenticação:** cadastro, login e logout com e-mail e senha, validação de campos, mensagens de erro em português e proteção das telas internas.
- **Início:** boas-vindas, acesso rápido aos módulos e destaques com os cadastros mais recentes.
- **Eventos:** listagem, detalhes, cadastro, edição e exclusão (título, descrição, categoria, data, horário, local, endereço e organização).
- **Rede de apoio:** catálogo de instituições, ONGs e espaços de acolhimento, com CRUD completo e campo opcional de site ou rede social.
- **Iniciativas:** projetos, campanhas e ações comunitárias, com CRUD completo e contato opcional.
- **Favoritos:** cada usuário salva eventos, instituições e iniciativas, em uma lista privada.
- **Perfil:** nome, e-mail e saída da conta.
- **Permissões por autoria:** todos os usuários logados veem os registros, mas somente o autor edita ou exclui o que cadastrou.
- **Interface:** tema roxo e lilás, cards, indicadores de carregamento, estados vazios, mensagens de sucesso e erro, e layout responsivo.

## 4. Tecnologias

| Tecnologia | Uso |
|---|---|
| Flutter 3.50.0 e Dart | Desenvolvimento do aplicativo |
| `material_ui` | Componentes Material (o Material saiu do SDK a partir do Flutter 3.47) |
| `supabase_flutter` | Autenticação e acesso ao banco |
| Supabase Authentication | Cadastro, login e sessão |
| Supabase Database (PostgreSQL) | Persistência, com Row Level Security |
| `go_router` | Rotas, navegação por abas e proteção de telas |
| `intl` | Formatação de datas e horários em português |
| Git e GitHub | Versionamento e entrega |

As versões exatas estão no `pubspec.yaml` e no `pubspec.lock`.


## 5. Instalação das dependências

**Pré-requisitos:** Flutter 3.50.0, Git e um navegador Chrome.

```bash
git clone https://github.com/[seu-usuario]/[nome-do-repositorio].git
cd [nome-do-repositorio]
flutter pub get
```

## 6. Configuração do Supabase

1. Em [supabase.com](https://supabase.com), crie um projeto. Guarde a senha do banco em local seguro; ela **não** é usada no app.
2. Abra **SQL Editor → New query**, cole todo o conteúdo de [`supabase/schema.sql`](supabase/schema.sql) e execute **uma única vez**. O script cria as tabelas, o trigger de perfil, as permissões e as políticas RLS.
3. Em **Authentication → Sign In / Providers → Email**, desative **Confirm email** para o ambiente de desenvolvimento. Em produção, mantenha ativado.
4. Copie a **Project URL** e a **publishable key** (*Project Settings → API Keys* ou botão **Connect**) e cole em `lib/config/supabase_config.dart`:

```dart
static const String url = 'https://SEU-PROJETO.supabase.co';
static const String publishableKey = 'SUA-CHAVE-PUBLICA';
```

A URL deve ser só o domínio, sem `/rest/v1` e sem barra no final.

> **Atenção:** use somente a chave **pública** (*publishable*). A *secret key*, a *service_role key* e a senha do banco **nunca** devem entrar no código nem no repositório.

## 7. Execução

**No navegador:**

```bash
flutter run -d web-server --web-hostname localhost --web-port 3000
```

Depois abra `http://localhost:3000`. Alternativamente, use `flutter run -d chrome`.

**Em dispositivo ou emulador Android:**

```bash
flutter devices
flutter run -d <id-do-dispositivo>
```

Para gerar um APK de release, adicione a permissão de internet em `android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

> O projeto foi desenvolvido e testado no navegador Chrome. A execução em Android e iOS não foi validada.

**Análise e build:**

```bash
flutter analyze
flutter build web
```

## 8. Autenticação

Utiliza o **Supabase Authentication** com e-mail e senha.

- **Cadastro:** nome, e-mail e senha (mínimo de 6 caracteres) com confirmação de senha. O nome viaja no campo `data` do `signUp` e é guardado nos metadados do usuário.
- **Perfil automático:** um *trigger* no banco (`handle_new_user`) cria a linha correspondente em `profiles` assim que o usuário é criado, copiando o nome informado.
- **Login e logout:** `signInWithPassword` e `signOut`.
- **Sessão:** guardada pelo `supabase_flutter` e restaurada ao reabrir o app.
- **Proteção de rotas:** o `AuthNotifier` observa o estado de login e avisa o GoRouter. A função `redirect` envia usuários não autenticados ao `/login` e usuários autenticados para fora das telas de login e cadastro.
- **Erros:** o `AuthService` converte as mensagens do Supabase em português e as lança como `AuthFailure`.
- **Dados sensíveis:** orientação sexual e identidade de gênero **não** são coletadas.

## 9. Testes

Os testes foram **manuais**, seguindo o roteiro em [`docs/ROTEIRO_DE_TESTES.md`](docs/ROTEIRO_DE_TESTES.md): autenticação, proteção de rotas, CRUD dos três módulos, permissões entre dois usuários, favoritos, interface e tratamento de erros.