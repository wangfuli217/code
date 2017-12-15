//BQH0LATE JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=5,CLASS=V,REGION=0M
//*ROUTE    PRINT R341
//*
//* JIMMY LUCAS LATEBF19 08/24/98
//* DETERMINES THE MOST RECENT (I.E. LATEST) BF19 MERGED FILE FOR
//* EACH STATE OR TERRITORY AND GENERATES FILENAMES IN THE FORM
//* STYR, E.G. NC97
//* 1. CHANGE BYR AND EYR TO YEAR(S) DESIRED
//* 2. CHANGE TYPE TO MATCH DESIRED DATA, CHECK RPT MACRO VAR
//* 3. DELETE ANY JCL REFERENCES TO BF19 FILES IN YOUR PROGRAM
//* 4. CUSTOMIZE THE READIN MACRO TO MATCH YOUR PROGRAM
//* ESTIMATED JOB TIME = 2.5 * YRS, TIME=2 FOR ONE YEAR
//*
//* PROGRAM UPDATE
//* 07/16/99  INSERTED THE MACRO CHECKEXT TO CORRECT THE PROBLEM
//*           WITH THE EXTENSION OF THE BF19 MEDMER FILES
//* 1/04/2000  REVISED CODE TO ACCEPT AND REFERENCE A FOUR DIGIT YEAR
//* 11 APR 2001 (KJK) ADDED CODE TO DELETE TEST FILES BEFORE
//*                   SELECTING LATEST VERSION
//* 04/18/2001 (BHB6) MODIFIED CODE TO CORRECTLY PROCESS THE NEW
//*            THREE DIGIT SHIPMENT NUMBERS
//* 09/13/2001 (BHB6) MODIFIED CODE TO ADD MICMER TO THE PROCESS
//*            AND CHANGED NB TO NE (NEBRASKA)
//* 10/09/2001 (BHB6) MODIFIED CODE TO CORRECTLY DELETE THE FILE
//*            NAMES THAT CONTAIN A LETTER AT THE END OF FILE NAME
//* 12/10/2001 (BHB6) MODIFIED CODE TO CAPTURE 2000 MORMER FILES
//*            THAT END WITH THE LETTER M AS THE LATEST FILE
//*            WE WERE PREVIOUSLY INSTRUCTED TO IGNORE ALL FILES
//*            ENDING WITH A LETTER
//* 08/14/2002 (BHB6) PROGRAM DID NOT REPORT FILE NAMES THAT END
//*            IN A LETTER PRIOR TO 2000
//* 01/06/2003 (BQH0) ADJUST FOR MEDICAL FILENAME CONVENTION
//*            CHANGES,  FORCE AN ABORT IF END YR IS LESS
//*            THAN BEGIN YEAR, CLEAN UP AND EMPLOY AN
//*            IMPROVED ALGORITHM FOR GENERATING THE PSEUDO-CODE.
//* 04/29/2003 (BQH0) FIX MISSING CURRENT YEAR MACROVARIABLES.
//*
//* OUTPUT A DIRECTORY LISTING OF BF19 FILE NAMES TO A DATASET
//***STEP1     EXEC PGM=IDCAMS
//***SYSPRINT  DD DSN=BQH0.BF19.DATASET,DISP=OLD
//***SYSIN     DD *
//*** LISTC LEVEL(BF19)
//*
//STEP2     EXEC SAS,OPTIONS='MSGCASE,MEMSIZE=0'
//WORK      DD SPACE=(CYL,(450,450),,,ROUND)
//IN        DD DSN=BQH0.BF19.DATASET,DISP=SHR
//SYSIN     DD *

OPTIONS LINESIZE=80 CAPS NOTES SOURCE MPRINT MLOGIC SYMBOLGEN;

%GLOBAL BYR EYR MERGETYP RPT CYR CURPR PRVPR TOTCUR TYR LYR;

%LET BYR=2003;     /* BEGINNING YEAR */
%LET EYR=2003;     /* ENDING YEAR */

%LET MERGETYP=3;   /* 1 = FETMER */
                   /* 2 = MEDMER */
                   /* 3 = MORMER */
                   /* 4 = NATMER */
                   /* 5 = MICMER */

%LET RPT=1;        /* PRINT LISTING OF BF19 FILES */
                   /* 1 = YES */
                   /* 0 = NO  */

