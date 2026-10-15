# Defema — site-catálogo e painel

Site-catálogo da **Defema** (Rua Tiradentes, 535 – Centro, Pirapozinho/SP): defensivos, ferramentas, máquinas, sementes, insumos, mudas, ferragens e EPIs, com pedido pelo WhatsApp.

- **Site:** https://lojadefema.github.io/
- **Painel administrativo:** https://lojadefema.github.io/admin/ (login da loja)

Os produtos ficam no Supabase (Postgres + Storage). O site lê só os produtos ativos; o painel grava, e só usuários cadastrados como administradores podem alterar dados (Row Level Security). A chave `anon` que aparece no código é pública por design; **nunca** coloque a chave `service_role` aqui.

Detalhes técnicos, SQL e scripts: [`sistema/`](sistema/README.md).
