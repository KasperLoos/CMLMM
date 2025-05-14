LIBNAME mydata "/home/u64042931/test/multilevel";

data MYDATA.ADLupdate;
    set MYDATA.ADL;
    
    /* Create new binary variable */
    if ADL <= 19  then ADL_binary = 1;
    else ADL_binary = 0;
    
    /* Alternative syntax that does the same thing */
    /* ADL_binary = (ADL_score <= 22); */
run;

proc means data=MYDATA.ADLupdate;
	var adl;
run;

proc print data=MYDATA.ADLupdate;
run;

**check frequencies to avoid quasi seperation**;
proc freq data=MYDATA.ADLupdate;
  tables NEURO*ADL_binary / nocol nopercent;
run;

proc glimmix data=MYDATA.ADLupdate ;
class NEURO housing ID;
model ADL_binary(event='1') = logtime NEURO housing age NEURO*logtime / dist=binomial solution;
random intercept logtime / type=un subject=ID solution;
estimate 'Test Random Slopes' NEURO*logtime 1 -1; /* Tests if slope variances = 0 */
run;

**age is not significant**;

proc glimmix data=MYDATA.ADLupdate;
class NEURO housing ID;
model ADL_binary(event='1') = logtime NEURO housing NEURO*logtime / dist=binomial solution;
random intercept logtime / type=un subject=ID solution;
estimate 'Test Random Slopes' NEURO*logtime 1 -1; /* Tests if slope variances = 0 */
run;

/* slopes are not significant different from each other */

proc glimmix data=MYDATA.ADLupdate ;
class NEURO housing ID;
model ADL_binary (event = '1') = logtime neuro housing NEURO*logtime / dist=binomial solution;
random intercept / subject= ID;
estimate 'Test Random Slopes' NEURO*logtime 1 -1;
run;

/*estimate is still not significant --> no time effect on NEURO. Leave the interaction out.
Final model: */

proc glimmix data=MYDATA.ADLupdate ;
class NEURO housing ID;
model ADL_binary (event = '1') = logtime neuro housing / dist=binomial solution;
random intercept / subject= ID;
run;

**to estimate and plot the marginal average evolutions, use the simplest model**;
proc glimmix data=MYDATA.ADLupdate;
class NEURO housing ID;
model ADL_binary (event = '1') = logtime neuro neuro*logtime  / dist=binomial solution;
random intercept / subject= ID solution;
run;

data MYDATA.ADLupdate;
do NEURO= 0 to 1 by 1;
   do subject=1 to 1000 by 1;
    	 b=sqrt(1.3708)*rannor(-1);
     		do logtime=-10 to 10 by 0.1;
    			if NEURO=0 then y=exp(-0.2812 + 1.4819 + b + (-0.3535 + 0.04722)*logtime)/(1+exp(-0.2812 + 1.4819 + b + (-0.3535 + 0.04722)*logtime));
               else y=exp(-0.2812 + b -0.3535*logtime)/(1+exp(-0.2812 + b -0.3535*logtime ));
          output;
    end;
  end;
end;

proc sort data= MYDATA.ADLupdate;
by logtime NEURO;
run;

ods exclude summary;
proc means data=MYDATA.ADLupdate;
var y;
by logtime NEURO;
output out=out;
run;
ods exclude none;

proc gplot data= out;
plot y*logtime = NEURO / haxis= axis1 vaxis=axis2 legend=legend1;
axis1 label=(h=2 'Time') value=(h=1.5) order=(-10 to 10 by 0.5) minor=none;
axis2 label=(h=2 A=90 'P(y=1)') value=(h=1.5) order=(0 to 1 by 0.1) minor=none;
legend1 label=(h= 1.5 'Neuro:') value=(h=1.5 '0' '1');
title h=2.5 'neuro';
where _stat_='MEAN';
run;quit;run;

**the same but now focussed on the area of interest: logtime between 0 and 3**;

data MYDATA.ADLupdate;
do NEURO= 0 to 1 by 1;
   do subject=1 to 1000 by 1;
    	 b=sqrt(1.3708)*rannor(-1);
     		do logtime=-0 to 3 by 0.1;
    			if NEURO=0 then y=exp(-0.2812 + 1.4819 + b + (-0.3535 + 0.04722)*logtime)/(1+exp(-0.2812 + 1.4819 + b + (-0.3535 + 0.04722)*logtime));
               else y=exp(-0.2812 + b -0.3535*logtime)/(1+exp(-0.3950 + b -0.3535*logtime ));
          output;
    end;
  end;
end;

proc sort data= MYDATA.ADLupdate;
by logtime NEURO;
run;

proc means data=MYDATA.ADLupdate;
var y;
by logtime NEURO;
output out=out;
run;

proc gplot data= out;
plot y*logtime = NEURO / haxis= axis1 vaxis=axis2 legend=legend1;
axis1 label=(h=2 'Time') value=(h=1.5) order=(0 to 3 by 0.1) minor=none;
axis2 label=(h=2 A=90 'P(y=1)') value=(h=1.5) order=(0 to 1 by 0.1) minor=none;
legend1 label=(h= 1.5 'Neuro:') value=(h=1.5 '0' '1');
title h=2.5 'neuro';
where _stat_='MEAN';
run;quit;run;

**no difference in slope is clearly visible**;