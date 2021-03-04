use ellis2021;

UPDATE orthogroup SET assemblyid = REPLACE(assemblyid, '|', '_') WHERE assemblyid LIKE 'D%';
UPDATE orthogroup SET assemblyid = REPLACE(assemblyid, '.', '_') WHERE assemblyid LIKE 'D%';

