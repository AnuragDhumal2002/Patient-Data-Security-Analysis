libname Patient xlsx "/home/u64061897/Clinical Data/patient_data_security_20.xlsx";

/* DATA IMPORTING (Patient records with security-related attributes) */

proc import datafile="/home/u64061897/Clinical Data/patient_data_security_20.xlsx"
    out=security_data dbms=xlsx replace;
    getnames=yes;
run;
title "Displaying First 5 Records of Security Data";
proc print data=security_data (obs=5);
run;

/* DATA CLEANING & VALIDATION*/
ods noproctitle;
title "Summary Statistics of Security Data";
proc means data=security_data n nmiss mean std min max;
run;
title;
ods proctitle;
proc sort data=security_data nodupkey;
    by Patient_ID Access_Timestamp;
run;
ods noproctitle;
title "Frequency Distribution of Unusual Access and Accessed Data";
proc freq data=security_data;
    tables Unusual_Access Access_Location Data_Accessed;
run;
title;
ods proctitle;
/* SECURITY RISK ANALYSIS */

data high_risk;
    set security_data;
    if Failed_Login_Attempts > 3 then Risk_Level = "High";
    else if Failed_Login_Attempts > 1 then Risk_Level = "Medium";
    else Risk_Level = "Low";
run;
ods noproctitle;
title "Distribution of Patients by Risk Level";
proc freq data=high_risk;
    tables Risk_Level;
run;
title;
ods proctitle;

/* DATA VISULIZATION */

proc sgplot data=security_data;
    histogram Failed_Login_Attempts;
    density Failed_Login_Attempts;
    title "Distribution of Failed Login Attempts";
run;


proc sgplot data=security_data;
    vbar Access_Location / group=Unusual_Access groupdisplay=cluster;
    title "Unusual Access by Location";
run;

/* GENERATE SECURITY REPORT */

ods pdf file="/home/u64061897/security_report.pdf";
ods noproctitle;
title "Security Risk Levels Report";
proc freq data=high_risk;
    tables Risk_Level;
run;
title;
ods proctitle;
ods noproctitle;
title "Unusual Access Events Report";
proc freq data=security_data;
    tables Unusual_Access;
run;
title;
ods proctitle;
ods pdf close;