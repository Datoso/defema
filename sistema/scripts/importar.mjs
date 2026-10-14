// =====================================================================
// DEFEMA · importar.mjs
// Sobe as fotos usadas (../site/img) para o bucket "produtos" do Supabase
// Storage (upsert) e insere/atualiza departamentos, subcategorias, produtos
// (pelo par nome + marca) e recria as opções, a partir de dados/produtos.json.
//
// Uso (na pasta "sistema"):
//   npm install
//   SUPABASE_URL=https://xxxx.supabase.co SUPABASE_SERVICE_ROLE_KEY=eyJ... node scripts/importar.mjs
//
// Opções:
//   --simular        só confere os arquivos e mostra o que faria (não envia nada)
//   --sem-fotos      não envia fotos (só dados)
//   --so-fotos       só envia fotos (não mexe nos dados)
//   --manter-precos  produto que JÁ existe mantém preço e promoção do banco
//
// O campo "ativo" de produtos já existentes nunca é alterado.
// ATENÇÃO: a service_role key ignora as regras de segurança. Use só no seu
// computador; NUNCA coloque no site nem no painel.
// =====================================================================
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const PASTA_FOTOS = path.resolve(raiz, "../site/img");
const BUCKET = "produtos";
const args = new Set(process.argv.slice(2));
const SIMULAR = args.has("--simular");
const SEM_FOTOS = args.has("--sem-fotos");
const SO_FOTOS = args.has("--so-fotos");
const MANTER_PRECOS = args.has("--manter-precos");
const TIPOS = { ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".png": "image/png", ".webp": "image/webp" };

function falhar(msg) { console.error("\n✖ " + msg); process.exit(1); }
const chave = (nome, marca) => `${nome}|${marca ?? ""}`;

const dados = JSON.parse(fs.readFileSync(path.join(raiz, "dados/produtos.json"), "utf8"));

// --- 1. Conferências locais -------------------------------------------
const fotos = [...new Set(dados.produtos.map(p => p.foto).filter(Boolean))];
const faltando = fotos.filter(f => !fs.existsSync(path.join(PASTA_FOTOS, f)));
const nOpcoes = dados.produtos.reduce((s, p) => s + (p.opcoes?.length || 0), 0);
console.log(`Dados: ${dados.departamentos.length} departamentos, ${dados.produtos.length} produtos, ${nOpcoes} opções, ${fotos.length} fotos usadas.`);
if (faltando.length) console.warn(`⚠ Fotos não encontradas em ${PASTA_FOTOS}:\n  - ${faltando.join("\n  - ")}`);

if (SIMULAR) {
  console.log("\n[simulação] Nada foi enviado. Fotos que seriam enviadas:");
  for (const f of fotos.filter(f => !faltando.includes(f))) console.log(`  ${BUCKET}/${f}`);
  if (!SO_FOTOS) {
    console.log("\n[simulação] Departamentos/subcategorias que seriam inseridos ou atualizados (pelo nome):");
    for (const d of dados.departamentos) console.log(`  ${d.ordem}. ${d.nome} → ${d.subcategorias.join(", ")}`);
    console.log("\n[simulação] Produtos que seriam inseridos ou atualizados (pelo nome + marca), com opções recriadas:");
    for (const p of dados.produtos) {
      const preco = p.preco == null ? "consultar" : `R$ ${Number(p.preco).toFixed(2)}${p.antigo != null ? ` (de R$ ${Number(p.antigo).toFixed(2)})` : ""}`;
      const ops = p.opcoes?.length ? ` · ${p.opNome || "Opções"}: ${p.opcoes.join(" / ")}` : "";
      console.log(`  - ${p.nome}${p.marca ? ` [${p.marca}]` : ""} · ${p.dep} > ${p.sub} · ${preco}${p.foto ? ` · foto ${p.foto}` : ""}${ops}`);
    }
  }
  console.log(`\n[simulação] Resumo: ${fotos.length - faltando.length} fotos, ${dados.departamentos.length} departamentos, ${dados.departamentos.reduce((s, d) => s + d.subcategorias.length, 0)} subcategorias, ${dados.produtos.length} produtos, ${nOpcoes} opções.`);
  process.exit(faltando.length ? 1 : 0);
}

const { SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY } = process.env;
if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY)
  falhar("Defina SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY (Supabase > Project Settings > API).");

const { createClient } = await import("@supabase/supabase-js");
const sb = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, { auth: { persistSession: false, autoRefreshToken: false } });
const ok = (r, oque) => { if (r.error) falhar(`${oque}: ${r.error.message}`); return r.data; };

