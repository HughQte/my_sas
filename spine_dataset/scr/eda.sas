/*project: vertebral dataset
	source: /kaggle/input/datasets/jessanrod3/vertebralcolumndataset
	author: Hieu Bui
	date: 2026-10-23*/
	
libname sas "/home/u64368263/personal_projects/data";

proc import datafile='/home/u64368263/personal_projects/data/Dataset_spine.csv'
	out=sas.spine
	dbms=csv
	replace;
run;

proc print data=sas.spine (obs=10);
run;

/*--- 1. Inspecting dataset ---*/
proc contents data=sas.spine;
run;

proc means data=sas.spine 
	n nmiss;
	var _NUMERIC_;
run;

proc freq data=sas.spine;
	tables Class_att / missing;  /*no missing found*/
run;

/*--- 2. Histogram distribution ---*/
/*convert all numeric features to long format*/
data sas.spine_long;
	set sas.spine;
	length Feature $32;
	array features[*] _NUMERIC_;
	
	do i = 1 to dim(features);
		Feature = vname(features[i]);
		Value = features[i];
		
		if not missing(Value) then output;
	end;
	keep Feature Value;
run;
/*create multi-panel histograms*/
ods graphics on;
ods graphics / width=12in height=8in;

proc sgpanel data=sas.spine_long;
	panelby Feature / columns=3 novarname uniscale=row;
	histogram Value / nbins=15;
	density Value / type=normal;
	colaxis label="Features";
	rowaxis label="Density";
	title "Distribution of All Features";
run;

/*--- 3. Boxplot distribution ---*/
ods graphics on;
ods graphics / width=12in height=8in;

proc sgpanel data=sas.spine_long;
	panelby Feature / columns=3 novarname uniscale=row;
	vbox Value;
	colaxis label="Features";
	rowaxis label="Value";
	title "Distribution of Spinal Features";
run;

/*--- 4. Correlation and Heatmap ---*/
/*calculate Pearson correlations*/
ods graphics on;

proc corr data=sas.spine outp=sas.corr_spine noprint nosimple;
	var _NUMERIC_;
run;
/*reshape correlation matrix*/
proc transpose 
	data=sas.corr_spine(where=(_TYPE_="CORR"))
	out=corr_long
	name=feature;
	by _NAME_ notsorted;
	var _NUMERIC_;
run;
/*create correlation heatmap*/
proc sgplot data=corr_long;
	heatmapparm x=_NAME_
				y=feature
				colorresponse=col1 /colormodel=(blue white red);
	gradlegend;
	xaxis display=(nolabel) discreteorder=data fitpolicy=rotate;
	yaxis display=(nolabel) discreteorder=data;
	title "Pearson Correlation Heatmap";
run;

/*--- 5. Barchart for Target ---*/
ods graphics on;
ods graphics / width=5in height=6in;
proc sgplot data=sas.spine;
	vbar Class_att / stat=freq datalabel missing;
	xaxis label="Class";
    yaxis label="Frequency";
    title "Distribution of Class";
run;




	
	




