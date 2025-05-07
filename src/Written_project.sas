/* Data import and manipulated */

/* Step 1: Import the sequences CSV */
proc import datafile="/home/u64145784/train_sequences.csv"
    out=train_sequences
    dbms=csv
    replace;
    getnames=yes;
run;

/* Step 2: Import the labels CSV */
proc import datafile="/home/u64145784/train_labels.csv"
    out=train_labels
    dbms=csv
    replace;
    getnames=yes;
run;

data train_labels;
    set train_labels;
    target_id = scan(ID, 1, '_');
    chain = scan(ID, 2, '_');
    full_id = catx('_', target_id, chain);
run;

/* Step 4: Merge and filter */
proc sql;
    create table filtered_data as
    select 
        a.target_id,
        a.sequence,
        b.x_1,
        b.y_1,
        b.z_1
    from train_sequences as a
    inner join train_labels as b
    on a.target_id = b.full_id
    where a.target_id in ("1SCL_A", "1RNK_A");
quit;

/* Step 5: Count how many coordinate entries per target_id */
proc sql;
    create table counts as
    select target_id, count(*) as total_count
    from filtered_data
    group by target_id;
quit;

/* Step 6: Extract the first record per target_id */
proc sort data=filtered_data out=sorted_data;
    by target_id;
run;

data summary_two_rows;
    set sorted_data;
    by target_id;
    if first.target_id;
run;

/* Step 7: Merge count info */
/* Can include a.sequence to show the sequence column */
proc sql;
    create table final_summary as
    select 
        a.target_id,
        a.x_1,
        a.y_1,
        a.z_1,
        b.total_count
    from summary_two_rows as a
    inner join counts as b
    on a.target_id = b.target_id;
quit;

/* Step 8: Display */
proc print data=final_summary label;
    title "Summary: 1 Row per Target ID with Total Count";
run;

/* Step 9: Drop the sequence column from filtered_data */
data full_no_sequence;
    set filtered_data(drop=sequence);
run;

/* Step 10: Print or export the full data without sequence */
proc print data=full_no_sequence;
    title "Full Coordinate Data for 1SCL_A and 1RNK_A (No Sequence)";
run;


/* Step 11: Sort before assigning index */
proc sort data=full_no_sequence out=sorted_data;
    by target_id;
run;

/* Step 12: Add position index */
data indexed_data;
    set sorted_data;
    by target_id;
    retain Position;
    if first.target_id then Position = 1;
    else Position + 1;
run;

/* Step 13: Encode target_id as numeric */
data encoded_data;
    set indexed_data;
    if target_id = "1SCL_A" then target_id_num = 1;
    else if target_id = "1RNK_A" then target_id_num = 2;
run;

/* Step 14: Reshape to long format, drop Position */
data final_formatted;
    set encoded_data;
    
    CoordType = 1; Value = x_1; output;
    CoordType = 2; Value = y_1; output;
    CoordType = 3; Value = z_1; output;

    keep target_id_num CoordType Value;
    rename target_id_num = target_id;
run;

/* Step 15: Print the final output */
proc print data=final_formatted label;
    title "Final RNA Data: Numeric target_id and CoordType, No Position";
run;


proc print data=final_formatted label;
    title "Formatted RNA Data (target_id as numeric)";
run;

/* ANOVA */

/*############# Homogeneous error variance model################*/

proc mixed data=final_formatted;
class target_id CoordType;
model value = target_id CoordType target_id*CoordType;
run;

/*############# Checking the equal variance assumption (Levene's Test) ################*/

/* Create a combined treatment variable */
data final_formatted_1;
    set final_formatted;
    target_idCoordType = catx('', target_id, CoordType); /* Combines Height and Width into one string */
run;

proc print data=final_formatted_1;
run;

proc glm data=final_formatted_1;
class target_idCoordType;
model value = target_idCoordType;
means target_idCoordType / hovtest=levene(type=abs);
run;

/*############# Heterogeneous error variance model################*/

/* using Satterthwaite approximation for degrees of freedom */
proc mixed data=final_formatted_1;
class target_idCoordType;
model value = target_idCoordType / ddfm=satterthwaite;
repeated / group=target_idCoordType;
run;

/*############# Checking the normality assumption ################*/

proc mixed data=final_formatted_1;
class target_idCoordType;
model value = target_idCoordType / ddfm=satterthwaite outp=diagnostics;
repeated / group=target_idCoordType;
run;

proc univariate data=diagnostics;
   histogram / normal;
   qqplot Resid / normal(mu=est sigma=est) square; 
run;

/*############# Effects model: using SATTERTHWAITE approximation for df ################*/

proc mixed data=bread1;
class Height Width HeightWidth;
model Sales = Height Width Height*Width / ddfm=satterthwaite;
repeated / group=HeightWidth;
run;

/* Two ANOVA */
/* Step 2: Two-Way ANOVA using PROC GLM */
proc glm data=final_formatted plots=diagnostics;
   class target_id CoordType;
   model value = target_id CoordType target_id*CoordType;
   means target_id CoordType target_id*CoordType / tukey cldiff; /* Optional: Multiple comparisons */
run;





