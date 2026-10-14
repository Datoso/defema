# Ligar o site (`defema.html`) ao Supabase

São **4 mudanças** no `defema.html` + 1 linha no `build.py`. Nenhuma outra função do site muda:
`PRODUTOS`, `DEPS` e `DEP_INFO` continuam `const`; o conteúdo deles é trocado **no lugar**.

Como fica o carregamento:

1. A página abre **na hora** (síncrono, como hoje) com a última cópia salva no aparelho
   (`localStorage`) ou, se não houver, com os produtos escritos no próprio HTML.
2. Em segundo plano, `carregarCatalogo()` busca no Supabase (limite de 6 s).
3. Se chegou algo diferente, o site troca os dados e redesenha a tela atual.
4. Se o Supabase falhar, nada acontece: o cliente continua vendo a cópia/os dados embutidos.

> Atalho: o patch com as 4 mudanças está em `sistema/site/defema.patch`.
> Na pasta `defema/`: `patch -p0 --dry-run < sistema/site/defema.patch` e, se não der erro,
> rode de novo sem `--dry-run`. Se o site tiver mudado muito, faça os passos à mão.

---

## Passo 1 · Carregar o script

Copie `sistema/site/carregar-produtos.js` para a mesma pasta do `defema.html`
e coloque esta linha **logo antes** do `<script>` principal (o que começa com
`/* ===== CONFIGURAÇÃO DA LOJA`):

```html
<script src="carregar-produtos.js"></script>
<script>
/* ===== CONFIGURAÇÃO DA LOJA (troque pelos dados reais) ===== */
```

Se o arquivo faltar, o site continua funcionando só com os dados embutidos
(`TEM_SUPABASE` fica `false`).

## Passo 2 · Configuração + troca no lugar (logo depois do array `PRODUTOS`)

Logo **depois** da linha `PRODUTOS.forEach((p,i)=>p.id=i);`, cole:

```js
/* ===== CATÁLOGO ONLINE (Supabase) =====
   Cole aqui o "Project URL" e a chave "anon public" (Settings > API).
   Vazios = o site usa só os produtos escritos acima. NUNCA use a service_role. */
const SUPABASE = { url: "", anonKey: "" };
const TEM_SUPABASE = !!(SUPABASE.url && SUPABASE.anonKey && window.carregarCatalogo);
/* cópia dos produtos escritos acima: usada se o Supabase falhar na 1ª visita */
const EMBUTIDO = { PRODUTOS: PRODUTOS.slice(), DEPS: {...DEPS}, DEP_INFO: {...DEP_INFO} };
/* troca o conteúdo de PRODUTOS/DEPS/DEP_INFO NO LUGAR (eles continuam const).
   Devolve true se algo mudou. */
function trocarCatalogo(d){
  if(!d || !d.PRODUTOS || !d.PRODUTOS.length) return false;
  if(assinaturaCatalogo(d) === assinaturaCatalogo({PRODUTOS, DEPS, DEP_INFO})) return false;
  PRODUTOS.splice(0, PRODUTOS.length, ...d.PRODUTOS);
  PRODUTOS.forEach((p,i)=>p.id=i);
  for(const k in DEPS) delete DEPS[k];
  for(const k in DEP_INFO) delete DEP_INFO[k];
  Object.assign(DEPS, d.DEPS); Object.assign(DEP_INFO, d.DEP_INFO);
  return true;
}
/* abre já com a última cópia salva neste aparelho (antes de restaurar o pedido) */
if(TEM_SUPABASE) trocarCatalogo(lerCatalogoCache({url: SUPABASE.url}));
```

**Por que aqui e não no fim?** Mais abaixo o site restaura o pedido salvo
(`defema-pedido`) e descarta itens cujo produto não existe. Aplicando a cópia
salva antes disso, itens de produtos cadastrados pelo painel não somem do pedido.

## Passo 3 · Descrição do banco tem prioridade

Primeira linha **dentro** de `function descricao(p){`:

```js
function descricao(p){
  if(p.descricao) return p.descricao;   // texto cadastrado no painel tem prioridade
  if(DESC_MARCA[p.nome+"|"+p.marca]) return DESC_MARCA[p.nome+"|"+p.marca];
  ...
```

