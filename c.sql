/*
    Script para alterar a sessao para um PDB disponivel
    Se nenhum parâmetro for fornecido, usa o primeiro PDB disponível
*/

@set

VARIABLE g_result_msg VARCHAR2(4000)

SET FEEDBACK OFF
SET TERMOUT OFF

COLUMN 1 NEW_VALUE 1
SELECT '' "1" FROM DUAL WHERE ROWNUM = 0;
DEF PDB_PARAM = "&1"


DECLARE
    v_pdb_name VARCHAR2(128);
    v_pdb_count NUMBER;
    v_alter_stmt VARCHAR2(256);
    v_pdb_exists NUMBER;
BEGIN
    
    -- Se parâmetro fornecido, verifica se o PDB existe
    IF '&PDB_PARAM' IS NOT NULL THEN
                
        SELECT COUNT(*) INTO v_pdb_exists
        FROM v$pdbs
        WHERE name = UPPER('&PDB_PARAM')
        AND name != 'PDB$SEED';
        
        IF v_pdb_exists = 1 THEN
            -- Usar o PDB fornecido no parâmetro
            v_pdb_name := UPPER('&PDB_PARAM');
        ELSE
            :g_result_msg := 'PDB &PDB_PARAM não encontrado. PDBs disponíveis:';
            
            FOR pdb_rec IN (SELECT name FROM v$pdbs WHERE name != 'PDB$SEED' ORDER BY name) LOOP
                :g_result_msg := :g_result_msg || CHR(10) || '- ' || pdb_rec.name;
            END LOOP;
            
            RETURN;
        END IF;
    ELSE

        -- Nenhum parâmetro fornecido, usar o primeiro PDB disponível

        SELECT COUNT(*) INTO v_pdb_count
        FROM v$pdbs
        WHERE name != 'PDB$SEED';
        
        IF v_pdb_count = 0 THEN
            :g_result_msg := 'Nenhum PDB disponível';
            RETURN;
        ELSIF v_pdb_count > 1 THEN
            :g_result_msg := 'Existe mais de um PDB disponível. Especifique qual deseja conectar:';
            
            FOR pdb_rec IN (SELECT name FROM v$pdbs WHERE name != 'PDB$SEED' ORDER BY name) LOOP
                :g_result_msg := :g_result_msg || CHR(10) || '- ' || pdb_rec.name;
            END LOOP;
            
            RETURN;
        ELSE
            -- Exatamente um PDB disponível
            SELECT name INTO v_pdb_name
            FROM v$pdbs
            WHERE name != 'PDB$SEED';
        END IF;
    END IF;
    
    -- executar o comando ALTER SESSION
    v_alter_stmt := 'ALTER SESSION SET CONTAINER = ' || v_pdb_name;    
    EXECUTE IMMEDIATE v_alter_stmt;
    
    :g_result_msg := 'Sessão alterada para ' || v_pdb_name;
EXCEPTION
    WHEN OTHERS THEN
        :g_result_msg := 'Erro ao alterar o PDB: ' || SQLERRM;
END;
/

SET SERVEROUTPUT ON FORMAT WRAPPED LINESIZE 300
SET TERMOUT ON

prompt
exec dbms_output.put_line(:g_result_msg);
prompt

SET FEEDBACK ON


undef 1, PDB_PARAM