
libname l '.';

proc sql;
  CONNECT TO ORACLE(USER=sasreport ORAPW=sasreport PATH=usprd259);
    CREATE TABLE l.lims_0001e_avandamet AS SELECT * FROM CONNECTION TO ORACLE (
      SELECT DISTINCT
        R.SampId,
        R.SampName,
        R.ResStrVal,
        R.SampCreateTS,
        S.SpecName,
        S.DispName,
        V.Name,
        V.DispName as DispName2,
        SS.SampStatus,
        PLS.ProcStatus
      FROM
        ProcLoopStat PLS,
        Result R,
        SampleStat SS,
        Var V,
        Spec S
      WHERE R.SampId IN (SELECT R.SampId
                         FROM Result R, Var V 
                         WHERE R.ResStrVal in ('0316761','10000000007397','10000000010844','10000000010846','10000000010847','10000000010848',
                                               '10000000010849','10000000010850','10000000010851','10000000010852','10000000011446',
                                               '10000000011447','10000000011448','10000000011449','10000000011500','10000000012062',
                                               '10000000012063','10000000012064','10000000012065','10000000012066','10000000012067',
                                               '10000000012068','10000000012069','10000000012080','10000000012081','10000000012595',
                                               '10000000021035','10000000021036','10000000021037','10000000021039','10000000021110',
                                               '10000000021111','10000000021112','10000000021113','10000000021114','10000000021115',
                                               '10000000021116','10000000021117','10000000021118','10000000021119','10000000021140',
                                               '10000000021141','10000000021142','10000000021143','10000000021144','10000000021624',
                                               '10000000021625','10000000021626','10000000021627','10000000021628','10000000024350',
                                               '10000000024351','10000000024352','10000000024353','10000000024354','10000000024355',
                                               '10000000024619','10000000024670','10000000024671','10000000024672','10000000024673',
                                               '10000000024674','10000000024675','10000000024676','10000000024677','10000000024678',
                                               '10000000024680','10000000024681','10000000024682','10000000024683','10000000024684',
                                               '10000000026175','10000000026176','10000000026177','10000000026178','10000000026179',
                                               '10000000026290','10000000026955','10000000027160','10000000027161','10000000027162',
                                               '10000000027163','10000000028820','10000000030131','10000000032235','10000000040951',
                                               '10000000047840','10000000047841','10000000047964','10000000054930','10000000068620',
                                               '10000000068621','10000000068623','10000000068804','10000000068805','10000000068806',
                                               '10000000068807','10000000068808','10000000068809','10000000068820','10000000068821',
                                               '10000000068822','10000000074690','10000000074691','10000000074692','10000000074693',
                                               '10000000074694','10000000096227','10000000096228','10000000096229','10000000096230',
                                               '4159608','640028','640029')
        AND R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODUCTCODE$')
        AND R.SampCreateTS BETWEEN TO_DATE('11SEP2008','DDMONYY') AND TO_DATE('19JUL2011','DDMONYY')
        AND R.SpecRevId = S.SpecRevId
        AND R.SpecRevId = V.SpecRevId
        AND R.VarId = V.VarId
        AND R.SampId = SS.SampId
        AND R.SampId = PLS.SampId
        AND R.ProcLoopId = PLS.ProcLoopId
        AND SS.CurrAuditFlag = 1
        AND SS.CurrCycleFlag = 1
        AND SS.SampStatus <> 20
        AND PLS.ProcStatus >= 16
        AND ((V.TYPE  = 'T' AND R.ResReplicateIx <> 0)  OR  (V.TYPE <> 'T' AND R.ResReplicateIx =  0)) 
        AND  R.ResSpecialResultType <> 'C'
    );

    CREATE TABLE l.lims_0002e_avandamet AS SELECT * FROM CONNECTION TO ORACLE (
      SELECT DISTINCT
        R.SampId,
        R.SampName,
        R.SampCreateTS,
        R.ResLoopIx,
        R.ResRepeatIx,
        R.ResReplicateIx,
        S.SpecName,
        S.DispName,
        V.Name,
        E.RowIx,
        E.ColumnIx,
        E.ElemStrVal,
        VC.ColName,
        SS.SampStatus,
        PLS.ProcStatus
      FROM
        Element E,
        Result R,
        ProcLoopStat PLS,
        SampleStat SS,
        Var V,
        VarCol VC,
        Spec S
      WHERE R.SampId IN (SELECT R.SampId
                         FROM Result R, Var V 
                         WHERE R.ResStrVal in ('0316761','10000000007397','10000000010844','10000000010846','10000000010847','10000000010848',
                                               '10000000010849','10000000010850','10000000010851','10000000010852','10000000011446',
                                               '10000000011447','10000000011448','10000000011449','10000000011500','10000000012062',
                                               '10000000012063','10000000012064','10000000012065','10000000012066','10000000012067',
                                               '10000000012068','10000000012069','10000000012080','10000000012081','10000000012595',
                                               '10000000021035','10000000021036','10000000021037','10000000021039','10000000021110',
                                               '10000000021111','10000000021112','10000000021113','10000000021114','10000000021115',
                                               '10000000021116','10000000021117','10000000021118','10000000021119','10000000021140',
                                               '10000000021141','10000000021142','10000000021143','10000000021144','10000000021624',
                                               '10000000021625','10000000021626','10000000021627','10000000021628','10000000024350',
                                               '10000000024351','10000000024352','10000000024353','10000000024354','10000000024355',
                                               '10000000024619','10000000024670','10000000024671','10000000024672','10000000024673',
                                               '10000000024674','10000000024675','10000000024676','10000000024677','10000000024678',
                                               '10000000024680','10000000024681','10000000024682','10000000024683','10000000024684',
                                               '10000000026175','10000000026176','10000000026177','10000000026178','10000000026179',
                                               '10000000026290','10000000026955','10000000027160','10000000027161','10000000027162',
                                               '10000000027163','10000000028820','10000000030131','10000000032235','10000000040951',
                                               '10000000047840','10000000047841','10000000047964','10000000054930','10000000068620',
                                               '10000000068621','10000000068623','10000000068804','10000000068805','10000000068806',
                                               '10000000068807','10000000068808','10000000068809','10000000068820','10000000068821',
                                               '10000000068822','10000000074690','10000000074691','10000000074692','10000000074693',
                                               '10000000074694','10000000096227','10000000096228','10000000096229','10000000096230',
                                               '4159608','640028','640029')
        AND R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODUCTCODE$')
        AND R.SampCreateTS BETWEEN TO_DATE('11SEP2008','DDMONYY') AND TO_DATE('19JUL2011','DDMONYY')
        AND R.SpecRevId = V.SpecRevId
        AND R.VarId = V.VarId
        AND R.ResId = E.ResId
        AND VC.ColNum = E.ColumnIx
        AND R.SpecRevId = VC.SpecRevId
        AND R.VarId = VC.TableVarId
        AND R.SampId = PLS.SampId
        AND R.ProcLoopId = PLS.ProcLoopId
        AND R.SampId = SS.SampId
        AND R.SpecRevId = S.SpecRevId
        AND SS.CurrAuditFlag = 1
        AND SS.CurrCycleFlag = 1
        AND SS.SampStatus <> 20
        AND PLS.ProcStatus >= 16
        AND ((V.TYPE =  'T' AND R.ResReplicateIx <> 0) OR (V.TYPE <> 'T' AND R.ResReplicateIx = 0))
        AND R.ResSpecialResultType <> 'C'
    );
  DISCONNECT FROM ORACLE;
quit;

