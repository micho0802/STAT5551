/*1c.*/
DATA p_value;
    t_stat = 2.769;
    df = 9;
    p_value = 1 - PROBT(t_stat, df); /* One-tailed test */
    PUT p_value=;
RUN;


/*2a.*/
/*Upload data*/
PROC IMPORT DATAFILE='/home/u64145784/HCL_data.txt'
    OUT=infection_rate
    DBMS=dlm
    REPLACE;
    DELIMITER=' ';
    GETNAMES=NO;
RUN;

/*Name the dataset*/
DATA infection_rate;
    SET infection_rate;
    RENAME VAR1=rate;
RUN;

/*90% CI for mu*/ 
PROC MEANS DATA=infection_rate MEAN STDDEV CLM ALPHA=0.10;
    VAR rate;
RUN;

/*2b.*/
PROC TTEST DATA=infection_rate H0=2.5 ALPHA=0.01 SIDES=L;
    VAR rate;
RUN;


/*3a.*/
/*Upload data*/
PROC IMPORT DATAFILE='/home/u64145784/Earlenth.dat'
    OUT=length_ear_corns
    DBMS=dlm
    REPLACE;
    DELIMITER=' ';
    GETNAMES=NO;
RUN;

/*Name the dataset*/
DATA length_ear_corns;
    SET length_ear_corns;
    RENAME VAR1=length;
RUN;
    
/*95% CI for mu*/ 
ods select BasicIntervals;
PROC UNIVARIATE DATA=length_ear_corns CIBASIC(ALPHA=0.05);
   VAR length;
RUN;

/* 3b: Chi-Square test for variance */
PROC IML;
    /* Load data */
    USE length_ear_corns;
    READ ALL VAR {length} into x;
    n = nrow(x);
    s2 = VAR(x); /* Sample variance */
    sigma0 = 7.5; /* Hypothesized variance */
    df = n - 1;

    /* Compute Chi-Square test statistic */
    chi_sq_stat = df * s2 / sigma0;

    /* Compute p-value for one-tailed test (variance > 7.5) */
    p_value = 1 - CDF("CHISQ", chi_sq_stat, df);

    /* Print results */
    PRINT n s2 chi_sq_stat p_value;
QUIT;


/* 3d: Compute Power when actual variance = 9 */
PROC IML;
    n = 15;          /* Sample size */
    df = n - 1;
    alpha = 0.01;    /* Significance level */
    sigma0 = 7.5;    /* Null hypothesis variance */
    sigma_a = 9;     /* Actual variance (alternative) */

    /* Noncentrality parameter for the noncentral Chi-Square distribution */
    lambda = df * sigma_a / sigma0;

    /* Critical value for the Chi-Square test */
    crit_value = QUANTILE("CHISQ", 1 - alpha, df);

    /* Power calculation */
    power = 1 - CDF("CHISQ", crit_value, df, lambda);

    /* Print power */
    PRINT power;
QUIT;

/*to obtain chi-square cutoff values, following commands can be used.*/
data d1;
*Lower_bound=cinv(&alpha/2,df);
*Upper_bound=cinv(1-&alpha/2,df);
Lower_bound=cinv(0.025,14);
Upper_bound=cinv(0.975,14);
run;
proc print data=d1;
run;


