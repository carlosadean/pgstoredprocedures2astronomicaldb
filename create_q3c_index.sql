CREATE OR REPLACE FUNCTION create_q3c_index(s text, t text, col1 text, col2 text) RETURNS boolean AS $$ 
BEGIN 
    EXECUTE 'ALTER TABLE '|| s ||'.'|| t ||' RENAME TO tmp_'|| t ||';'; 
    EXECUTE 'CREATE TABLE '|| s ||'.'|| t ||' AS SELECT * FROM '|| s ||'.tmp_'|| t ||' ORDER BY q3c_ang2ipix('|| col1 ||','|| col2 ||');'; 
    EXECUTE 'CREATE INDEX '|| t ||'_'|| col1 ||'_'|| col2 ||' ON '|| s ||'.'|| t ||' (q3c_ang2ipix('|| col1 ||','|| col2 ||'));';
    EXECUTE 'ALTER TABLE '|| s ||'.'|| t ||' CLUSTER ON '|| t ||'_'|| col1 ||'_'|| col2 ||';';
    EXECUTE 'ANALYZE '|| s ||'.'|| t ||';';
    EXECUTE 'GRANT ALL ON '|| s ||'.'|| t ||' TO gavoadmin;';
    EXECUTE 'GRANT ALL ON '|| s ||'.'|| t ||' TO gavo;';
    EXECUTE 'GRANT SELECT ON '|| s ||'.'|| t ||' TO untrusted;';
    EXECUTE 'DROP TABLE '|| s ||'.tmp_'|| t ||';';
    RETURN true;

    EXCEPTION WHEN OTHERS THEN RETURN false; 

END;
$$ LANGUAGE plpgsql;
