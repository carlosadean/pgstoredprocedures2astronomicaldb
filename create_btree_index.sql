CREATE OR REPLACE FUNCTION create_btree_index(s text, t text, col text) RETURNS boolean AS $$
BEGIN
        EXECUTE 'CREATE INDEX '|| t ||'_'|| col ||'_idx' || ' ON '|| s ||'.'|| t || '(' || col ||')';
            RETURN true;

                EXCEPTION WHEN OTHERS THEN RETURN false;

END;
$$ LANGUAGE plpgsql;
