-- =====================================================================
-- DEFEMA · Catálogo — 10_fotos_e_historico.sql
--  1) produtos.fotos_extras: fotos a mais de cada produto (carrossel no site)
--  2) fotos padronizadas (500×500, fundo branco) passam a vir da pasta img/ do site
--  3) produtos_historico: toda mudança de preço fica registrada (quem, quando, de → para)
-- Pode rodar de novo sem problema.
-- =====================================================================

-- 1) Fotos extras ------------------------------------------------------
alter table public.produtos add column if not exists fotos_extras text[] not null default '{}';
comment on column public.produtos.fotos_extras is 'Fotos a mais do produto (carrossel na página do produto). Caminhos no bucket "produtos" ou img/... do site.';

-- 2) Fotos padronizadas do site ----------------------------------------
update public.produtos
   set foto_url = 'img/' || foto_url
 where foto_url in ('abafador.jpg','abobora-hibrido-f1-tetsukabuto.jpg','abobora-precoce-menina-brasileira.jpg','abobora-tipo-jacarezinho-itapua.jpg','abobrinha-de-tronco-caserta.jpg','adubo-heringer.jpg','alface-crespa-grand-rapids.jpeg','alface-grandes-lagos-americana.jpeg','alface-lisa-baba-de-verao.jpeg','alicate-gedore.jpg','almeirao-de-cabeca-pao-de-acucar.jpg','almeirao-folha-larga-amarelo-radiche.jpg','aparador-eletrico.jpg','arame-farpado-motto.jpg','arame-ovalado-z700.jpg','atratex-mata-mosca.jpg','baygon-universal.jpg','beterraba-itapua.jpg','bota-pvc-branca.jpg','bota-pvc-vonder.jpg','botina-seguranca.jpg','butox-p-ce25.jpg','cadeado-pado.jpg','cadeado-papaiz.jpg','capa-pvc-vonder.jpg','carolina-soil.jpeg','cavadeira-articulada.jpg','cebola-baia-periforme.jpg','cebolinha-hibrido-sahara.jpg','chave-combinada.jpg','chave-fenda-vonder.jpg','chave-phillips-vonder.jpg','colher-pedreiro-tramontina.jpg','colosso-pulverizacao.jpg','couve-brocolis-piracicaba-precoce.jpg','couve-manteiga-da-georgia.jpg','cultivador-tramontina.jpg','diazitop-pm.jpg','enxada-tane.jpg','enxada-tramontina.jpg','enxadao-duas-caras.jpg','facao-16.jpg','facao-tramontina.jpg','feijao-vagem-macarrao-trepador-favorito.jpg','ficam-vc.jpg','formicida-po-pikapau.jpg','furadeira-vonder-fiv1050.jpg','grampo-gerdau.jpg','grao-verde-dipil.jpg','jilo-escuro-morro-grande-verde.jpg','k-othrine-sc25.jpg','lesmicida-kelldrin-50g.jpg','lesmicida-metaldeido-250g.jpg','mangueira-azul-siliconada.jpg','mangueira-mantac.jpg','martelo-vonder.jpg','mata-formiga-guarany.jpg','maxixe-maxixe.jpg','melancia-charleston-gray.jpeg','melancia-crimson-sweet.jpg','melao-caipira-gaucho.jpeg','melao-redondo-gaucho.jpeg','moranga-exposicao-de-mesa.jpg','pa-de-bico.jpg','pa-quadrada-tramontina.jpg','paceta.jpg','parafusadeira-vonder.jpg','pepino-melhorado-aodai.jpeg','pjh20-jacto.jpeg','prego-gerdau.jpg','protetor-3m-pomp.jpg','pulverizador-brudden-5l.jpg','pulverizador-vonder-pl005.jpg','quiabo-santa-cruz.jpg','rabanete-vermelho-gigante-siculo.jpg','rocadeira-gasolina.jpg','rucula-gigante-folha-larga.jpeg','serrote-irwin.jpg','serrote-tramontina.jpg','tesoura-de-poda.jpg','tesoura-poda-galhos.jpg','tomate-cereja.jpg','tomate-santa-cruz-kada.jpg','triatox.jpg');

-- 3) Histórico de preços -----------------------------------------------
create table if not exists public.produtos_historico (
  id                 bigserial primary key,
  produto_id         uuid null references public.produtos(id) on delete set null,
  produto_nome       text,
  campo              text not null check (campo in ('preco', 'preco_antigo', 'preco_bandeja')),
  valor_antes        numeric(10,2) null,
  valor_depois       numeric(10,2) null,
  alterado_em        timestamptz not null default now(),
  alterado_por       uuid null,
  alterado_por_email text null
);
comment on table public.produtos_historico is 'Cada mudança de preço, preço antigo (promoção) ou preço da bandeja, gravada automaticamente por gatilho.';
create index if not exists produtos_historico_quando_idx on public.produtos_historico (alterado_em desc);

create or replace function public.registrar_historico_preco()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  nome text := new.nome || coalesce(' ' || nullif(new.marca, ''), '');
  quem uuid := auth.uid();
  email text := coalesce(auth.jwt() ->> 'email', null);
begin
  if new.preco is distinct from old.preco then
    insert into public.produtos_historico (produto_id, produto_nome, campo, valor_antes, valor_depois, alterado_por, alterado_por_email)
    values (new.id, nome, 'preco', old.preco, new.preco, quem, email);
  end if;
  if new.preco_antigo is distinct from old.preco_antigo then
    insert into public.produtos_historico (produto_id, produto_nome, campo, valor_antes, valor_depois, alterado_por, alterado_por_email)
    values (new.id, nome, 'preco_antigo', old.preco_antigo, new.preco_antigo, quem, email);
  end if;
  if new.preco_bandeja is distinct from old.preco_bandeja then
    insert into public.produtos_historico (produto_id, produto_nome, campo, valor_antes, valor_depois, alterado_por, alterado_por_email)
    values (new.id, nome, 'preco_bandeja', old.preco_bandeja, new.preco_bandeja, quem, email);
  end if;
  return new;
end $$;

drop trigger if exists produtos_historico_preco on public.produtos;
create trigger produtos_historico_preco
  after update of preco, preco_antigo, preco_bandeja on public.produtos
  for each row execute function public.registrar_historico_preco();

grant select on public.produtos_historico to authenticated;
revoke all on public.produtos_historico from anon;
alter table public.produtos_historico enable row level security;
drop policy if exists "historico: admin lê" on public.produtos_historico;
create policy "historico: admin lê" on public.produtos_historico
  for select to authenticated using (public.eh_admin());

-- conferência
select (select count(*) from produtos where foto_url like 'img/%') fotos_do_site,
       (select count(*) from produtos where foto_url is not null and foto_url not like 'img/%') fotos_no_storage,
       (select count(*) from produtos_historico) historico;
