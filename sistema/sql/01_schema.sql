-- =====================================================================
-- DEFEMA · Catálogo — 01_schema.sql
-- Cria as tabelas do catálogo (conforme CONTRATO.md). Rode PRIMEIRO no
-- SQL Editor do Supabase. Pode ser rodado de novo ("if not exists").
-- =====================================================================

-- gen_random_uuid() já existe no Postgres 13+; a extensão é só garantia.
create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------
-- Departamentos (ex.: "Ferramentas", "Sementes")
-- ---------------------------------------------------------------------
create table if not exists public.departamentos (
  id     serial  primary key,
  nome   text    unique not null,
  info   text,              -- frase curta mostrada no site (DEP_INFO)
  ordem  int     default 0  -- posição no menu (menor aparece antes)
);
comment on table  public.departamentos       is 'Departamentos do catálogo (menu principal do site).';
comment on column public.departamentos.nome  is 'Nome do departamento, único (ex.: Ferramentas).';
comment on column public.departamentos.info  is 'Texto curto exibido junto ao departamento no site.';
comment on column public.departamentos.ordem is 'Ordem de exibição; menor aparece primeiro.';

-- ---------------------------------------------------------------------
-- Subcategorias (ex.: "Ferramentas manuais" dentro de "Ferramentas")
-- ---------------------------------------------------------------------
create table if not exists public.subcategorias (
  id              serial primary key,
  departamento_id int    references public.departamentos(id) on delete cascade,
  nome            text   not null,
  ordem           int    default 0,
  unique (departamento_id, nome)
);
comment on table  public.subcategorias                 is 'Subcategorias de cada departamento.';
comment on column public.subcategorias.departamento_id is 'Departamento ao qual a subcategoria pertence.';
comment on column public.subcategorias.ordem           is 'Ordem dentro do departamento; menor aparece primeiro.';
create index if not exists subcategorias_departamento_idx on public.subcategorias (departamento_id, ordem);

-- ---------------------------------------------------------------------
-- Produtos. Identidade de negócio = nome + marca (marca pode ser NULL;
-- o índice único trata NULL como texto vazio).
-- ---------------------------------------------------------------------
create table if not exists public.produtos (
  id              uuid primary key default gen_random_uuid(),
  nome            text not null,
  marca           text null,
  subcategoria_id int  references public.subcategorias(id),
  unidade         text,
  preco           numeric(10,2) null,
  preco_antigo    numeric(10,2) null,
  descricao       text,
  foto_url       text null,
  ilustracao      jsonb null,
  icone           text null,
  destaque        bool default false,
  novidade        bool default false,
  restrito        bool default false,
  por_metro       bool default false,
  op_nome         text null,
  ativo           bool default true,
  ordem           int  default 0,
  criado_em       timestamptz default now(),
  atualizado_em   timestamptz default now()
);
-- Bancos criados por uma versão anterior deste script tinham "foto_path": renomeia.
do $$ begin
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='produtos' and column_name='foto_path')
     and not exists (select 1 from information_schema.columns where table_schema='public' and table_name='produtos' and column_name='foto_url') then
    alter table public.produtos rename column foto_path to foto_url;
  end if;
end $$;
comment on table  public.produtos                 is 'Produtos do catálogo. Identidade de negócio: nome + marca.';
comment on column public.produtos.nome            is 'Nome do produto exibido no site.';
comment on column public.produtos.marca           is 'Marca; NULL quando não houver.';
comment on column public.produtos.subcategoria_id is 'Subcategoria (e, por ela, o departamento) do produto.';
comment on column public.produtos.unidade         is 'Embalagem/unidade de venda (ex.: "Saco 50 kg").';
comment on column public.produtos.preco           is 'Preço atual em R$. NULL = "Consultar preço".';
comment on column public.produtos.preco_antigo    is 'Preço "de" (riscado). Preenchido = produto em promoção.';
comment on column public.produtos.descricao       is 'Descrição exibida no detalhe do produto.';
comment on column public.produtos.foto_url       is 'Caminho do arquivo no bucket "produtos" do Storage (ex.: enxada-tane.jpg).';
comment on column public.produtos.ilustracao      is 'Ilustração SVG provisória (array JSON do site) usada enquanto não há foto.';
comment on column public.produtos.icone           is 'Ícone provisório usado enquanto não há foto nem ilustração.';
comment on column public.produtos.destaque        is 'Aparece em "Mais procurados".';
comment on column public.produtos.novidade        is 'Mostra o selo "Novidade".';
comment on column public.produtos.restrito        is 'Venda restrita (ex.: produto de uso profissional).';
comment on column public.produtos.por_metro       is 'Vendido por metro (o cliente informa a metragem).';
comment on column public.produtos.op_nome         is 'Rótulo das opções do produto (Tamanho, Peso, Bitola...).';
comment on column public.produtos.ativo           is 'Falso = produto escondido do site (ex.: acabou o estoque).';
comment on column public.produtos.ordem           is 'Ordem de exibição; menor aparece primeiro.';
comment on column public.produtos.atualizado_em   is 'Atualizado automaticamente a cada UPDATE (trigger).';

-- Nome + marca únicos (marca NULL conta como '')
create unique index if not exists produtos_nome_marca_unico on public.produtos (nome, coalesce(marca, ''));
create index if not exists produtos_subcategoria_idx on public.produtos (subcategoria_id, ordem);
create index if not exists produtos_ativo_idx        on public.produtos (ativo, ordem);
create index if not exists produtos_destaque_idx     on public.produtos (ordem) where destaque;
create index if not exists produtos_promocao_idx     on public.produtos (ordem) where preco_antigo is not null;

-- Atualiza "atualizado_em" automaticamente em todo UPDATE
create or replace function public.tocar_atualizado_em()
returns trigger language plpgsql as $$
begin
  new.atualizado_em := now();
  return new;
end $$;
comment on function public.tocar_atualizado_em() is 'Trigger: grava a data/hora da última alteração em atualizado_em.';

drop trigger if exists produtos_atualizado_em on public.produtos;
create trigger produtos_atualizado_em
  before update on public.produtos
  for each row execute function public.tocar_atualizado_em();

-- ---------------------------------------------------------------------
-- Opções de um produto (tamanhos, pesos, bitolas...); rótulo em produtos.op_nome
-- ---------------------------------------------------------------------
create table if not exists public.produto_opcoes (
  id         serial primary key,
  produto_id uuid   references public.produtos(id) on delete cascade,
  nome       text   not null,
  ordem      int    default 0
);
comment on table  public.produto_opcoes       is 'Opções selecionáveis de um produto (ex.: 20 mm, 25 mm...).';
comment on column public.produto_opcoes.ordem is 'Ordem em que a opção aparece no site.';
create index if not exists produto_opcoes_produto_idx on public.produto_opcoes (produto_id, ordem);

-- ---------------------------------------------------------------------
-- Administradores: usuários do Supabase Auth que podem editar o catálogo.
-- Para incluir: insert into public.administradores(user_id) values ('<uuid do usuário>');
-- ---------------------------------------------------------------------
create table if not exists public.administradores (
  user_id uuid primary key references auth.users(id) on delete cascade
);
comment on table public.administradores is 'Usuários (auth.users) autorizados a editar o catálogo pelo painel.';
