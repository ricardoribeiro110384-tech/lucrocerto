-- Venda atômica e segura: executada na conta autenticada
create or replace function public.register_sale(p_product_id uuid,p_qty integer)
returns uuid language plpgsql security invoker set search_path = '' as $$
declare p public.products%rowtype; sale_id uuid;
begin
 if auth.uid() is null then raise exception 'Login obrigatório'; end if;
 if p_qty is null or p_qty < 1 then raise exception 'Quantidade inválida'; end if;
 select * into p from public.products where id=p_product_id and user_id=auth.uid() for update;
 if not found then raise exception 'Produto não encontrado'; end if;
 if p.stock<p_qty then raise exception 'Estoque insuficiente'; end if;
 update public.products set stock=stock-p_qty where id=p.id and user_id=auth.uid();
 insert into public.sales(user_id,product_id,qty,sold_on,unit_price,unit_cost)
 values(auth.uid(),p.id,p_qty,current_date,p.price,p.cost) returning id into sale_id;
 return sale_id;
end $$;
revoke all on function public.register_sale(uuid,integer) from public,anon;
grant execute on function public.register_sale(uuid,integer) to authenticated;