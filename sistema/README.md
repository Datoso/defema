# Sistema Defema: catálogo online (guia passo a passo)

Com este sistema, a loja muda **preço, promoção, foto e produtos** por um painel, sem mexer no código do site.
Tudo roda em serviços **gratuitos**:

| Peça | Para que serve | Onde fica |
|---|---|---|
| **Supabase** | banco de dados + fotos + login | supabase.com |
| **Site** (`defema.html`) | vitrine para os clientes | Netlify ou Vercel |
| **Painel** (`sistema/admin/index.html`) | onde a loja edita os produtos | Netlify ou Vercel |

> Se o Supabase sair do ar, o site **continua funcionando** com a última cópia salva no aparelho do cliente
> ou com os produtos que já estão dentro do arquivo do site.

Tempo da primeira configuração: **cerca de 1 hora**.

---

## Arquitetura

```
   CLIENTE (celular/PC)                    SUPABASE (São Paulo)                    LOJA (família)
 ┌──────────────────────┐   lê (anon)   ┌───────────────────────────┐  edita   ┌──────────────────────┐
 │ Site  defema.com.br  │ ────────────▶ │ Banco: departamentos,     │ ◀─────── │ Painel  /admin       │
 │ carregar-produtos.js │ ◀──────────── │ subcategorias, produtos,  │ ───────▶ │ login e-mail/senha   │
 │ cópia no aparelho    │  produtos +   │ produto_opcoes            │          │ (só administradores) │
 │ + dados embutidos    │  fotos        │ Storage: bucket "produtos"│          └──────────────────────┘
 └──────────────────────┘               │ Regras (RLS): visitante   │
                                        │ só LÊ produtos ativos     │
                                        └───────────────────────────┘
```

- O **site** só lê (chave *anon*). Ele abre na hora com a cópia salva e se atualiza em segundo plano.
- O **painel** grava, mas só para usuários que estão na tabela `administradores`.
- As **fotos** ficam no Storage, numa pasta pública chamada `produtos`.

Pastas:

```
defema/
├── site/                     site atual (defema.html + img/)
└── sistema/
    ├── README.md             este guia
    ├── CONTRATO.md           estrutura do banco (para programadores)
    ├── package.json          dependências do script de importação
    ├── sql/                  01_schema.sql · 02_seguranca.sql · 03_dados.sql
    ├── dados/produtos.json   produtos atuais do site, exportados
    ├── scripts/importar.mjs  envia fotos (e dados) para o Supabase
    ├── admin/index.html      painel da loja
    └── site/                 ligação do site ao banco
        ├── carregar-produtos.js
        ├── INTEGRAR.md       como plugar no defema.html (para o programador)
        ├── defema.patch      as mesmas mudanças, prontas para aplicar
        └── teste.mjs         teste automático (node sistema/site/teste.mjs)
```

---

## 1. Criar a conta e o projeto no Supabase

1. Entre em **https://supabase.com** → **Start your project** → crie a conta (com GitHub ou e-mail).
2. Clique em **New project**:
   - **Name**: `defema`
   - **Database Password**: clique em **Generate a password** e **guarde a senha** em lugar seguro.
   - **Region**: **South America (São Paulo)**
   - Plano: **Free**
3. Clique em **Create new project** e espere uns 2 minutos até o projeto ficar pronto.

- [ ] Projeto `defema` criado na região São Paulo
- [ ] Senha do banco guardada

---

## 2. Criar as tabelas (SQL Editor)

No menu da esquerda, abra **SQL Editor** → **New query**. Para **cada arquivo abaixo, nesta ordem**:
abra o arquivo no computador (Bloco de Notas ou VS Code), copie **todo** o conteúdo, cole no editor e clique em **Run**.

1. `sistema/sql/01_schema.sql`: cria as tabelas
2. `sistema/sql/02_seguranca.sql`: cria as regras de quem pode ver e alterar, e a pasta de fotos
3. `sistema/sql/03_dados.sql`: cadastra os departamentos e os produtos atuais do site

Cada um deve terminar sem erro vermelho (normalmente "Success. No rows returned"). Se der erro, veja a seção 9.

> ⚠ O `03_dados.sql` volta os produtos aos dados originais do site. **Rode só na primeira vez.**
> Depois que a loja começar a usar o painel, não rode de novo.

- [ ] Os 3 arquivos rodaram sem erro, na ordem
- [ ] Em **Table Editor → produtos** aparecem os produtos

---

## 3. Criar o usuário administrador (quem entra no painel)

1. Menu **Authentication** → **Users** → **Add user** → **Create new user**.
2. Preencha o **e-mail** e uma **senha forte** da pessoa da loja. Marque **Auto Confirm User** e crie.
3. Clique no usuário criado e copie o **User UID** (algo como `3f2a9c1e-....`).
4. **SQL Editor** → **New query**, cole o comando trocando o código e clique em **Run**:
   ```sql
   insert into administradores(user_id) values ('COLE-AQUI-O-USER-UID');
   ```
