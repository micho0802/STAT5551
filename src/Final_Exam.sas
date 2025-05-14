/* 1c (alpha = 0.05) and 1d (alpha = 0.01)*/
data critical_value;
    alpha = 0.01;
    df = 24;
    *t_critical = tinv(1 - alpha, df);
    t_critical = tinv(1 - alpha/2, df); /* two-tailed: use 1 - alpha/2 */
    put t_critical=;
run;


/* 2 */
/* Import the data */
data soda;
input machine$ weight;
datalines;
A 12.05
A 12.07 
A 12.04 
A 12.04 
A 11.99
B 11.98 
B 12.05 
B 12.06 
B 12.02 
B 11.99
C 12.04 
C 12.03 
C 12.03 
C 12.00 
C 11.96
D 12.00 
D 11.97 
D 11.98 
D 11.99 
D 11.96
;
proc print data = soda;
run;

/* 2c */

proc glm data = soda;
class machine;
model weight=machine;
means machine/ hovtest=levene(type=abs);
run;

/* 2d */

/* Normality assumption */
proc glm data=soda;
    class machine;
    model weight = machine;
    output out=anova_out r=resid;
run;

proc univariate data=anova_out normal;
    var resid;
run;

/* 2e */
/*Pairwise comparisions*/
proc glm data=soda;
class machine;
model weight=machine;
*lsmeans machine/ pdiff stderr; /*General t-test*/
lsmeans machine/ pdiff=all adjust=TUKEY;
run;

/* 3 */
/* Import the data */
data score_data;
input school score;
datalines;
1 500
1 450
1 505
1 404
1 555
1 567
1 588
1 577
1 566
1 644
1 511
1 522
1 543
1 578
2 355
2 388
2 440
2 600
2 510
2 501
2 502
2 489
2 499
2 489
2 515
2 520
2 520
2 480
2 427
2 435

;
proc print data = score_data;
run;

/* 3b */
/* Check Normality within each group */
proc univariate data=score_data normal;
    class school;
    var score;
run;


/* Perform t-test and variance equality test */
proc ttest data=score_data sides=L h0=0;
    class school;
    var score;
run;


/* 3d */
proc ttest data=score_data sides=U h0=0 alpha=0.05;
    class school;
    var score;
run;

/* 4e */
data f_critical;
    alpha = 0.05;
    df1 = 2;
    df2 = 22;
    f_crit = finv(1 - alpha, df1, df2);  /* One-way upper tail */
    put f_crit=;
run;