CREATE OR REPLACE FUNCTION add_radec_healpix(s text, t text, ordering text, nside text) RETURNS boolean AS $$

DECLARE
sql2 varchar;
sql3 varchar;

BEGIN
    sql2 := 'ALTER TABLE '|| s ||'.'|| t ||' RENAME TO tmp_'|| t ||';';

    RAISE NOTICE '%', sql2;

    EXECUTE sql2;

    IF ordering = 'ring' THEN

        sql2 := 'CREATE TABLE temp_'|| t ||' AS (SELECT pixel, signal, D[1] as ra, D[2] as dec FROM (SELECT pixel, signal, healpix_ipix2ang_ring('|| nside ||', pixel) FROM '|| s ||'.tmp_'|| t ||') as A(pixel, signal, D) );';

        RAISE NOTICE '%', sql2;

        EXECUTE sql2;

    ELSEIF ordering = 'nest' THEN

        sql2 := 'CREATE TABLE temp_'|| t ||' AS (SELECT pixel, signal, D[1] as ra, D[2] as dec FROM (SELECT pixel, signal, healpix_ipix2ang_nest('|| nside ||', pixel) FROM '|| s ||'.tmp_'|| t ||') as A(pixel, signal, D) );';

        RAISE NOTICE '%', sql2;

        EXECUTE sql2;

    ELSE

        RAISE NOTICE 'Invalid ordering name %', ordering;

    END IF;

    sql3 := 'CREATE TABLE '|| s ||'.'|| t ||' AS (SELECT pixel, signal, ra, dec FROM temp_'|| t ||' ORDER BY q3c_ang2ipix(ra, dec));';
    RAISE NOTICE '%', sql3;
    EXECUTE sql3;

    sql3 := 'CREATE INDEX '|| t ||'_'|| 'ra' ||'_'|| 'dec' ||' ON '|| s ||'.'|| t ||' (q3c_ang2ipix('|| 'ra' ||','|| 'dec' ||'));';
    RAISE NOTICE '%', sql3;
    EXECUTE sql3;

    sql3 := 'ALTER TABLE '|| s ||'.'|| t ||' CLUSTER ON '|| t ||'_'|| 'ra' ||'_'|| 'dec' ||';';
    RAISE NOTICE '%', sql3;
    EXECUTE sql3;

    sql3 := 'ANALYZE '|| s ||'.'|| t ||';';
    RAISE NOTICE '%', sql3;
    EXECUTE sql3;

    sql3 := 'GRANT ALL ON '|| s ||'.'|| t ||' TO gavoadmin;';
    RAISE NOTICE '%', sql3;
    EXECUTE sql3;

    sql3 := 'GRANT ALL ON '|| s ||'.'|| t ||' TO gavo;';
    RAISE NOTICE '%', sql3;
    EXECUTE sql3;

    sql3 := 'GRANT SELECT ON '|| s ||'.'|| t ||' TO untrusted;';
    RAISE NOTICE '%', sql3;
    EXECUTE sql3;

    sql3 := 'DROP TABLE '|| s ||'.tmp_'|| t ||';';
    RAISE NOTICE '%', sql3;
    EXECUTE sql3;

    sql3 := 'DROP TABLE temp_'|| t ||';';
    RAISE NOTICE '%', sql3;
    EXECUTE sql3;

    RETURN true;

    EXCEPTION WHEN OTHERS THEN RETURN false;

END;
$$
LANGUAGE plpgsql;