5. Recomendado: nas configurações de **Authentication** (provedores / sign up), **desligue** a opção que
   permite que qualquer pessoa crie conta ("Allow new users to sign up"). Assim só você cria usuários.

- [ ] Usuário criado e confirmado
- [ ] UID inserido na tabela `administradores`

---

## 4. Subir as fotos dos produtos

As fotos estão em `site/img/`. Elas vão para o bucket **`produtos`** do Storage, **com o mesmo nome de arquivo**.

### Opção A: automática (precisa do Node.js 18 ou mais novo; baixe a versão "LTS" em nodejs.org)

Pegue a **service_role key** (ou "secret key") na área de chaves de API do projeto (veja o aviso na seção 7).
Num terminal, **na pasta `sistema`**:

```bash
cd sistema
npm install
SUPABASE_URL=https://SEU-PROJETO.supabase.co SUPABASE_SERVICE_ROLE_KEY=COLE-A-SERVICE-ROLE node scripts/importar.mjs
```

No **Windows (PowerShell)**, a última linha fica assim:

```powershell
$env:SUPABASE_URL="https://SEU-PROJETO.supabase.co"; $env:SUPABASE_SERVICE_ROLE_KEY="COLE-A-SERVICE-ROLE"; node scripts/importar.mjs
```

- Só conferir, sem enviar nada: acrescente `--simular`.
- Depois que a loja já estiver usando o painel, use **`--so-fotos`** (envia só as fotos e **não mexe** em preços nem textos).
- **Feche o terminal no fim**: a service_role não pode ficar salva em lugar nenhum.

### Opção B: manual, pelo site do Supabase

1. Menu **Storage** → bucket **produtos** (criado pelo `02_seguranca.sql`).
2. **Upload files** → arraste **todas** as fotos de `site/img/`.
3. **Não renomeie** os arquivos: o banco procura a foto pelo nome (ex.: `k-othrine-sc25.jpg`).

- [ ] Fotos aparecem em **Storage → produtos**
- [ ] Ao abrir uma foto e pegar a URL pública, a imagem abre no navegador

---

## 5. Ligar o site e o painel ao Supabase

1. Em **Project Settings → API** (em projetos novos: **API Keys** e **Data API**), copie:
   - **Project URL**: `https://xxxx.supabase.co`
   - **anon public** key (texto longo começando com `eyJ...`) **ou** a **publishable** key (`sb_publishable_...`).
     As duas servem e são públicas.
2. **Painel**: abra `sistema/admin/index.html` num editor de texto e preencha, no início do arquivo:
   ```js
   const SUPABASE_URL = "https://xxxx.supabase.co";
   const SUPABASE_ANON_KEY = "eyJ...";
   ```
3. **Site**: o programador aplica as mudanças descritas em `sistema/site/INTEGRAR.md`
   (ou o `defema.patch`) e copia `carregar-produtos.js` para a pasta do site. Depois, no `defema.html`:
   ```js
   const SUPABASE = { url: "https://xxxx.supabase.co", anonKey: "eyJ..." };
   ```
4. Teste: abra o painel, entre com o e-mail/senha da seção 3, mude o preço de um produto,
   recarregue o site e confira o preço novo (pode levar uma segunda recarga, veja a seção 8).

- [ ] Painel abre e o login funciona
- [ ] Site mostra o preço alterado no painel

---

## 6. Publicar de graça e usar o domínio próprio

### Montar a pasta para publicar

```
publicar/
├── index.html              ← o defema.html (já ligado ao Supabase) renomeado
├── carregar-produtos.js
├── og.png
├── img/                    ← fotos (reserva, caso o Supabase falhe)
└── admin/
    └── index.html          ← o painel (sistema/admin/index.html)
```

O site fica em `defema.com.br` e o painel em `defema.com.br/admin`.

### Netlify Drop (mais fácil)
1. Crie a conta em **https://app.netlify.com** → adicione um site novo com **deploy manual**.
2. **Arraste a pasta `publicar`** para a página. Sai um endereço `algo.netlify.app`. Teste-o.
3. Para atualizar depois: na aba **Deploys**, arraste a pasta de novo.

### Vercel (alternativa)
**https://vercel.com** → **Add New → Project** → envie a pasta (ou rode `npx vercel` dentro de `publicar`).

### Domínio (Registro.br)
1. Na Netlify (ou Vercel), em **Domains**, adicione `defema.com.br`. A própria tela mostra os registros de DNS a criar.
2. No **registro.br** → seu domínio → **DNS → Editar zona**, crie os registros que a Netlify/Vercel mostrou
   (normalmente um **A** para `defema.com.br` e um **CNAME** para `www`).
3. Espere de 1 a 24 horas. O **HTTPS** (cadeado) é ativado sozinho.

