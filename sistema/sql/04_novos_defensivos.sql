-- Novos defensivos (14/10): subcategorias Formicidas e Lesmicidas + 7 produtos
begin;
update public.subcategorias set ordem = 5
 where nome = 'Uso profissional' and departamento_id = (select id from public.departamentos where nome = 'Defensivos');
insert into public.subcategorias (departamento_id, nome, ordem)
select d.id, s.nome, s.ordem from public.departamentos d,
  (values ('Formicidas', 3), ('Lesmicidas', 4)) as s(nome, ordem)
where d.nome = 'Defensivos'
on conflict (departamento_id, nome) do update set ordem = excluded.ordem;

with novos(nome, marca, sub, dep, unidade, descricao, foto, restrito, novidade) as (values
 ('Atratex Mata Mosca', null, 'Inseticidas', 'Defensivos', 'Sachê 25 g · isca granulada',
  'Isca mosquicida granulada à base de tiametoxam, de venda livre, eficaz contra a mosca doméstica. Espalhe em locais onde as moscas pousam, longe de crianças e animais. Leia o rótulo antes de usar.',
  'atratex-mata-mosca.jpg', false, true),
 ('Baygon Universal Spray', 'SC Johnson', 'Inseticidas', 'Defensivos', 'Aerossol',
  'Inseticida em aerossol de ação rápida contra mosquitos, baratas e moscas, para uso doméstico.',
  'baygon-universal.jpg', false, true),
 ('Formicida Pó 50 S', 'Pikapau', 'Formicidas', 'Defensivos', 'Caixa 1 kg',
  'Formicida em pó à base de deltametrina, de venda livre, eficaz contra formigas. Aplique nos olheiros e trilhas, de preferência com polvilhadeira.',
  'formicida-po-pikapau.jpg', false, true),
 ('Grão Verde formicida isca granulada', 'Dipil', 'Formicidas', 'Defensivos', 'Pacote 500 g (10 × 50 g)',
  'Isca formicida granulada para formigas cortadeiras (saúva e quenquém), linha jardinagem amadora. Distribua ao lado das trilhas ativas, em dia seco.',
  'grao-verde-dipil.jpg', false, true),
 ('Lesmicida', 'Kelldrin', 'Lesmicidas', 'Defensivos', 'Pacote 50 g · resistente à água',
  'Isca granulada eficaz contra lesmas e caracóis em hortas e jardins, resistente à água.',
  'lesmicida-kelldrin-50g.jpg', false, true),
 ('Lesmicida Metaldeído 5%', 'Kelldrin', 'Uso profissional', 'Defensivos', 'Pacote 250 g',
  'Moluscicida à base de metaldeído 5% contra lesmas e caracóis. Produto de venda restrita a instituições ou empresas especializadas.',
  'lesmicida-metaldeido-250g.jpg', true, true),
 ('Mata-formiga (polvilhadeira)', 'Guarany', 'Formicidas', 'Defensivos', 'Bomba manual com mangueira',
  'Aplicador manual para formicida em pó: bombeie e injete o pó direto no formigueiro pela mangueira, sem contato com o produto.',
  'mata-formiga-guarany.jpg', false, true)
)
insert into public.produtos (nome, marca, subcategoria_id, unidade, preco, descricao, foto_url, restrito, novidade, ativo, ordem)
select n.nome, n.marca, s.id, n.unidade, null, n.descricao, n.foto, n.restrito, n.novidade, true,
       (select coalesce(max(ordem),0) from public.produtos) + row_number() over ()
from novos n
join public.departamentos d on d.nome = n.dep
join public.subcategorias s on s.departamento_id = d.id and s.nome = n.sub
where not exists (select 1 from public.produtos p where p.nome = n.nome and coalesce(p.marca,'') = coalesce(n.marca,''));

select nome, marca, restrito from public.produtos where criado_em > now() - interval '1 minute' order by ordem;
commit;
