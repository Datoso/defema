// Teste de carregar-produtos.js (Node 18+, sem internet).
// Roda o arquivo como <script> clássico num "navegador" falso (node:vm),
// com fetch e localStorage simulados.   Uso: node sistema/site/teste.mjs
import assert from "node:assert/strict";
import fs from "node:fs";
import vm from "node:vm";

const codigo = fs.readFileSync(new URL("./carregar-produtos.js", import.meta.url), "utf8");
const SUPA = "https://abcd1234.supabase.co";
const ANON = "eyJhbGciOiJIUzI1NiJ9.anon.assinatura"; // formato JWT da chave anon clássica
const espera = ms => new Promise(r => setTimeout(r, ms));

/** Cria um "navegador" novo. memoria = Map do localStorage (pode ser compartilhado). */
function navegador(fetchFalso, { memoria = new Map(), semStorage = false } = {}) {
  const avisos = [];
  const win = {
    fetch: fetchFalso, AbortController, setTimeout, clearTimeout,
    console: { warn: (...a) => avisos.push(a.join(" ")), log() {} },
    localStorage: semStorage
      ? { getItem() { throw new Error("SecurityError"); }, setItem() { throw new Error("SecurityError"); } }
      : { getItem: k => (memoria.has(k) ? memoria.get(k) : null), setItem: (k, v) => memoria.set(k, String(v)) },
  };
  win.window = win;
  vm.createContext(win);
  vm.runInContext(codigo, win, { filename: "carregar-produtos.js" });
  return { win, memoria, avisos };
}
// Objetos criados dentro do vm têm outro Object.prototype: normaliza antes de comparar
const puro = o => JSON.parse(JSON.stringify(o));

/* ---------- payload realista, como o PostgREST devolve ---------- */
const FERR = { nome: "Ferramentas", info: "Enxadas, pás, martelos, furadeiras", ordem: 2 };
const DEF = { nome: "Defensivos", info: "Inseticidas, carrapaticidas e uso profissional", ordem: 1 };
const SEM = { nome: "Sementes", info: "Hortaliças Isla", ordem: 4 };
const linha = (x) => ({
  id: crypto.randomUUID(), marca: null, preco: null, preco_antigo: null, descricao: null, foto_url: null,
  ilustracao: null, icone: null, destaque: false, novidade: false, restrito: false, por_metro: false,
  op_nome: null, ativo: true, ordem: 0, criado_em: "2026-10-14T12:00:00Z", atualizado_em: "2026-10-14T12:00:00Z",
  produto_opcoes: [], ...x,
});
const PRODUTOS_DB = [
  // ordem 30 vem primeiro no array de propósito: o carregador tem de reordenar
  linha({ nome: "Chave combinada", unidade: "Boca e estria · unitária", preco: 18.5, preco_antigo: 22,
    op_nome: "Medida", ordem: 30, destaque: true,
    produto_opcoes: [{ nome: "10 mm", ordem: 2 }, { nome: "8 mm", ordem: 1 }, { nome: "12 mm", ordem: 3 }],
    subcategorias: { nome: "Ferramentas manuais", ordem: 1, departamentos: FERR } }),
  linha({ nome: "K-Othrine SC 25", marca: "Bayer", unidade: "Frasco 30 mL · ambientes externos",
    descricao: "Inseticida piretroide (deltametrina).", foto_url: "k-othrine-sc25.jpg", ordem: 10,
    subcategorias: { nome: "Inseticidas", ordem: 1, departamentos: DEF } }),
  linha({ nome: "Ficam VC Profissional", marca: "Envu", unidade: "Sachê 15 g", restrito: true,
    foto_url: "produtos/ficam vc.jpg", ordem: 20, novidade: true,
    subcategorias: { nome: "Uso profissional", ordem: 3, departamentos: DEF } }),
  linha({ nome: "Alface crespa", marca: "Isla", unidade: "Envelope", preco: "6.50", por_metro: false,
    ilustracao: ["envelope", "Alface|crespa", "#2f6b2f", "#e8f3df"], ordem: 40,
    subcategorias: { nome: "Folhosas e temperos", ordem: 1, departamentos: SEM } }),
  // o produto inativo NÃO vem (o RLS e o filtro ativo=eq.true o escondem)
];
const DEPS_DB = [
  { ...SEM, subcategorias: [{ nome: "Raízes e bulbos", ordem: 3 }, { nome: "Folhosas e temperos", ordem: 1 }] },
  { ...DEF, subcategorias: [{ nome: "Uso profissional", ordem: 3 }, { nome: "Inseticidas", ordem: 1 }, { nome: "Carrapaticidas e mosquicidas", ordem: 2 }] },
  { ...FERR, subcategorias: [{ nome: "Ferramentas manuais", ordem: 1 }] },
];
const FALLBACK = {
  PRODUTOS: [{ nome: "Produto embutido", dep: "Ferramentas", sub: "Ferramentas manuais", un: "un", preco: null, id: 0 }],
  DEPS: { Ferramentas: ["Ferramentas manuais"] }, DEP_INFO: { Ferramentas: "embutido" },
};