- [ ] Site no ar em `*.netlify.app` (ou `*.vercel.app`)
- [ ] `defema.com.br` abrindo com cadeado e `defema.com.br/admin` abrindo o painel

---

## 7. Segurança: leia uma vez

| Chave | Pode ficar pública? | Onde usar |
|---|---|---|
| **anon / publishable** | ✅ **Sim.** Ela só deixa **ver** produtos ativos, departamentos e fotos. As regras do banco (RLS) bloqueiam o resto. | site e painel |
| **service_role / secret** | ❌ **NUNCA.** Ela ignora todas as regras: quem tiver essa chave pode apagar tudo. | só no terminal, na hora de importar (seção 4) |

- **Nunca** cole a service_role no site, no painel, em e-mail ou em mensagem.
- **Quem é admin?** Só quem está na tabela `administradores`. Uma pessoa com login, mas fora dessa tabela, **não altera nada**.
- **Novo funcionário**: repita a seção 3. Cada um com **o próprio login**.
- **Tirar o acesso** (SQL Editor) e depois apagar o usuário em **Authentication → Users**:
  ```sql
  delete from administradores where user_id = (select id from auth.users where email = 'pessoa@email.com');
  ```
- Se a service_role vazar: gere uma nova na área de chaves de API do projeto (a antiga deixa de valer).

---

## 8. Uso no dia a dia (pelo painel `defema.com.br/admin`)

Entre com seu e-mail e senha, procure o produto e clique nele.

| Quero... | Faça assim |
|---|---|
| **Mudar o preço** | Altere **Preço** → **Salvar**. Vazio = "Consultar preço". |
| **Colocar em promoção** | Em **Preço antigo**, o preço de antes (aparece riscado); em **Preço**, o novo, **menor**. Salve. |
| **Tirar da promoção** | Apague o **Preço antigo** → Salvar. |
| **Trocar a foto** | Escolha uma imagem nova (quadrada, JPG) → Salvar. |
| **Esconder um produto** (acabou) | Desmarque **Ativo** → Salvar. Some do site, mas fica no painel para reativar. |
| **Destacar** | Marque **Mais procurado** ou **Novidade**. |
| **Produto novo** | **Novo produto** → nome, marca, departamento/subcategoria, unidade, preço, foto → Salvar. |

**Quando aparece no site?** Para quem abre o site pela primeira vez, na hora. Quem já visitou vê primeiro
a cópia salva no aparelho e, em poucos segundos, a página se atualiza sozinha com o preço novo.

**Plano B sem o painel:** no Supabase, **Table Editor → produtos**, edite a célula (`preco`, `preco_antigo`, `ativo`...) e salve.

**Cópia de reserva dentro do site:** o `index.html` traz uma cópia do catálogo (entre os marcadores
`<catalogo-embutido>`), usada quando o Supabase não responde. Ela é atualizada **sozinha todo dia às 6h**
pelo GitHub Actions (**Actions → Sincronizar catálogo**), que também baixa para `img/` as fotos novas do painel.
Para atualizar na hora, abra essa tela e clique em **Run workflow**. Essa visita diária ao banco também evita
que o plano grátis do Supabase pause o projeto por falta de acesso. Não edite essa parte do `index.html` à mão:
a próxima sincronização sobrescreve. Para conferir sem gravar: `node sistema/scripts/sincronizar-embutido.mjs --simular`.

---

## 9. Problemas comuns

| Problema | O que fazer |
|---|---|
| O site não mostra as mudanças | Recarregue. Confira `url` e `anonKey` no site (sem espaço sobrando). Aperte F12 → **Console**: o aviso `[Defema] ...` mostra o motivo. |
| `HTTP 401` / `Invalid API key` | A chave está errada ou incompleta. Copie de novo a **anon/publishable**. |
| `HTTP 400` / "column does not exist" | Os SQLs não rodaram completos ou fora de ordem. Rode `01` e depois `02`. |
| Login do painel funciona, mas não salva ("row-level security") | O usuário não está em `administradores`. Refaça o passo 3.4. |
| Foto não aparece (só o ícone) | O nome do arquivo no Storage tem de ser **igual** ao cadastrado (maiúsculas e acentos contam) e o bucket `produtos` tem de ser público. |
| "Project paused" | No plano grátis o projeto pausa após alguns dias **sem nenhum acesso** (a sincronização diária da seção 8 evita isso). No Supabase, clique em **Restore project**. Enquanto isso o site usa a cópia salva/os dados embutidos. |
| Esqueci a senha do painel | **Authentication → Users** → envie a recuperação de senha, ou crie o usuário de novo e refaça o passo 3.4. |
| `importar.mjs` reclama de `SUPABASE_URL` | As variáveis têm de estar na **mesma linha/janela** do comando (veja o exemplo do Windows na seção 4). |
| O domínio não abre | O DNS pode levar até 24 h. Confira os registros no Registro.br. |
