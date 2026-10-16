-- =====================================================================
-- DEFEMA · Catálogo — 03_dados.sql  (GERADO por scripts/gerar-sql-dados.mjs)
-- Carga inicial: 7 departamentos, 99 produtos e 80 opções exportados do site.
-- Rode DEPOIS do 01 e do 02. Pode rodar de novo (idempotente): atualiza
-- pelo nome + marca e recria as opções. ATENÇÃO: rodar de novo sobrescreve
-- preços/textos alterados no painel (o campo "ativo" é preservado).
-- foto_url = nome do arquivo no bucket "produtos" do Storage.
-- =====================================================================
begin;

-- Departamentos
insert into public.departamentos (nome, info, ordem) values ('Defensivos', 'Inseticidas, carrapaticidas e uso profissional', 1)
  on conflict (nome) do update set info = excluded.info, ordem = excluded.ordem;
insert into public.departamentos (nome, info, ordem) values ('Ferramentas', 'Enxadas, pás, martelos, furadeiras', 2)
  on conflict (nome) do update set info = excluded.info, ordem = excluded.ordem;
insert into public.departamentos (nome, info, ordem) values ('Máquinas', 'Pulverizadores, roçadeiras e aparadores', 3)
  on conflict (nome) do update set info = excluded.info, ordem = excluded.ordem;
insert into public.departamentos (nome, info, ordem) values ('Sementes', 'Hortaliças Isla', 4)
  on conflict (nome) do update set info = excluded.info, ordem = excluded.ordem;
insert into public.departamentos (nome, info, ordem) values ('Insumos', 'Adubo, calcário, substrato', 5)
  on conflict (nome) do update set info = excluded.info, ordem = excluded.ordem;
insert into public.departamentos (nome, info, ordem) values ('Mudas', 'Bandejas de hortaliças, café e maracujá', 6)
  on conflict (nome) do update set info = excluded.info, ordem = excluded.ordem;
insert into public.departamentos (nome, info, ordem) values ('Ferragens e EPIs', 'Botas, arames, pregos e grampos', 7)
  on conflict (nome) do update set info = excluded.info, ordem = excluded.ordem;

-- Subcategorias
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Inseticidas', 1 from public.departamentos where nome = 'Defensivos'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Carrapaticidas e mosquicidas', 2 from public.departamentos where nome = 'Defensivos'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Uso profissional', 3 from public.departamentos where nome = 'Defensivos'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Ferramentas manuais', 1 from public.departamentos where nome = 'Ferramentas'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Ferramentas elétricas', 2 from public.departamentos where nome = 'Ferramentas'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Jardinagem', 3 from public.departamentos where nome = 'Ferramentas'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Pulverizadores', 1 from public.departamentos where nome = 'Máquinas'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Roçadeiras e aparadores', 2 from public.departamentos where nome = 'Máquinas'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Folhosas e temperos', 1 from public.departamentos where nome = 'Sementes'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Frutos e legumes', 2 from public.departamentos where nome = 'Sementes'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Raízes e bulbos', 3 from public.departamentos where nome = 'Sementes'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Adubos', 1 from public.departamentos where nome = 'Insumos'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Calcário', 2 from public.departamentos where nome = 'Insumos'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Terras e substratos', 3 from public.departamentos where nome = 'Insumos'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Bandeja 200 mudas', 1 from public.departamentos where nome = 'Mudas'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Bandeja 128 mudas', 2 from public.departamentos where nome = 'Mudas'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Mudas unitárias', 3 from public.departamentos where nome = 'Mudas'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'EPIs', 1 from public.departamentos where nome = 'Ferragens e EPIs'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Cercas e arames', 2 from public.departamentos where nome = 'Ferragens e EPIs'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;
insert into public.subcategorias (departamento_id, nome, ordem)
  select id, 'Ferragens', 3 from public.departamentos where nome = 'Ferragens e EPIs'
  on conflict (departamento_id, nome) do update set ordem = excluded.ordem;

