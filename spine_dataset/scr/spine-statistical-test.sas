/*project: vertebral dataset statistical model
	source: /kaggle/input/datasets/jessanrod3/vertebralcolumndataset
	author: Hieu Bui
	date: 2026-10-27*/
	
libname sas "/home/u64368263/personal_projects/data";

proc import datafile='/home/u64368263/personal_projects/data/Dataset_spine.csv'
	out=sas.spine
	dbms=csv
	replace;
run;

proc contents data=sas.spine;
run;

/* inspect column name of the dataset */
proc sql;
    select name, length(name) as name_length
    from dictionary.columns
    where libname="SAS" and memname="SPINE";
quit;

/* rename column name for easy use */
data sas.spine;
    set sas.spine;

    rename
        'pelvic incidence'n = pelvic_incidence
        ' pelvic tilt'n = pelvic_tilt
        ' lumbar lordosis angle'n = lumbar_lordosis
        ' sacral slope'n = sacral_slope
        ' pelvic radius'n = pelvic_radius
        ' grade of spondylolisthesis'n = spondylolisthesis_grade;
run;

/* --- Independent-samples t-test --- */
/* Compare measurements between Normal and Abnormal groups*/
proc ttest data=sas.spine plots=all;
    class Class_att;
    var pelvic_incidence
    	pelvic_tilt
    	lumbar_lordosis
    	sacral_slope
    	pelvic_radius
    	spondylolisthesis_grade;
run;
/* ------------------------------------------------------------------ */

/* --- Logistic regression --- */
/* Estimate the probability of an Abnormal classification */
ods graphics on;

proc logistic data=sas.spine
    plots(only)=roc;

    model class_att(event="Abnormal") =
        pelvic_incidence
    	pelvic_tilt
    	lumbar_lordosis
    	sacral_slope
    	pelvic_radius
    	spondylolisthesis_grade
        / clodds=wald;

    output out=sas.spine_pred
        p=pred_prob;
run;
/* ------------------------------------------------------------------ */

/* Linear discriminant analysis */
/* Classify observations into Normal or Abnormal groups */
proc discrim data=sas.spine
    method=normal
    pool=yes
    crossvalidate;

    class class_att;

    var pelvic_incidence
    	pelvic_tilt
    	lumbar_lordosis
    	sacral_slope
    	pelvic_radius
    	spondylolisthesis_grade;
run;
/* ------------------------------------------------------------------ */