const resp = (corpo, status = 200) => ({ ok: status < 300, status, json: async () => structuredClone(corpo) });
function fetchOk(produtos = PRODUTOS_DB, deps = DEPS_DB, log = []) {
  return async (url, init) => {
    log.push({ url, init });
    return url.includes("/rest/v1/produtos?") ? resp(produtos) : resp(deps);
  };
}
let ok = 0;
const teste = async (nome, fn) => { await fn(); ok++; console.log("  ✔ " + nome); };
console.log("carregar-produtos.js");

/* ---------- 1) mapeamento ---------- */
await teste("busca no Supabase e mapeia para o formato do site", async () => {
  const log = [];
  const { win, memoria } = navegador(fetchOk(PRODUTOS_DB, DEPS_DB, log));
  const r = await win.carregarCatalogo({ url: SUPA + "/", anonKey: ANON, fallback: FALLBACK });
  assert.equal(r.origem, "supabase");
  assert.equal(r.erro, undefined);

  // requisições: endpoint, filtro, ordem, embed e cabeçalhos
  const p = log.find(x => x.url.includes("/rest/v1/produtos?"));
  const u = new URL(p.url);
  assert.equal(u.origin + u.pathname, SUPA + "/rest/v1/produtos");
  assert.equal(u.searchParams.get("select"), "*,produto_opcoes(nome,ordem),subcategorias(nome,ordem,departamentos(nome,info,ordem))");
  assert.equal(u.searchParams.get("ativo"), "eq.true");
  assert.equal(u.searchParams.get("order"), "ordem.asc");
  assert.equal(p.init.headers.apikey, ANON);
  assert.equal(p.init.headers.Authorization, "Bearer " + ANON);
  assert.ok(log.some(x => x.url.startsWith(SUPA + "/rest/v1/departamentos?")), "consulta departamentos");


  const P = puro(r.PRODUTOS);
  assert.deepEqual(P.map(x => x.nome), ["K-Othrine SC 25", "Ficam VC Profissional", "Chave combinada", "Alface crespa"], "ordem do banco");
  assert.deepEqual(P.map(x => x.id), [0, 1, 2, 3], "id = posição");

  assert.deepEqual(P[0], {
    nome: "K-Othrine SC 25", marca: "Bayer", dep: "Defensivos", sub: "Inseticidas",
    un: "Frasco 30 mL · ambientes externos", preco: null,
    foto: SUPA + "/storage/v1/object/public/produtos/k-othrine-sc25.jpg",
    descricao: "Inseticida piretroide (deltametrina).", id: 0,
  }, "produto com preco null (consultar) e foto");
  assert.equal(P[1].foto, SUPA + "/storage/v1/object/public/produtos/ficam%20vc.jpg", "prefixo do bucket removido e nome codificado");
  assert.equal(P[1].restrito, true); assert.equal(P[1].novo, true);

  const chave = P[2];                                   // sem marca, com opções e promoção
  assert.ok(!("marca" in chave), "sem marca → campo omitido");
  assert.deepEqual(chave.opcoes, ["8 mm", "10 mm", "12 mm"], "opções ordenadas");
  assert.equal(chave.opNome, "Medida");
  assert.equal(chave.preco, 18.5); assert.equal(chave.antigo, 22); assert.equal(chave.top, true);
  assert.ok(!("foto" in chave) && !("porMetro" in chave) && !("novo" in chave));
  assert.equal(chave.descricao, "", "sem descrição → '' (site usa a automática)");

  const alface = P[3];
  assert.equal(alface.preco, 6.5, "numeric em texto vira número");
  assert.deepEqual(alface.ilu, ["envelope", "Alface|crespa", "#2f6b2f", "#e8f3df"]);
  assert.ok(!("opcoes" in alface) && !("opNome" in alface), "sem opções → omitido");

  // DEPS / DEP_INFO na ordem do painel, incluindo subcategoria ainda sem produto
  assert.deepEqual(puro(r.DEPS), {
    Defensivos: ["Inseticidas", "Carrapaticidas e mosquicidas", "Uso profissional"],
    Ferramentas: ["Ferramentas manuais"],
    Sementes: ["Folhosas e temperos", "Raízes e bulbos"],
  });
  assert.deepEqual(Object.keys(r.DEPS), ["Defensivos", "Ferramentas", "Sementes"]);
  assert.equal(r.DEP_INFO.Sementes, "Hortaliças Isla");

  // salvou no cache
  const salvo = JSON.parse(memoria.get("defema-catalogo:" + SUPA));
  assert.equal(salvo.PRODUTOS.length, 4); assert.ok(salvo.salvoEm > 0);
});

