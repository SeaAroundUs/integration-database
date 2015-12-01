CREATE OR REPLACE FUNCTION generate_simple_acronym(i_phrase text) 
returns text AS 
$f$ 
  select strings(substr(t.w,1,1) order by t.ord) 
    from unnest(string_to_array(i_phrase, ' ')) with ordinality as t(w, ord);
$f$
LANGUAGE sql;
