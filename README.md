# postgrest-repro

This repro is about a bug in postgrest that fails if a table in the "primary" schema has the same name as a view in another schema also exposed by postgrest.

Schema:

```sql
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
```

The query (using supabase-js):

```ts
const { data, error } = await s.from("one").select("name,list:two(name)");
```

## Steps to reproduce

1. Start supabase and install dependencies with bun
2. Run `bun run index.ts` - it will fail
3. Remove `api` from schemas in the supabase config
4. Stop and start supabase
5. Run `bun run index.ts` - it will work

Expectation is that postgrest prefers the table over the view when the table is in the same schema that the query is targeting. Note that explicitly setting the db schema on the supabase client also does not change anything.