await teste("chave nova sb_publishable_ vai só no header apikey", async () => {
  const log = [];
  const { win } = navegador(fetchOk(PRODUTOS_DB, DEPS_DB, log));
  const r = await win.carregarCatalogo({ url: SUPA, anonKey: "sb_publishable_abc123" });
  assert.equal(r.origem, "supabase");
  assert.equal(log[0].init.headers.apikey, "sb_publishable_abc123");
  assert.ok(!("Authorization" in log[0].init.headers));
});

await teste("se a consulta de departamentos falhar, DEPS sai dos produtos", async () => {
  const f = async url => url.includes("/produtos?") ? resp(PRODUTOS_DB) : resp({ message: "erro" }, 500);
  const { win } = navegador(f);
  const r = await win.carregarCatalogo({ url: SUPA, anonKey: ANON, fallback: FALLBACK });
  assert.equal(r.origem, "supabase");
  assert.deepEqual(puro(r.DEPS), {
    Defensivos: ["Inseticidas", "Uso profissional"], Ferramentas: ["Ferramentas manuais"], Sementes: ["Folhosas e temperos"],
  });
});

/* ---------- 2) fallback ---------- */
for (const [nome, f] of [
  ["erro de rede", async () => { throw new TypeError("Failed to fetch"); }],
  ["HTTP 401 (chave errada)", async () => resp({ message: "Invalid API key" }, 401)],
  ["catálogo vazio (RLS mal configurado)", async url => resp([])],
  ["resposta que não é lista", async () => resp({ erro: true })],
]) {
  await teste("fallback para os dados embutidos: " + nome, async () => {
    const { win, memoria } = navegador(f);
    const r = await win.carregarCatalogo({ url: SUPA, anonKey: ANON, fallback: FALLBACK });
    assert.equal(r.origem, "embutido");
    assert.ok(r.erro);
    assert.equal(r.PRODUTOS, FALLBACK.PRODUTOS);
    assert.equal(memoria.size, 0, "não grava cache em falha");
  });
}

await teste("fallback por tempo esgotado (aborta o fetch)", async () => {
  let abortado = false;
  const lento = (url, init) => new Promise((res, rej) => {
    init.signal.addEventListener("abort", () => { abortado = true; rej(new Error("AbortError")); });
  });
  const { win } = navegador(lento);
  const t0 = Date.now();
  const r = await win.carregarCatalogo({ url: SUPA, anonKey: ANON, fallback: FALLBACK, timeoutMs: 150 });
  assert.equal(r.origem, "embutido");
  assert.match(r.erro, /tempo esgotado/);
  assert.ok(Date.now() - t0 < 1000, "não fica esperando");
  assert.ok(abortado, "AbortController acionado");
});

await teste("sem url/anonKey → embutido sem chamar a rede", async () => {
  let chamou = false;
  const { win } = navegador(async () => { chamou = true; });
  const r = await win.carregarCatalogo({ url: "", anonKey: "", fallback: FALLBACK });
  assert.equal(r.origem, "embutido"); assert.equal(chamou, false);
});

