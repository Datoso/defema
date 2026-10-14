# Contrato de dados — Sistema Defema (Supabase)
Todos os agentes seguem ESTE contrato. Não renomeie tabelas/colunas.

## Tabelas (schema public)
- departamentos(id serial pk, nome text unique not null, info text, ordem int default 0)
- subcategorias(id serial pk, departamento_id int fk → departamentos on delete cascade, nome text not null, ordem int default 0, unique(departamento_id,nome))
- produtos(id uuid pk default gen_random_uuid(), nome text not null, marca text null, subcategoria_id int fk → subcategorias, unidade text, preco numeric(10,2) null  -- null = "consultar preço",
  preco_antigo numeric(10,2) null -- preenchido = promoção, descricao text, foto_url text null -- caminho no bucket "produtos", ex. "enxada-tane.jpg",
  ilustracao jsonb null, icone text null, destaque bool default false -- "mais procurado", novidade bool default false, restrito bool default false,
  por_metro bool default false, op_nome text null, ativo bool default true, ordem int default 0, criado_em timestamptz default now(), atualizado_em timestamptz default now())
  unique(nome, coalesce(marca,'')) (via índice único)
- produto_opcoes(id serial pk, produto_id uuid fk → produtos on delete cascade, nome text not null, ordem int default 0)
- administradores(user_id uuid pk references auth.users) — função public.eh_admin() (supabase.rpc("eh_admin")) diz se o usuário logado é admin
- Storage: bucket público "produtos" (fotos JPEG 500x500).

## Mapeamento para o formato do site (array PRODUTOS)
nome→nome, marca→marca, departamento.nome→dep, subcategoria.nome→sub, unidade→un, preco→preco, preco_antigo→antigo,
destaque→top, novidade→novo, foto_url→foto (URL pública do Storage), ilustracao→ilu, icone→icone, restrito→restrito,
por_metro→porMetro, opcoes(ordenadas).nome→opcoes, op_nome→opNome, descricao→descricao. Departamentos→DEPS {dep:[subs]} e DEP_INFO {dep:info}.

## Arquivo de dados exportado
/home/claude/defema/sistema/dados/produtos.json =
{ "departamentos":[{"nome","info","ordem","subcategorias":["..."]}],
  "produtos":[{"nome","marca","dep","sub","un","preco","antigo","top","novo","foto"(nome do arquivo em site/img ou null),"ilu","icone","restrito","porMetro","opcoes","opNome","descricao","ordem"}] }
Gerado avaliando a página /home/claude/defema/site/defema.html (file://) com Playwright (Chromium em /opt/pw-browsers, NODE_PATH=$(npm root -g)): PRODUTOS, DEPS, DEP_INFO e descricao(p).
