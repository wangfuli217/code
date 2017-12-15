/********************************************************************************
*  SAVED AS:                pqa.sas
*                                                                         
*  CODED ON:                23JUL2015 by Bob Heckel
*                                                                         
*  DESCRIPTION:            Process individual datasets for each worksheet,
*                          convert X to 1 for flag fields, create combined
*                          dataset per list 
*                                                                           
*  PARAMETERS:              Incoming dataset names, output directory
*
*  MACROS CALLED:           NONE
*                                                                         
*  INPUT GLOBAL VARIABLES:  NONE
*                                                                         
*  OUTPUT GLOBAL VARIABLES: NONE  
*                                                                         
*  LAST REVISED:                                                          
*   23-Jul-15 (bheckel)     Initial version
*   27-Jul-15 (bheckel)     Change statins to statin, hrm_2004 to hrm to align
*                           with previous PQA dataset
*   09-Mar-16 (bheckel)     diabetesapprtx_htn no longer in xslx, Statins in 
*                           Diabetes tab changed field names to TableA_Antidiabetics
*                           etc.
********************************************************************************/
options ls=max ps=max NOlabel /*validvarname=any*/ mprint sgen NOcenter;

 /* Assign a temporary folder.  QC prior to overwriting old pqa datasets */
libname PQA '/Drugs/Personnel/bob/PQA_NDC_merge';

%macro convert_flags(dsin=);
  %local flagnames NUMflagnames;

  data t;
    length source $32;
    set PQA.&dsin;
    source = "&dsin";
  run;

  /* Assumptions: 
   * All flag fields end in _flag except for Antidiabetics and Statins fields 
   * Flag fields hold 'X' or 'x' except for flags that aren't flags like New_Update_Flag, etc.
  */
  proc sql NOprint;
    select count(*) into :cntobs
    from dictionary.columns
    where memname eq "&dsin" and upcase(name) like '%_FLAG' and upcase(name) ne 'NEW_UPDATE_FLAG' and upcase(name) ne 'CATEGORY_FLAG' and upcase(name) ne 'STEP_FLAG'
    ;
    select name into :flagnames separated by ' '
    from dictionary.columns
    where memname eq "&dsin" and upcase(name) like '%_FLAG' and upcase(name) ne 'NEW_UPDATE_FLAG' and upcase(name) ne 'CATEGORY_FLAG' and upcase(name) ne 'STEP_FLAG'
    ;
    select catt('NUM',name) into :NUMflagnames separated by ' '
    from dictionary.columns
    where memname eq "&dsin" and upcase(name) like '%_FLAG' and upcase(name) ne 'NEW_UPDATE_FLAG' and upcase(name) ne 'CATEGORY_FLAG' and upcase(name) ne 'STEP_FLAG'
    ;
  quit;

  /* Convert 'X's to 1 */
  data t(drop=i);
    set t;

    /* Add flags that don't look like flags.
     * TODO add Antidiabetics & Statins flags only for those datasets where they appear.  Right now all datasets will have these 2 variables. 
     * Assumption is that these 2 empty columns can be safely ignored for those drug categories where they do not apply.
     */
/***    array flagnames $ &flagnames Antidiabetics Statins;***/
    /*                           Statins in Diabetes tab                       */
    array flagnames $ &flagnames TableA_Antidiabetics TableB_Statins;
    array NUMflagnames &NUMflagnames NUMTableA_Antidiabetics NUMTableB_Statins;

    do i=1 to dim(flagnames);
      if upcase(flagnames[i]) eq 'X' then do;
        NUMflagnames[i] = 1;
      end;
    end;

    drop &flagnames TableA_Antidiabetics TableB_Statins;
  run;

  /* Rename flag vars */
  data t;
    set t;

    %local i2 f2;
    %let i2=1;
    %let f2=%scan(&NUMflagnames NUMTableA_Antidiabetics NUMTableB_Statins, &i2, ' ');

    %do %while ( &f2 ne  );
      %let i2=%eval(&i2+1);

      rename &f2 = %substr(&f2, 4); 

      %let f2=%scan(&NUMflagnames NUMTableA_Antidiabetics NUMTableB_Statins, &i2, ' ');
    %end;
  run;

  data PQA.&dsin;
    set t;
  run;
%mend convert_flags;

%macro build_combined;
  data t(drop=source);  /* source is no longer relevant since rows from multiple datasets will collapse into one */
    set PQA.PQA_RASA(in=from_rasa)
        PQA.PQA_DIABETES(in=from_diabetes)
        PQA.PQA_INSULINS(in=from_insulins)
        PQA.PQA_STATINS(in=from_statins)
