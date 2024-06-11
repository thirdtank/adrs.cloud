INSERT INTO accounts (email, created_at) VALUES( 'davec@naildrivin5.com',now());


--
-- Data for Name: adrs; Type: TABLE DATA; Schema: public; Owner: postgres
--

insert into adrs (title, context, facing, decision, neglected, achieve, accepting, because, created_at, accepted_at, account_id)
select
'Web Apps use GET and POST only',
'Building a web app and *not* an API',
'complexity and confusion around the various HTTP verbs.  For a web page, PUT, PATCH, and DELETE don''t make sense as the browser cannot use this in a form submission.\r\n\r\nFurther, PUT vs PATCH is confusing, and POST seems to cover most needs. There doesn''t seem to be any real technical reason to use PUT, PATCH, or DELETE for a form submission.',
'To only use `GET` and `POST` for web app interaction, meaning actions that result in rendering HTML or that are intended to interact with a user.',
'RESTFul behavior (other verbs), or an abstraction on top of GET/POST',
'A simpler surface area for the controller layer that maps directly to HTML and what the web actually does and actually supports',
'This will be different than other frameworks, and certainly coerce all non-idempotent actions into a POST.',
'Ultimately, for the web app part, there is no benefit to PATCH, PUT, and DELETE. Forms can''t use these methods, so they must be hacked and then the backend basically conflates all of this stuff in a potentially confusing way.',
now() - interval '1 week',
now() - interval '2 days',
accounts.id
from accounts where email = 'davec@naildrivin5.com'
;

insert into adrs (title, context, facing, decision, neglected, achieve, accepting, because, created_at, accepted_at, account_id)
select
'Helpers run amok',
'making things easy',
'not worrying about nonsense',
'All APIs will work via magical helper  methods that are dropped in from wherever',
'To produce beautiful code',
'An API that is wonderful to look it, if slightly opaque',
'That the API might be just like Rails.',
'We want something that is cool',
now() - interval '2 weeks',
now() - interval '1 day',
accounts.id
from accounts where email = 'davec@naildrivin5.com';

insert into adrs (title, context, facing, decision, neglected, achieve, accepting, because, created_at, accepted_at, account_id)
select
'Everything works via Objects - helpers just simplify the use of objects',
'controlling complexity and conceptual overhead of what will be a large API footprint',
'A potential for a confusing API that has no real cohesion or easy ability to locate documentation about how things work.',
'All APIs will work via objects, classes, and methods and can be done with explicit code that calls `.new`, passes arguments, etc.  DSL-style designs are to be eschewed or minimized, and not required on any level to use.',
'Over-focusing on brevity, conciseness, pidgen English or other "delightful" yet hard to really learn and understand designs.',
'An API that is based on classes and methods, each of which can be easily documented and understood.  Helper methods can be introduced as needed, but not as first order concerns.',
'That the API might be more verbose than Rails.',
'We want something that is composed of known building blocks and not a massive  blob of seemingly free functions.',
now(),
now(),
accounts.id
from accounts where email = 'davec@naildrivin5.com';

insert into adrs (title, created_at, account_id)
select
'This is a refinement',
now(),
accounts.id
from accounts where email = 'davec@naildrivin5.com';
update adrs set
refines_adr_id = (select id from adrs where title = 'Everything works via Objects - helpers just simplify the use of objects')
where title = 'This is a refinement';

update adrs AS replaced_adr set replaced_by_adr_id = replacing.id
from adrs AS replacing
where replaced_adr.title = 'Helpers run amok' and
      replacing.title = 'Everything works via Objects - helpers just simplify the use of objects'
;


insert into adrs (title, created_at, account_id)
select
  'All methods can be used',
  now(),
  accounts.id
from accounts where email = 'davec@naildrivin5.com';

insert into adrs (title, created_at, account_id)
select
  'Web Apps use GET, POST, and DELETE only',
  now(),
  accounts.id
from accounts where email = 'davec@naildrivin5.com';

insert into proposed_adr_replacements(replaced_adr_id,replacing_adr_id, created_at)
  WITH replaced AS (
    SELECT
      id
    FROM
      adrs
    WHERE
      title = 'Web Apps use GET and POST only'
  ),
  replacing AS (
    SELECT
      id
    FROM
      adrs
    WHERE
      title = 'All methods can be used'
  )
  SELECT
    replaced.id, replacing.id, now()
  FROM
    replaced, replacing
;

insert into proposed_adr_replacements(replaced_adr_id,replacing_adr_id, created_at)
  WITH replaced AS (
    SELECT
      id
    FROM
      adrs
    WHERE
      title = 'Web Apps use GET and POST only'
  ),
  replacing AS (
    SELECT
      id
    FROM
      adrs
    WHERE
      title = 'Web Apps use GET, POST, and DELETE only'
  )
  SELECT
    replaced.id, replacing.id, now()
  FROM
    replaced, replacing
;