/* ---------- 3) cache: stale-while-revalidate ---------- */
await teste("com cache: responde na hora e revalida em segundo plano", async () => {
  // 1ª visita grava o cache; na 2ª o preço mudou no banco e a rede é lenta
  const novos = structuredClone(PRODUTOS_DB);
  novos[1].preco = 39.9;
  const lentoMasOk = async url => { await espera(80); return url.includes("/produtos?") ? resp(novos) : resp(DEPS_DB); };
  const m = new Map();
  await navegador(fetchOk(), { memoria: m }).win.carregarCatalogo({ url: SUPA, anonKey: ANON });
  const { win } = navegador(lentoMasOk, { memoria: m });
  assert.equal(win.lerCatalogoCache({ url: SUPA }).PRODUTOS.length, 4, "lerCatalogoCache síncrono");

  let atualizado = null;
  const t0 = Date.now();
  const r = await win.carregarCatalogo({ url: SUPA, anonKey: ANON, fallback: FALLBACK, onAtualizar: d => (atualizado = d) });
  assert.equal(r.origem, "cache");
  assert.ok(Date.now() - t0 < 50, "não esperou a rede");
  assert.equal(r.PRODUTOS[0].preco, null, "devolveu a cópia antiga");
  assert.equal(atualizado, null);

  await espera(150);
  assert.ok(atualizado, "onAtualizar chamado");
  assert.equal(atualizado.origem, "supabase");
  assert.equal(atualizado.PRODUTOS[0].preco, 39.9);
  assert.equal(win.lerCatalogoCache({ url: SUPA }).PRODUTOS[0].preco, 39.9, "cache renovado");
});

await teste("com cache e nada mudou: não chama onAtualizar", async () => {
  const m = new Map();
  await navegador(fetchOk(), { memoria: m }).win.carregarCatalogo({ url: SUPA, anonKey: ANON });
  const { win } = navegador(fetchOk(), { memoria: m });
  let chamadas = 0;
  const r = await win.carregarCatalogo({ url: SUPA, anonKey: ANON, onAtualizar: () => chamadas++ });
  assert.equal(r.origem, "cache");
  await espera(30);
  assert.equal(chamadas, 0);
});

await teste("com cache e Supabase fora do ar: mantém a cópia, sem erro", async () => {
  const m = new Map();
  await navegador(fetchOk(), { memoria: m }).win.carregarCatalogo({ url: SUPA, anonKey: ANON });
  const { win, avisos } = navegador(async () => { throw new Error("offline"); }, { memoria: m });
  let chamadas = 0;
  const r = await win.carregarCatalogo({ url: SUPA, anonKey: ANON, fallback: FALLBACK, onAtualizar: () => chamadas++ });
  assert.equal(r.origem, "cache"); assert.equal(r.PRODUTOS.length, 4);
  await espera(30);
  assert.equal(chamadas, 0); assert.ok(avisos.some(a => a.includes("offline")));
});

await teste("cache corrompido ou de outra versão é ignorado", async () => {
  for (const lixo of ["{quebrado", JSON.stringify({ v: 999, PRODUTOS: [{}], DEPS: {} })]) {
    const m = new Map([["defema-catalogo:" + SUPA, lixo]]);
    const { win } = navegador(fetchOk(), { memoria: m });
    assert.equal(win.lerCatalogoCache({ url: SUPA }), null);
    const r = await win.carregarCatalogo({ url: SUPA, anonKey: ANON, fallback: FALLBACK });
    assert.equal(r.origem, "supabase");
  }
});

await teste("localStorage bloqueado (aba anônima) não quebra", async () => {
  const { win } = navegador(fetchOk(), { semStorage: true });
  assert.equal(win.lerCatalogoCache({ url: SUPA }), null);
  const r = await win.carregarCatalogo({ url: SUPA, anonKey: ANON, fallback: FALLBACK });
  assert.equal(r.origem, "supabase"); assert.equal(r.PRODUTOS.length, 4);
});

await teste("cache é separado por projeto (url)", async () => {
  const m = new Map();
  await navegador(fetchOk(), { memoria: m }).win.carregarCatalogo({ url: SUPA, anonKey: ANON });
  const { win } = navegador(fetchOk(), { memoria: m });
  assert.equal(win.lerCatalogoCache({ url: "https://outro.supabase.co" }), null);
});

console.log(`\n${ok} testes passaram.`);
