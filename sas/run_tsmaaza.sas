//BQH0EFGH JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0'
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN    DD *

 /********DEBUG AVOID GETREG***********/
%LET IN2004='DWJ2.NHX0401.MORMERZ';
%LET NSPAN=1;
%LET YEAR=2004;
%LET YR=04;
%LET STATE=NH;
%LET STATNAME=NEW HAMPSHIRE;
%LET FNAME=DWJ2.NHX0401.MORMERZ;
 /********DEBUG AVOID GETREG***********/

 /******AVOID PREMAIL******/
LIBNAME NEWTEMP 'DWJ2.TEMPLATE.LIB' DISP=SHR;
OPTIONS NOCAPS;
FILENAME OUTPDF FTP
  "temp.pdf"
  CD="/home/bqh0/public_html"
  HOST='158.111.250.31'
  USER="bqh0"
  PASS='dAebrpt5'
  RECFM=S
  DEBUG;

ODS LISTING CLOSE;

OPTIONS ORIENTATION=LANDSCAPE;
ODS NOPTITLE;
ODS PATH SASHELP.TMPLMST (READ) NEWTEMP.TEMPLAT (READ);

 /* Must edit on MF (after upload) to '^' */
ODS ESCAPECHAR='�';
ODS PDF FILE=OUTPDF STYLE=STYLES.TEST1 NOTOC;
 /******AVOID PREMAIL*****/

%include 'dwj2.vscp.pgmlib(tsmaaza)';