DATA _NULL_;
  IF &EYR LT &BYR THEN
    DO;
      PUT '!!! BEGINNING YEAR (BYR) MUST BE LESS THAN OR '
          'EQUAL TO ENDING YEAR (EYR) !!!';
      ABORT ABEND;
    END;
  /* GET CURRENT YEAR (E.G. 2003) */
  CALL SYMPUT("CYR", SUBSTR(PUT("&SYSDATE9"D,MMDDYY10.),7,4));
RUN;


* SET VARIABLES FOR PROCESSING OF DATA BASED ON BYR, EYR AND CYR VALS;
* CURPR: FLAG TO PROCESS CURRENT YEAR;
* PRVPR: FLAG TO PROCESS PREVIOUS YEAR(S);
%MACRO SETVARS;
  %IF &BYR=&EYR AND &EYR=&CYR %THEN
    %DO;
      %LET CURPR=1;
      %LET PRVPR=0;
    %END;
  %ELSE %IF &BYR=&EYR AND &EYR NE &CYR %THEN
    %DO;
      %LET CURPR=0;
      %LET PRVPR=1;
    %END;
  %ELSE %IF &EYR=&CYR %THEN
    %DO;
      %LET CURPR=1;
      %LET PRVPR=1;
    %END;
  %ELSE
    %DO;
      %LET CURPR=0;
      %LET PRVPR=1;
    %END;
%MEND SETVARS;
%SETVARS


* READ IN FILE NAMES FROM THE LISTC LISTING OF ALL BF19 FILES;
DATA RAWDATA;
  LENGTH FN $ 25;
  INFILE IN TRUNCOVER;
  * E.G. BF19.AKX0120.MORMER1 ;
  INPUT FN $ 18-42;
RUN;