-- Produtos (único por nome + coalesce(marca,''))
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'K-Othrine SC 25', 'Bayer', s.id, 'Frasco 30 mL · ambientes externos', null, null, 'Inseticida piretroide (deltametrina) para desinsetização de ambientes externos. Usado contra baratas, formigas, pulgas, moscas e mosquitos ao redor da casa, do galpão e das instalações.', 'k-othrine-sc25.jpg', null, null, false, false, false, false, null, 10
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Defensivos' and s.nome = 'Inseticidas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Diazitop PM', 'Clarion', s.id, 'Sachê 25 g · uso rural', null, null, 'Inseticida organofosforado em pó molhável, de uso veterinário e rural. Dilua em água conforme a tabela do sachê.', 'diazitop-pm.jpg', null, null, false, false, false, false, null, 20
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Defensivos' and s.nome = 'Inseticidas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Butox P CE 25', 'MSD Saúde Animal', s.id, 'Frasco 20 mL · carrapatos, moscas e sarna', null, null, 'Carrapaticida, mosquicida e sarnicida à base de deltametrina, de uso veterinário. Indicado para o gado e outros animais, aplicado por pulverização ou banho.', 'butox-p-ce25.jpg', null, null, false, false, false, false, null, 30
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Defensivos' and s.nome = 'Carrapaticidas e mosquicidas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Triatox', 'MSD Saúde Animal', s.id, 'Frasco 200 mL · carrapaticida para bovinos', null, null, 'Carrapaticida para bovinos à base de amitraz, de uso veterinário. Aplicado por pulverização ou banho de imersão.', 'triatox.jpg', null, null, false, false, false, false, null, 40
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Defensivos' and s.nome = 'Carrapaticidas e mosquicidas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Colosso Pulverização', 'Ourofino', s.id, 'Frasco 25 mL · carrapatos e moscas no gado', null, null, 'Carrapaticida e mosquicida da Ourofino para pulverização em bovinos. Respeite o período de carência (abate e leite) informado no rótulo.', 'colosso-pulverizacao.jpg', null, null, false, false, false, false, null, 50
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Defensivos' and s.nome = 'Carrapaticidas e mosquicidas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Ficam VC Profissional', 'Envu', s.id, 'Sachê 15 g · escorpiões, baratas e mosquitos', null, null, 'Inseticida profissional (bendiocarbe) para controle de escorpiões, baratas e mosquitos, inclusive o Aedes aegypti. Produto de venda restrita a dedetizadoras e órgãos públicos.', 'ficam-vc.jpg', null, null, false, false, true, false, null, 60
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Defensivos' and s.nome = 'Uso profissional'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Enxada larga com cabo 145 cm', 'Tramontina', s.id, 'Cabo de madeira', 79.9, null, 'Enxada larga com cabo de madeira, para capinar, abrir sulcos e fazer leiras.', 'enxada-tramontina.jpg', null, null, true, false, false, false, null, 70
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Cavadeira articulada', null, s.id, 'Cabos de madeira', 99.9, 114.9, 'Cavadeira de duas hastes, para abrir buracos de mourão, cerca e plantio de mudas.', 'cavadeira-articulada.jpg', null, null, false, false, false, false, null, 80
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Pá de bico com cabo', null, s.id, 'Cabo longo de madeira', 64.9, null, 'Pá de bico com cabo longo, para cavar e revolver terra.', 'pa-de-bico.jpg', null, null, false, false, false, false, null, 90
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Pá quadrada com cabo', 'Tramontina', s.id, 'Cabo longo de madeira', null, null, 'Pá quadrada com cabo longo, para recolher e transportar terra, areia, adubo e calcário.', 'pa-quadrada-tramontina.jpg', null, null, false, false, false, false, null, 100
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Furadeira de impacto FIV 1050', 'Vonder', s.id, 'Com fio · empunhadura auxiliar', null, null, 'Furadeira de impacto Vonder com fio, para furar madeira, metal e alvenaria. Acompanha empunhadura auxiliar e limitador de profundidade.', 'furadeira-vonder-fiv1050.jpg', null, null, false, false, false, false, null, 110
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas elétricas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Parafusadeira e furadeira a bateria', 'Vonder', s.id, 'Com maleta, carregador, brocas e bits', null, null, 'Parafusadeira e furadeira sem fio Vonder, com maleta, bateria, carregador, brocas e bits. Prática para montagem, manutenção e serviços no sítio.', 'parafusadeira-vonder.jpg', null, null, false, false, false, false, null, 120
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas elétricas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Enxadão duas caras', null, s.id, 'Pá de um lado, corte do outro', null, null, 'Enxadão com dois lados: um largo para cavar e outro estreito para cortar raízes e terra dura.', 'enxadao-duas-caras.jpg', null, null, false, false, false, false, null, 130
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Enxada', 'Tane', s.id, 'Sem cabo', null, null, 'Enxada Tane sem cabo, para capina e preparo do solo. Escolha o peso: quanto maior, mais larga e pesada.', 'enxada-tane.jpg', null, null, false, false, false, false, 'Peso', 140
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Colher de pedreiro', 'Tramontina', s.id, 'Cabo de madeira', null, null, 'Colher de pedreiro Tramontina com cabo de madeira, para assentar tijolo e aplicar massa.', 'colher-pedreiro-tramontina.jpg', null, null, false, false, false, false, null, 150
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Marreta', null, s.id, 'Marreta de mão · cabo de madeira', null, null, 'Marreta oitavada de mão (também chamada de paceta) com cabo de madeira, para quebrar, bater estaca, talhadeira e serviços de obra.', 'paceta.jpg', null, null, false, false, false, false, null, 160
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Chave de fenda', 'Vonder', s.id, 'Unitária', null, null, 'Chave de fenda Vonder unitária, com haste cromada e cabo emborrachado. Escolha o tamanho.', 'chave-fenda-vonder.jpg', null, null, false, false, false, false, 'Tamanho', 170
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Chave Phillips', 'Vonder', s.id, 'Unitária', null, null, 'Chave Phillips Vonder unitária, com haste cromada e cabo emborrachado. Escolha o tamanho.', 'chave-phillips-vonder.jpg', null, null, false, false, false, false, 'Tamanho', 180
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Mangueira trançada', 'Mantac', s.id, 'Vendida por metro', 7, null, 'Mangueira de jardim trançada Mantac, vendida por metro: escolha a quantidade de metros no pedido. Pergunte pelos engates e esguichos.', 'mangueira-mantac.jpg', null, null, false, false, false, true, null, 190
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Jardinagem'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Mangueira azul siliconada', null, s.id, 'Vendida por metro', null, null, 'Mangueira siliconada azul, flexível e resistente, vendida por metro. Pergunte pelos engates e esguichos.', 'mangueira-azul-siliconada.jpg', null, null, false, false, false, true, null, 200
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Jardinagem'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Cultivador de mão 3 dentes', 'Tramontina', s.id, 'Cabo curto de madeira', null, null, 'Cultivador de mão para afofar a terra e tirar matinho de canteiros e vasos.', 'cultivador-tramontina.jpg', null, null, false, true, false, false, null, 210
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Jardinagem'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Ancinho de jardim', 'Tramontina', s.id, 'Com cabo', 44.9, null, 'Ancinho (rastelo) para juntar folhas e nivelar canteiros.', null, '["ancinho"]'::jsonb, null, false, false, false, false, null, 220
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Jardinagem'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Tesoura de poda', null, s.id, 'Cabo com mola · uso leve', 49.9, null, 'Tesoura de poda com mola, para galhos finos, flores, folhas e colheita.', 'tesoura-de-poda.jpg', null, null, false, false, false, false, null, 230
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Jardinagem'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Tesoura de poda para galhos', null, s.id, 'Reforçada · galhos mais grossos', null, null, 'Tesoura de poda reforçada, para galhos mais grossos de árvores frutíferas e cercas vivas.', 'tesoura-poda-galhos.jpg', null, null, false, false, false, false, null, 240
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Jardinagem'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Pulverizador costal PJH 20', 'Jacto', s.id, 'Manual, 20 L · câmara metálica', 449, 489, 'Pulverizador costal manual de 20 litros, com câmara de pressão metálica. Clássico da Jacto para aplicação em lavoura, horta e pastagem.', 'pjh20-jacto.jpeg', null, null, true, false, false, false, null, 250
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Máquinas' and s.nome = 'Pulverizadores'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Pulverizador manual 5 L', 'Brudden', s.id, 'Com alças para as costas', null, null, 'Pulverizador manual de 5 litros, leve e com alças. Bom para horta, jardim e pequenas áreas.', 'pulverizador-brudden-5l.jpg', null, null, false, false, false, false, null, 260
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Máquinas' and s.nome = 'Pulverizadores'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Pulverizador lateral manual PL 005', 'Vonder', s.id, '5 L · compressão prévia', null, null, 'Pulverizador de compressão prévia de 5 litros: bombeie antes e aplique com o gatilho. Leve, com alça de ombro, para jardim e horta.', 'pulverizador-vonder-pl005.jpg', null, null, false, false, false, false, null, 270
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Máquinas' and s.nome = 'Pulverizadores'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Roçadeira a gasolina', null, s.id, 'Guidão duplo · fio de nylon', null, null, 'Roçadeira lateral com motor a gasolina e guidão duplo, para roçar mato, capim e beira de cerca. Usa fio de nylon ou lâmina.', 'rocadeira-gasolina.jpg', null, null, false, false, false, false, null, 280
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Máquinas' and s.nome = 'Roçadeiras e aparadores'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Aparador de grama elétrico', null, s.id, 'Com fio · carretel de nylon', null, null, 'Aparador elétrico com fio de nylon, leve, para acabamento de grama e bordas no quintal e no jardim.', 'aparador-eletrico.jpg', null, null, false, false, false, false, null, 290
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Máquinas' and s.nome = 'Roçadeiras e aparadores'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Alface Crespa Grand Rapids TBR', 'Isla', s.id, 'Envelope', 6.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'alface-crespa-grand-rapids.jpeg', null, null, true, false, false, false, null, 300
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Folhosas e temperos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Alface Grandes Lagos Americana', 'Isla', s.id, 'Envelope', 6.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'alface-grandes-lagos-americana.jpeg', null, null, false, false, false, false, null, 310
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Folhosas e temperos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Alface Lisa Baba de Verão', 'Isla', s.id, 'Envelope', 6.9, 8.9, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'alface-lisa-baba-de-verao.jpeg', null, null, false, false, false, false, null, 320
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Folhosas e temperos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Almeirão de Cabeça Pão de Açúcar', 'Isla', s.id, 'Envelope', 6.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'almeirao-de-cabeca-pao-de-acucar.jpg', null, null, false, false, false, false, null, 330
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Folhosas e temperos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Almeirão Amarelo (Radiche)', 'Isla', s.id, 'Envelope', 6.5, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'almeirao-folha-larga-amarelo-radiche.jpg', null, null, false, false, false, false, null, 340
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Folhosas e temperos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Couve Manteiga da Geórgia', 'Isla', s.id, 'Envelope', 6.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'couve-manteiga-da-georgia.jpg', null, null, true, false, false, false, null, 350
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Folhosas e temperos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Couve-Brócolis Piracicaba Precoce', 'Isla', s.id, 'Envelope', 7.5, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'couve-brocolis-piracicaba-precoce.jpg', null, null, false, false, false, false, null, 360
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Folhosas e temperos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Rúcula Gigante Folha Larga', 'Isla', s.id, 'Envelope', 6.5, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'rucula-gigante-folha-larga.jpeg', null, null, false, false, false, false, null, 370
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Folhosas e temperos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Cebolinha Híbrida Sahara', 'Isla', s.id, 'Envelope', 9.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'cebolinha-hibrido-sahara.jpg', null, null, false, true, false, false, null, 380
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Folhosas e temperos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Tomate Santa Cruz Kada (Paulista)', 'Isla', s.id, 'Envelope', 7.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'tomate-santa-cruz-kada.jpg', null, null, true, false, false, false, null, 390
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Frutos e legumes'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Tomate Cereja', 'Isla', s.id, 'Envelope', 8.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'tomate-cereja.jpg', null, null, false, false, false, false, null, 400
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Frutos e legumes'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Abóbora Híbrida Tetsukabuto F1', 'Isla', s.id, 'Envelope', 14.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'abobora-hibrido-f1-tetsukabuto.jpg', null, null, false, false, false, false, null, 410
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Frutos e legumes'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Abóbora Menina Brasileira Precoce', 'Isla', s.id, 'Envelope', 6.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'abobora-precoce-menina-brasileira.jpg', null, null, false, false, false, false, null, 420
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Frutos e legumes'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Abóbora Itapuã 301 tipo Jacarezinho', 'Isla', s.id, 'Envelope', 7.5, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'abobora-tipo-jacarezinho-itapua.jpg', null, null, false, false, false, false, null, 430
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Frutos e legumes'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Abobrinha de Tronco Caserta', 'Isla', s.id, 'Envelope', 6.9, 8.5, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'abobrinha-de-tronco-caserta.jpg', null, null, false, false, false, false, null, 440
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Frutos e legumes'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Moranga Exposição de Mesa', 'Isla', s.id, 'Envelope', 7.5, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'moranga-exposicao-de-mesa.jpg', null, null, false, false, false, false, null, 450
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Frutos e legumes'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Melancia Crimson Sweet', 'Isla', s.id, 'Envelope', 7.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'melancia-crimson-sweet.jpg', null, null, true, false, false, false, null, 460
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Frutos e legumes'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Melancia Charleston Gray Super', 'Isla', s.id, 'Envelope', 7.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'melancia-charleston-gray.jpeg', null, null, false, false, false, false, null, 470
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Frutos e legumes'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Melão Caipira Gaúcho', 'Isla', s.id, 'Envelope', 7.5, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'melao-caipira-gaucho.jpeg', null, null, false, false, false, false, null, 480
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Frutos e legumes'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Melão Redondo Gaúcho', 'Isla', s.id, 'Envelope', 7.5, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'melao-redondo-gaucho.jpeg', null, null, false, false, false, false, null, 490
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Frutos e legumes'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Pepino Melhorado Aodai', 'Isla', s.id, 'Envelope', 6.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'pepino-melhorado-aodai.jpeg', null, null, false, false, false, false, null, 500
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Frutos e legumes'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Quiabo Santa Cruz 47', 'Isla', s.id, 'Envelope', 6.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'quiabo-santa-cruz.jpg', null, null, false, false, false, false, null, 510
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Frutos e legumes'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Jiló Verde Escuro Morro Grande', 'Isla', s.id, 'Envelope', 6.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'jilo-escuro-morro-grande-verde.jpg', null, null, false, false, false, false, null, 520
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Frutos e legumes'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Maxixe', 'Isla', s.id, 'Envelope', 6.5, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'maxixe-maxixe.jpg', null, null, false, false, false, false, null, 530
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Frutos e legumes'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Feijão-Vagem Macarrão Trepador (Favorito)', 'Isla', s.id, 'Envelope', 8.9, 10.9, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'feijao-vagem-macarrao-trepador-favorito.jpg', null, null, false, false, false, false, null, 540
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Frutos e legumes'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Beterraba Itapuã 202', 'Isla', s.id, 'Envelope', 6.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'beterraba-itapua.jpg', null, null, false, false, false, false, null, 550
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Raízes e bulbos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Cebola Baia Periforme', 'Isla', s.id, 'Envelope', 6.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'cebola-baia-periforme.jpg', null, null, false, false, false, false, null, 560
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Raízes e bulbos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Rabanete Gigante Sículo', 'Isla', s.id, 'Envelope', 5.9, null, 'Semente de hortaliça Isla em envelope. No verso do envelope você encontra a época de plantio da sua região, o espaçamento e o tempo até a colheita.', 'rabanete-vermelho-gigante-siculo.jpg', null, null, false, false, false, false, null, 570
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Sementes' and s.nome = 'Raízes e bulbos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Adubo NPK 10-10-10', 'Heringer', s.id, 'Saco 50 kg', 219.9, 239.9, 'Adubo mineral NPK. Os números são as porcentagens de nitrogênio (N), fósforo (P) e potássio (K). Fórmula equilibrada, de uso geral.', 'adubo-heringer.jpg', null, null, true, false, false, false, null, 580
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Insumos' and s.nome = 'Adubos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Adubo NPK 20-05-20', 'Heringer', s.id, 'Saco 50 kg', 249.9, null, 'Adubo mineral NPK. Os números são as porcentagens de nitrogênio (N), fósforo (P) e potássio (K). Mais nitrogênio e potássio: muito usado em adubação de cobertura.', 'adubo-heringer.jpg', null, null, false, false, false, false, null, 590
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Insumos' and s.nome = 'Adubos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Adubo NPK 04-14-08', 'Heringer', s.id, 'Saco 50 kg', 189.9, null, 'Adubo mineral NPK. Os números são as porcentagens de nitrogênio (N), fósforo (P) e potássio (K). Rico em fósforo: muito usado no plantio.', 'adubo-heringer.jpg', null, null, false, false, false, false, null, 600
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Insumos' and s.nome = 'Adubos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Calcário dolomítico PRNT 90%', null, s.id, 'Saco 40 kg', 32.9, null, 'Corrige a acidez do solo e fornece cálcio e magnésio para as plantas. Aplique com antecedência ao plantio e incorpore à terra. A quantidade certa depende da análise de solo; pergunte no balcão.', null, '["saco","CALCÁRIO|DOLOMÍTICO","#8a8f94","#e9e6df"]'::jsonb, null, false, false, false, false, null, 610
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Insumos' and s.nome = 'Calcário'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Substrato para plantas Carolina Soil', 'Carolina Soil', s.id, 'Saco 45 L', 42.9, null, 'Substrato pronto para produção de mudas em bandejas, copinhos e vasos. Leve, retém água e não precisa misturar.', 'carolina-soil.jpeg', null, null, false, false, false, false, null, 620
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Insumos' and s.nome = 'Terras e substratos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Terra vegetal', null, s.id, 'Saco 25 kg', 16.9, null, 'Terra rica em matéria orgânica para vasos, canteiros e jardins.', null, '["saco","TERRA|VEGETAL","#2f6b3c","#5a3d26"]'::jsonb, null, false, false, false, false, null, 630
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Insumos' and s.nome = 'Terras e substratos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Húmus de minhoca', null, s.id, 'Saco 25 kg', 34.9, 39.9, 'Adubo orgânico natural que melhora a terra e nutre as plantas. Bom para horta, vasos, jardim e plantio de mudas.', null, '["saco","HÚMUS DE|MINHOCA","#6b4a2f","#3a281b"]'::jsonb, null, false, false, false, false, null, 640
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Insumos' and s.nome = 'Terras e substratos'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Muda de alface crespa Vanda', null, s.id, 'Bandeja com 200 mudas', 40, null, 'Bandeja com 200 mudas prontas para transplante para o canteiro ou para o vaso. Retire na loja.', null, '["bandeja","alface",200]'::jsonb, null, false, false, false, false, null, 650
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Mudas' and s.nome = 'Bandeja 200 mudas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Muda de alface americana', null, s.id, 'Bandeja com 200 mudas', 40, null, 'Bandeja com 200 mudas prontas para transplante para o canteiro ou para o vaso. Retire na loja.', null, '["bandeja","americana",200]'::jsonb, null, false, false, false, false, null, 660
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Mudas' and s.nome = 'Bandeja 200 mudas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Muda de rúcula', null, s.id, 'Bandeja com 200 mudas', 40, null, 'Bandeja com 200 mudas prontas para transplante para o canteiro ou para o vaso. Retire na loja.', null, '["bandeja","rucula",200]'::jsonb, null, false, false, false, false, null, 670
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Mudas' and s.nome = 'Bandeja 200 mudas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Muda de coentro', null, s.id, 'Bandeja com 200 mudas', 40, null, 'Bandeja com 200 mudas prontas para transplante para o canteiro ou para o vaso. Retire na loja.', null, '["bandeja","coentro",200]'::jsonb, null, false, false, false, false, null, 680
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Mudas' and s.nome = 'Bandeja 200 mudas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Muda de salsa', null, s.id, 'Bandeja com 200 mudas', 40, null, 'Bandeja com 200 mudas prontas para transplante para o canteiro ou para o vaso. Retire na loja.', null, '["bandeja","salsa",200]'::jsonb, null, false, false, false, false, null, 690
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Mudas' and s.nome = 'Bandeja 200 mudas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Muda de cebolinha', null, s.id, 'Bandeja com 200 mudas', 40, null, 'Bandeja com 200 mudas prontas para transplante para o canteiro ou para o vaso. Retire na loja.', null, '["bandeja","cebolinha",200]'::jsonb, null, false, false, false, false, null, 700
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Mudas' and s.nome = 'Bandeja 200 mudas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Muda de almeirão Pão de Açúcar', null, s.id, 'Bandeja com 200 mudas', 40, null, 'Bandeja com 200 mudas prontas para transplante para o canteiro ou para o vaso. Retire na loja.', null, '["bandeja","almeirao",200]'::jsonb, null, false, false, false, false, null, 710
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Mudas' and s.nome = 'Bandeja 200 mudas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Muda de pimentão híbrido Magali', null, s.id, 'Bandeja com 128 mudas', 60, null, 'Bandeja com 128 mudas prontas para transplante para o canteiro ou para o vaso. Retire na loja.', null, '["bandeja","pimentao",128]'::jsonb, null, false, false, false, false, null, 720
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Mudas' and s.nome = 'Bandeja 128 mudas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Muda de berinjela Napoli', null, s.id, 'Bandeja com 128 mudas', 60, null, 'Bandeja com 128 mudas prontas para transplante para o canteiro ou para o vaso. Retire na loja.', null, '["bandeja","berinjela",128]'::jsonb, null, false, false, false, false, null, 730
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Mudas' and s.nome = 'Bandeja 128 mudas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Muda de berinjela japonesa', null, s.id, 'Bandeja com 128 mudas', 60, null, 'Bandeja com 128 mudas prontas para transplante para o canteiro ou para o vaso. Retire na loja.', null, '["bandeja","berinjela",128]'::jsonb, null, false, false, false, false, null, 740
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Mudas' and s.nome = 'Bandeja 128 mudas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Muda de couve manteiga', null, s.id, 'Bandeja com 128 mudas', 60, null, 'Bandeja com 128 mudas prontas para transplante para o canteiro ou para o vaso. Retire na loja.', null, '["bandeja","couve",128]'::jsonb, null, false, false, false, false, null, 750
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Mudas' and s.nome = 'Bandeja 128 mudas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Muda de jiló', null, s.id, 'Bandeja com 128 mudas', 60, null, 'Bandeja com 128 mudas prontas para transplante para o canteiro ou para o vaso. Retire na loja.', null, '["bandeja","jilo",128]'::jsonb, null, false, false, false, false, null, 760
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Mudas' and s.nome = 'Bandeja 128 mudas'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Muda de pimenta malagueta', null, s.id, 'Muda pequena, tamanho de bandeja', 1, null, 'Muda pequena, do tamanho das de bandeja, pronta para plantar em vaso ou canteiro.', null, '["vaso","malagueta"]'::jsonb, null, false, false, false, false, null, 770
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Mudas' and s.nome = 'Mudas unitárias'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Muda de pimenta dedo-de-moça', null, s.id, 'Muda pequena, tamanho de bandeja', 1, null, 'Muda pequena, do tamanho das de bandeja, pronta para plantar em vaso ou canteiro.', null, '["vaso","dedo"]'::jsonb, null, false, false, false, false, null, 780
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Mudas' and s.nome = 'Mudas unitárias'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Muda de café', null, s.id, 'Tubete plástico de ~15 cm', 7, null, 'Muda de café em tubete plástico de cerca de 15 cm, pronta para plantio.', null, '["vaso","cafe"]'::jsonb, null, false, false, false, false, null, 790
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Mudas' and s.nome = 'Mudas unitárias'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Muda de maracujá azedo', null, s.id, 'Saquinho 30 × 25 cm · para suco', 15, null, 'Muda de maracujá azedo (para suco) em saquinho de 30 × 25 cm. Precisa de espaldeira ou cerca para subir.', null, '["vaso","maracuja"]'::jsonb, null, false, false, false, false, null, 800
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Mudas' and s.nome = 'Mudas unitárias'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Botina de segurança com elástico', null, s.id, 'Couro · vários números', null, null, 'Botina de couro com elástico lateral, fácil de calçar, para o trabalho no campo e na obra.', 'botina-seguranca.jpg', null, null, false, false, false, false, null, 810
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferragens e EPIs' and s.nome = 'EPIs'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Bota de PVC preta', 'Vonder', s.id, 'Cano médio · vários números', null, null, 'Bota de PVC impermeável Vonder, cano médio, solado antiderrapante. Para curral, horta e dias de chuva.', 'bota-pvc-vonder.jpg', null, null, false, false, false, false, null, 820
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferragens e EPIs' and s.nome = 'EPIs'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Bota de PVC branca cano longo', null, s.id, 'Vários números', null, null, 'Bota de PVC branca de cano longo, impermeável. Muito usada em ordenha, laticínio e cozinha industrial.', 'bota-pvc-branca.jpg', null, null, false, false, false, false, null, 830
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferragens e EPIs' and s.nome = 'EPIs'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Protetor auricular tipo concha', null, s.id, 'Abafador de ruído com haste ajustável', null, null, 'Abafador de ruído tipo concha, para usar com roçadeira, motosserra, trator e outras máquinas barulhentas.', 'abafador.jpg', null, null, false, false, false, false, null, 840
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferragens e EPIs' and s.nome = 'EPIs'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Protetor auditivo de silicone Pomp Plus', '3M', s.id, 'Par com cordão · caixinha', null, null, 'Protetor auditivo 3M de inserção, em silicone, com cordão e caixinha para guardar. Reutilizável.', 'protetor-3m-pomp.jpg', null, null, false, false, false, false, null, 850
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferragens e EPIs' and s.nome = 'EPIs'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Capa de chuva de PVC', 'Vonder', s.id, 'Com manga e capuz · sem forro', null, null, 'Capa de chuva Vonder de PVC laminado, com manga e capuz, sem forro.', 'capa-pvc-vonder.jpg', null, null, false, false, false, false, 'Tamanho', 860
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferragens e EPIs' and s.nome = 'EPIs'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Arame farpado Motto', 'Belgo', s.id, 'Rolo 500 m', null, null, 'Arame farpado galvanizado Belgo, em rolo de 500 metros, para cercas de divisa e pastagem.', 'arame-farpado-motto.jpg', null, null, false, false, false, false, null, 870
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferragens e EPIs' and s.nome = 'Cercas e arames'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Arame ovalado Z-700', 'Belgo', s.id, 'Rolo 1.000 m · arame liso', null, null, 'Arame liso ovalado de alta resistência Belgo, em rolo de 1.000 metros. Muito usado em cercas de gado e cerca elétrica.', 'arame-ovalado-z700.jpg', null, null, false, false, false, false, null, 880
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferragens e EPIs' and s.nome = 'Cercas e arames'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Grampo polido para cerca 19×11', 'Gerdau', s.id, 'Pacote 1 kg', null, null, 'Grampo em U para fixar arame em mourões e estacas de madeira. Pacote de 1 kg.', 'grampo-gerdau.jpg', null, null, false, false, false, false, null, 890
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferragens e EPIs' and s.nome = 'Cercas e arames'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Prego com cabeça', 'Gerdau', s.id, 'Pacote 1 kg', null, null, 'Prego com cabeça Gerdau em pacote de 1 kg, para madeira, cerca, telhado e obra. Escolha a bitola.', 'prego-gerdau.jpg', null, null, false, false, false, false, 'Bitola', 900
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferragens e EPIs' and s.nome = 'Ferragens'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Cadeado de latão', 'Pado', s.id, 'Com 2 chaves', null, null, 'Cadeado Pado de latão maciço, resistente à ferrugem, com 2 chaves. Escolha o tamanho.', 'cadeado-pado.jpg', null, null, false, false, false, false, 'Tamanho', 910
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferragens e EPIs' and s.nome = 'Ferragens'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Cadeado de latão', 'Papaiz', s.id, 'Com 2 chaves', null, null, 'Cadeado Papaiz de latão maciço, resistente à ferrugem, com 2 chaves. Escolha o tamanho.', 'cadeado-papaiz.jpg', null, null, false, false, false, false, 'Tamanho', 920
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferragens e EPIs' and s.nome = 'Ferragens'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Alicate universal', 'Gedore', s.id, 'Cabo isolado 1000 V', null, null, 'Alicate universal Gedore com cabo isolado para 1000 V. Corta, segura e torce fios e arames.', 'alicate-gedore.jpg', null, null, false, false, false, false, null, 930
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Martelo de unha', 'Vonder', s.id, 'Cabo de madeira', null, null, 'Martelo de unha Vonder com cabo de madeira. Prega e arranca pregos. Escolha o tamanho da cabeça.', 'martelo-vonder.jpg', null, null, false, false, false, false, 'Tamanho', 940
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Serrote', 'Irwin', s.id, 'Linha profissional · cabo de madeira', null, null, 'Serrote Irwin Jack, linha profissional, com dentes temperados e cabo de madeira. Corte rápido e preciso em madeira. Escolha o tamanho.', 'serrote-irwin.jpg', null, null, false, false, false, false, 'Tamanho', 950
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Serrote', 'Tramontina', s.id, 'Uso geral · cabo de madeira', null, null, 'Serrote Tramontina de uso geral, com cabo de madeira. Bom custo-benefício para serviços do dia a dia no sítio e em casa.', 'serrote-tramontina.jpg', null, null, false, false, false, false, 'Tamanho', 960
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Facão', 'Corneta', s.id, 'Lâmina de aço', null, null, 'Facão Corneta para roçar, abrir picada e cortar galhos. Escolha o tamanho da lâmina.', 'facao-16.jpg', null, null, false, false, false, false, 'Tamanho', 970
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Facão', 'Tramontina', s.id, 'Lâmina de aço carbono · cabo de madeira', null, null, 'Facão Tramontina com lâmina de aço carbono e cabo de madeira, para mato e serviços do sítio. Escolha o tamanho.', 'facao-tramontina.jpg', null, null, false, false, false, false, 'Tamanho', 980
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, preco_antigo, descricao, foto_url, ilustracao, icone, destaque, novidade, restrito, por_metro, op_nome, ordem)
select 'Chave combinada', null, s.id, 'Boca e estria · unitária', null, null, 'Chave combinada (boca e estria) unitária, para porcas e parafusos de máquinas, implementos e manutenção. Escolha a medida.', 'chave-combinada.jpg', null, null, false, false, false, false, 'Medida', 990
  from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
 where d.nome = 'Ferramentas' and s.nome = 'Ferramentas manuais'
