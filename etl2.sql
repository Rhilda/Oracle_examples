delete from stg_terminals;
delete from stg_transactions;
delete from stg_cards;
delete from stg_clients;
delete from stg_accounts;

insert into stg_transactions ( trans_id, trans_date, card_num, oper_type, amt, oper_result, terminal_id )
	select trans_id, trans_date, card, oper_type, amt, oper_result, terminal_id
	from all02
	where to_date(trans_date, 'DD/MM/YYYY hh24:mi:ss') > ( select last_date from meta_main where tablle = 'fact_transactions');

insert into fact_transactions( trans_id, trans_date, card_num, oper_type, amt, oper_result, terminal )
	select trans_id, to_date(trans_date, 'DD/MM/YYYY hh24:mi:ss'), card_num, oper_type, amt, oper_result, terminal_id
	from stg_transactions;

update meta_main set
last_date = ( select max(to_date(trans_date, 'DD/MM/YYYY hh24:mi:ss')) from stg_transactions )
where tablle = 'fact_transactions';

insert into stg_cards ( card_num, account, dt )
	select card, account, trans_date
	from all02
	where to_date(trans_date, 'DD/MM/YYYY hh24:mi:ss') > ( select last_date from meta_main where tablle = 'dim_cards_hist');

insert into dim_cards_hist ( card_num, account_num, effective_from, effective_to )
select card_num, account, to_date(dt, 'DD/MM/YYYY hh24:mi:ss'), to_date( '2999-12-31', 'YYYY-MM-DD' )
from stg_cards st
where (st.card_num, st.account) not in
(select card_num, account_num from dim_cards_hist)
and (st.card_num, to_date(dt, 'DD/MM/YYYY hh24:mi:ss')) in (
    select card_num, max(to_date(dt, 'DD/MM/YYYY hh24:mi:ss')) from stg_cards
    group by card_num);

merge into dim_cards_hist tg
using stg_cards st
on ( (tg.account_num <> st.account)
and tg.card_num = st.card_num and tg.effective_from < to_date(dt, 'DD/MM/YYYY hh24:mi:ss') )
when matched then update set 
	tg.effective_to = to_date(dt, 'DD/MM/YYYY hh24:mi:ss') - interval '1' day
	where tg.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' );

update meta_main set
last_date = ( select max(to_date(dt, 'DD/MM/YYYY hh24:mi:ss')) from stg_cards )
where tablle = 'dim_cards_hist';

insert into stg_accounts ( account, valid_to, client, dt )
	select account, acc_valid_to, client_id, trans_date
	from all02
	where to_date(trans_date, 'DD/MM/YYYY hh24:mi:ss') > ( select last_date from meta_main where tablle = 'dim_accounts_hist');

insert into dim_accounts_hist ( account_num, valid_to, client, effective_from, effective_to ) 
select account, valid_to, client, to_date(dt, 'DD/MM/YYYY hh24:mi:ss'), to_date( '2999-12-31', 'YYYY-MM-DD' )
from stg_accounts st
where (st.account, st.valid_to, st.client) not in
(select account_num, valid_to, client from dim_accounts_hist)
and (st.account, to_date(dt, 'DD/MM/YYYY hh24:mi:ss')) in (
    select account, max(to_date(dt, 'DD/MM/YYYY hh24:mi:ss')) from stg_accounts
    group by account);

merge into dim_accounts_hist tg
using stg_accounts st
on ( (tg.account_num <> st.account or tg.valid_to <> st.valid_to or tg.client <> st.client)
and tg.account_num = st.account and tg.effective_from < to_date(dt, 'DD/MM/YYYY hh24:mi:ss') )
when matched then update set 
	tg.effective_to = to_date(dt, 'DD/MM/YYYY hh24:mi:ss') - interval '1' day
		where tg.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' );

update meta_main set
last_date = ( select max(to_date(dt, 'DD/MM/YYYY hh24:mi:ss')) from stg_accounts )
where tablle = 'dim_accounts_hist';

insert into stg_clients ( client_id, last_name, first_name, patronymic, date_of_birth, passport_num, passport_valid_to, phone, dt )
	select client_id, last_name, first_name, patronymic, date_of_birth, passport_num, passport_valid_to, phone, trans_date
	from all02
	where to_date(trans_date, 'DD/MM/YYYY hh24:mi:ss') > ( select last_date from meta_main where tablle = 'dim_clients_hist');

