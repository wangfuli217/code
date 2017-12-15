 /**********************************************************************
 * PROGRAM NAME  MRAAAAX
 *               (FORMERLY MULTRC)
 *
 * DESCRIPTION   GENERIC PROGRAM TO TABULATE THE COUNT OF 'Y' FROM Y/N
 *               MULTI-RACE CHECKBOXES AND PRODUCE SUMMARY DATA.
 *
 * CALLED BY     MRNAAOA, MRFAAOA, MRMAAOA MRNAAZA, MRFAAZA, MRMAAZA
 *
 *               EACH OF THESE CALLERS WILL BE A REQUEST TO %INCLUDE
 *               THIS CODE AND THEN TO CALL THE RUNMULTI MACRO BELOW
 *               LIKE THIS:
 *               %RUNMULTI(NATALITY, 277, 224, 9, ANNUAL, RACE MOTHER);
 *
 * CALLS TO
 *
 * INPUT MVARS   YEAR STATE FNAME STATNAME RSPAN IN2003...
 *
 * PROGRAMMER    BQH0
 *
 * DATE WRITTEN  12 FEB 2003
 *
 * TODO RESTORE MONTHLY & QUARTERLY REPORTS
 *
 * UPDATE LOG
 * 2003-02-19 (BQH0) DWJ2 REQUESTED DISPLAY OF 'EXACTLY 1 Y RECORDS'
 * 2003-07-25 (BQH0) ALLOW OUTPUT OF MONTHLY/QUARTERLY DATA
 * 2003-09-26 (BQH0) FIX INVALID RECORD COUNT
 * 2003-12-29 (BQH0) FIX BAD RECORD COUNT.  STANDARDIZE FOR 2004.
 * 2003-12-30 (BQH0) ADD ABILITY TO PRODUCE MULTI-YEAR REPORTS
 * 2004-01-04 (KJK4) CHANGED MVAR SPAN TO RSPAN
 * 2004-01-06 (BQH0) FIXED 'DROP ALIAS' PROBLEM
 * 2004-01-07 (BQH0) ALLOW ALL BLANK CHECKBOXES
 * 2004-01-08 (BQH0) CENTER REPORT
 * 2004-02-04 (BQH0) ADDED STYLE ELEMENTS FOR PDF OUTPUT
 * 2004-02-11 (BQH0) ADDED CATEGORIES TO THE LOWER SECTION PER DWJ2
 * 2004-02-19 (BQH0) REMOVED POTENTIAL DOUBLECOUNTING OF INVALIDS
 *                   PER DWJ2
 * 2004-02-25 (BQH0) ADDED TITLE TO DISTINGUISH BETWEEN MOTH & FATH
 *                   REPORT SECTIONS
 **********************************************************************/
OPTIONS SOURCE SOURCE2 MLOGIC MPRINT SYMBOLGEN NOERRORABEND MISSING=0
        LINESIZE=135
        ;
TITLE1;
FOOTNOTE1;

%GLOBAL BYR CYR;
%LET BYR = %EVAL(&YEAR-&RSPAN+1);
%LET CYR = &YEAR;

 /* BUILD IN2003, IN2004, ETC. FOR EACH YEAR THIS STATE HAS SUBMITTED
  * MULTIRACE DATA.
  */
%MACRO FILEREF;
  %LOCAL I T;

  %DO I = 1 %TO &RSPAN;
    %LET T = %EVAL(&YEAR+1-&I);
    FILENAME IN&T "&&IN&T" DISP=SHR WAIT=250;
  %END;
%MEND FILEREF;
%FILEREF


 /* FOR PROC REPORT DISPLAY BELOW. */
PROC FORMAT;
  /* FOR THE UPPER REPORT. */
  VALUE $F_CKBX 'T1'  = 'WHITE'
                'T2'  = 'BLACK'
                'T3'  = 'AM. INDIAN/ALASKAN NATIVE'
                'T4'  = 'ASIAN'
                'T5'  = 'CHINESE'
                'T6'  = 'FILIPINO'
                'T7'  = 'JAPANESE'
                'T8'  = 'KOREAN'
                'T9'  = 'VIETNAMESE'
                'T10' = 'OTHER ASIAN'
                'T11' = 'NATIVE HAWAIIAN'
                'T12' = 'GUAMANIAN'
                'T13' = 'SAMOAN'
                'T14' = 'OTHER PACIFIC ISLANDER'
                'T15' = 'OTHER'
                ;
  /* FOR THE LOWER REPORT. */
  VALUE $F_COND 'ALLNOCNT'  = "15 'N' CHECKBOXES"
                  'BADCNT'  = "ONE OR MORE INVALID CHECKBOXES"
                   'YCNT1'  = "EXACTLY ONE 'Y' CHECKBOX"
                   'YCNT2'  = "EXACTLY TWO 'Y' CHECKBOXES"
                   'YCNT3'  = "EXACTLY THREE 'Y' CHECKBOXES"
                   'YCNT4'  = "FOUR OR MORE 'Y' CHECKBOXES"
                   ;