on conflict (nome, coalesce(marca, '')) do update set subcategoria_id = excluded.subcategoria_id, unidade = excluded.unidade,
  preco = excluded.preco, preco_antigo = excluded.preco_antigo, descricao = excluded.descricao, foto_url = excluded.foto_url,
  ilustracao = excluded.ilustracao, icone = excluded.icone, destaque = excluded.destaque, novidade = excluded.novidade,
  restrito = excluded.restrito, por_metro = excluded.por_metro, op_nome = excluded.op_nome, ordem = excluded.ordem;

-- Opções (tamanhos, pesos...): recria as opções de cada produto
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'K-Othrine SC 25' and coalesce(marca, '') = 'Bayer');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Diazitop PM' and coalesce(marca, '') = 'Clarion');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Butox P CE 25' and coalesce(marca, '') = 'MSD Saúde Animal');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Triatox' and coalesce(marca, '') = 'MSD Saúde Animal');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Colosso Pulverização' and coalesce(marca, '') = 'Ourofino');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Ficam VC Profissional' and coalesce(marca, '') = 'Envu');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Enxada larga com cabo 145 cm' and coalesce(marca, '') = 'Tramontina');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Cavadeira articulada' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Pá de bico com cabo' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Pá quadrada com cabo' and coalesce(marca, '') = 'Tramontina');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Furadeira de impacto FIV 1050' and coalesce(marca, '') = 'Vonder');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Parafusadeira e furadeira a bateria' and coalesce(marca, '') = 'Vonder');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Enxadão duas caras' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Enxada' and coalesce(marca, '') = 'Tane');
insert into public.produto_opcoes (produto_id, nome, ordem) select (select id from public.produtos where nome = 'Enxada' and coalesce(marca, '') = 'Tane'), v.nome, v.ordem from (values ('1 lb', 1), ('1,5 lb', 2), ('2 lb', 3), ('2,5 lb', 4)) as v(nome, ordem);
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Colher de pedreiro' and coalesce(marca, '') = 'Tramontina');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Marreta' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Chave de fenda' and coalesce(marca, '') = 'Vonder');
insert into public.produto_opcoes (produto_id, nome, ordem) select (select id from public.produtos where nome = 'Chave de fenda' and coalesce(marca, '') = 'Vonder'), v.nome, v.ordem from (values ('1/8" × 3"', 1), ('3/16" × 4"', 2), ('1/4" × 6"', 3), ('5/16" × 8"', 4)) as v(nome, ordem);
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Chave Phillips' and coalesce(marca, '') = 'Vonder');
insert into public.produto_opcoes (produto_id, nome, ordem) select (select id from public.produtos where nome = 'Chave Phillips' and coalesce(marca, '') = 'Vonder'), v.nome, v.ordem from (values ('1/8" × 3"', 1), ('3/16" × 4"', 2), ('1/4" × 6"', 3)) as v(nome, ordem);
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Mangueira trançada' and coalesce(marca, '') = 'Mantac');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Mangueira azul siliconada' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Cultivador de mão 3 dentes' and coalesce(marca, '') = 'Tramontina');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Ancinho de jardim' and coalesce(marca, '') = 'Tramontina');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Tesoura de poda' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Tesoura de poda para galhos' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Pulverizador costal PJH 20' and coalesce(marca, '') = 'Jacto');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Pulverizador manual 5 L' and coalesce(marca, '') = 'Brudden');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Pulverizador lateral manual PL 005' and coalesce(marca, '') = 'Vonder');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Roçadeira a gasolina' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Aparador de grama elétrico' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Alface Crespa Grand Rapids TBR' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Alface Grandes Lagos Americana' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Alface Lisa Baba de Verão' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Almeirão de Cabeça Pão de Açúcar' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Almeirão Amarelo (Radiche)' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Couve Manteiga da Geórgia' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Couve-Brócolis Piracicaba Precoce' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Rúcula Gigante Folha Larga' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Cebolinha Híbrida Sahara' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Tomate Santa Cruz Kada (Paulista)' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Tomate Cereja' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Abóbora Híbrida Tetsukabuto F1' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Abóbora Menina Brasileira Precoce' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Abóbora Itapuã 301 tipo Jacarezinho' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Abobrinha de Tronco Caserta' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Moranga Exposição de Mesa' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Melancia Crimson Sweet' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Melancia Charleston Gray Super' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Melão Caipira Gaúcho' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Melão Redondo Gaúcho' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Pepino Melhorado Aodai' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Quiabo Santa Cruz 47' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Jiló Verde Escuro Morro Grande' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Maxixe' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Feijão-Vagem Macarrão Trepador (Favorito)' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Beterraba Itapuã 202' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Cebola Baia Periforme' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Rabanete Gigante Sículo' and coalesce(marca, '') = 'Isla');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Adubo NPK 10-10-10' and coalesce(marca, '') = 'Heringer');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Adubo NPK 20-05-20' and coalesce(marca, '') = 'Heringer');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Adubo NPK 04-14-08' and coalesce(marca, '') = 'Heringer');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Calcário dolomítico PRNT 90%' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Substrato para plantas Carolina Soil' and coalesce(marca, '') = 'Carolina Soil');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Terra vegetal' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Húmus de minhoca' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Muda de alface crespa Vanda' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Muda de alface americana' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Muda de rúcula' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Muda de coentro' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Muda de salsa' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Muda de cebolinha' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Muda de almeirão Pão de Açúcar' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Muda de pimentão híbrido Magali' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Muda de berinjela Napoli' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Muda de berinjela japonesa' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Muda de couve manteiga' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Muda de jiló' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Muda de pimenta malagueta' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Muda de pimenta dedo-de-moça' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Muda de café' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Muda de maracujá azedo' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Botina de segurança com elástico' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Bota de PVC preta' and coalesce(marca, '') = 'Vonder');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Bota de PVC branca cano longo' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Protetor auricular tipo concha' and coalesce(marca, '') = '');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Protetor auditivo de silicone Pomp Plus' and coalesce(marca, '') = '3M');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Capa de chuva de PVC' and coalesce(marca, '') = 'Vonder');
insert into public.produto_opcoes (produto_id, nome, ordem) select (select id from public.produtos where nome = 'Capa de chuva de PVC' and coalesce(marca, '') = 'Vonder'), v.nome, v.ordem from (values ('G', 1), ('GG', 2)) as v(nome, ordem);
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Arame farpado Motto' and coalesce(marca, '') = 'Belgo');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Arame ovalado Z-700' and coalesce(marca, '') = 'Belgo');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Grampo polido para cerca 19×11' and coalesce(marca, '') = 'Gerdau');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Prego com cabeça' and coalesce(marca, '') = 'Gerdau');
insert into public.produto_opcoes (produto_id, nome, ordem) select (select id from public.produtos where nome = 'Prego com cabeça' and coalesce(marca, '') = 'Gerdau'), v.nome, v.ordem from (values ('12×12', 1), ('15×15', 2), ('17×21', 3), ('18×27', 4), ('20×42', 5)) as v(nome, ordem);
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Cadeado de latão' and coalesce(marca, '') = 'Pado');
insert into public.produto_opcoes (produto_id, nome, ordem) select (select id from public.produtos where nome = 'Cadeado de latão' and coalesce(marca, '') = 'Pado'), v.nome, v.ordem from (values ('20 mm', 1), ('25 mm', 2), ('30 mm', 3), ('35 mm', 4), ('40 mm', 5), ('45 mm', 6), ('50 mm', 7), ('60 mm', 8)) as v(nome, ordem);
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Cadeado de latão' and coalesce(marca, '') = 'Papaiz');
insert into public.produto_opcoes (produto_id, nome, ordem) select (select id from public.produtos where nome = 'Cadeado de latão' and coalesce(marca, '') = 'Papaiz'), v.nome, v.ordem from (values ('20 mm', 1), ('25 mm', 2), ('30 mm', 3), ('35 mm', 4), ('40 mm', 5), ('45 mm', 6), ('50 mm', 7), ('60 mm', 8)) as v(nome, ordem);
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Alicate universal' and coalesce(marca, '') = 'Gedore');
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Martelo de unha' and coalesce(marca, '') = 'Vonder');
insert into public.produto_opcoes (produto_id, nome, ordem) select (select id from public.produtos where nome = 'Martelo de unha' and coalesce(marca, '') = 'Vonder'), v.nome, v.ordem from (values ('25 mm', 1), ('27 mm', 2), ('29 mm', 3)) as v(nome, ordem);
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Serrote' and coalesce(marca, '') = 'Irwin');
insert into public.produto_opcoes (produto_id, nome, ordem) select (select id from public.produtos where nome = 'Serrote' and coalesce(marca, '') = 'Irwin'), v.nome, v.ordem from (values ('18"', 1), ('20"', 2), ('22"', 3), ('24"', 4)) as v(nome, ordem);
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Serrote' and coalesce(marca, '') = 'Tramontina');
insert into public.produto_opcoes (produto_id, nome, ordem) select (select id from public.produtos where nome = 'Serrote' and coalesce(marca, '') = 'Tramontina'), v.nome, v.ordem from (values ('16"', 1), ('18"', 2), ('20"', 3), ('22"', 4), ('24"', 5)) as v(nome, ordem);
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Facão' and coalesce(marca, '') = 'Corneta');
insert into public.produto_opcoes (produto_id, nome, ordem) select (select id from public.produtos where nome = 'Facão' and coalesce(marca, '') = 'Corneta'), v.nome, v.ordem from (values ('10"', 1), ('12"', 2), ('14"', 3), ('16"', 4), ('18"', 5), ('20"', 6)) as v(nome, ordem);
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Facão' and coalesce(marca, '') = 'Tramontina');
insert into public.produto_opcoes (produto_id, nome, ordem) select (select id from public.produtos where nome = 'Facão' and coalesce(marca, '') = 'Tramontina'), v.nome, v.ordem from (values ('12"', 1), ('14"', 2), ('16"', 3)) as v(nome, ordem);
delete from public.produto_opcoes where produto_id = (select id from public.produtos where nome = 'Chave combinada' and coalesce(marca, '') = '');
insert into public.produto_opcoes (produto_id, nome, ordem) select (select id from public.produtos where nome = 'Chave combinada' and coalesce(marca, '') = ''), v.nome, v.ordem from (values ('6 mm', 1), ('7 mm', 2), ('8 mm', 3), ('9 mm', 4), ('10 mm', 5), ('11 mm', 6), ('12 mm', 7), ('13 mm', 8), ('14 mm', 9), ('15 mm', 10), ('16 mm', 11), ('17 mm', 12), ('18 mm', 13), ('19 mm', 14), ('20 mm', 15), ('21 mm', 16), ('22 mm', 17), ('23 mm', 18), ('24 mm', 19), ('25 mm', 20), ('26 mm', 21), ('27 mm', 22), ('28 mm', 23), ('30 mm', 24), ('32 mm', 25)) as v(nome, ordem);

-- Conferência: esperado 99 produtos e 80 opções
select (select count(*) from public.produtos) as total_produtos, (select count(*) from public.produto_opcoes) as total_opcoes;
commit;
