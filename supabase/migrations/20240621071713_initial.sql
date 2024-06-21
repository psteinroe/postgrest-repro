create table public.one (
    id serial primary key,
    name text not null
);

create table public.two (
    id serial primary key,
    name text not null
);

create table public.one_two (
    one_id int references one(id),
    two_id int references two(id),
    primary key (one_id, two_id)
);

create schema api;

grant usage on schema api to postgres, anon, authenticated, service_role;
alter default privileges in schema api grant all on tables to postgres, anon, authenticated, service_role;
alter default privileges in schema api grant all on functions to postgres, anon, authenticated, service_role;
alter default privileges in schema api grant all on sequences to postgres, anon, authenticated, service_role;

create view api.one with (security_invoker) as
select id, name
from public.one;

create view api.two with (security_invoker) as
select id, name
from public.two;

create view api.one_two with (security_invoker) as
select one_id, two_id
from public.one_two;