RUN;


 /* THIS MACRO IS CALLED ONCE FOR EACH EVENT (TWICE FOR NAT & FET).
  *
  * E.G. %RUNMULTI(MORTALITY, 166, 135, 49, QUARTER, DECEDENT);
  * OR
  * E.G. %RUNMULTI(NATALITY, 277, 1, 9, QUARTER, RACE OF MOTHER);
  * E.G. %RUNMULTI(NATALITY, 277, 1, 9, QUARTER, RACE OF FATHER);
  *
  * IT WORKS THE SAME FOR ALL EVENTS AND FOR REVISERS OR PARTIAL
  * REVISERS.  REPORT CAN BE GENERATED FOR ANNUAL, MONTHLY OR QUARTELY
  * PERIODS.
  *
  * ACCEPTS: -THE STRING NATALITY, MORTALITY OR FETAL
  *          -THE FIRST BYTE POSITION OF THE 15 BYTE CHECKBOXES
  *          -THE FIRST BYTE POSTION OF THE 4 BYTE EVENT YEAR
  *          -THE FIRST BYTE POSITION OF THE 2 BYTE EVENT MONTH
  *          -THE STRING ANNUAL, MONTH OR QUARTER
  *          -THE (OPTIONAL) STRING MOTHER OR FATHER FOR DIFFERENTIATING
  *           NATALITY AND FETAL'S 2 15 BYTE BLOCKS (E.G. RACE OF MOTHER)
  *
  * RETURNS: NOTHING, RUNS REPORT
  */
