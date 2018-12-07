CREATE OR REPLACE FUNCTION add_tilename(s text, t text, col1 text, col2 text)
  RETURNS boolean AS
$BODY$DECLARE
sql1 varchar;
sql2 varchar;
st varchar;
--msg1 varchar := 'tilename does not exists in '|| s ||'.'|| t ||'';
gets varchar;
sqlUpdate varchar;
objeto RECORD;
msg varchar;
tile RECORD;
tot integer := 0;
status integer := 0;
idx varchar;
countAlterados integer := 0;
BEGIN
    BEGIN
	st := 'ALTER TABLE '|| s ||'.'|| t ||' DROP COLUMN tilename;';
	EXECUTE st;
    EXCEPTION WHEN OTHERS THEN
	RAISE NOTICE 'tilename does not exists';
    END;

    BEGIN
	st := 'ALTER TABLE '|| s ||'.'|| t ||' ADD COLUMN tilename text;';
	EXECUTE st;
    EXCEPTION WHEN duplicate_column THEN 
	RAISE NOTICE 'tilename already exists';
    END;

    sql2 := 'SELECT '|| col1 ||' as ra,'|| col2 ||' as dec FROM '|| s ||'.'|| t ||';';
    --RAISE NOTICE '%', sql2;

    FOR objeto IN EXECUTE sql2
    LOOP
        -- criar indices para a coluna de IDs e posteriormente na coluna tilename
	-- para cada linha recuperar o tilename com o ra x dec do select anterior
	-- coloquei o limit pois um objeto pode estar na borda da tile e com isso aparecer em duas tiles
	gets := 'SELECT C.tilename FROM public.coadd_tile as C WHERE C.urall < '|| objeto.ra ||' AND C.udecll < '|| objeto.dec ||' AND C.uraur > '|| objeto.ra ||' AND C.udecur > '|| objeto.dec ||' LIMIT 
1;';
        --RAISE NOTICE '%', gets;

	FOR tile IN EXECUTE gets 
        LOOP
		sqlUpdate := 'UPDATE '|| s ||'.'|| t ||' SET tilename = '''||tile.tilename||''' WHERE q3c_radial_query('|| col1 ||', '|| col2 ||', '|| objeto.ra ||', '|| objeto.dec ||', 0.001);';
		--RAISE NOTICE '%', sqlUpdate;
		-- Se o update der certo colocar o status
		EXECUTE sqlUpdate;
		countAlterados = countAlterados +1;
	END LOOP;
	
        tot = tot + 1;
	RAISE NOTICE 'VARRIDOS%', tot;
	
    END LOOP;
    -- criar indices na coluna tilename
    idx := 'CREATE INDEX '|| t ||'_tilename ON '|| s ||'.'|| t ||' (tilename);';
    EXECUTE idx;
    RAISE NOTICE 'SQL INDEX %', idx;
    RAISE NOTICE 'DEBUG 2 %', tot;
    RAISE NOTICE 'Alterados: %', countAlterados;
    
    RETURN true;
    EXCEPTION WHEN OTHERS THEN RETURN false; 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION add_tilename(text, text, text, text)
  OWNER TO gavoadmin;

