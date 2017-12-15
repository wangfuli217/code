//BQH0FRAK JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0,ALTPRINT=OLST,
//                                                ALTLOG=OLOG'
//OLST     DD DISP=SHR,DSN=BQH0.INC.SASLST WAIT=10
//OLOG     DD DISP=SHR,DSN=BQH0.INC.SASLOG WAIT=10
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN    DD *

options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ckrawfiles.sas
  *
  *  Summary: Iterate the latest merge (text) files after creating a giant
  *           work.tmp that holds all lines from all merge files.
  *
  *           Use loopallfiles.sas if you don't know exactly which BF19...
  *           files to loop and want to use logic to parse Register.
  *
  *           See also loopallmvds.sas to compare results with this output.
  *
  *           ___CHECK US TOTALS___
  *
  *           See ckallstatefiles.sas for pedantic version.
  *
  *  Created: Wed 25 Feb 2004 09:56:04 (Bob Heckel)
  * Modified: Thu 05 Aug 2004 11:35:02 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOthreads NOcenter NOreplace;

***options FMTSEARCH=(FMTLIB); 
***libname FMTLIB 'DWJ2.NAT2003R.FMTLIB' DISP=SHR WAIT=3;

data tmp;
  infile cards MISSOVER;
  input fn $ 1-50;
  /* EDIT */
  cards;
BF19.MIX0306.FETMERZ
BF19.WAX0302.FETMERZ
  ;
run;

data tmp;
  set tmp;
  length currinfile $50;

  infile TMPIN FILEVAR=fn FILENAME=currinfile TRUNCOVER END=done; 

  do while ( not done );
    /* EDIT */
    input @428 myvar $CHAR4.;
    output;
  end;
run;

data tmp;
  set tmp;
  /* EDIT */
  ***myvar2=put(myvar, $V007A.);
  ***myvar2=myvar;
run;

proc freq data=tmp;
  ***tables myvar2 / NOCUM;
  tables myvar / NOCUM;
run;

 /*
BF19.MIX0306.FETMERZ
BF19.WAX0302.FETMERZ

BF19.ALX0305.FETMER
BF19.AKX0316.FETMER
BF19.ASX0301.FETMER
BF19.AZX0305.FETMER
BF19.ARX0305.FETMER
BF19.COX0302.FETMER
BF19.CTX0305.FETMER
BF19.DEX0308.FETMER
BF19.DCX0308.FETMER
BF19.FLX0312.FETMER
BF19.GAX0330.FETMER
BF19.GUX0302.FETMER
BF19.HIX0305.FETMER
BF19.IDX0328.FETMER
BF19.ILX0307.FETMER
BF19.INX0305.FETMER
BF19.IAX0315.FETMER
BF19.KSX0342.FETMER
BF19.KYX0307.FETMER
BF19.LAX0355.FETMER
BF19.MEX0302.FETMER
BF19.MDX0308.FETMER
BF19.MAX0313.FETMER
BF19.MNX0307.FETMER
BF19.MSX0304.FETMER
BF19.MOX0366.FETMER
BF19.MTX0304.FETMER
BF19.NEX0305.FETMER
BF19.NHX0307.FETMER
BF19.NJX0308.FETMER
BF19.NMX0303.FETMER
BF19.NCX0335.FETMER
BF19.NDX0304.FETMER
BF19.MPX0301.FETMER
BF19.OHX0314.FETMER
BF19.OKX0303.FETMER
BF19.ORX0341.FETMER
BF19.PAX0304.FETMER
BF19.PRX0304.FETMER
BF19.RIX0314.FETMER
BF19.SCX0314.FETMER
BF19.SDX0303.FETMER
BF19.TNX0306.FETMER
BF19.UTX0303.FETMER
BF19.VTX0303.FETMER
BF19.VAX0307.FETMER
BF19.VIX0304.FETMER
BF19.WVX0314.FETMER
BF19.WIX0305.FETMER
BF19.WYX0302.FETMER

BF19.AKX0323.NATMER
BF19.ALX0337.NATMER
BF19.ARX0361.NATMER
BF19.ASX0303.NATMER
BF19.AZX0382.NATMER
BF19.CAX0331.NATMER
BF19.COX0329.NATMER1
BF19.CTX0330.NATMER
BF19.DCX0328.NATMER
BF19.DEX0336.NATMER
BF19.FLX0341.NATMER
BF19.GAX03104.NATMER
BF19.GUX0315.NATMER
BF19.HIX0362.NATMER
BF19.IAX0341.NATMER
BF19.IDX0334.NATMER
BF19.ILX0317.NATMER
BF19.INX0354.NATMER
BF19.KSX0358.NATMER5
BF19.KYX0322.NATMER
BF19.LAX0370.NATMER
BF19.MAX0340.NATMER1
BF19.MDX0343.NATMER
BF19.MEX0358.NATMER
BF19.MIX03151.NATMER
BF19.MNX0330.NATMER2
BF19.MOX0373.NATMER
BF19.MPX0303.NATMER
BF19.MSX0319.NATMER
BF19.MTX0316.NATMER
BF19.NCX0337.NATMER
BF19.NDX0352.NATMER
BF19.NEX0351.NATMER
BF19.NHX0391.NATMER
BF19.NJX0330.NATMER
BF19.NMX0365.NATMER
BF19.NVX0316.NATMER
BF19.NYX03116.NATMER
BF19.OHX0355.NATMER
BF19.OKX0317.NATMER
BF19.ORX0369.NATMER
BF19.PRX0320.NATMER
BF19.RIX0317.NATMER
BF19.SCX0346.NATMER
BF19.SDX0374.NATMER
BF19.TNX0333.NATMER
BF19.TXX03106.NATMER
BF19.UTX0352.NATMER
BF19.VAX0326.NATMER
BF19.VIX0324.NATMER
BF19.VTX0327.NATMER
BF19.WIX0325.NATMER1
BF19.WVX0357.NATMER
BF19.WYX0332.NATMER
BF19.YCX0315.NATMER
  */