* DETERMINE WHICH BF19 FILENAMES TO USE FOR A GIVEN YEAR;
%MACRO GENYEAR(LYR=);
  * TWO DIGIT YEAR REPRESENTATION OF THE GIVEN YEAR;
  DATA _NULL_;
    CALL SYMPUT('TYR', SUBSTR("&LYR",3,2));
  RUN;

  * FILTER ONLY DATA SPECIFIED BY MERGETYP;
  %MACRO GENTYPE;
    %IF &MERGETYP = 1 %THEN
      %DO;
        DATA ALLF&LYR;
          SET ALLF&LYR;
          IF TYPE NE 'FETMER' THEN DELETE;
          IF YR NE &TYR THEN DELETE;
        RUN;
      %END;
    %ELSE %IF &MERGETYP = 2 %THEN
      %DO;
        DATA ALLF&LYR;
          SET ALLF&LYR;
          IF TYPE NE 'MEDMER' THEN DELETE;
          IF YR NE &TYR THEN DELETE;
        RUN;
      %END;
    %ELSE %IF &MERGETYP = 3 %THEN
      %DO;
        DATA ALLF&LYR;
          SET ALLF&LYR;
          IF TYPE NE 'MORMER' THEN DELETE;
          IF YR NE &TYR THEN DELETE;
        RUN;
      %END;
    %ELSE %IF &MERGETYP = 4 %THEN
      %DO;
        DATA ALLF&LYR;
          SET ALLF&LYR;
          IF TYPE NE 'NATMER' THEN DELETE;
          IF YR NE &TYR THEN DELETE;
        RUN;
      %END;
    %ELSE %IF &MERGETYP = 5 %THEN
      %DO;
        DATA ALLF&LYR;
          SET ALLF&LYR;
          IF TYPE NE 'MICMER' THEN DELETE;
          IF YR NE &TYR THEN DELETE;
        RUN;
      %END;
  %MEND GENTYPE;

  DATA ALLF&LYR;
    SET RAWDATA;
    LENGTH ST $ 2  YR $ 2  INDX $ 2  TYPE $ 6  FULLTYPE $ 8;

    * PARSE THE NAME OF THE MERGE FILE ON THE MAINFRAME;
    * E.G. BF19.AKX0199.MORMER10 ;
    FN=TRIM(FN);
    * E.G. BF19;
    WORD1=SCAN(FN,1,'.');
    * E.G. AKX0199;
    WORD2=SCAN(FN,2,'.');
    * E.G. MORMER1;
    WORD3=SCAN(FN,3,'.');
    * E.G. AK;
    ST=SUBSTR(FN,6,2);
    * E.G. 01;
    YR=SUBSTR(FN,9,2);
    * SHIPMENTS RANGE FROM 001-999;
    * E.G. 99 (REMOVES TRAILING PERIOD, IF ANY);
    SHIP=TRANSLATE(SUBSTR(FN,11,3),'','.');
    * E.G. 0199 (2 DIGIT YEAR PLUS 2 OR 3 DIGIT SHIPMENT NUM);
    YRN=TRANSLATE(SUBSTR(FN,9,5),'','.');
    * E.G. MORMER;
    TYPE=SUBSTR(WORD3,1,6);
    * E.G. MORMER10;
    FULLTYPE=SUBSTR(WORD3,1,8);
    * E.G. 10;
    INDX=SUBSTR(FULLTYPE,7,2);
    * E.G. AK2002 (LIBNAME TAG);
    TAG = ST || SUBSTR("&LYR",1,4);

    IF WORD1 NE 'BF19' THEN DELETE;

    * DELETES MERGED FILES THAT END WITH AN ALPHA EXTENSION;
    * BUT ON 12102001 DAVID ASKED US TO USE THE 2000 MORTALITY;
    * DATASET NAMES THAT END IN THE LETTER M;
    * PREV WE WERE TOLD TO RETAIN THESE FILES BUT USE THE FINAL;
    * FILES AS LISTED IN THE EXCEL SPREADSHEET WITHOUT THE LETTER M;
    * THE FOLLOWING IF STATEMENT AND THE ELSE ARE THE LATEST EDITIONS;
    *                                                                ;

    * 2003-01-09 (BQH0) MEDICAL IS USING ALPHA EXTENSIONS;
    * EXTENDED THE IF-THEN LOOP TO CAPTURE FILES LIKE 'MEDMERX';
    * FILENAMES CAN LOOK LIKE BF19.AKX0199.MEDMER (NORMAL) OR;
    *                         BF19.AKX0199.MEDMER1 (1999,2000) OR;
    *                         BF19.AKX0199.MEDMER10 (1999,2000) OR;
    *                         BF19.AKX0199.MEDMERR (2001) OR;
    *                         BF19.AKX0199.MEDMERX (2001) OR;
    IF TYPE EQ 'MORMER' THEN
      DO;
        IF SUBSTR(INDX,1,1) GE 'A' AND SUBSTR(INDX,1,1) LE 'Z' THEN
          DO;
            IF SUBSTR(INDX,1,1) NE 'M' THEN DELETE;
          END;
        IF SUBSTR(INDX,2,1) GE 'A' AND SUBSTR(INDX,2,1) LE 'Z' THEN
          DO;
            IF SUBSTR(INDX,2,1) NE 'M' THEN DELETE;
          END;
      END;
    ELSE IF TYPE EQ 'MEDMER' THEN
      DO;
        * ELIMINATE MEDMER GARBAGE LIKE BF19.XOX0216.MEDMER;
        IF ST IN ('AK','AL','AR','AS','AZ','CA','CO','CT','DC','DE',
                  'FL','GA','GU','HI','IA','ID','IL','IN','KS','KY',
                  'LA','MA','MD','ME','MI','MN','MO','MP','MS','MT',
                  'NC','ND','NE','NH','NJ','NM','NV','NY','OH','OK',
                  'OR','PA','PR','RI','SC','SD','TN','TX','UT','VA',
                  'VI','VT','WA','WI','WV','WY','YC');
        * MEDICAL HAS BIZARRE ENTRIES LIKE 'MEX01AA';
        IF SHIP GE 'A' AND SHIP LE 'Z' THEN DELETE;
        * NEED TO EVENTUALLY DO A NUMERIC (NOT ASCII) SORT;
        IF INDX GE '0' AND INDX LE '9' THEN
          DO;
            IF INDX NE . THEN
              INDX=INPUT(INDX, F3.);
          END;
      END;
    ELSE IF TYPE EQ 'MICMER' THEN
      DO;
        * WANT TO SKIP FILES WITH THE TRAILING WORD 'BACKUP';
        FROMEND = LENGTH(FN) - 5;
        IF SUBSTR(FN, FROMEND, 6) EQ 'BACKUP' THEN DELETE;
      END;
    ELSE
      DO;
        IF 'A' LE SUBSTR(INDX,1,1) LE 'Z' THEN DELETE;
        IF 'A' LE SUBSTR(INDX,2,1) LE 'Z' THEN DELETE;
      END;
  RUN;

  * RUN NESTED MACRO TO FILTER DATA SET FOR SPECIFIED TYPE (MORMER, ;
  * MEDMER, ETC.);
  %GENTYPE

  * 041801 CONVERT THE YRN VALUE WHICH IS THE YR AND SHIPMENT NUMBER;
  * TO NUMERIC BEFORE SORTING SO THE 3 DIGIT SHIP NOS ARE AT BOTTOM;
  * 091301 I CHANGED THE CONVERSION FROM CHAR TO NUM BECAUSE IT WAS;
  * NOT WORKING FOR MICMER 1998 NOW THAT IT IS USING THE INPUT;
  * FUNCTION IT APPEARS TO BE FINE;
  * 091201 CHANGED THE INPUT STATEMENT TO 5 FROM 4 BECAUSE IT NO;
  * LONGER CAPTURED THE 3 DIGIT SHIPMENT NUMBERS;
  DATA ALLF&LYR;
    SET ALLF&LYR;
    YRNUM = INPUT(YRN,5.);
  RUN;

  PROC SORT DATA=ALLF&LYR;
    BY ST YRNUM INDX;
  RUN;

  * CORRECT THE PROBLEM OF 4TH LEVEL EXTENSIONS OF;
  * THE BF19 MEDMER FILES (E.G. 'BF19.NJX0110.MEDMER.PENDINGS');
  DATA ALLF&LYR;
    SET ALLF&LYR;
    EXT = SUBSTR(FN,23,3);
    IF EXT NE '' THEN DELETE;
  RUN;

  * CHOOSE THE LATEST BF19 FROM THE DATASET;
  DATA ALLF&LYR;
    SET ALLF&LYR;
    BY ST YRNUM INDX;
    IF LAST.ST;
    KEEP FN TAG YR;
  RUN;
