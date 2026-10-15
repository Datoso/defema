// Teste de sincronizar-embutido.mjs (Node 18+, sem internet: o fetch do Supabase é simulado).
// Uso, na raiz do repositório: node sistema/scripts/sincronizar-embutido.teste.mjs
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { sincronizar, lerBloco, lerConfig } from "./sincronizar-embutido.mjs";

const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const html = fs.readFileSync(path.join(raiz, "index.html"), "utf8");
const pastaImg = path.join(raiz, "img");
const { url } = lerConfig(html);
const atual = lerBloco(html);
assert.ok(atual && atual.PRODUTOS.length > 50, "cópia embutida lida do index.html");

/** Linhas do banco equivalentes à cópia atual (inverso do mapeamento do CONTRATO.md). */
function linhasDoBanco(cat) {
  const deps = Object.keys(cat.DEPS).map((d, i) => ({ nome: d, info: cat.DEP_INFO[d], ordem: i + 1,
    subcategorias: cat.DEPS[d].map((s, j) => ({ nome: s, ordem: j + 1 })) }));
  const produtos = cat.PRODUTOS.map((p, i) => ({
    nome: p.nome, marca: p.marca ?? null, unidade: p.un ?? null, preco: p.preco ?? null, preco_antigo: p.antigo ?? null,
    destaque: !!p.top, novidade: !!p.novo, restrito: !!p.restrito, por_metro: !!p.porMetro,
    foto_url: p.foto ? p.foto.replace(/^img\//, "") : null, ilustracao: p.ilu ?? null, icone: p.icone ?? null,
    op_nome: p.opNome ?? null, descricao: p.descricao ?? null, ativo: true, ordem: i,
    produto_opcoes: (p.opcoes || []).map((n, j) => ({ nome: n, ordem: j })),
    subcategorias: { nome: p.sub, ordem: 0, departamentos: { nome: p.dep, info: cat.DEP_INFO[p.dep], ordem: 0 } },
  }));
  return { produtos, deps };
}

function simularSupabase({ produtos, deps }) {
  globalThis.fetch = async endereco => {
    const corpo = endereco.includes("/rest/v1/produtos") ? produtos : endereco.includes("/rest/v1/departamentos") ? deps : null;
    if (!corpo) return { ok: false, status: 404 };
    return { ok: true, status: 200, json: async () => JSON.parse(JSON.stringify(corpo)) };
  };
}

const baixadas = [];
const baixar = async (u, destino) => { baixadas.push([u, path.basename(destino)]); return true; }; // não grava
const silencio = () => {};

// 1) Banco igual à cópia → nada muda
simularSupabase(linhasDoBanco(atual));
assert.equal(await sincronizar(html, { pastaImg, baixar, log: silencio }), null);
assert.deepEqual(baixadas, [], "nenhuma foto a baixar quando todas estão em img/");

// 2) Produto novo cadastrado no painel (com foto só no Storage) + um desativado
{
  const banco = linhasDoBanco(atual);
  const modelo = banco.produtos.find(p => p.subcategorias.nome === "Formicidas e lesmicidas");
  banco.produtos.push({ ...modelo, nome: "Formicida Teste", marca: "Marca X", foto_url: "formicida teste.jpg",
    preco: 12.5, preco_antigo: null, novidade: true, descricao: "", produto_opcoes: [], ordem: 1000 });
  banco.produtos[0] = { ...banco.produtos[0], ativo: false };
  simularSupabase(banco);
  const log = [];
  const novo = await sincronizar(html, { pastaImg, baixar, log: m => log.push(m) });
  assert.ok(novo, "index.html mudou");
  const cat = lerBloco(novo);
  assert.equal(cat.PRODUTOS.length, atual.PRODUTOS.length, "+1 novo, -1 desativado");
  const p = cat.PRODUTOS.find(x => x.nome === "Formicida Teste");
  assert.deepEqual({ foto: p.foto, preco: p.preco, novo: p.novo, dep: p.dep, temDescricao: "descricao" in p },
    { foto: "img/formicida-teste.jpg", preco: 12.5, novo: true, dep: "Defensivos", temDescricao: false });
  assert.ok(!cat.PRODUTOS.some(x => x.nome === atual.PRODUTOS[0].nome && x.marca === atual.PRODUTOS[0].marca), "desativado saiu");
  assert.deepEqual(baixadas, [[url + "/storage/v1/object/public/produtos/formicida%20teste.jpg", "formicida-teste.jpg"]]);
  assert.ok(log.some(m => m.includes("Entraram: Formicida Teste (Marca X)")), log.join("\n"));
  // o resto da página fica igual
  const fora = s => s.slice(0, s.indexOf("/* <catalogo-embutido>")) + s.slice(s.indexOf("/* </catalogo-embutido> */"));
  assert.equal(fora(novo), fora(html));
  // e rodar de novo sobre o resultado não muda nada
  baixadas.length = 0;
  assert.equal(await sincronizar(novo, { pastaImg, baixar: async () => true, log: silencio }), null);
}

// 3) Travas: catálogo vazio ou muito menor não grava
simularSupabase({ produtos: [], deps: [] });
await assert.rejects(sincronizar(html, { pastaImg, baixar, log: silencio }), /0 produtos/);
{
  const banco = linhasDoBanco(atual);
  banco.produtos = banco.produtos.slice(0, Math.floor(atual.PRODUTOS.length / 3));
  simularSupabase(banco);
  await assert.rejects(sincronizar(html, { pastaImg, baixar, log: silencio }), /erro de configuração/);
}

// 4) Erro de rede → lança (o Actions mostra a falha e não grava)
globalThis.fetch = async () => ({ ok: false, status: 401 });
await assert.rejects(sincronizar(html, { pastaImg, baixar, log: silencio }), /HTTP 401/);

console.log("ok: sincronizar-embutido");
