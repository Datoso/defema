-- (14/10) Formicidas e Lesmicidas viram uma só subcategoria: "Formicidas e lesmicidas" (venda livre).
-- O Lesmicida Metaldeído 5% continua em "Uso profissional" (venda restrita).
begin;
update public.subcategorias set nome = 'Formicidas e lesmicidas', ordem = 3
 where nome = 'Formicidas' and departamento_id = (select id from public.departamentos where nome = 'Defensivos');

update public.produtos set subcategoria_id = (select s.id from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
                                             where d.nome = 'Defensivos' and s.nome = 'Formicidas e lesmicidas')
 where subcategoria_id = (select s.id from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
                          where d.nome = 'Defensivos' and s.nome = 'Lesmicidas');

delete from public.subcategorias
 where nome = 'Lesmicidas' and departamento_id = (select id from public.departamentos where nome = 'Defensivos');

update public.subcategorias set ordem = 4
 where nome = 'Uso profissional' and departamento_id = (select id from public.departamentos where nome = 'Defensivos');

select s.ordem, s.nome as subcategoria, p.nome as produto, p.restrito
from public.subcategorias s join public.departamentos d on d.id = s.departamento_id
left join public.produtos p on p.subcategoria_id = s.id
where d.nome = 'Defensivos' order by s.ordem, p.nome;
commit;
