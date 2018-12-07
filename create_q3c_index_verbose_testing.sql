/*

function: create_q3c_index_verbosed()
author: @carlosadean
version: v1 2018-08-10
based on create_q3c_index by Angelo Fausti

ps: before use this function make sure the table does not have any dependents objects, like a view,
    otherwise you will lose a lot of time running it and the result will be flawed.

*/

CREATE OR REPLACE FUNCTION public.create_q3c_index_verbosed(s text, t text, col1 text, col2 text)
RETURNS boolean AS
$BODY$DECLARE
-- variables
altera_tmp varchar;
cria_tabela varchar;
cria_indice varchar;
clusteriza varchar;
analiza varchar;
grant_all1 varchar;
grant_all2 varchar;
grant_select varchar;
drop_table varchar;
--

BEGIN
    altera_tmp := 'ALTER TABLE '|| s ||'.'|| t ||' RENAME TO tmp_'|| t ||';';
    EXECUTE altera_tmp;
    RAISE NOTICE '%', altera_tmp;

    cria_tabela := 'CREATE TABLE '|| s ||'.'|| t ||' AS SELECT * FROM '|| s ||'.tmp_'|| t ||' ORDER BY q3c_ang2ipix('|| col1 ||','|| col2 ||');';
    EXECUTE cria_tabela;
    RAISE NOTICE '%', cria_tabela;

    cria_indice := 'CREATE INDEX '|| t ||'_'|| col1 ||'_'|| col2 ||' ON '|| s ||'.'|| t ||' (q3c_ang2ipix('|| col1 ||','|| col2 ||'));';
    EXECUTE cria_indice;
    RAISE NOTICE '%', cria_indice;

    clusteriza := 'ALTER TABLE '|| s ||'.'|| t ||' CLUSTER ON '|| t ||'_'|| col1 ||'_'|| col2 ||';';
    EXECUTE clusteriza;
    RAISE NOTICE '%', clusteriza;

    analiza := 'ANALYZE '|| s ||'.'|| t ||';';
    EXECUTE analiza;
    RAISE NOTICE '%', analiza;

    grant_all1 := 'GRANT ALL ON '|| s ||'.'|| t ||' TO useradmin;';
    EXECUTE grant_all1;
    RAISE NOTICE '%', grant_all1;

    grant_all2 :=  'GRANT ALL ON '|| s ||'.'|| t ||' TO user;';
    EXECUTE grant_all2;
    RAISE NOTICE '%', grant_all2;

    grant_select := 'GRANT SELECT ON '|| s ||'.'|| t ||' TO useruntrusted;';
    EXECUTE grant_select;
    RAISE NOTICE '%', grant_select;

    drop_table := 'DROP TABLE '|| s ||'.tmp_'|| t ||';';
    EXECUTE drop_table;
    RAISE NOTICE '%', drop_table;

    RETURN true;

    EXCEPTION WHEN OTHERS THEN RETURN false;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
