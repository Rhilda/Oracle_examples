insert into report ( fraud_dt, passport, fio, phone, fraud_type, report_dt )
(
select distinct trans_date, passport_num,
					 last_name || ' ' || first_name || ' ' || patronymic fio, phone, 1 fraud_type,
					 ( select max(last_date) from meta_main ) rdt
from fact_transactions tra
left join dim_cards_hist car 
	on tra.card_num = trim( car.card_num )
and car.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' )
left join dim_accounts_hist acc 
	on car.account_num = acc.account_num
and acc.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' )
left join dim_clients_hist cli 
	on acc.client = cli.client_id
and cli.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' )
where trunc( trans_date ) = (select  trunc(max(last_date)) from meta_main )
and (trans_date > passport_valid_to)

union all

select distinct trans_date, cli.passport_num,
					 last_name || ' ' || first_name || ' ' || patronymic fio, phone, 2 fraud_type,
					 ( select max(last_date) from meta_main ) rdt
from fact_transactions tra
left join dim_cards_hist car 
	on tra.card_num = trim(car.card_num)
and car.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' )
left join dim_accounts_hist acc 
	on car.account_num = acc.account_num
and acc.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' )
left join dim_clients_hist cli 
	on acc.client = cli.client_id
and cli.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' )
where trunc( trans_date ) = (select trunc(max(last_date)) from meta_main )
and trans_date > valid_to

union all

select distinct trans_date, passport_num, fio, phone, fraud_type, rdt from (
   select trans_date, passport_num, fio, phone, fraud_type, rdt, rn from (
      select trans_date, passport_num, card_num, fio, phone, fraud_type, rdt,
      row_number() over (partition by card_num order by trans_date) rn 
      from ( select * from (
              select distinct trans_date, cli.passport_num, tra.card_num,
                  last_name || ' ' || first_name || ' ' || patronymic fio, phone, 3 fraud_type,
                  ( select max(last_date) from meta_main ) rdt,
                  trans_date - lag(trans_date, 1, null) over (partition by tra.card_num order by trans_date) val,
                  lag(terminal_city, 1, terminal_city) over (partition by tra.card_num order by trans_date) next,
                  terminal_city
              from fact_transactions tra
              left join dim_terminals_hist ter 
                  on tra.terminal = ter.terminal_id
              and ter.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' ) 
              left join dim_cards_hist car 
                  on tra.card_num = trim(car.card_num)
              and car.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' )
              left join dim_accounts_hist acc 
                  on car.account_num = acc.account_num
              and acc.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' )
              left join dim_clients_hist cli 
                  on acc.client = cli.client_id
              and cli.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' ))
          	where val <= 1/24 and terminal_city <> next
                  and (trunc( trans_date ) = (select trunc(max(last_date)) from meta_main )
                  or trunc( trans_date ) = (select trunc(max(last_date)) from meta_main ) - interval '1' day)))
   where rn = 1)

union all

select tdt, passport_num, fio, phone, fraud_type, rdt from (
    select distinct trans_date, cli.passport_num, tra.card_num, phone,
              last_name || ' ' || first_name || ' ' || patronymic fio, 4 fraud_type,
              ( select max(last_date) from meta_main ) rdt,
              amt, oper_result res,
              lead(amt, 1, null) over (partition by tra.card_num order by trans_date) amt2,
              lead(amt, 2, null) over (partition by tra.card_num order by trans_date) amt3,
              lead(amt, 3, null) over (partition by tra.card_num order by trans_date) amt4,
              lead(oper_result, 1, null) over (partition by tra.card_num order by trans_date) res2,
              lead(oper_result, 2, null) over (partition by tra.card_num order by trans_date) res3,
              lead(oper_result, 3, null) over (partition by tra.card_num order by trans_date) res4,
              lead(trans_date, 3, to_date( '2999-12-31', 'YYYY-MM-DD' )) over (partition by tra.card_num order by trans_date) - trans_date val,
              lead(trans_date, 3, to_date( '2999-12-31', 'YYYY-MM-DD' )) over (partition by tra.card_num order by trans_date) tdt
          from fact_transactions tra
          left join dim_cards_hist car 
              on tra.card_num = trim(car.card_num)
          and car.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' )
          left join dim_accounts_hist acc 
              on car.account_num = acc.account_num
          and acc.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' )
          left join dim_clients_hist cli 
              on acc.client = cli.client_id
          and cli.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' ))
    where val <= 20/(24*60) and amt > amt2 and amt2 > amt3 and amt3 > amt4
    and res = 'Отказ' and res2 = 'Отказ' and res3 = 'Отказ' and res4 = 'Успешно'
    and ( trunc( trans_date ) = (select trunc(max(last_date)) from meta_main ) 
    or trunc( trans_date ) = (select trunc(max(last_date)) from meta_main ) - interval '1' day )
)
