
%let db=sdev581;
%let usr=ks;
%let pw=ev123dba;

 /* Implicit pass-through */
libname ORA oracle user=&usr password=&pw path=&db;

options NOlabel;
proc sql NOprint;
  select name into :VARNAMES separated by ','
  from dictionary.columns
  where libname eq 'ORA' and memname eq 'USER_ROLE2'
  ;
quit;
%put _all_;

data us1authlogins;
  set ORA.user_role2;
  if user_status='A' and user_domain in:('us1_auth','US1_AUTH') then do;
    user_domain = 'WMSERVICE';
    updated_by_patron_id='rsh86800';
    output;
  end;
run;

proc sql;
/***  insert into ORA.user_role2 (user_nm, user_patron_id, user_domain, user_role, user_status, prod_op_ind, updated_by_patron_id)***/
  insert into ORA.user_role2 (&VARNAMES)
  select * 
  from us1authlogins
  ;
quit;
proc print data=_LAST_(obs=max) width=minimum; run;

