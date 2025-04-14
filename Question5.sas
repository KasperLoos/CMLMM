LIBNAME mydata "/home/u64042931/test/multilevel";


proc mixed data=MYDATA.ADL;
	class neuro housing;
	model adl = logtime neuro housing age logtime*housing age*logtime/solution;
	random intercept logtime /subject=ID solution;
    contrast 'Old (80) vs Young (60) on ADL slope'
         logtime 0 
         age*logtime 20;
run;



**compare the slope of a 60 ears old with a 80 years old*;
proc mixed data=MYDATA.ADL;
	class neuro housing;
	model adl = logtime neuro housing age age*logtime/solution;
	random intercept logtime /subject=ID solution;
    contrast 'Old (80) vs Young (60) on ADL slope'
         logtime 0 
         age*logtime 20;
run;

* split data set in 'younger' and 'older' groups and compare slopes*;
data MYDATA.ADL;
    set MYDATA.ADL;
    if 65 <= age < 80 then agegrp = 1;  * younger old;
    else if 80 <= age <= 95 then agegrp = 2;  * older old;
run;

proc mixed data=MYDATA.ADL;
    class neuro housing agegrp;
    model adl = logtime neuro housing agegrp agegrp*logtime / solution;
    random intercept logtime / subject=ID solution;

    contrast 'ADL slope: age 80-95 vs 65-80' 
             logtime 0 
             agegrp*logtime 1 -1;
run;

*compare slopes of different housings with each other*;
proc mixed data=MYDATA.ADL;
    class neuro housing;
    model adl = logtime neuro housing age logtime*housing / solution;
    random intercept logtime / subject=ID solution;
    contrast 'Slope: Housing 1 vs 3' 
         logtime 0 
         logtime*housing 1 0 -1;
    contrast 'Slope: Housing 1 vs 2' 
         logtime 0 
         logtime*housing 1 -1 0;
    contrast 'Slope: Housing 2 vs 3' 
         logtime 0 
         logtime*housing 0 1 -1;
run;

proc sql;
    select id, count(distinct neuro) as unique_values
    from MYDATA.adl
    group by id
    having unique_values > 1;
quit; *no they are not;