%MEND GENYEAR;


* HANDLE POTENTIAL MULTI-YEAR REQUESTS BY ITERATING AND COMBINING;
%MACRO ALLYEARS;
  %DO I=&BYR %TO &EYR;
    %GENYEAR(LYR=&I)
  %END;

  %MACRO COMBINE;
    %DO I=&BYR %TO &EYR;
      ALLF&I
    %END;
  %MEND COMBINE;

  * ALLYEARS HOLDS THE (57 X NUM YEARS REQUESTED) MOST RECENT BF19 FILES;
  DATA ALLYEARS;
    SET %COMBINE;
  RUN;

  %IF &RPT=1 %THEN %DO;
    PROC PRINT;
    RUN;
  %END;

  * CREATE DATASET OF UP TO 57 STATES THAT HAVE SUBMITTED A FILE SO ;
  * FAR IN THE CURRENT YEAR.  USED BY %READIN BELOW;
  DATA CURRENT;
    SET ALLYEARS;
    LENGTH ST $2;
    ST=SUBSTR(TAG,1,2);
    MYR=SUBSTR("&CYR",3,2);
    IF YR=MYR;
    KEEP TAG ST;
  RUN;

  * OBTAIN THE NUMBER OF CURRENTLY AVAILABLE MERGE FILES FOR THE ;
  * CURRENT YEAR.  USED BY %READIN BELOW;
  DATA _NULL_;
    SET CURRENT END=LAST;
    N = _N_;
    IF LAST THEN CALL SYMPUT('TOTCUR',N);
  RUN;
%MEND ALLYEARS;
%ALLYEARS


FILENAME FLEXCODE CATALOG 'WORK.FLEX.SOURCE';
* GENERATE FILENAME STATEMENTS;
DATA _NULL_;
  SET ALLYEARS;
  FILE FLEXCODE;
  PUT 'FILENAME ' TAG "'" FN "' DISP=SHR;";
RUN;
%INCLUDE FLEXCODE / SOURCE2;


FILENAME FLEXCOD2 CATALOG 'WORK.FLEX2.SOURCE';
* GENERATE &TOTCUR NUMBER OF MACROVARIABLES REPRESENTING THE CURRENTLY ;
* AVAILABLE MERGE FILES FOR THE CURRENT YEAR;
DATA _NULL_;
  SET CURRENT;
  FILE FLEXCOD2;
  PUT '%LET CUR' _N_ "= " ST ";";
RUN;
%INCLUDE FLEXCOD2 / SOURCE2;


**** TOGGLE ENDSAS AND CUSTOMIZE THE FOLLOWING TEMPLATE TO YOUR NEEDS ****;
***ENDSAS;

