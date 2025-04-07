/*2h.*/
/* Compute critical F-value at alpha = 0.05, df1 = 2, df2 = 9 */
data CriticalF;
   alpha = 0.05;
   df_num = 2;    /* numerator degrees of freedom */
   df_den = 9;    /* denominator degrees of freedom */
   
   /* SAS computes critical F-value using quantile function */
   F_critical = finv(1 - alpha, df_num, df_den);
   
   proc print data=CriticalF;
      var alpha df_num df_den F_critical;
      title 'Critical F-value for alpha=0.05 and df1=2, df2=9';
   run;
   
/*3a.*/
data bulk_density;
input treatment $ solid_bulk_density;
datalines;
continous_grazing 1.83
continous_grazing 2.01
continous_grazing 1.94
continous_grazing 1.79
1_week_rest 1.74
1_week_rest 1.68
1_week_rest 1.85
1_week_rest 1.72
2_week_rest 1.53
2_week_rest 1.60
2_week_rest 1.56
2_week_rest 1.62
;
proc print data=bulk_density;
run;
/* ANOVA table*/
proc glm data=bulk_density alpha=0.05;
class treatment;
model solid_bulk_density = treatment;
means treatment/ hovtest=levene(type=abs);
run;

/*3b.*/
/*Residual Analysis*/
proc glm data=bulk_density;
class treatment;
model solid_bulk_density=treatment;
OUTPUT OUT=CHECK P=YHAT R=RESIDUAL; 
means packageType;
RUN;

PROC GPLOT DATA=CHECK;
PLOT RESIDUAL*YHAT/VREF=0;
TITLE �Residuals vs Fitted Values Plot�;

/*Checking the normality assumption*/
PROC UNIVARIATE DATA=CHECK NOPRINT;
PROBPLOT RESIDUAL/NORMAL(MU=EST SIGMA=EST);
TITLE �Normal Probability Plot of the Residuals�;
RUN;

proc univariate data=CHECK;
   histogram / NORMAL;
qqplot RESIDUAL/NORMAL(MU=EST SIGMA=EST) SQUARE;; 
run;


/*3c.*/
/*Conclusion*/

/*3d.*/
/*Pairwise comparisions*/
proc glm data=bulk_density;
class treatment;
model solid_bulk_density=treatment;
lsmeans treament/ pdiff stderr;
lsmeans treatment/ pdiff=all adjust=TUKEY;
run;


/*4d.*/
data CriticalF;
   alpha = 0.05;
   df_num = 3;    /* numerator degrees of freedom */
   df_den = 20;    /* denominator degrees of freedom */
   
   /* SAS computes critical F-value using quantile function */
   F_critical = finv(1 - alpha, df_num, df_den);
   
   proc print data=CriticalF;
      var alpha df_num df_den F_critical;
      title 'Critical F-value for alpha=0.05 and df1=2, df2=9';
   run;