insert into dim_clients_hist ( client_id, last_name, first_name, patronymic, date_of_birth, passport_num, passport_valid_to, phone, effective_from, effective_to ) 
select client_id, last_name, first_name, patronymic, date_of_birth, passport_num, passport_valid_to, phone, to_date(dt, 'DD/MM/YYYY hh24:mi:ss'), to_date( '2999-12-31', 'YYYY-MM-DD' )
from stg_clients st
where (st.client_id, st.last_name, st.first_name, st.patronymic, st.date_of_birth, st.passport_num, st.passport_valid_to, st.phone) not in
(select client_id, last_name, first_name, patronymic, date_of_birth, passport_num, passport_valid_to, phone from dim_clients_hist)
and (st.client_id, to_date(dt, 'DD/MM/YYYY hh24:mi:ss')) in (
    select client_id, max(to_date(dt, 'DD/MM/YYYY hh24:mi:ss')) from stg_clients
    group by client_id );

merge into dim_clients_hist tg
using (select * from stg_clients where (client_id, to_date(dt, 'DD/MM/YYYY hh24:mi:ss')) in (
    select client_id, max(to_date(dt, 'DD/MM/YYYY hh24:mi:ss'))
    from stg_clients
    group by client_id)) st
on ( (tg.last_name <> st.last_name or tg.first_name <> st.first_name or tg.patronymic <> st.patronymic or tg.date_of_birth <> st.date_of_birth
or tg.passport_num <> st.passport_num or tg.passport_valid_to <> st.passport_valid_to or tg.phone <> st.phone)
and tg.client_id = st.client_id and tg.effective_from < to_date(dt, 'DD/MM/YYYY hh24:mi:ss') )
when matched then update set 
	tg.effective_to = to_date(dt, 'DD/MM/YYYY hh24:mi:ss') - interval '1' day
		where tg.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' );

update meta_main set
last_date = ( select max(to_date(dt, 'DD/MM/YYYY hh24:mi:ss')) from stg_clients )
where tablle = 'dim_clients_hist';

insert into stg_terminals ( terminal_id, terminal_type, terminal_city, terminal_address, dt )
	select terminal_id, terminal_type, terminal_city, terminal_address, trans_date
	from all02
	where to_date(trans_date, 'DD/MM/YYYY hh24:mi:ss') > ( select last_date from meta_main where tablle = 'dim_terminals_hist');

insert into dim_terminals_hist ( terminal_id, terminal_type, terminal_city, terminal_address, effective_from, effective_to ) 
select terminal_id, terminal_type, terminal_city, terminal_address, to_date(dt, 'DD/MM/YYYY hh24:mi:ss'), to_date( '2999-12-31', 'YYYY-MM-DD' )
from STG_terminals st
where (st.terminal_id, st.terminal_type, st.terminal_city, st.terminal_address) not in
(select terminal_id, terminal_type, terminal_city, terminal_address from dim_terminals_hist)
and (st.terminal_id, to_date(dt, 'DD/MM/YYYY hh24:mi:ss')) in (
    select terminal_id, max(to_date(dt, 'DD/MM/YYYY hh24:mi:ss')) from stg_terminals
    group by terminal_id);

merge into dim_terminals_hist tg
using (select * from stg_terminals where (terminal_id, to_date(dt, 'DD/MM/YYYY hh24:mi:ss')) in (
    select terminal_id, max(to_date(dt, 'DD/MM/YYYY hh24:mi:ss'))
    from stg_terminals
    group by terminal_id)) st
on ( (tg.terminal_type <> st.terminal_type or tg.terminal_city <> st.terminal_city or tg.terminal_address <> st.terminal_address )
and tg.effective_from < to_date(dt, 'DD/MM/YYYY hh24:mi:ss') and tg.terminal_id = st.terminal_id )
when matched then update set 
    tg.effective_to = to_date(dt, 'DD/MM/YYYY hh24:mi:ss') - interval '1' day
		where tg.effective_to = to_date( '2999-12-31', 'YYYY-MM-DD' );
        
update meta_main set
last_date = ( select max(to_date(dt, 'DD/MM/YYYY hh24:mi:ss')) from stg_terminals )
where tablle = 'dim_terminals_hist';

commit;
