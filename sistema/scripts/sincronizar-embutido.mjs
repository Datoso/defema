// Atualiza a cópia do catálogo que fica escrita dentro do index.html (DEPS, DEP_INFO e PRODUTOS)
// com o que está no Supabase. É essa cópia que o site usa quando o Supabase não responde
// na primeira visita; sem ela em dia, um produto cadastrado só pelo painel "some" nessa hora.
//
// Uso (Node 18+, sem npm install), na raiz do repositório:
//   node sistema/scripts/sincronizar-embutido.mjs            → grava index.html (e fotos novas em img/)
//   node sistema/scripts/sincronizar-embutido.mjs --simular  → só mostra o que mudaria
//
// Usa só a chave anon (pública) que já está no index.html; lê apenas produtos ativos.
// Fotos que estão no Storage e ainda não existem em img/ são baixadas para img/, assim a cópia
// funciona mesmo com o Supabase fora do ar. Roda sozinho pelo GitHub Actions
// (.github/workflows/sincronizar-catalogo.yml).
import { createRequire } from "node:module";
import { fileURLToPath } from "node:url";
import path from "node:path";
import fs from "node:fs";

const require = createRequire(import.meta.url);
const raizRepo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const { montarCatalogo } = require(path.join(raizRepo, "carregar-produtos.js"));

export const INICIO = "/* <catalogo-embutido>";
export const FIM = "/* </catalogo-embutido> */";

// Mesmas consultas de carregar-produtos.js (buscarDoSupabase)
const SELECT_PRODUTOS =
  "*,produto_opcoes(nome,ordem),subcategorias(nome,ordem,departamentos(nome,info,ordem))";
const SELECT_DEPS = "nome,info,ordem,subcategorias(nome,ordem)";

const ORDEM_CAMPOS = ["nome", "marca", "dep", "sub", "un", "preco", "antigo", "top", "novo", "restrito",
  "porMetro", "opcoes", "opNome", "foto", "ilu", "icone", "descricao"];

/** Lê { url, anonKey } da linha `const SUPABASE = {...}` do index.html. */
export function lerConfig(html) {
  const m = html.match(/const SUPABASE = \{\s*url:\s*"([^"]*)",\s*anonKey:\s*"([^"]*)"\s*\}/);
  if (!m || !m[1] || !m[2]) throw new Error("não achei url/anonKey do Supabase no index.html");
  return { url: m[1].replace(/\/+$/, ""), anonKey: m[2] };
}

async function getJson(endereco, anonKey) {
  const cab = { apikey: anonKey, Accept: "application/json" };
  if (/^eyJ/.test(anonKey)) cab.Authorization = "Bearer " + anonKey;
  const r = await fetch(endereco, { headers: cab, signal: AbortSignal.timeout(30000) });
  if (!r.ok) throw new Error("HTTP " + r.status + " em " + endereco.split("?")[0]);
  return r.json();
}

export async function buscarCatalogo({ url, anonKey }) {
  const rest = url + "/rest/v1/";
  const [produtos, deps] = await Promise.all([
    getJson(rest + "produtos?select=" + encodeURIComponent(SELECT_PRODUTOS) + "&ativo=eq.true&order=ordem.asc", anonKey),
    getJson(rest + "departamentos?select=" + encodeURIComponent(SELECT_DEPS) + "&order=ordem.asc", anonKey),
  ]);
  if (!Array.isArray(produtos) || !Array.isArray(deps)) throw new Error("resposta inesperada do Supabase");
  return montarCatalogo(produtos, deps, url);
}

/** Nome de arquivo seguro para img/ a partir da URL pública do Storage. */
function nomeDaFoto(fotoUrl) {
  const base = decodeURIComponent(new URL(fotoUrl).pathname.split("/").pop() || "");
  return base.replace(/[^A-Za-z0-9._-]/g, "-");
}

/**
 * Troca as URLs do Storage por "img/arquivo" (baixando o que faltar).
 * baixar(url, destino) é injetável para teste; devolve true se gravou.
 * Devolve a lista de fotos novas gravadas em img/.
 */
export async function localizarFotos(catalogo, { url, pastaImg, baixar = baixarFoto }) {
  const prefixo = url + "/storage/v1/object/public/";
  const novas = [];
  for (const p of catalogo.PRODUTOS) {
    if (!p.foto || !p.foto.startsWith(prefixo)) continue;
    const nome = nomeDaFoto(p.foto);
    if (!nome) continue;
    const destino = path.join(pastaImg, nome);
    if (!fs.existsSync(destino)) {
      if (!(await baixar(p.foto, destino))) continue; // falhou: mantém a URL do Storage
      novas.push(nome);
    }
    p.foto = "img/" + nome;
  }
  return novas;
}

async function baixarFoto(endereco, destino) {
  try {
    const r = await fetch(endereco, { signal: AbortSignal.timeout(30000) });
    const tipo = r.headers.get("content-type") || "";
    if (!r.ok || !tipo.startsWith("image/")) throw new Error("HTTP " + r.status + " " + tipo);
    const buf = Buffer.from(await r.arrayBuffer());
    if (!buf.length || buf.length > 5 * 1024 * 1024) throw new Error(buf.length + " bytes");
    fs.writeFileSync(destino, buf);
    return true;
  } catch (e) {
    console.warn("[Defema] não baixei a foto " + endereco + ": " + e.message);
    return false;
  }
}

