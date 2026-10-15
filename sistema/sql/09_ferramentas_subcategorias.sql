-- =====================================================================
-- DEFEMA · Catálogo — 09_ferramentas_subcategorias.sql
-- Divide "Ferramentas manuais" em subcategorias mais fáceis de achar
-- e ajusta a marreta (hexagonal, sem cabo, por peso). Pode rodar de novo.
-- =====================================================================

-- 1) Subcategorias novas de Ferramentas, na ordem do menu
insert into public.subcategorias (departamento_id, nome, ordem)
select d.id, v.nome, v.ordem
  from public.departamentos d,
       (values ('Enxadas e enxadões', 1), ('Pás', 2), ('Cavadeiras', 3),
               ('Martelos e marretas', 4), ('Chaves', 5), ('Serrotes e facões', 6)) v(nome, ordem)
 where d.nome = 'Ferramentas'
on conflict (departamento_id, nome) do update set ordem = excluded.ordem;

update public.subcategorias s set ordem = v.ordem
  from public.departamentos d,
       (values ('Ferramentas manuais', 7), ('Ferramentas elétricas', 8), ('Jardinagem', 9),
               ('Pulverizadores', 10), ('Roçadeiras e aparadores', 11)) v(nome, ordem)
 where s.departamento_id = d.id and d.nome = 'Ferramentas' and s.nome = v.nome;

-- 2) Move os produtos que estavam em "Ferramentas manuais"
update public.produtos p
   set subcategoria_id = destino.id
  from (values ('Enxada larga com cabo 145 cm', 'Enxadas e enxadões'), ('Enxadão duas caras', 'Enxadas e enxadões'),
               ('Enxada', 'Enxadas e enxadões'), ('Pá de bico com cabo', 'Pás'), ('Pá quadrada com cabo', 'Pás'),
               ('Cavadeira articulada', 'Cavadeiras'), ('Martelo de unha', 'Martelos e marretas'),
               ('Marreta', 'Martelos e marretas'), ('Marreta hexagonal', 'Martelos e marretas'),
               ('Chave de fenda', 'Chaves'), ('Chave Phillips', 'Chaves'), ('Chave combinada', 'Chaves'),
               ('Serrote', 'Serrotes e facões'), ('Facão', 'Serrotes e facões')) v(produto, sub),
       public.subcategorias destino
       join public.departamentos d on d.id = destino.departamento_id and d.nome = 'Ferramentas'
 where destino.nome = v.sub
   and p.nome = v.produto
   and p.subcategoria_id in (select s.id from public.subcategorias s where s.departamento_id = d.id);

-- 3) Marreta: hexagonal, sem cabo, escolha por peso (cabo vendido à parte)
update public.produtos p
   set nome = 'Marreta hexagonal',
       unidade = 'Sem cabo · cabo vendido à parte',
       descricao = 'Marreta hexagonal sem cabo, para quebrar pedra, bater estaca e serviços pesados. Escolha o peso. O cabo é vendido à parte.',
       op_nome = 'Peso'
 where p.nome in ('Marreta', 'Marreta hexagonal')
   and p.subcategoria_id in (select s.id from public.subcategorias s join public.departamentos d on d.id = s.departamento_id where d.nome = 'Ferramentas');

delete from public.produto_opcoes o
 using public.produtos p
 where o.produto_id = p.id and p.nome = 'Marreta hexagonal';

insert into public.produto_opcoes (produto_id, nome, ordem)
select p.id, v.nome, v.ordem
  from public.produtos p,
       (values ('500 g', 1), ('1 kg', 2), ('1,5 kg', 3), ('2 kg', 4), ('3 kg', 5), ('4 kg', 6), ('5 kg', 7), ('10 kg', 8)) v(nome, ordem)
 where p.nome = 'Marreta hexagonal';

-- conferência
select s.ordem, s.nome as subcategoria, count(p.id) as produtos
  from public.subcategorias s
  join public.departamentos d on d.id = s.departamento_id and d.nome = 'Ferramentas'
  left join public.produtos p on p.subcategoria_id = s.id
 group by s.ordem, s.nome order by s.ordem;