// --- 2. Fotos -----------------------------------------------------------
if (!SEM_FOTOS) {
  const b = await sb.storage.getBucket(BUCKET);
  if (b.error) {
    console.log(`Bucket "${BUCKET}" não existe; criando (público)...`);
    ok(await sb.storage.createBucket(BUCKET, { public: true }), "criar bucket");
  }
  const enviar = fotos.filter(f => !faltando.includes(f));
  let n = 0;
  for (const f of enviar) {
    const corpo = fs.readFileSync(path.join(PASTA_FOTOS, f));
    const tipo = TIPOS[path.extname(f).toLowerCase()] || "application/octet-stream";
    ok(await sb.storage.from(BUCKET).upload(f, corpo, { contentType: tipo, upsert: true, cacheControl: "3600" }), `enviar foto ${f}`);
    process.stdout.write(`\rFotos enviadas: ${++n}/${enviar.length}`);
  }
  console.log("");
}
if (SO_FOTOS) { console.log("✔ Pronto (só fotos)."); process.exit(0); }

// --- 3. Departamentos e subcategorias ----------------------------------
const deps = ok(await sb.from("departamentos")
  .upsert(dados.departamentos.map(d => ({ nome: d.nome, info: d.info ?? null, ordem: d.ordem ?? 0 })), { onConflict: "nome" })
  .select("id, nome"), "departamentos");
const idDep = Object.fromEntries(deps.map(d => [d.nome, d.id]));

const subsLinhas = dados.departamentos.flatMap(d =>
  d.subcategorias.map((s, i) => ({ departamento_id: idDep[d.nome], nome: s, ordem: i + 1 })));
const subs = ok(await sb.from("subcategorias")
  .upsert(subsLinhas, { onConflict: "departamento_id,nome" })
  .select("id, nome, departamento_id"), "subcategorias");
const nomeDep = Object.fromEntries(deps.map(d => [d.id, d.nome]));
const idSub = Object.fromEntries(subs.map(s => [`${nomeDep[s.departamento_id]}|${s.nome}`, s.id]));
console.log(`Departamentos: ${deps.length} · Subcategorias: ${subs.length}`);

// --- 4. Produtos (identidade = nome + marca) ---------------------------
// O índice único usa coalesce(marca,''), que o upsert da API não aceita;
// por isso: lê os existentes, atualiza pelo id ou insere.
const atuais = ok(await sb.from("produtos").select("id, nome, marca, preco, preco_antigo"), "ler produtos atuais");
const existentes = new Map(atuais.map(p => [chave(p.nome, p.marca), p]));

const idProd = {};
const novos = [];
let atualizados = 0;
for (const p of dados.produtos) {
  const sub = idSub[`${p.dep}|${p.sub}`];
  if (!sub) falhar(`Subcategoria não encontrada para "${p.nome}": ${p.dep} > ${p.sub}`);
  const linha = {
    nome: p.nome, marca: p.marca ?? null, subcategoria_id: sub, unidade: p.un ?? null,
    preco: p.preco ?? null, preco_antigo: p.antigo ?? null, descricao: p.descricao ?? null,
    foto_url: p.foto ?? null, ilustracao: p.ilu ?? null, icone: p.icone ?? null,
    destaque: !!p.top, novidade: !!p.novo, restrito: !!p.restrito, por_metro: !!p.porMetro,
    op_nome: p.opNome ?? null, ordem: p.ordem ?? 0,
  };
  const atual = existentes.get(chave(p.nome, p.marca));
  if (atual) {
    if (MANTER_PRECOS) { linha.preco = atual.preco; linha.preco_antigo = atual.preco_antigo; }
    ok(await sb.from("produtos").update(linha).eq("id", atual.id), `atualizar "${p.nome}"`);
    idProd[chave(p.nome, p.marca)] = atual.id;
    atualizados++;
  } else novos.push(linha);
}
if (novos.length) {
  const ins = ok(await sb.from("produtos").insert(novos).select("id, nome, marca"), "inserir produtos");
  for (const p of ins) idProd[chave(p.nome, p.marca)] = p.id;
}
console.log(`Produtos: ${novos.length} inseridos, ${atualizados} atualizados.`);

// --- 5. Opções (recria) -------------------------------------------------
const ids = dados.produtos.map(p => idProd[chave(p.nome, p.marca)]);
for (let i = 0; i < ids.length; i += 100)
  ok(await sb.from("produto_opcoes").delete().in("produto_id", ids.slice(i, i + 100)), "limpar opções");
const opcoes = dados.produtos.flatMap(p =>
  (p.opcoes || []).map((o, i) => ({ produto_id: idProd[chave(p.nome, p.marca)], nome: o, ordem: i + 1 })));
if (opcoes.length) ok(await sb.from("produto_opcoes").insert(opcoes), "inserir opções");
console.log(`Opções: ${opcoes.length}`);
console.log("\n✔ Importação concluída.");
