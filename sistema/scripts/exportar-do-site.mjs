// Exporta os produtos embutidos em ../site/defema.html para dados/produtos.json (formato do CONTRATO.md).
// Uso: NODE_PATH=$(npm root -g) PLAYWRIGHT_BROWSERS_PATH=/opt/pw-browsers node scripts/exportar-do-site.mjs
// Abre a página via file:// num Chromium headless e lê PRODUTOS, DEPS, DEP_INFO e descricao(p).
// Grava primeiro em produtos.tmp.json e depois renomeia (ninguém lê arquivo pela metade).
import { createRequire } from "node:module";
import { fileURLToPath, pathToFileURL } from "node:url";
import path from "node:path";
import fs from "node:fs";

const require = createRequire(import.meta.url);
const { chromium } = require("playwright");

const aqui = path.dirname(fileURLToPath(import.meta.url));
const raiz = path.resolve(aqui, "..");
const html = path.resolve(raiz, "../site/defema.html");

const browser = await chromium.launch();
const page = await browser.newPage();
await page.route(/^https?:/, r => r.abort()); // sem internet
await page.goto(pathToFileURL(html).href, { waitUntil: "load" });
const dados = await page.evaluate(() => {
  const departamentos = Object.keys(DEPS).map((nome, i) => ({
    nome, info: DEP_INFO[nome] ?? null, ordem: i + 1, subcategorias: [...DEPS[nome]],
  }));
  const produtos = PRODUTOS.map((p, i) => ({
    nome: p.nome,
    marca: p.marca ?? null,
    dep: p.dep,
    sub: p.sub,
    un: p.un ?? null,
    preco: p.preco ?? null,
    antigo: p.antigo ?? null,
    top: !!p.top,
    novo: !!p.novo,
    foto: p.foto ? String(p.foto).split("/").pop() : null,
    ilu: p.ilu ?? null,
    icone: p.icone ?? null,
    restrito: !!p.restrito,
    porMetro: !!p.porMetro,
    opcoes: Array.isArray(p.opcoes) ? [...p.opcoes] : [],
    opNome: p.opNome ?? null,
    descricao: typeof descricao === "function" ? (descricao(p) ?? null) : (p.descricao ?? null),
    ordem: (i + 1) * 10,
  }));
  return { departamentos, produtos, total: PRODUTOS.length };
});
await browser.close();

if (dados.produtos.length !== dados.total) throw new Error("contagem divergente");
const tmp = path.join(raiz, "dados/produtos.tmp.json");
const out = path.join(raiz, "dados/produtos.json");
fs.writeFileSync(tmp, JSON.stringify({ departamentos: dados.departamentos, produtos: dados.produtos }, null, 2) + "\n");
fs.renameSync(tmp, out);
const nOp = dados.produtos.reduce((s, p) => s + p.opcoes.length, 0);
console.log(`OK: ${dados.produtos.length} produtos, ${nOp} opções, ${dados.departamentos.length} departamentos -> ${out}`);