Produto sem descrição no banco chega com `descricao: ""` e cai nas regras atuais
(`DESC_MARCA`, `DESC`, `NPK`, sementes, mudas…).

## Passo 4 · Boot assíncrono (fim do script)

Troque o `render();` final (o que vem logo depois de
`if(["inicio","produtos","sobre"].includes(h)) state.page = h;`) por:

```js
/* departamento novo criado no painel: usa ícone e cores padrão */
function coresPadrao(){
  Object.keys(DEPS).forEach(d=>{ ICON[d] ??= ICON["Ferramentas"]; TINT[d] ??= "#eef0ec"; INK[d] ??= "#1f4d2d"; });
}
/* chega catálogo novo do Supabase: troca e redesenha a tela atual */
function atualizarCatalogo(d){
  if(!trocarCatalogo(d)) return;
  coresPadrao();
  for(const k in SEL) delete SEL[k];                 // ids mudaram: zera opções escolhidas
  const dlg = document.getElementById("dlgProduto"); if(dlg.open) dlg.close();
  if(state.dep && !DEPS[state.dep]) { state.dep = null; state.sub = null; }
  renderAtalhos(); atualizarPedido(); render();
}
coresPadrao();
renderAtalhos();
render();
if(TEM_SUPABASE) carregarCatalogo({ ...SUPABASE, fallback: EMBUTIDO, onAtualizar: atualizarCatalogo })
  .then(atualizarCatalogo);
```

- `carregarCatalogo` **nunca rejeita**. Ela devolve `{PRODUTOS, DEPS, DEP_INFO, origem}`:
  `"cache"` (respondeu com a cópia e revalida por trás; `onAtualizar` é chamado se mudou),
  `"supabase"` ou `"embutido"` (falhou → devolve o `fallback`).
- `atualizarCatalogo` só redesenha se o conteúdo mudou (compara por `assinaturaCatalogo`),
  então chamar duas vezes com o mesmo dado não pisca a tela.
- O pedido (`PEDIDO`) usa nome + marca, não o `id`, e continua válido após a troca.

## Build standalone (`out/defema.html`, arquivo único)

O `build.py` já troca `img/...` por data URLs nos produtos **embutidos** (que viram o
`fallback`). Falta só embutir o carregador. No `build.py`, antes do `open(...,'w')`, adicione:

```python
TAG = '<script src="carregar-produtos.js"></script>'
js = open('/home/claude/defema/sistema/site/carregar-produtos.js').read()
s = s.replace(TAG, '<script>\n' + js + '\n</script>', 1)
```

(O arquivo não contém `</script>`, então pode ser colado inline sem escapar.)
No standalone, as fotos que vêm do Supabase são URLs do Storage (precisam de internet);
sem internet, vale o fallback com as fotos embutidas.

## Como testar

- Teste automático do carregador: `node sistema/site/teste.mjs` (15 casos).
- No navegador: abra o site com o DevTools → Rede. Deve aparecer
  `.../rest/v1/produtos?select=...` com status 200. Mude um preço no painel e
  recarregue: na 1ª recarga aparece a cópia antiga e, em instantes, o preço novo.
- Com `SUPABASE.url` vazio o site se comporta exatamente como hoje.

## Detalhes do mapeamento (banco → site)

| Banco | Site |
|---|---|
| `nome`, `marca` (null → omitido) | `nome`, `marca` |
| `subcategorias.departamentos.nome` / `subcategorias.nome` | `dep` / `sub` |
| `unidade` | `un` |
| `preco` (null = "Consultar preço"), `preco_antigo` | `preco`, `antigo` |
| `destaque`, `novidade`, `restrito`, `por_metro` | `top`, `novo`, `restrito`, `porMetro` (só quando `true`) |
| `foto_url` (caminho no bucket `produtos`) | `foto` = `URL/storage/v1/object/public/produtos/<caminho>` |
| `ilustracao`, `icone` | `ilu`, `icone` |
| `produto_opcoes` ordenadas por `ordem`, `op_nome` | `opcoes`, `opNome` (omitidos se não houver opções) |
| `descricao` | `descricao` (`""` se vazio) |
| tabela `departamentos` + `subcategorias` (por `ordem`) | `DEPS`, `DEP_INFO` |

Catálogo vazio vindo do Supabase é tratado como **erro** (quase sempre é chave ou RLS
errados), para não apagar a vitrine.
