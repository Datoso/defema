-- Reorganização (14/10): Sementes + Mudas → "Sementes e mudas"; Máquinas → dentro de Ferramentas.
-- Sementes: "Sementes de hortaliças" (folhosas e temperos) e "Sementes de vegetais" (frutos, legumes, raízes e bulbos).
begin;
insert into public.departamentos (nome, info, ordem)
values ('Sementes e mudas', 'Sementes Isla, bandejas de mudas, café e maracujá', 3)
on conflict (nome) do update set info = excluded.info;

-- novas subcategorias de sementes
insert into public.subcategorias (departamento_id, nome, ordem)
select d.id, s.nome, s.ordem from public.departamentos d,
  (values ('Sementes de hortaliças', 1), ('Sementes de vegetais', 2)) s(nome, ordem)
where d.nome = 'Sementes e mudas'
on conflict (departamento_id, nome) do update set ordem = excluded.ordem;

update public.produtos p set subcategoria_id = (select s.id from public.subcategorias s join public.departamentos d on d.id = s.departamento_id where d.nome = 'Sementes e mudas' and s.nome = 'Sementes de hortaliças')
where p.subcategoria_id in (select s.id from public.subcategorias s join public.departamentos d on d.id = s.departamento_id where d.nome = 'Sementes' and s.nome = 'Folhosas e temperos');

update public.produtos p set subcategoria_id = (select s.id from public.subcategorias s join public.departamentos d on d.id = s.departamento_id where d.nome = 'Sementes e mudas' and s.nome = 'Sementes de vegetais')
where p.subcategoria_id in (select s.id from public.subcategorias s join public.departamentos d on d.id = s.departamento_id where d.nome = 'Sementes');

delete from public.subcategorias where departamento_id = (select id from public.departamentos where nome = 'Sementes');

-- mudas vão para o novo departamento (mantêm as próprias subcategorias)
update public.subcategorias set departamento_id = (select id from public.departamentos where nome = 'Sementes e mudas'),
  ordem = case nome when 'Bandeja 200 mudas' then 3 when 'Bandeja 128 mudas' then 4 else 5 end
where departamento_id = (select id from public.departamentos where nome = 'Mudas');

-- máquinas viram subcategorias de Ferramentas
update public.subcategorias set departamento_id = (select id from public.departamentos where nome = 'Ferramentas'),
  ordem = case nome when 'Pulverizadores' then 4 else 5 end
where departamento_id = (select id from public.departamentos where nome = 'Máquinas');

delete from public.departamentos where nome in ('Sementes', 'Mudas', 'Máquinas');

update public.departamentos set ordem = case nome
  when 'Defensivos' then 1 when 'Ferramentas' then 2 when 'Sementes e mudas' then 3
  when 'Insumos' then 4 when 'Ferragens e EPIs' then 5 else ordem end,
  info = case nome when 'Ferramentas' then 'Enxadas, pulverizadores, roçadeiras e mais' else info end;

select d.ordem, d.nome as departamento, s.nome as subcategoria, count(p.id) as produtos
from public.departamentos d join public.subcategorias s on s.departamento_id = d.id
left join public.produtos p on p.subcategoria_id = s.id
group by d.ordem, d.nome, s.ordem, s.nome order by d.ordem, s.ordem;
commit;