/***        PQA.PQA_DIABETESAPPRTX_HTN(in=from_diabetesapprtx_htn)***/
        PQA.PQA_RESPIRATORY(in=from_respiratory)
        PQA.PQA_HRM_2014(in=from_hrm_2014)
        PQA.PQA_STATINS_IN_DIABETES(in=from_statins_in_diabetes)
        ;

    if from_rasa then rasa=1;
    else if from_diabetes then diabetes=1;
    else if from_insulins then insulin=1;
    else if from_statins then statin=1;
    else if from_diabetesapprtx_htn then diabetesapprtx_htn=1;
    else if from_respiratory then respiratory=1;
    else if from_hrm_2014 then hrm=1;
    else if from_statins_in_diabetes then statins_in_diabetes=1;
    else put 'ERROR: ' (_ALL_)(=);
  run;

   /* Remove complete duplicates */
  proc sql NOprint;
    create table t2 as
    select distinct *
    from t
    ;
  quit;

  proc sort data=t2; by ndc; run;

   /* Collapse/overlay multiple NDC rows to single */
  data PQA.pqa_medlist;
    update t2(obs=0) t2;
    by ndc;
  run;
%mend build_combined;

%macro dsloop(ds);
  %local i f; %let i=1;
  %let f=%scan(&ds, &i, ' ');

  %do %while ( &f ne  );
    %let i=%eval(&i+1);

    %convert_flags(dsin=&f);

    %let f=%scan(&ds, &i, ' ');
  %end;
%mend;

%macro qc;
  proc sql NOPRINT;
    select memname into :ds separated by ' '
    from dictionary.members
    where libname like 'PQA';
  quit;
  %put _USER_;

  %local i f; %let i=1;
  %let f=%scan(&ds, &i, ' ');

  %do %while ( &f ne  );
    %let i=%eval(&i+1);

    title "!!!&f"; proc freq data=PQA.&f; run; title;

    %let f=%scan(&ds, &i, ' ');
  %end;
%mend;


 /* 1-Manually import worksheets in workbook via EG to
  * ~/bheckel_moya/PQA_NDC_merge/20150803_ManualImport/, cp them to
  * ~/bheckel_moya/PQA_NDC_merge/ then re-run manual import for any
  * non-standard var names if the following macro fails
  */

 /* 2-Convert flags to "1"s */
%dsloop(PQA_ANTIPSYCHOTICS
        PQA_ANTIRETROVIRALS
        PQA_BENZO_SED_HYP
        PQA_BETABLOCKERS
        PQA_CCB
        PQA_DDI_2014
        PQA_DEMENTIAB
/***        PQA_DIABETESAPPRTX_HTN***/
        PQA_DIABETES
        PQA_DIABETESDOSING
        PQA_HRM_2014
        PQA_INSULINS
        PQA_OPIOIDS
        PQA_PDC_A_ANTICOAGULANTS
        PQA_PDC_B_ANTICOAGULANTS_EXCL
        PQA_RASA
        PQA_RESPIRATORY
        PQA_STATINS
        PQA_STATINS_IN_DIABETES)
        ;

/* 3-Create the collapsed to single obs per NDC dataset */
%build_combined;

%qc;


endsas;
 /* Toggle additional QC */

options ls=max ps=max NOlabel mprint nocenter;

libname PQA '/Drugs/Personnel/bob/PQA_NDC_merge' access=readonly;
data t; set PQA.pqa_medlist(obs=0); length source $32;run;
proc append base=t data=PQA.PQA_RASA FORCE; run;
proc append base=t data=PQA.PQA_DIABETES FORCE; run;
proc append base=t data=PQA.PQA_INSULINS FORCE; run;
proc append base=t data=PQA.PQA_STATINS FORCE; run;
/***proc append base=t data=PQA.PQA_DIABETESAPPRTX_HTN FORCE; run;***/
proc append base=t data=PQA.PQA_RESPIRATORY FORCE; run;
proc append base=t data=PQA.PQA_HRM_2014 FORCE; run;
proc append base=t data=PQA.PQA_STATINS_IN_DIABETES FORCE; run;

proc sql NOprint;
  create table single as
  select *
  from t
  group by ndc
  having count(ndc)=1
  ;
  create table mult as
  select *
  from t
  group by ndc
  having count(ndc)>1
  ;
quit;

/* toggle 1a-find a multiple ndc to trace  1b-find a single  */
title "ds:mult";proc print data=mult(obs=max) width=minimum heading=H; run;title; endsas;   
/***title "ds:sing";proc print data=single(obs=max) width=minimum heading=H; run;title;***/

/* toggle 2- */
/***data t2; set t pqa.pqa_medlist(where=(ndc='00003422111')); run; title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; where ndc='00003422111';run;title;***/