%LET ST1=AL;
%LET ST2=AK;
%LET ST3=AZ;
%LET ST4=AR;
%LET ST5=CA;
%LET ST6=CO;
%LET ST7=CT;
%LET ST8=DE;
%LET ST9=DC;
%LET ST10=FL;
%LET ST11=GA;
%LET ST12=HI;
%LET ST13=ID;
%LET ST14=IL;
%LET ST15=IN;
%LET ST16=IA;
%LET ST17=KS;
%LET ST18=KY;
%LET ST19=LA;
%LET ST20=ME;
%LET ST21=MD;
%LET ST22=MA;
%LET ST23=MI;
%LET ST24=MN;
%LET ST25=MS;
%LET ST26=MO;
%LET ST27=MT;
%LET ST28=NE;
%LET ST29=NV;
%LET ST30=NH;
%LET ST31=NJ;
%LET ST32=NM;
%LET ST33=NY;
%LET ST34=NC;
%LET ST35=ND;
%LET ST36=OH;
%LET ST37=OK;
%LET ST38=OR;
%LET ST39=PA;
%LET ST40=RI;
%LET ST41=SC;
%LET ST42=SD;
%LET ST43=TN;
%LET ST44=TX;
%LET ST45=UT;
%LET ST46=VT;
%LET ST47=VA;
%LET ST48=WA;
%LET ST49=WV;
%LET ST50=WI;
%LET ST51=WY;
%LET ST52=PR;
%LET ST53=VI;
%LET ST54=GU;
%LET ST55=YC;
%LET TOTST=55;
 /* NOT INCLUDING AS AND MP BECAUSE THEY CAUSE %READIN TO FAIL
  * WHEN MISSING.
  */

 /* SAMPLE MACRO TO BE CUSTOMIZED TO YOUR NEEDS: */
%MACRO READIN;
  /* THE 55 STATES ARE ASSUMED TO BE AVAILABLE FOR EACH PREVIOUS PERIOD. */
  %IF &PRVPR=1 %THEN
    %DO;
      /* HANDLE THE CURRENT YEAR LATER. */
      %IF &CURPR=1 %THEN %LET EYR=%EVAL(&EYR-1);
        %DO J = 1 %TO &TOTST;
          %DO K = &BYR %TO &EYR;
            %LET S = &&ST&J;
            DATA IN&J&K;
              INFILE &S&K;
              INPUT VAR1 $ 3-8  VAR2 $ 10-11  VAR3 $ 15-16;
            RUN;
          %END;
        %END;
        %DO K = &BYR %TO &EYR;
           DATA RPT&K;
             /* E.G. IN12002, IN22002, ... */
             SET IN1&K IN2&K IN3&K IN4&K IN5&K IN6&K IN7&K IN8&K IN9&K
                 IN10&K IN11&K IN12&K IN13&K IN14&K IN15&K IN16&K IN17&K
                 IN18&K IN19&K IN20&K IN21&K IN22&K IN23&K IN24&K IN25&K
                 IN26&K IN27&K IN28&K IN29&K IN30&K IN31&K IN32&K IN33&K
                 IN34&K IN35&K IN36&K IN37&K IN38&K IN39&K IN40&K IN41&K
                 IN42&K IN43&K IN44&K IN45&K IN46&K IN47&K IN48&K IN49&K
                 IN50&K IN51&K IN52&K IN53&K IN54&K IN55&K
                 ;
           RUN;
        %END;
        /* RESET */
        %IF &CURPR=1 %THEN %LET EYR=%EVAL(&EYR+1);
    %END;

  /* THE 55 STATES ARE NOT NECESSARILY AVAILABLE. */
  %IF &CURPR=1 %THEN
    %DO;
      %DO J = 1 %TO &TOTCUR;
        %DO K = &CYR %TO &CYR;
          %LET S = &&CUR&J;
          DATA IN&J&K;
             /* E.G. IN12003, IN22003, ... */
            INFILE &S&K;
            INPUT VAR1 $ 3-8  VAR2 $ 10-11  VAR3 $ 15-16;
          RUN;
        %END;
      %END;

      %MACRO CURFILES;                                                          
        %DO C = 1 %TO &TOTCUR;                                                    
          IN&C&CYR                                                              
        %END;                                                                   
      %MEND CURFILES;                                                           
                                                                                
      DATA RPT&CYR;                                                             
        SET %CURFILES;                                                          
      RUN;
    %END;

  %DO Z=&BYR %TO &EYR;
    TITLE "SAMPLE REPORT: YEAR &Z";
    PROC PRINT DATA=RPT&Z (OBS=10); 
    RUN;
  %END;
%MEND READIN;
%READIN
