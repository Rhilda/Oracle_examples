drop table stg_terminals;
drop table stg_transactions;
drop table stg_cards;
drop table stg_clients;
drop table stg_accounts;
drop table dim_terminals_hist;
drop table fact_transactions;
drop table dim_cards_hist;
drop table dim_clients_hist;
drop table dim_accounts_hist;
drop table meta_main;
drop table report;

create table stg_terminals as(
    select terminal_id, terminal_type, terminal_city, terminal_address, trans_date dt
    from all01
    where 1=0);
    
create table stg_transactions as(
    select trans_id, amt, card card_num, oper_type, oper_result, terminal_id, trans_date 
    from all01
    where 1=0);
    
create table stg_cards as(
    select card card_num, account, trans_date dt  
    from all01
    where 1=0);
    
create table stg_clients as(
    select client_id, last_name, first_name, patronymic, date_of_birth,
            passport_num, passport_valid_to, phone, trans_date dt  
    from all01
    where 1=0);
    
create table stg_accounts as(
    select account, acc_valid_to valid_to, client_id client, trans_date dt 
    from all01
    where 1=0);

create table meta_main (
    tablle      varchar2(40),
    last_date   date
);

create table report (
    fraud_dt    date,
    passport    varchar2(15),
    fio         varchar2(90),
    phone       varchar2(20),
    fraud_type  number(1),
    report_dt   date
);

create table dim_cards_hist (
    card_num        char(20),
    account_num     char(20),
    effective_from  date,
    effective_to    date
);

create table dim_clients_hist (
    client_id           varchar2(20),
    last_name           varchar2(100),
    first_name          varchar2(100),
    patronymic          varchar2(100),
    date_of_birth       date,
    passport_num        varchar2(15),
    passport_valid_to   date,
    phone               varchar2(20),
    effective_from      date,
    effective_to        date
);

create table dim_accounts_hist (
    account_num         char(20),
    valid_to            date,
    client              varchar2(20),
    effective_from      date,
    effective_to        date
);
create table dim_terminals_hist (
    terminal_id         varchar2(9),
    terminal_type       varchar2(4),
    terminal_city       varchar2(43),
    terminal_address    varchar2(90),
    effective_from      date,
    effective_to        date
);

create table fact_transactions (
    trans_id    varchar2(30),
    trans_date  date,
    card_num    char(20),
    oper_type   varchar2(20),
    amt         dec(20,2),
    oper_result varchar2(14),
    terminal    varchar2(9)
);

insert into meta_main (tablle, last_date) values ('fact_transactions',to_date('01-01-1800 00:00:00','DD/MM/YYYY hh24:mi:ss'));
insert into meta_main (tablle, last_date) values ('dim_terminals_hist',to_date('01-01-1800 00:00:00','DD/MM/YYYY hh24:mi:ss'));
insert into meta_main (tablle, last_date) values ('dim_accounts_hist',to_date('01-01-1800 00:00:00','DD/MM/YYYY hh24:mi:ss'));
insert into meta_main (tablle, last_date) values ('dim_cards_hist',to_date('01-01-1800 00:00:00','DD/MM/YYYY hh24:mi:ss'));
insert into meta_main (tablle, last_date) values ('dim_clients_hist',to_date('01-01-1800 00:00:00','DD/MM/YYYY hh24:mi:ss'));
commit;

