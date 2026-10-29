/*project: vertebral dataset ml models
	source: /kaggle/input/datasets/jessanrod3/vertebralcolumndataset
	author: Hieu Bui
	date: 2026-10-29*/
	
libname sas "/home/u64368263/personal_projects/data";

proc import datafile='/home/u64368263/personal_projects/data/Dataset_spine.csv'
	out=sas.spine
	dbms=csv
	replace;
run;

proc contents data=sas.spine;
run;
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

/* Convert class_att into binary 0, 1 */
data sas.spine_binary; set sas.spine;
	if class_att in ("Abnormal", "Yes", "1") then binary_target = 1;
	else binary_target = 0;
run;

/* Specify features and target for the models */
%let feature_input = pelvic_incidence 
					pelvic_tilt
					lumbar_lordosis
					sacral_slope
					pelvic_radius
					spondylolisthesis_grade;
%let target_input = binary_target;

/* --- Decision Tree --- */
proc hpsplit data=sas.spine_binary;
	input &feature_input. / level=interval;
	target &target_input. / level=nominal;
	partition fraction(test=0.3 seed=123);
	prune costcomplexity;
run;

*continue...;


