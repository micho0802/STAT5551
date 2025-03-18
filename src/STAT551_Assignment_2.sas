/* Asignment 2 */

/* 2a */
/* Upload data */
PROC IMPORT DATAFILE='/home/u64145784/Nloss.dat'
    OUT=Nloss_data
    DBMS=dlm
    REPLACE;
    DELIMITER=' ';
    GETNAMES=NO;
RUN;

/* Name the dataset */
DATA Nloss_data;
    SET Nloss_data;
    RENAME VAR1=UN_and_U VAR2=Nloss;
RUN;

/* Test for a difference in variance with alpha = .05 */
PROC TTEST DATA=Nloss_data ALPHA=0.05;
    CLASS UN_and_U;
    VAR Nloss;
RUN;

/* 2b */
/* Normality assumption */
PROC UNIVARIATE DATA=Nloss_data;
    BY UN_and_U;
    HISTOGRAM/NORMAL;
RUN;

/* 2c */
/* Run the code on 2a */

/* 2e */
/* Hypothesis test for differences in mean with alpha = 0.05 */
PROC TTEST DATA=Nloss_data Side=2 ALPHA=0.05;
    CLASS UN_and_U;
    VAR Nloss;
RUN;

/* 2f */
/* Hypothesis test for differences in mean greater than 2 */
PROC TTEST DATA=Nloss_data SIDE=U H0=2 ALPHA=0.05;
    CLASS UN_and_U;
    VAR Nloss;
RUN;


/* 3a */
/* Determine the critical value */
DATA F_critical;
    F_8_15_0_05 = FINV(0.95, 8, 15);
    F_6_10_0_95 = FINV(0.95, 6, 10);
RUN;

/* 3b */
/* Compute F1 and F2 for the middle 90% probability */
DATA F_middle;
    F1 = FINV(0.05, 5, 7);
    F2 = FINV(0.95, 5, 6);
RUN;

/* 3c */
/* Compute P(X > 10) for F_6_9 */
DATA F_prob;
    P_X_greater_10 = 1 - CDF("F", 10, 6, 9);
RUN;

/* 4a */
data bacteria;
    input RoomType BacteriaCount;
    datalines;
     1 11.9
     1 9.0
     1 10.2
     1 12.3
     1 11.1
     1 11.5
     1 11.2
     1 10.7
     2 6.4
     2 7.3
     2 16.4
     2 11.6
     2 8.4
     2 1.2
     2 4.3
     2 13.7
     2 12.5
;
run;

/* 4b */
/* Point estimate */
PROC TTEST DATA=bacteria;
    CLASS RoomType;
    VAR BacteriaCount;
RUN;

/* 4c */
/* Normality assumption */
PROC UNIVARIATE DATA=bacteria;
    BY RoomType;
    HISTOGRAM/NORMAL;
RUN;
/* Equality of variance */
/* Run 4b */

/* 4d */
PROC TTEST DATA=bacteria ALPHA=0.01;
    CLASS RoomType;
    VAR BacteriaCount;
RUN;

/* 4f */
PROC TTEST DATA=bacteria ALPHA=0.01 SIDES=U;
   CLASS RoomType;
   VAR BacteriaCount;
RUN;





