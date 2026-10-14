// Gera sql/03_dados.sql a partir de dados/produtos.json (formato do CONTRATO.md).
// Uso: node scripts/gerar-sql-dados.mjs
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const dados = JSON.parse(fs.readFileSync(path.join(raiz, "dados/produtos.json"), "utf8"));

const q = v => v === null || v === undefined ? "null" : `'${String(v).replace(/'/g, "''")}'`;
const n = v => v === null || v === undefined ? "null" : String(Number(v));
const b = v => (v ? "true" : "false");
const j = v => v === null || v === undefined ? "null" : `${q(JSON.stringify(v))}::jsonb`;
const alvo = p => `(select id from public.produtos where nome = ${q(p.nome)} and coalesce(marca, '') = ${q(p.marca ?? "")})`;
const nOp = dados.produtos.reduce((s, p) => s + (p.opcoes?.length || 0), 0);

const L = [];
L.push(`-- =====================================================================
-- DEFEMA · Catálogo — 03_dados.sql  (GERADO por scripts/gerar-sql-dados.mjs)
-- Carga inicial: ${dados.departamentos.length} departamentos, ${dados.produtos.length} produtos e ${nOp} opções exportados do site.
-- Rode DEPOIS do 01 e do 02. Pode rodar de novo (idempotente): atualiza
-- pelo nome + marca e recria as opções. ATENÇÃO: rodar de novo sobrescreve
-- preços/textos alterados no painel (o campo "ativo" é preservado).
-- foto_url = nome do arquivo no bucket "produtos" do Storage.
-- =====================================================================
begin;
`);

L.push("-- Departamentos");
for (const d of dados.departamentos)
  L.push(`insert into public.departamentos (nome, info, ordem) values (${q(d.nome)}, ${q(d.info)}, ${n(d.ordem)})
  on conflict (nome) do update set info = excluded.info, ordem = excluded.ordem;`);

L.push("\n-- Subcategorias");
for (const d of dados.departamentos) d.subcategorias.forEach((s, i) =>
  L.push(`insert into public.subcategorias (departamento_id, nome, ordem)
  select id, ${q(s)}, ${i + 1} from public.departamentos where nome = ${q(d.nome)}
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;`));

L.push("\n-- Produtos (único por nome + coalesce(marca,''))");
for (const p of dados.produtos)
  L.push(`insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select ${q(p.nome)}, ${q(p.marca)}, s.id, ${q(p.un)}, ${n(p.preco)}, ${n(p.antigo)}, ${q(p.descricao)}, ${q(p.foto)}, ${j(p.ilu)}, ${q(p.icone)}, ${b(p.top)}, ${b(p.novo)}, ${b(p.restrito)}, ${b(p.porMetro)}, ${q(p.opNome)}, ${n(p.ordem)}
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = ${q(p.dep)} and s.nome = ${q(p.sub)}
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;`);

L.push("\n-- Opções (tamanhos, pesos...): recria as opções de cada produto");
for (const p of dados.produtos) {
  L.push(`delete from public.produto_opcoes where produto_id = ${alvo(p)};`);
  if (p.opcoes?.length) {
    const vals = p.opcoes.map((o, i) => `(${q(o)}, ${i + 1})`).join(", ");
    L.push(`insert into public.produto_opcoes (produto_id, nome, ordem) select ${alvo(p)}, v.nome, v.ordem from (values ${vals}) as v(nome, ordem);`);
  }
}

L.push(`
-- Conferência: esperado ${dados.produtos.length} produtos e ${nOp} opções
select (select count(*) from public.produtos) as total_produtos, (select count(*) from public.produto_opcoes) as total_opcoes;
commit;
`);
fs.writeFileSync(path.join(raiz, "sql/03_dados.sql"), L.join("\n"));
console.log(`OK: sql/03_dados.sql (${dados.produtos.length} produtos, ${nOp} opções)`);
