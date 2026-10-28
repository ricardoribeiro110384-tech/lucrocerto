# LucroCerto — próximos passos (SaaS)

A página `index.html` é um **protótipo local**: não possui autenticação, contas ou cobrança. Não armazene dados confidenciais de clientes nele.

## Infraestrutura proposta

1. Criar um projeto Supabase **novo, dedicado** ao LucroCerto; não reutilizar o banco de outro negócio.
2. Executar `supabase/schema.sql` no SQL Editor, revisar as políticas RLS e conferir os avisos de segurança.
3. Configurar autenticação por e-mail com confirmação de endereço, URLs de redirecionamento e política de senhas.
4. Conectar frontend à API com URL do projeto e **publishable key** (pública). Jamais publicar chave secret/service_role.
5. Migrar as operações de produtos e vendas para o banco. Para evitar inconsistências de estoque com acessos simultâneos, implementar registro de venda transacional no servidor antes de liberar clientes.
6. Testar isolamento entre duas contas e importação de dados.
7. Criar backend seguro para pagamentos recorrentes, webhook idempotente e bloqueio por assinatura; nunca confiar no plano enviado pelo navegador.
8. Publicar a versão comercial somente depois de testes e definição de políticas de privacidade e retenção de dados.

## Cuidados

- RLS por `user_id` protege os registros de contas diferentes.
- Primeira versão é **uma conta por negócio**; equipes e várias lojas exigirão modelagem de organizações e permissões.
- Exclusão de vendas não estorna automaticamente o estoque no protótipo.
- Backup local e banco na nuvem são fluxos diferentes; não haverá migração automática sem implementação.
- `subscriptions` é somente leitura no navegador; alteração exclusivamente por serviço confiável.
- Preços exibidos na interface são exemplos, não cobranças habilitadas.