const lit = v => JSON.stringify(v);
function objeto(o) {
  const chaves = [...ORDEM_CAMPOS.filter(k => k in o), ...Object.keys(o).filter(k => !ORDEM_CAMPOS.includes(k))];
  return "{" + chaves.map(k => k + ":" + lit(o[k])).join(", ") + "}";
}

/** Texto JS que vai entre os marcadores: DEPS, DEP_INFO e PRODUTOS (um produto por linha). */
export function gerarBloco({ PRODUTOS, DEPS, DEP_INFO }) {
  const linhas = [
    INICIO + " gerado por sistema/scripts/sincronizar-embutido.mjs a partir do Supabase.",
    "   Não edite à mão: mude no painel e rode a sincronização (GitHub > Actions > Sincronizar catálogo).",
    "   foto: imagem em img/ · preco: null = \"Consultar preço\" · antigo = preço riscado (promoção)",
    "   top = mais procurado · novo = novidade · ilu = ilustração provisória (sem foto) */",
    "const DEPS = {",
    ...Object.keys(DEPS).map((d, i, a) => "  " + lit(d) + ": " + lit(DEPS[d]) + (i < a.length - 1 ? "," : "")),
    "};",
    "const DEP_INFO = {",
    ...Object.keys(DEP_INFO).map((d, i, a) => "  " + lit(d) + ": " + lit(DEP_INFO[d]) + (i < a.length - 1 ? "," : "")),
    "};",
    "const PRODUTOS = [",
  ];
  let depAtual = null;
  PRODUTOS.forEach((p, i) => {
    const c = { ...p };
    delete c.id;
    if (!c.descricao) delete c.descricao; // "" = o site usa a descrição automática
    if (c.dep !== depAtual) { linhas.push("  /* " + c.dep + " */"); depAtual = c.dep; }
    linhas.push("  " + objeto(c) + (i < PRODUTOS.length - 1 ? "," : ""));
  });
  linhas.push("];", FIM);
  return linhas.join("\n");
}

/** Substitui o trecho entre os marcadores. */
export function aplicarNoHtml(html, bloco) {
  const a = html.indexOf(INICIO), b = html.indexOf(FIM);
  if (a < 0 || b < a || html.indexOf(INICIO, a + 1) >= 0)
    throw new Error("marcadores do catálogo embutido não encontrados (ou repetidos) no index.html");
  return html.slice(0, a) + bloco + html.slice(b + FIM.length);
}

/** Lê o catálogo que está hoje entre os marcadores (para comparar e para as travas). */
export function lerBloco(html) {
  const a = html.indexOf(INICIO), b = html.indexOf(FIM);
  if (a < 0 || b < a) return null;
  return new Function(html.slice(a, b + FIM.length) + "\nreturn { PRODUTOS, DEPS, DEP_INFO };")();
}

/**
 * Busca o catálogo e devolve o index.html novo, ou null se a cópia já está em dia.
 * Lança erro (sem alterar nada) se o Supabase devolver um catálogo vazio ou muito menor.
 */
export async function sincronizar(html, { pastaImg, baixar, log = console.log }) {
  const config = lerConfig(html);
  const atual = lerBloco(html);
  if (!atual) throw new Error("marcadores do catálogo embutido não encontrados no index.html");

  const novo = await buscarCatalogo(config);
  // Travas: catálogo vazio ou muito menor quase sempre é chave/RLS errada, não loja vazia
  if (!novo.PRODUTOS.length) throw new Error("o Supabase devolveu 0 produtos; nada foi alterado");
  if (novo.PRODUTOS.length < atual.PRODUTOS.length / 2)
    throw new Error(`o Supabase devolveu ${novo.PRODUTOS.length} produtos e a cópia tem ${atual.PRODUTOS.length}; ` +
      "parece erro de configuração, nada foi alterado. Se foi de propósito, edite o index.html à mão uma vez.");

  const novas = await localizarFotos(novo, { url: config.url, pastaImg, baixar });
  const htmlNovo = aplicarNoHtml(html, gerarBloco(novo));
  if (htmlNovo === html) {
    log(`Catálogo embutido já está em dia (${novo.PRODUTOS.length} produtos).`);
    return null;
  }
  const chave = p => p.nome + (p.marca ? " (" + p.marca + ")" : "");
  const antes = new Set(atual.PRODUTOS.map(chave)), depois = new Set(novo.PRODUTOS.map(chave));
  const entrou = [...depois].filter(k => !antes.has(k)), saiu = [...antes].filter(k => !depois.has(k));
  log(`Produtos: ${atual.PRODUTOS.length} → ${novo.PRODUTOS.length}`);
  if (entrou.length) log("Entraram: " + entrou.join("; "));
  if (saiu.length) log("Saíram: " + saiu.join("; "));
  if (novas.length) log("Fotos novas em img/: " + novas.join(", "));
  return htmlNovo;
}

async function principal() {
  const simular = process.argv.includes("--simular");
  const arquivo = path.join(raizRepo, "index.html");
  const htmlNovo = await sincronizar(fs.readFileSync(arquivo, "utf8"), {
    pastaImg: path.join(raizRepo, "img"),
    baixar: simular ? async () => true : baixarFoto, // simulação: finge que baixou, não grava nada
  });
  if (!htmlNovo) return;
  if (simular) { console.log("(simulação: nada foi gravado)"); return; }
  fs.writeFileSync(arquivo, htmlNovo);
  console.log("index.html atualizado.");
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  principal().catch(e => { console.error("[Defema] " + e.message); process.exit(1); });
}