%MACRO RUNMULTI(TYPE, STARTBYTE, YEARBYTE, MONBYTE, DTSPAN, WHO);
  /* USING SEVERAL SINGLE LETTER MVARS TO LOOP IN MANY DIFFERENT PLACES
   * WITHOUT HAVING TO WORRY ABOUT COLLISIONS.
   */
  %LOCAL THIS NUMPDS A B C D E F G H I J K L M BLKWIDTH;

  /* E.G. MORTALITY */
  %LET TYPE=%UPCASE(&TYPE);
  /* E.G. ANNUAL */
  %LET DTSPAN=%UPCASE(&DTSPAN);
  /* BYTE WIDTH OF CHECKBOXES */
  %LET BLKWIDTH=15;

  /* FOR ERROR MESSAGES */
  %LET THIS=MRAAAAX;

  %IF &DTSPAN EQ QUARTER %THEN
    %LET NUMPDS=4;
  %ELSE %IF &DTSPAN EQ MONTH %THEN
    %LET NUMPDS=12;
  %ELSE %IF &DTSPAN EQ ANNUAL %THEN
    %LET NUMPDS=1;
  %ELSE
    %PUT !!! ERROR: (&THIS) UNKNOWN DTSPAN MACROVARIABLE (&DTSPAN) !!!;

  /* ELIMINATE MORTALITY ALIAS RECORDS.  NOTE: THERE ARE BETTER WAYS TO
   * DO THIS.
   */
  %LOCAL ALIASINP ALIASDEL;
  %IF &TYPE EQ MORTALITY %THEN
    %DO;
      /* PARTIAL REVISER */
      %IF &STARTBYTE EQ 166 %THEN
        %LET ALIASINP=%NRSTR(@47 ALIAS $CHAR1.);
      /* FULL REVISER */
      %ELSE %IF &STARTBYTE EQ 271 %THEN
        %LET ALIASINP=%NRSTR(@138 ALIAS $CHAR1.);
      %ELSE
        %PUT !!! ERROR: (&THIS) UNKNOWN STARTBYTE MVAR (&STARTBYTE) !!!;

      %LET ALIASDEL=%NRSTR(IF ALIAS = "1" THEN DELETE);
    %END;
  %ELSE
    %DO;
      %LET ALIASINP= ;
      %LET ALIASDEL= ;
    %END;

  %DO A=&BYR %TO &CYR;
    DATA WORK.RACEDATA&A;
      RETAIN BADRECFLAG 0;
      INFILE IN&A;

      INPUT @&STARTBYTE (R1-R15) ($CHAR1.)
            @&STARTBYTE ALLBOXES $CHAR&BLKWIDTH..
            @&YEARBYTE BYEAR $CHAR4.
            @&MONBYTE MO $CHAR2.
            @13 VOIDFLAG $CHAR1.
            &ALIASINP
            ;

      &ALIASDEL;

      /* REVISERS MUST HAVE VOID RECORDS REMOVED.  THIS ASSUMES OLD
       * STYLE BIRTH HAD FILLER IN POSTION 13, OLD STYLE DEATH HAD AN
       * ALPHA LAST NAME CHARACTER IN POSITION 13 AND THE VOID FLAG IS
       * BYTE 13 IN BOTH REVISER LAYOUTS.
       */
      IF VOIDFLAG EQ '1' THEN
        DELETE;

      IF "&DTSPAN" EQ 'QUARTER' THEN
        DO;
          IF MO IN('01','02','03') THEN
            INTERVAL = 1;
          ELSE IF MO IN('04','05','06') THEN
            INTERVAL = 2;
          ELSE IF MO IN('07','08','09') THEN
            INTERVAL = 3;
          ELSE IF MO IN('10','11','12') THEN
            INTERVAL = 4;
          ELSE
            INTERVAL = 0;
        END;
      ELSE IF "&DTSPAN" EQ 'MONTH' THEN
        INTERVAL = MO;
      ELSE IF "&DTSPAN" EQ 'ANNUAL' THEN
        INTERVAL = 1;
      ELSE
        PUT "!!! ERROR: (&THIS) UNKNOWN DTSPAN MVAR (&DTSPAN) !!!";

      /* TOTAL RAW (EXCLUDING ALIAS, VOIDS) NUMBER OF RECORDS IN THE
       * MERGEFILE.
       */
      CNT+1;

      /* 1.  15 CONSECUTIVE N */
      IF UPCASE(ALLBOXES) EQ 'NNNNNNNNNNNNNNN' THEN
        ALLNOCNT+1;

      /* 2.  COUNT, TO LATER BE REMOVED FROM THE DATASET, RECORDS WITH
       * SPACES OR NON Y, NON N I.E. BAD DATA.  BAD DATA DEFINITION IS PER
       * DWJ2.
       */

      /* ONLY Y OR N IS A VALID CHAR. */
      YCNT = LENGTH(COMPRESS(UPCASE(ALLBOXES),
                                 COMPRESS(COLLATE(0,255),'Y'))||'.')-1;
      NCNT = LENGTH(COMPRESS(UPCASE(ALLBOXES),
                                 COMPRESS(COLLATE(0,255),'N'))||'.')-1;

      IF YCNT+NCNT LT &BLKWIDTH THEN
        DO;
          BADRECFLAG = 1;
          BADCNT+1;
        END;
      ELSE
        BADRECFLAG = 0;

      /* 3.  AT LEAST 1, 2, 3, 4 'Y' ON A VALID RECORD. */
      IF YCNT+NCNT EQ &BLKWIDTH THEN
        DO;
          IF YCNT EQ 1 THEN
            YCNT1+1;
          ELSE IF YCNT EQ 2 THEN
            YCNT2+1;
          ELSE IF YCNT EQ 3 THEN
            YCNT3+1;
          ELSE IF YCNT GE 4 THEN
            YCNT4+1;
        END;
    RUN;
  %END;

  %IF &DTSPAN EQ QUARTER %THEN
    %DO;
      %LOCAL Q1RECCNT Q2RECCNT Q3RECCNT Q4RECCNT;
      /* AVOID DIV BY 0 ERRORS. */
      %LET Q1RECCNT=1;
      %LET Q2RECCNT=1;
      %LET Q3RECCNT=1;
      %LET Q4RECCNT=1;
      %LOCAL Q;
      %DO Q=1 %TO 4;
        DATA RACEDATA&Q;
          SET WORK.RACEDATA;
          IF INTERVAL = &Q;
          IF "&Q" EQ 1 THEN
            CALL SYMPUT('Q1RECCNT', _N_);
          ELSE IF "&Q" EQ 2 THEN
            CALL SYMPUT('Q2RECCNT', _N_);
          ELSE IF "&Q" EQ 3 THEN
            CALL SYMPUT('Q3RECCNT', _N_);
          ELSE IF "&Q" EQ 4 THEN
            CALL SYMPUT('Q4RECCNT', _N_);
        RUN;
      %END;
    %END;
  %ELSE %IF &DTSPAN EQ MONTH %THEN
    %DO;
      %LOCAL M1RECCNT M2RECCNT M3RECCNT M4RECCNT
             M5RECCNT M6RECCNT M7RECCNT M8RECCNT
             M9RECCNT M10RECCNT M11RECCNT M12RECCNT
             ;
      /* AVOID DIV BY 0 ERRORS. */
      %LET M1RECCNT=1;
      %LET M2RECCNT=1;
      %LET M3RECCNT=1;
      %LET M4RECCNT=1;
      %LET M5RECCNT=1;
      %LET M6RECCNT=1;
      %LET M7RECCNT=1;
      %LET M8RECCNT=1;
      %LET M9RECCNT=1;
      %LET M10RECCNT=1;
      %LET M11RECCNT=1;
      %LET M12RECCNT=1;
      %LOCAL M;
      %DO M=1 %TO 12;
        DATA RACEDATA&M;
          SET WORK.RACEDATA;
          IF INTERVAL = &M;
          IF "&M" EQ 1 THEN
            CALL SYMPUT('M1RECCNT', _N_);
          ELSE IF "&M" EQ 2 THEN
            CALL SYMPUT('M2RECCNT', _N_);
          ELSE IF "&M" EQ 3 THEN
            CALL SYMPUT('M3RECCNT', _N_);
          ELSE IF "&M" EQ 4 THEN
            CALL SYMPUT('M4RECCNT', _N_);
          ELSE IF "&M" EQ 5 THEN
            CALL SYMPUT('M5RECCNT', _N_);
          ELSE IF "&M" EQ 6 THEN
            CALL SYMPUT('M6RECCNT', _N_);
          ELSE IF "&M" EQ 7 THEN
            CALL SYMPUT('M7RECCNT', _N_);
          ELSE IF "&M" EQ 8 THEN
            CALL SYMPUT('M8RECCNT', _N_);
          ELSE IF "&M" EQ 9 THEN
            CALL SYMPUT('M9RECCNT', _N_);
          ELSE IF "&M" EQ 10 THEN
            CALL SYMPUT('M10RECCNT', _N_);
          ELSE IF "&M" EQ 11 THEN
            CALL SYMPUT('M11RECCNT', _N_);
          ELSE IF "&M" EQ 12 THEN
            CALL SYMPUT('M12RECCNT', _N_);
        RUN;
      %END;
    %END;
  %ELSE %IF &DTSPAN EQ ANNUAL %THEN
    %DO B=&BYR %TO &CYR;
      /* ANNUAL WILL USUALLY HAVE UP TO A 5 YEAR RANGE REQUESTED. */
      DATA RACEDATA1_&B;
        SET WORK.RACEDATA&B (DROP= VOIDFLAG MO ALLBOXES);
      RUN;
    %END;
  %ELSE
    %PUT !!! ERROR: (&THIS) UNKNOWN DTSPAN MACROVARIABLE (&DTSPAN) !!!;

  %DO C=&BYR %TO &CYR;
    %DO I=1 %TO &NUMPDS;
      DATA WORK.COUNTBOXES&I._&C (KEEP= M1-M15 T1-T15 BYEAR
                                        R1-R15 INTERVAL CNT
                                        YCNT1 YCNT2 YCNT3 YCNT4
                                        ALLNOCNT BADCNT);
        SET WORK.RACEDATA&I._&C;

        /* DON'T USE INVALID RECORDS IN THE FIRST PROC REPORT. */
        IF BADRECFLAG EQ 1 THEN
          DELETE;

        ARRAY RCKBOXES{*} $ R1-R15;
        ARRAY BINARIES{*} M1-M15;
        ARRAY TOTALS{*} T1-T15;

        DO I=1 TO HBOUND(RCKBOXES);
          IF RCKBOXES{I} = 'Y' THEN
            BINARIES{I}=1;
          ELSE IF RCKBOXES{I} = 'N' THEN
            BINARIES{I}=0;
          /* "IMPOSSIBLE" */
          ELSE
            BINARIES{I}='?';

          /* THE FINAL OBS OF EACH OF THE T'S WILL HOLD THE VALID COUNT
           * OF Y'S FOR THAT BYTE POSITION.  E.G. 7 IN T1'S FINAL OBS
           * INDICATES 7 Y'S WERE FOUND FOR WHITE IN VALID RECORDS.  IT
           * WILL NEVER BE HIGHER THAN THE MAX OBS IN THE RACEDATA&I._&C
           * DATASET.
           */
          TOTALS{I}+SUM(OF BINARIES{I});
        END;
      RUN;

      /* IF ANY DATASET IS EMPTY (ALL BADRECFLAGS DELETED), MUST INSERT A
       * DUMMY LINE TO AVOID ABEND.  HI 2003 FITS THIS PATTERN.
       *
       * PUT THE STRUCTURE OF THE DATASET INTO A NEW, EMPTY, SAS DATASET THEN
       * SET ONE RECORD TO ZEROS.
       */
      DATA WORK.ZERODUMMY;
        SET WORK.COUNTBOXES&I._&C (OBS= 0) POINT=P;
        /* EACH NUMERIC WILL AUTOMATICALLY BE FORCED TO 0 */
        BYEAR="&C";
        OUTPUT;
        STOP;
      RUN;

      %LOCAL DSID NUMOBS RC;
      %LET DSID=%SYSFUNC(OPEN(WORK.COUNTBOXES&I._&C));
      %LET NUMOBS=%SYSFUNC(ATTRN(&DSID, NOBS));
      %LET RC=%SYSFUNC(CLOSE(&DSID));

      DATA WORK.COUNTBOXES&I._&C;
        IF "&NUMOBS" NE 0 THEN
          SET WORK.COUNTBOXES&I._&C;
        ELSE
          SET WORK.ZERODUMMY;
      RUN;

      DATA WORK.FINAL&I._&C (DROP= M1-M15 R1-R15);
        SET WORK.COUNTBOXES&I._&C END=LASTOBS;
        /* TOTAL COUNT OF 'Y'S */
        IF LASTOBS THEN
          OUTPUT;
      RUN;
    %END;
  %END;

  /* NEED TO WORK WITH A SINGLE DATASET STARTING HERE.  BOTH PROC
   * REPORTS USE WORK.FINAL
   */
  /* ANNUAL */
  %IF &NUMPDS EQ 1 %THEN
    %DO;
      DATA WORK.FINAL (KEEP= T1-T15 INTERVAL BYEAR YCNT1
                             YCNT2 YCNT3 YCNT4 ALLNOCNT BADCNT CNT);
        %LOCAL SETSTR F;
        %LET SETSTR=;
        %DO D=&BYR %TO &CYR;
          %LET SETSTR=&SETSTR FINAL&NUMPDS._&D ;
        %END;
        SET &SETSTR;
      RUN;
    %END;
  /* MONTH OR QUARTER */
  %ELSE %IF &NUMPDS GT 1 %THEN
    %DO;
      /* TODO DOES THIS STILL WORK? */
      DATA WORK.FINAL (KEEP= T1-T15 INTERVAL BYEAR YCNT1
                             YCNT2 YCNT3 YCNT4 ALLNOCNT BADCNT CNT);
        %LOCAL SETSTR;
        %LET SETSTR=;
        %DO E=1 %TO &NUMPDS;
          %LET SETSTR=&SETSTR FINAL&E ;
        %END;
        SET &SETSTR;
      RUN;
    %END;
  %ELSE
    %PUT !!! ERROR: (&THIS) UNKNOWN MACROVARIABLE (&NUMPDS) !!!;

  /* NEED THE COUNT OF ALL NON-ALIAS, NON-VOID RECORDS FOR DENOMINATOR
   * IN PROC REPORT TO CALC THE "YYYY RACE AS A % OF ALL RECS"
   */
  %IF &NUMPDS EQ 1 %THEN
    %DO;
      /* OK TO IGNORE LOG WARNINGS ABOUT DENOM (MACRO RESOLUTION
       * TIMING), CAN'T FIGURE OUT HOW TO ELIM W/O BREAKING CODE.
       */
      DATA WORK.FINAL (DROP= CNT);
        SET WORK.FINAL;
        %DO F=&BYR %TO &CYR;
          /* TODO TRYING TO AVOID LOG WARNINGS, THESE DON'T WORK */
          /*** %GLOBAL DENOM; ***/
          /*** %LET DENOM =  ; ***/
          IF BYEAR EQ "&F" THEN
            CALL SYMPUT("DENOM&F", CNT);
        %END;
      RUN;
    %END;

  TITLE "&STATNAME &CYR &TYPE TIME SERIES ANALYSIS";
  TITLE2 "(USING ANNUAL PERCENTAGES)";
  TITLE3 "COUNT OF &WHO CHECKBOXES";
  TITLE4 "DATASET NAME:  &FNAME";

  /* TAKE SINGLE OBS PER INTERVAL AND MAKE A DATASET WITH ONE OBS FOR
   * EACH OF THE 15 RACES.
   */
  PROC TRANSPOSE DATA=FINAL OUT=TRANSPOSED PREFIX=INTERVAL NAME=COUNTS
                                                         PREFIX=&DTSPAN;
    ***ID INTERVAL;
    /* TODO THIS MAY BREAK MO AND/OR QTR */
    ID BYEAR;
  RUN;

  DATA TRANSPOSED;
    LENGTH COUNTS $20;
    SET TRANSPOSED;
    /* ONLY USING THESE FOR THE "CONDITION" REPORT. */
    IF COUNTS NOT IN('YCNT1', 'YCNT2', 'YCNT3', 'YCNT4', 'ALLNOCNT',
                     'BADCNT', 'INTERVAL');
  RUN;

  /* RUN THE PROC REPORTS DEPENDING ON THE INTERVAL: */

  %IF &DTSPAN EQ QUARTER %THEN
    %DO;
      PROC REPORT DATA=TRANSPOSED;
        COLUMN COUNTS QUARTER1 Q1PCT QUARTER2 Q2PCT QUARTER3 Q3PCT
               QUARTER4 Q4PCT
               ;

        DEFINE COUNTS / GROUP ORDER=DATA FORMAT=$F_CKBX. WIDTH=30
                        'VALID RECORDS ONLY'
                        ;
        DEFINE QUARTER1 / CENTER SPACING=1 FORMAT=COMMA8. 'Q1 CKBOX CNT';
        DEFINE QUARTER2 / CENTER SPACING=1 FORMAT=COMMA8. 'Q2 CKBOX CNT';
        DEFINE QUARTER3 / CENTER SPACING=1 FORMAT=COMMA8. 'Q3 CKBOX CNT';
        DEFINE QUARTER4 / CENTER SPACING=1 FORMAT=COMMA8. 'Q4 CKBOX CNT';
        DEFINE Q1PCT / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                       'Q1 RACE AS % OF ALL RECS'
                       ;
        DEFINE Q2PCT / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                       'Q2 RACE AS % OF ALL RECS'
                       ;
        DEFINE Q3PCT / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                       'Q3 RACE AS % OF ALL RECS'
                       ;
        DEFINE Q4PCT / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                       'Q4 RACE AS % OF ALL RECS'
                       ;

        RBREAK BEFORE / SKIP UL;

        COMPUTE Q1PCT;
          Q1PCT = _C2_/&Q1RECCNT;
        ENDCOMPUTE;
        COMPUTE Q2PCT;
          Q2PCT = _C4_/&Q2RECCNT;
        ENDCOMPUTE;
        COMPUTE Q3PCT;
          Q3PCT = _C6_/&Q3RECCNT;
        ENDCOMPUTE;
        COMPUTE Q4PCT;
          Q4PCT = _C8_/&Q4RECCNT;
        ENDCOMPUTE;

        RBREAK AFTER / SKIP OL SUMMARIZE;

        COMPUTE AFTER;
          COUNTS = 'TOTAL Y CHECKBOXES';
        ENDCOMP;
      RUN;
    %END;  /* QUARTER */
  %ELSE %IF &DTSPAN EQ MONTH %THEN
    %DO;
      PROC REPORT DATA=TRANSPOSED;
        COLUMN COUNTS MONTH1 M1PCT MONTH2 M2PCT MONTH3 M3PCT MONTH4
               M4PCT MONTH5 M5PCT MONTH6 M6PCT MONTH7 M7PCT MONTH8 M8PCT
               MONTH9 M9PCT MONTH10 M10PCT MONTH11 M11PCT MONTH12 M12PCT
               ;

        DEFINE COUNTS / GROUP ORDER=DATA FORMAT=$F_CKBX. WIDTH=25 ID
                        'VALID RECORDS ONLY'
                        ;
        DEFINE MONTH1 / CENTER SPACING=1 FORMAT=COMMA8. 'JAN CKBOX CNT';
        DEFINE MONTH2 / CENTER SPACING=1 FORMAT=COMMA8. 'FEB CKBOX CNT';
        DEFINE MONTH3 / CENTER SPACING=1 FORMAT=COMMA8. 'MAR CKBOX CNT';
        DEFINE MONTH4 / CENTER SPACING=1 FORMAT=COMMA8. 'APR CKBOX CNT';
        DEFINE MONTH5 / CENTER SPACING=1 FORMAT=COMMA8. 'MAY CKBOX CNT';
        DEFINE MONTH6 / CENTER SPACING=1 FORMAT=COMMA8. 'JUN CKBOX CNT';
        DEFINE MONTH7 / CENTER SPACING=1 FORMAT=COMMA8. 'JUL CKBOX CNT' PAGE;
        DEFINE MONTH8 / CENTER SPACING=1 FORMAT=COMMA8. 'AUG CKBOX CNT';
        DEFINE MONTH9 / CENTER SPACING=1 FORMAT=COMMA8. 'SEP CKBOX CNT';
        DEFINE MONTH10 / CENTER SPACING=1 FORMAT=COMMA8. 'OCT CKBOX CNT';
        DEFINE MONTH11 / CENTER SPACING=1 FORMAT=COMMA8. 'NOV CKBOX CNT';
        DEFINE MONTH12 / CENTER SPACING=1 FORMAT=COMMA8. 'DEC CKBOX CNT';

        DEFINE M1PCT / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                       'JAN RACE AS % OF ALL RECS'
                       ;
        DEFINE M2PCT / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                       'FEB RACE AS % OF ALL RECS'
                       ;
        DEFINE M3PCT / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                       'MAR RACE AS % OF ALL RECS'
                       ;
        DEFINE M4PCT / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                       'APR RACE AS % OF ALL RECS'
                       ;
        DEFINE M5PCT / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                       'MAY RACE AS % OF ALL RECS'
                       ;
        DEFINE M6PCT / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                       'JUN RACE AS % OF ALL RECS'
                       ;
        DEFINE M7PCT / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                       'JUL RACE AS % OF ALL RECS'
                       ;
        DEFINE M8PCT / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                       'AUG RACE AS % OF ALL RECS'
                       ;
        DEFINE M9PCT / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                       'SEP RACE AS % OF ALL RECS'
                       ;
        DEFINE M10PCT / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                       'OCT RACE AS % OF ALL RECS'
                       ;
        DEFINE M11PCT / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                       'NOV RACE AS % OF ALL RECS'
                       ;
        DEFINE M12PCT / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                       'DEC RACE AS % OF ALL RECS'
                       ;

        RBREAK BEFORE / SKIP UL;

        COMPUTE M1PCT;
          M1PCT = _C2_/&M1RECCNT;
        ENDCOMPUTE;
        COMPUTE M2PCT;
          M2PCT = _C4_/&M2RECCNT;
        ENDCOMPUTE;
        COMPUTE M3PCT;
          M3PCT = _C6_/&M3RECCNT;
        ENDCOMPUTE;
        COMPUTE M4PCT;
          M4PCT = _C8_/&M4RECCNT;
        ENDCOMPUTE;
        COMPUTE M5PCT;
          M5PCT = _C10_/&M5RECCNT;
        ENDCOMPUTE;
        COMPUTE M6PCT;
          M6PCT = _C12_/&M6RECCNT;
        ENDCOMPUTE;
        COMPUTE M7PCT;
          M7PCT = _C14_/&M7RECCNT;
        ENDCOMPUTE;
        COMPUTE M8PCT;
          M8PCT = _C16_/&M8RECCNT;
        ENDCOMPUTE;
        COMPUTE M9PCT;
          M9PCT = _C18_/&M9RECCNT;
        ENDCOMPUTE;
        COMPUTE M10PCT;
          M10PCT = _C20_/&M10RECCNT;
        ENDCOMPUTE;
        COMPUTE M11PCT;
          M11PCT = _C22_/&M11RECCNT;
        ENDCOMPUTE;
        COMPUTE M12PCT;
          M12PCT = _C24_/&M12RECCNT;
        ENDCOMPUTE;

        RBREAK AFTER / SKIP OL SUMMARIZE;

        COMPUTE AFTER;
          COUNTS = 'TOTAL Y CHECKBOXES';
        ENDCOMP;
      RUN;
      /* TODO GENERATE BOTTOMREPORT FOR MONTHLY RUNS */
    %END;  /* MONTH */
  %ELSE %IF &DTSPAN EQ ANNUAL %THEN
    %DO;
      PROC REPORT DATA=TRANSPOSED SPLIT='*';
        COLUMN COUNTS
        %DO G=&BYR %TO &CYR;
          ANNUAL&G PCT&G
        %END;
        %STR(;);

        DEFINE COUNTS  / GROUP ORDER=DATA FORMAT=$F_CKBX. WIDTH=30 " ";
        %DO H=&BYR %TO &CYR;
          DEFINE ANNUAL&H / CENTER SPACING=1 FORMAT=COMMA8. 
                            "&H*CKBOX*'Y' CNT"
                            STYLE={CELLWIDTH=80PT JUST=RIGHT}
                            ;
          DEFINE PCT&H    / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                            "&H*'Y' CNT*AS % OF*ALL RECS"
                            STYLE={CELLWIDTH=80PT JUST=RIGHT}
                            ;
        %END;

        RBREAK BEFORE / SKIP UL;

        /* NEED TO USE _C2_ _C4_ _C6_ ... TO GET THE NUMERATOR (THE "YYYY
         * CKBOX CNT")
         */
        %LOCAL EVEN;
        %LET EVEN=0;
        %DO J=&BYR %TO &CYR;
          %LET EVEN=%EVAL(&EVEN+2);
          COMPUTE PCT&J;
            PCT&J = _C&EVEN._/&DENOM&&J;
          ENDCOMPUTE;
        %END;

        RBREAK AFTER / SKIP OL SUMMARIZE;

        COMPUTE AFTER;
          COUNTS = 'TOTAL Y CHECKBOXES';
          LINE ' ';
          LINE 'NOTE: VALID RECORDS ONLY';
          LINE 'TOTAL PERCENTAGE WILL NOT NECESSARILY SUM TO 100%';
        ENDCOMP;
      RUN;


      /* BEGIN BOTTOM "CONDITION" RPT: */
      DATA BOTTOMRPT (KEEP= BYEAR YCNT1 YCNT2 YCNT3 YCNT4 ALLNOCNT
                            BADCNT);
        SET FINAL;
      RUN;

      PROC TRANSPOSE DATA=BOTTOMRPT OUT=TRANSPOSED2 NAME=CONDIT
                          PREFIX=&DTSPAN;
        ID BYEAR;
      RUN;

      /* DON'T PAGE BREAK BETWEEN REPORTS */
      ***OPTIONS FORMDLIM='.';

      PROC REPORT DATA=TRANSPOSED2 SPLIT='*';
        COLUMN CONDIT
        %DO K=&BYR %TO &CYR;
          ANNUAL&K PCT&K
        %END;
        %STR(;);

        DEFINE CONDIT  / GROUP ORDER=DATA WIDTH=30 FORMAT=$F_COND. ' ';
        %DO L=&BYR %TO &CYR;
          DEFINE ANNUAL&L / CENTER SPACING=1 FORMAT=COMMA8.
                            "&L*REC*CNT"
                            STYLE={CELLWIDTH=80PT JUST=RIGHT}
                            ;
          DEFINE PCT&L    / COMPUTED CENTER SPACING=1 FORMAT=PERCENT8.1
                            "&L CNT*AS % OF*ALL RECS"
                            STYLE={CELLWIDTH=80PT JUST=RIGHT}
                            ;
        %END;

        RBREAK BEFORE / SKIP UL;

        %LOCAL EVEN2;
        %LET EVEN2=0;
        %DO M=&BYR %TO &CYR;
          %LET EVEN2=%EVAL(&EVEN2+2);
          COMPUTE PCT&M;
            PCT&M = _C&EVEN2._/&DENOM&&M;
          ENDCOMPUTE;
        %END;

        RBREAK AFTER / SKIP OL SUMMARIZE;

        COMPUTE AFTER;
          COUNTS = 'TOTAL NUMBER OF RECORDS';
        ENDCOMP;
      RUN;
      /* DO PAGE BREAK BETWEEN CALLS TO THIS MACRO OR WHEN DONE */
      /***OPTIONS FORMDLIM='';***/   /* ODS DOESN'T RESPOND TO THIS */
    %END;  /* ANNUAL */
  %ELSE
    %PUT !!! ERROR: (&THIS) UNKNOWN DTSPAN MACROVARIABLE (&DTSPAN) !!!;
%MEND RUNMULTI;
