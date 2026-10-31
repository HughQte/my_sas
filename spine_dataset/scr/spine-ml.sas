/* Project: Classify normal/abnormal spine by using ml models
	author: Hieu Bui
	date: 2026-10-30 */
	
/* 1. Import dataset */
libname sas "/home/u64368263/personal_projects/data";

proc import
    datafile="/home/u64368263/personal_projects/data/Dataset_spine.csv"
    out=sas.spine
    dbms=csv
    replace;
    guessingrows=max;
run;

/* 2. Rename features */
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

/* 3. Binary classification target */
data sas.spine_binary;
    set sas.spine;
    length binary_target 8;
    select (upcase(strip(class_att)));
        when ("ABNORMAL", "YES", "1")
            binary_target = 1;
        when ("NORMAL", "NO", "0")
            binary_target = 0;
        otherwise binary_target = .;
    end;
    if missing(binary_target) then delete;
run;

/* 4. Verify outcome distribution */
proc freq data=sas.spine_binary;
    tables class_att*binary_target / missing;
run;

/* 5. Define predictors */
%let feature_input =
    pelvic_incidence
    pelvic_tilt
    lumbar_lordosis
    sacral_slope
    pelvic_radius
    spondylolisthesis_grade;

%let target_input = binary_target;

/* 6. Decision Tree */
ods graphics on;

proc hpsplit data=sas.spine_binary
             maxdepth=5
             seed=123;
    class &target_input.;
    model &target_input.(event='1')
        = &feature_input.;
    grow entropy;
    prune costcomplexity;
    partition fraction(validate=0.3 seed=123);
run;

/* 7. Logistic Regression */
proc logistic data=sas.spine_binary
              plots(only)=roc;
    model &target_input.(event='1')
        = &feature_input.
        / clodds=wald;
    roc;
run;

ods graphics off;
