-- =====================================================================
-- DEFEMA · Catálogo — 08_mudas_pedido.sql
-- Mudas – balcão: cada venda guarda o VALOR (R$) e o PEDIDO (sessão de
-- balcão salva de uma vez). Só acrescenta colunas; pode rodar de novo.
-- =====================================================================
alter table public.mudas_movimentos add column if not exists valor  numeric(10,2) null;
alter table public.mudas_movimentos add column if not exists pedido uuid null;
comment on column public.mudas_movimentos.valor  is 'Valor da venda em R$ (preço do lote na hora × lotes). Nulo para NF ou preço a consultar.';
comment on column public.mudas_movimentos.pedido is 'Agrupa as vendas salvas juntas (um pedido de balcão). Nulo em registros antigos e NFs.';
create index if not exists mudas_movimentos_pedido_idx on public.mudas_movimentos (pedido);
