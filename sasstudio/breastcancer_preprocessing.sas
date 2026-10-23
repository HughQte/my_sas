/*project title: wdbc.data_logistic regression
	author: Hieu Bui
	date: 2026-10-20*/

libname sas "/home/u64368263/personal_projects/data";

proc import datafile='/home/u64368263/personal_projects/data/wdbc.data'
	out=sas.bc
	dbms=dlm
	replace;
	DELIMITER=',';
	getnames=no;
run;

/*Dataset does not originally arrived with column's name.
Need to rename all of the VAR# columns.*/
data sas.bc; set sas.bc;
rename 
	VAR1 = id
	VAR2 = diagnosis 
	VAR3 = radius1
	VAR4 = texture1
	VAR5 = perimeter1
	VAR6 = area1
	VAR7 = smoothness1
	VAR8 = compactness1
	VAR9 = concavity1
	VAR10 = concave_points1
	VAR11 = symmetry1
	VAR12 = fractal_dimension1
	VAR13 = radius2
	VAR14 = texture2
	VAR15 = perimeter2
	VAR16 = area2
	VAR17 = smoothness2
	VAR18 = compactness2
	VAR19 = concavity2
	VAR20 = concave_points2
	VAR21 = symmetry2
	VAR22 = fractal_dimension2
	VAR23 = radius3
	VAR24 = texture3
	VAR25 = perimeter3
	VAR26 = area3
	VAR27 = smoothness3
	VAR28 = compactness3
	VAR29 = concavity3
	VAR30 = concave_points3
	VAR31 = symmetry3
	VAR32 = fractal_dimension3;
run;

/*Show data contents*/
proc contents data=sas.bc;
run;
		
/*Show the first 10 rows of the dataset*/
proc print data=sas.bc (obs=10);
run;

/*Summary statistics for all numeric features*/
proc means data=sas.bc
	(drop=id) 
	nmiss mean std min max;
run;

/*Distribution of the target*/
proc freq data=sas.bc;
	table diagnosis /missing;
run;
