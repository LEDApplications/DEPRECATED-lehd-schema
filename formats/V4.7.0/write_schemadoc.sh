#!/bin/bash
# set defaults
toclevels=4
# print out info
if [[ -z $1 ]]
then
echo "
	$0 [start|version]

	will build the format documentation from CSV files and a template.

	Version = draft|official changes a note in the document
	"
	exit 1
fi

if [[ "$1" = "start" ]]
then
# parse version from directory
   version=draft
else
   version=$1
fi
case $version in
	official|draft)
	author=ces.qwi.feedback@census.gov
	;;
esac
cwd=$(pwd)
numversion=${cwd##*/}
# convert the column definitions to CSV
sed 's/  /,/g;s/R N/R,N/; s/,,/,/g; s/,,/,/g; s/,,/,/g; s/, /,/g' column_definitions.txt | tail -n +2 > tmp.csv

# create ascii doc version
asciifile=lehd_public_use_schema.asciidoc
# this revision is used to dynamically download a sample for the version.txt. should be available for both QWI and J2J
versionvintage=latest_release
# versionj2jvintage=$versionvintage
versionj2jvintage=latest_release
versionstate=de
versionurl=https://lehd.ces.census.gov/data/qwi/${versionvintage}/${versionstate}
versionj2jurl=https://lehd.ces.census.gov/data/j2j/${versionj2jvintage}/${versionstate}/j2j
previousvintage=$(cd ..; ls -1d * | grep -E "V[0-9]" | tail -2 | head -1)


echo "= LEHD Public Use Data Schema $numversion" > $asciifile
echo "<${author}>" >> $asciifile
echo "$(date +%d\ %B\ %Y)
// a2x: --dblatex-opts \"-P latex.output.revhistory=0 --param toc.section.depth=${toclevels}\"
:ext-relative: {outfilesuffix}
( link:$(basename $asciifile .asciidoc).pdf[Printable version] )

" >> $asciifile
# A note on the relevance/beta/draft status of this file.

case $version in
	draft)
	echo "
[IMPORTANT]
.Important
==============================================
This specification is draft. Feedback is welcome. Please write us at link:mailto:${author}?subject=LEHD_Schema_draft[${author}].
==============================================
	" >> $asciifile
	;;
	official)
	echo "
[IMPORTANT]
.Important
==============================================
Feedback is welcome. Please write us at link:mailto:${author}?subject=LEHD_Schema[${author}].
==============================================
	" >> $asciifile
	;;
esac

echo "
Purpose
-------
The public-use data from the Longitudinal Employer-Household Dynamics Program, including the Quarterly Workforce Indicators (QWI)
and Job-to-Job Flows (J2J), are available for download with the following data schema.
These data are available  through the LEHD website’s Data page at
https://lehd.ces.census.gov/data/ and through the LED Extraction Tool at https://ledextract.ces.census.gov/.

This document describes the data schema for LEHD files. LEHD-provided SHP files are separately described in link:lehd_shapefiles{ext-relative}[]. For each variable,
a set of allowable values is defined. Definitions are provided as CSV files,
with header variable definitions.  Changes relative to the original v4.0 version are listed <<changes,at the end>>.

File naming
-----------
The naming conventions of the data files is documented in link:lehd_csv_naming{ext-relative}[].

Extends
-------
This version reimplements some features from  V4.0. Many files compliant with LEHD or QWI Schema v4.0 will also be compliant with this schema, but compatibility is not guaranteed.

Supersedes
----------
This version supersedes V4.6.0, for files released as of R2020Q4.

Basic Schema
------------
Each data file is structured as a CSV file. The first columns contain <<identifiers>>, subsequent columns contain <<indicators>>, followed by <<statusflags,status flags>>. In some cases, visually formatted Excel (XLSX) files are also available,  containing the same information together with header lines  on each sheet.

=== Generic structure

[width=\"30%\",format=\"csv\",cols=\"<2\",options=\"header\"]
|===================================================
Column name
[ Identifier1 ]
[ Identifier2 ]
[ Identifier3 ]
[ ... ]
[ Indicator 1 ]
[ Indicator 2 ]
[ Indicator 3 ]
[ ... ]
[ Status Flag 1 ]
[ Status Flag 2 ]
[ Status Flag 3 ]
[ ... ]
|===================================================

Note: A full list of indicators for each type of file are shown below in the <<indicators,Indicators>> section.
While all indicators are included in the CSV files, only the requested indicators
will be included in data outputs from the LED Extraction Tool.

<<<

=== [[identifiers]]Identifiers
Records, unless otherwise noted, are parts of time-series data. Unique record identifiers are noted below, by file type.
Identifiers without the year and quarter component can be considered a series identifier.
" >> $asciifile

############################## Identifiers
for arg in lehd_mapping_identifiers.csv
do
  name="$(echo ${arg%*.csv}| sed 's/lehd_//; s/_/ for /; s/mapping/Mapping/; s/ident/Ident/')"
  echo "==== $name
( link:${arg}[] )

Each of the released files has a set of variables uniquely identifying records ('Identifiers'). The table below relates the set of identifier specifications
to the released files. The actual CSV files containing the identifiers for each set are listed after this table. Each identifier can take on a specified list of values, documented in the section on <<catvars,Categorical Variables>>.

[width=\"80%\",format=\"csv\",cols=\"<3,8*^1\",options=\"header\"]
|===================================================
include::$arg[]
|===================================================
<<<
" >> $asciifile
done

### Hardcode identifier order
for arg in lehd_identifiers_qwi.csv lehd_identifiers_j2j.csv lehd_identifiers_j2jod.csv lehd_identifiers_pseo.csv
do
  name="$(echo ${arg%*.csv}| sed 's/lehd_//; s/_/ for /; s/ident/Ident/')"
  echo "==== $name
( link:${arg}[] )

[width=\"100%\",format=\"csv\",cols=\"2*^1,<3\",options=\"header\"]
|===================================================
include::$arg[]
|===================================================
<<<

" >> $asciifile
done


################################# Variables
echo "
<<<
=== [[indicators]]Indicators
The following tables and associated mapping files
list the indicators available on each file.  The descriptor files themselves are structured as follows:

- The ''Indicator Variable'' is the short name of the variable on the CSV files, suitable for machine processing in a wide variety of statistical applications.
- When given, the ''Alternate name'' may appear in related documentation and articles.
- The ''Status Flag'' is used to indicate publication or data quality status (see <<statusflags,Status Flags>>).
- The ''Indicator Name'' is a non-abbreviated version of the ''Indicator Variable''.
- The ''Description'' provides more verbose description of the variable.
- ''Units'' identify the type of variable according to a very simplified taxonomoy (not formalized yet): counts, rates, monetary amounts.
- ''Concept'' classifies the variables into higher-level concepts. The taxonomy for these concepts has not been finalized yet, see link:label_concept_draft.csv[label_concept_draft.csv] for a draft version.
- The ''Base'' indicates the denominator used to compute the statistic, and may be '1'.

==== National QWI and state-level QWI ====

( link:variables_qwi.csv[variables_qwi.csv] )
[width=\"95%\",format=\"csv\",cols=\"3*^2,<5,<5,<2,<2,^2\",options=\"header\"]
|===================================================
include::variables_qwi.csv[]
|===================================================
<<<

==== National QWI and state-level QWI rates ====
Rates are computed from published data, and are provided as a convenience.


( link:variables_qwir.csv[variables_qwir.csv] )
[width=\"95%\",format=\"csv\",cols=\"3*^2,<5,<5,<2,<2,<2\",options=\"header\"]
|===================================================
include::variables_qwir.csv[]
|===================================================


<<<

==== Job-to-job flow counts (J2J)
( link:variables_j2j.csv[] )
[width=\"95%\",format=\"csv\",cols=\"3*^2,<5,<5,<2,<2,^1\",options=\"header\"]
|===================================================
include::variables_j2j.csv[]
|===================================================
<<<

==== Job-to-job flow rates (J2JR)
( link:variables_j2jr.csv[] )

Rates are computed from published data, and are provided as a convenience.


[width=\"95%\",format=\"csv\",cols=\"3*^2,<5,<5,<2,<2,^1\",options=\"header\"]
|===================================================
include::variables_j2jr.csv[]
|===================================================


<<<

==== Job-to-job flow Origin-Destination (J2JOD)
( link:variables_j2jod.csv[] )
[width=\"95%\",format=\"csv\",cols=\"3*^2,<5,<5,<2,<2,^1\",options=\"header\"]
|===================================================
include::variables_j2jod.csv[]
|===================================================
<<<
" >> $asciifile

tmp_pseoevars_cols=$(mktemp -p $cwd)
cut -d ',' -f 1,3,5,6,7 variables_pseoe.csv >> $tmp_pseoevars_cols
echo "
==== Post-Secondary Employment Outcomes Earnings (PSEOE)
( link:variables_pseoe.csv[] )
[width=\"95%\",format=\"csv\",cols=\"<1,<3,<5,2*<1\",options=\"header\"]
|===================================================
include::$tmp_pseoevars_cols[]
|===================================================
<<<
" >> $asciifile

tmp_pseofvars_cols=$(mktemp -p $cwd)
cut -d ',' -f 1,3,5,6,7 variables_pseof.csv >> $tmp_pseofvars_cols
echo "
==== Post-Secondary Employment Outcomes Flows(PSEOF)
( link:variables_pseof.csv[] )
[width=\"95%\",format=\"csv\",cols=\"<1,<3,<5,2*<1\",options=\"header\"]
|===================================================
include::$tmp_pseofvars_cols[]
|===================================================
<<<
" >> $asciifile


################################# Variability measures
for arg in   $(ls variables_*v.csv)
do
	tmpfile=tmp_$arg
	head -4 $arg  > $tmpfile
	echo "...,,,," >> $tmpfile
	grep "vt_" $arg | head -3 >> $tmpfile
	echo "...,,,," >> $tmpfile
	grep "vb_" $arg | head -3 >> $tmpfile
	echo "...,,,," >> $tmpfile
	grep "vw_" $arg | head -3 >> $tmpfile
	echo "...,,,," >> $tmpfile
	grep "df_" $arg | head -3 >> $tmpfile
	echo "...,,,," >> $tmpfile
	grep "mr_" $arg | head -3 >> $tmpfile
done

echo "
<<<
=== [[vmeasures]]Variability measures
The following tables and associated mapping files
list the variability measures available on each file.  The ''Variability Measure'' is the short name of the variable on the CSV files,
suitable for machine processing in a wide variety of statistical applications. When given, the ''Alternate Name'' may appear in related documentation and articles.
The ''Variable Name'' is a more verbose description of the variability measure.

Six variability measures are published:

* Total variability, prefixed by vt_
* Standard error, prefixed by st_, and computed as the square root of Total Variability
* Between-implicate variability, prefixed by vb_
* Average within-implicate variability, prefixed by vw_
* Degrees of freedom, prefixed by df_
* Missingness ratio, prefixed by mr_

A missing variability measure indicates a structural zero in the corresponding indicator. This is currently not associated with a flag.

//Not all indicators have associated variability measures. For more details, see the following document TBD.

==== Generic structure

[width=\"30%\",format=\"csv\",cols=\"<2\",options=\"header\"]
|===================================================
Column name
[ Identifier1 ]
[ Identifier2 ]
[ Identifier3 ]
[ ... ]
[ Standard error for Indicator 1 ]
[ Standard error for Indicator 2 ]
[ Standard error for Indicator 3 ]
[ ... ]
[ Total variation for Indicator 1 ]
[ Total variation for Indicator 2 ]
[ Total variation for Indicator 3 ]
[ ... ]
[ Between-implicate variability for Indicator 1 ]
[ Between-implicate variability for Indicator 2 ]
[ Between-implicate variability for Indicator 3 ]
[ ... ]
[ Average within-implicate variability for Indicator 1 ]
[ Average within-implicate variability for Indicator 2 ]
[ Average within-implicate variability for Indicator 3 ]
[ ... ]
[ Degrees of freedom for Indicator 1 ]
[ Degrees of freedom for Indicator 2 ]
[ Degrees of freedom for Indicator 3 ]
[ ... ]
[ Missingness ratio for Indicator 1 ]
[ Missingness ratio for Indicator 2 ]
[ Missingness ratio for Indicator 3 ]
[ ... ]
|===================================================


Note: A full list of indicators for each type of file are shown  in the <<indicators,Indicators>> section. In the tables below, only a sample
of variability measures are printed, but the complete list is available in the linked CSV schema files.

<<<

==== National QWI and state-level QWI ====

( link:variables_qwiv.csv[variables_qwiv.csv] )
[width=\"95%\",format=\"csv\",cols=\"2*^2,<5,<5,<2\",options=\"header\"]
|===================================================
include::tmp_variables_qwiv.csv[]
|===================================================

<<<
==== National QWI and state-level QWI rates ====

( link:variables_qwirv.csv[variables_qwirv.csv] )
[width=\"95%\",format=\"csv\",cols=\"2*^2,<5,<5,<2\",options=\"header\"]
|===================================================
include::tmp_variables_qwirv.csv[]
|===================================================


<<<

==== Job-to-job flow counts (J2J)
Soon.
//( link:variables_j2j.csv[] )
//[width=\"95%\",format=\"csv\",cols=\"3*^2,<5\",options=\"header\"]
//|===================================================
//include::tmp_variables_j2jv.csv[]
//|===================================================
//<<<
//

==== Job-to-job flow rates (J2JR)
Soon.
//( link:variables_j2jr.csv[] )
//[width=\"95%\",format=\"csv\",cols=\"3*^2,<5\",options=\"header\"]
//|===================================================
//include::tmp_variables_j2jrv.csv[]
//|===================================================
//<<<

==== Job-to-job flow Origin-Destination (J2JOD)
Soon.
//( link:variables_j2jod.csv[] )
//[width=\"95%\",format=\"csv\",cols=\"^3,^2,^3,<5\",options=\"header\"]
//|===================================================
//include::tmp_variables_j2jodv.csv[]
//|===================================================

<<<

" >> $asciifile


################################ Formats
echo "
== [[catvars]]Categorical Variables
Categorical variable descriptions are displayed above each table, with the variable name shown in parentheses. Unless otherwise stated, every possible value/label combination for each categorical variable is listed. Please note that not all values will be available in every table.

" >> $asciifile

# we do industry and geo last
for arg in $(ls label_*csv| grep -vE "geo|ind_level|industry|agg_level|flags|fips|stusps|concept_draft|pseo|cip|inst|degree")
do
  name=$(echo ${arg%*.csv}| sed 's/label_//')
  echo "=== $name
( link:${arg}[] )

[width=\"60%\",format=\"csv\",cols=\"^1,<4\",options=\"header\"]
|===================================================
include::$arg[]
|===================================================
" >> $asciifile
done
################################ Industry formats
# now do industry
  name=Industry

  echo "<<<
=== $name ===

 " >> $asciifile

for arg in   $(ls label_ind_level*csv)
do
  name="$(echo ${arg%*.csv}| sed 's/lehd_//; s/_/ for /')"
  link="$(echo ${arg%*.csv}| sed 's/label_//')"
  echo "[[$link]]
==== Industry levels
( link:${arg}[] )

[width=\"60%\",format=\"csv\",cols=\"^1,<4\",options=\"header\"]
|===================================================
include::$arg[]
|===================================================
" >> $asciifile

arg=label_industry.csv
	# construct the sample industry file
	head -8 $arg > tmp2.csv
	echo "...,," >> tmp2.csv
	grep -A 4 -B 4 "31-33" $arg | tail -8  >> tmp2.csv
	echo "...,," >> tmp2.csv

echo "
==== Industry
( link:${arg}[] )

Only a small subset of available values shown.
The 2017 NAICS (North American Industry Classification System) is used for all years.
QWI releases prior to R2018Q1 used the 2012 NAICS classification (see link:../V4.1.3[Schema v4.1.3]).
For a full listing of all valid 2017 NAICS codes, see https://www.census.gov/cgi-bin/sssd/naics/naicsrch?chart=2017.

[width=\"90%\",format=\"csv\",cols=\"^1,<5,^1\",options=\"header\"]
|===================================================
include::tmp2.csv[]
|===================================================
<<<
" >> $asciifile
done

echo "
=== Educational Institution ===

==== Institution Levels
( link:label_inst_level.csv[] )

Educational institutions are tabulated individually in the current data release.
Future releases may aggregate to institutions to higher levels, such as state or Census Division.

[width=\"60%\",format=\"csv\",cols=\"^1,<4\",options=\"header\"]
|===================================================
include::label_inst_level.csv[]
|===================================================
" >> $asciifile

#Institution rownum
#University of Colorado Boulder 2630
#University of Texas - Austin 32017
#Ohio State University 17398
#University of Michigan (00232500) 11819
#University of Wisconsin - Madison 23062
#Pennsylvania State University (00332900) 19324

echo "
==== Institution
( link:label_institution.csv[] )

Institution identifiers are sourced from the
https://www2.ed.gov/offices/OSFAP/PEPS/dataextracts.html[U.S. Department of Education, Federal Student Aid office].
This list has been supplemented with records for regional groupings of institutions (may be used in future PSEO tabulations).

[width=\"80%\",format=\"csv\",cols=\"^1,<4,^2,3*^1\",options=\"header\"]
|===================================================
include::label_institution.csv[lines=1]
...,,,,,
include::label_institution.csv[lines=2630;32017;17398;11819;23062;19324]
...,,,,,
|===================================================
" >> $asciifile

echo "
=== Degree level
( link:label_degree_level.csv[] )

The degree levels are sourced from the
https://surveys.nces.ed.gov/ipeds/VisInstructions.aspx?survey=10&id=30080&show=part#chunk_1526[National Center for Education Statistics (NCES), Integrated Postsecondary Education Data System (IPEDS)].

[width=\"60%\",format=\"csv\",cols=\"^1,<4\",options=\"header\"]
|===================================================
include::label_degree_level.csv[]
|===================================================
" >> $asciifile

echo "
=== Classification of Instruction Programs (CIP)

==== CIP levels
( link:label_cip_level.csv[] )

[width=\"60%\",format=\"csv\",cols=\"^1,<4\",options=\"header\"]
|===================================================
include::label_cip_level.csv[]
|===================================================
" >> $asciifile

echo "
==== CIP Codes
( link:label_cipcode.csv[] )

CIP codes are sourced from the https://nces.ed.gov/ipeds/cipcode/[National Center for Education Statistics (NCES), Integrated Postsecondary Education Data System (IPEDS)].
Data are reported using 2020 CIP codes, for all years.

[width=\"90%\",format=\"csv\",cols=\"^1,<2,^1,^1,<6\",options=\"header\"]
|===================================================
include::label_cipcode.csv[lines=1;2;3;4;5;117;118]
|===================================================
" >> $asciifile

echo "
=== Grad Cohort

\`grad_cohort\` is a 4-digit number representing the first year of the graduation cohort. The number of years in the cohort is reported in the separate <<#_grad_cohort_years>> variable.

====
If \`grad_cohort\`=2010 and \`grad_cohort_years\`=3, then the cell includes graduates from 2010, 2011, and 2012.
====

When tabulating across all cohorts, the value *0000* will be used for grad_cohort.

=== Grad Cohort Years

\`grad_cohort_years\` is the number of years in the cohort of reference (see <<#_grad_cohort>>). It varies by <<#_degree_level>>. Bachelor's degrees (05) are reported in 3 year cohorts, all other degrees are reported in 5 year cohorts. The \`grad_cohort_years\` will take a value (3,5). As tabulations are not done across degree types, the appropriate value will be reported in \`grad_cohort_years\` when \`grad_cohort\`=0000.
" >> $asciifile

################################ Geo formats
# now do geography
  name=Geography
	# construct the NS file
	nsfile=label_fipsnum.csv
	#echo "geography,label" > $nsfile
	#echo '00,"National (50 States + DC)"' >> $nsfile
	#grep -h -E "^[0-9][0-9]," label_geography_??.csv | sort -n -k 1 >> $nsfile

	# construct the sample fips file
	head -8 $nsfile > tmp.csv
	echo "...,," >> tmp.csv
	head -50 $nsfile | tail -8  >> tmp.csv

	# construct the composite file from separate files
	# we clean up line endings at the same time
	[[ -f tmp3.csv ]] && rm tmp3.csv
	head -1 label_geography_us.csv > label_geography.csv
	for arg in $(ls label_geography_*.csv | grep -vE "cbsa")
	do
	  tail -n +2 $arg | unix2dos | dos2unix >> tmp3.csv
	done
	# split sorting: N, S, C, M, W, B
	grep -E ",N$" tmp3.csv | sort -n -k 1 -t , >> label_geography.csv
	grep -E ",S$" tmp3.csv | sort -n -k 1 -t , >> label_geography.csv
	grep -E ",C$" tmp3.csv | sort -n -k 1 -t , >> label_geography.csv
	grep -E ",M$" tmp3.csv | sort -n -k 1 -t , >> label_geography.csv
	grep -E ",W$" tmp3.csv | sort    -k 1 -t , >> label_geography.csv
	grep -E ",B$" tmp3.csv | sort -n -k 1 -t , >> label_geography.csv
	grep -E ",D$" tmp3.csv | sort -n -k 1 -t , >> label_geography.csv
  # we check that we have the same numbers

	# convert to UTF-8
	#iconv -t UTF-8 -f ISO-8859-15 label_geography.csv  > tmp3.csv
	#mv tmp3.csv label_geography.csv
	rm tmp3.csv

  echo "=== [[geography]]$name ===

  " >> $asciifile

for arg in   $(ls label_geo_level*csv)
do
  name="$(echo ${arg%*.csv}| sed 's/label_//')"
	tmp_geo_csv=$(mktemp -p $cwd)
	cut -d ',' -f 1,2,3 $arg >> $tmp_geo_csv
  echo "[[$name]]
==== [[geolevel]] Geographic levels
Geography labels for data files are provided in separate files, by scope. Each file 'label_geograpy_SCOPE.csv' may contain one or more types of records as flagged by <<geolevel,geo_level>>. For convenience, a composite file containing all geocodes is available as link:label_geography.csv[].
The 2019 vintage of https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html[Census TIGER/Line geography] is used for all tabulations as of the R2020Q1 release.


Shapefiles are described in a link:lehd_shapefiles{ext-relative}[separate document].


( link:${arg}[] )

[width=\"90%\",format=\"csv\",cols=\"^1,<3,<8\",options=\"header\"]
|===================================================
include::$tmp_geo_csv[]
|===================================================
" >> $asciifile
done


tmp_stusps_csv=$(mktemp -p $cwd)
cut -d ',' -f 1,2 label_stusps.csv >> $tmp_stusps_csv
echo "

==== [[geostate]]National and state-level values ====
( link:$nsfile[] )

The file link:$nsfile[$nsfile] contains values and labels
for all entities of <<geolevel,geo_level>> 'N' or 'S', and is a summary of separately available files.
[width=\"40%\",format=\"csv\",cols=\"^1,<3,^1\",options=\"header\"]
|===================================================
include::tmp.csv[]
|===================================================

( link:label_geography_division.csv[] )

The file link:label_geography_division.csv[label_geography_division.csv] contains values and labels
for all entities of <<geolevel,geo_level>> 'D'. For more information on which states comprise each division, see the map https://www2.census.gov/geo/pdfs/maps-data/maps/reference/us_regdiv.pdf[here].

[width=\"40%\",format=\"csv\",cols=\"^1,<3,^1\",options=\"header\"]
|===================================================
include::label_geography_division.csv[]
|===================================================

==== [[stusps]]State postal codes

Some parts of the schema use (lower or upper-case) state postal codes.

( link:label_stusps.csv[] )

[width=\"40%\",format=\"csv\",cols=\"^1,<2\",options=\"header\"]
|===================================================
include::$tmp_stusps_csv[]
|===================================================


==== [[geosubstate]]Detailed state and substate level values

Files of type 'label_geography_[ST].csv' will contain identifiers and labels for geographic areas entirely comprised within a given state '[ST]'. State-specific parts of cross-state CBSA, in records of type <<geolevel,geo_level>> = M, are present on files of type 'label_geography_[ST].csv'. The file link:label_geography_metro.csv[] contains labels for records of type <<geolevel,geo_level>> = B, for metropolitan areas only.



">> $asciifile

#[IMPORTANT]
#.Important
#==============================================
#The above section should include hyperlinks to
#the appropriate reference.
#==============================================

echo "
[format=\"csv\",width=\"50%\",cols=\"^1,^2,^3\",options=\"header\"]
|===================================================
Scope,Types,Format file" >> $asciifile
	for arg in label_geography_us.csv
	do
	state=$(echo ${arg%*.csv} | awk -F_ ' { print $3 } '| tr [a-z] [A-Z])
	echo "$state,N,link:${arg}[]" >> $asciifile
	done
	for arg in label_geography_division.csv
	do
	state=$(echo ${arg%*.csv} | awk -F_ ' { print $3 } '| tr [a-z] [A-Z])
	echo "$state,D,link:${arg}[]" >> $asciifile
	done
	for arg in label_geography_metro.csv
	do
	state=$(echo ${arg%*.csv} | awk -F_ ' { print $3 } '| tr [a-z] [A-Z])
	echo "$state,B,link:${arg}[]" >> $asciifile
	done
  echo "*States*,," >> $asciifile
  for arg in  $(ls label_geography_??.csv|grep -v geography_us)
  do
  	state=$(echo ${arg%*.csv} | awk -F_ ' { print $3 } '| tr [a-z] [A-Z])
	echo "$state,S C W M,link:${arg}[]" >> $asciifile
  done
echo "|===================================================" >> $asciifile

################################# Variables
# finish file

nsfile=label_agg_level.csv
nsfileshort=tmp_label_agg_level.csv

head -8 $nsfile > $nsfileshort
echo "...,,,,,,,,,,,,,,,,,,,,,," >> $nsfileshort
head -14 $nsfile | tail -3 >> $nsfileshort
echo "...,,,,,,,,,,,,,,,,,,,,,," >> $nsfileshort
head -31 $nsfile | tail -3 >> $nsfileshort
echo "...,,,,,,,,,,,,,,,,,,,,,," >> $nsfileshort

tmp_nsfileshort_csv=$(mktemp -p $cwd)
cut -d ',' -f 1-9 $nsfileshort >> $tmp_nsfileshort_csv
echo "
<<<
=== Aggregation level

==== J2J
( link:$nsfile[] )

Measures within the J2J and QWI data products are tabulated on many different dimensions, including demographic characteristics, geography, industry, and other firm characteristics. For Origin-Destination (O-D) tables, characteristics of the origin and destination firm can be tabulated separately.  Every tabulation level is assigned a unique aggregation index, represented by the agg_level variable. This index starts from 1, representing a national level grand total (all industries, workers, etc.), and progresses through different combinations of characteristics. There are gaps in the progression to leave space for aggregation levels that may be included in future data releases.

The following variables are included in the link:$nsfile[label_agg_level.csv]   file:

[width=\"60%\",format=\"csv\",cols=\"<2,<5\",options=\"header\"]
|===================================================
include::variables_agg_level.csv[]
|===================================================


The characteristics available on an aggregation level are repeated using a series of flags following the standard schema:

- <<_cip_levels,cip_level>> - degree field reporting level of table
- <<_institution_levels,inst_level>> - institution reporting level of table
- <<geolevel,geo_level>> - geographic level of table
- <<ind_level,ind_level>> - industry level of table
- by_ variables - flags indicating other dimensions reported, including ownership, demographics, firm age and size.

A shortened representation of the file is provided below, the complete file is available in the link above.


[width=\"90%\",format=\"csv\",cols=\">1,3*<2,5*<1\",options=\"header\"]
|===================================================
include::$tmp_nsfileshort_csv[]
|===================================================
">> $asciifile

# use all cols
tmp_pseoagg_cols=label_agg_level_pseo.csv
tmp_pseoagg_rows=$(mktemp -p $cwd)

head -5 $tmp_pseoagg_cols > $tmp_pseoagg_rows
echo "...,,,,,,,,,," >> $tmp_pseoagg_rows
head -50 $tmp_pseoagg_cols | tail -3 >> $tmp_pseoagg_rows
echo "...,,,,,,,,,," >> $tmp_pseoagg_rows
head -100 $tmp_pseoagg_cols | tail -3 >> $tmp_pseoagg_rows
echo "...,,,,,,,,,," >> $tmp_pseoagg_rows


echo "
==== PSEO
( link:label_agg_level_pseo.csv[] )

Measures within the PSEO data product can be tabulated by characteristics of the graduate
(e.g., institution attended, instructional program, degree level, etc.) and by characteristics of employment
(state, industry). All measures may not be available on all levels of aggregation - for example,
earnings variables may not be available when tabulating by place and industry of work, though counts are.
Every tabulation level is assigned a unique aggregation index, represented by the agg_level_pseo variable.
This index starts from 1, representing a national level grand total (all institutions, graduates, industries,
etc.), and progresses through different combinations of characteristics. There are gaps in the progression to
leave space for aggregation levels that may be included in future data releases. Aggregation levels that are
available in the PSEO release will be flagged.

The following variables are included in the link:label_agg_level_pseo.csv[] file:

[width=\"60%\",format=\"csv\",cols=\"<2,<5\",options=\"header\"]
|===================================================
Variable,Description
agg_level_pseo, index representing level of aggregation reported on a given record
grad_char,Characteristics of graduate and program
firm_char,Characterstics of place of employment
pseoe,Flag: aggregation level available on PSEO Earnings
pseof,Flag: aggregation level available on PSEO Flows
|===================================================

The characteristics available on an aggregation level are repeated using a series of flags following the standard schema:

- <<#_institution_levels,inst_levels>> - institution level of table
- <<geolevel,geo_level>> - geographic level of table
- <<ind_level,ind_level>> - industry level of table
- by_ variables - flags indicating other dimensions reported, including ownership, demographics, firm age and size.


[width=\"90%\",format=\"csv\",cols=\"^1,2*<3,8*^1\",options=\"header\"]
|===================================================
include::$tmp_pseoagg_rows[]
|===================================================

===== Restricted 4-digit CIP tabulations in earnings data (PSEOE)

Earnings estimates and counts are provided only at the 2-digit CIP level for Masters and Doctor Research programs (degree levels 07 and 17). Records are included for 4-digit programs observed, but all measures are suppressed.
">> $asciifile


echo "
==== QWI

Aggregation level to be added to QWI in a future release
">> $asciifile


arg=label_flags.csv
echo "
<<<
== [[statusflags]]Status Flags
( link:${arg}[] )

Most indicators in the LEHD data products have associated status flags. Each status flag in the tables above contains one of the following valid values. The values and their interpretation are listed in the tables below. Unless otherwise specified in this section, a status flag will take the values described in 7.1 Standard Status Flags.

=== Standard Status Flags

[IMPORTANT]
.Important
==============================================
Note: Currently, the J2J and PSEO tables only contain status flags '-1', '1', '5'. Status flags with values 10 or above only appear in online applications, not in CSV files.
==============================================


[width=\"80%\",format=\"csv\",cols=\"^1,<4\",options=\"header\"]
|===================================================
include::$arg[]
|===================================================

=== IPEDS Count Status Flag
( link:label_flags_ipeds_count.csv[] )

Graduate counts are provided from public use data from the https://nces.ed.gov/ipeds/use-the-data[Integrated Postsecondary Education Data System (IPEDS)]. Counts are linked to graduation cohorts in the PSEO data and included in the PSEOE tables. In a small number of cases, misalignment in programs (CIPCODE) is observed between the IPEDS and PSEO counts. In these cases, the IPEDS counts adjusted to be consistent with those on PSEO, and the count is flagged accordingly.

[width=\"80%\",format=\"csv\",cols=\"^1,<4\",options=\"header\"]
|===================================================
include::label_flags_ipeds_count.csv[]
|===================================================


">> $asciifile


arg=variables_version.csv
sed 's/naming convention/link:lehd_csv_naming{ext-relative}[]/' $arg |
  sed 's/stusps/<<stusps>>/' |
  sed 's/geography/<<geography>>/' > tmp_$arg
echo "
<<<

== [[metadata]]Metadata
( link:${arg}[] )

=== [[metadataqwij2j]]Version Metadata for QWI, J2J, and PSEO Files (version.txt)

Each data release is accompanied by one or more files with metadata on geographic and temporal coverage, in a compact notation. These files follow the following naming convention:
--------------------------------
$(awk -F, ' NR == 5 { print $1 }' naming_convention.csv  )
--------------------------------
where each component is described in more detail in link:lehd_csv_naming{ext-relative}[].

The contents contains the following elements:
[width=\"90%\",format=\"csv\",cols=\"<1,<3,<4\",options=\"header\"]
|===================================================
include::tmp_$arg[]
|===================================================

For instance, the metadata for the $versionvintage QWI release of
$(grep -E "^$versionstate," naming_geohi.csv | awk  -F, ' { print $2 } ' | sed 's/"//g')
(obtained from $versionurl/version_qwi.txt[here]) has the following content:
--------------------------------
" >> $asciifile
# During the RC phase, this won't work, since it is not published yet
echo "
$(curl $versionurl/version_qwi.txt)
--------------------------------
Similarly, the metadata for the $versionj2jvintage release of
$(grep -E "^$versionstate," naming_geohi.csv | awk  -F, ' { print $2 } ' | sed 's/"//g') J2J
tabulations (obtained from $versionj2jurl/version_j2j.txt[here]) has  the following content:
--------------------------------
$(curl $versionj2jurl/version_j2j.txt)
--------------------------------
Some J2J metadata may contain multiple lines, as necessary.

The PSEO metadata will contain separate lines for the PSEOE and PSEOF tables. The year range for PSEO tables is based on the <<#_grad_cohort>>, the start year of the graduation cohort. An example for Colorado institutions has the following content:

--------------------------------
PSEOE CO 08 2001-2015 V4.5.0 2019Q1 pseopu_co_20190617_0839
PSEOF CO 08 2001-2015 V4.5.0 2019Q1 pseopu_co_20190617_0839
--------------------------------

=== [[metadataj2jod]]Additional Metadata for J2JOD Files (avail.csv)
(link:variables_avail.csv[])

Because the origin-destination (J2JOD) data link two regions, we provide an auxiliary file with the time range that cells containing data for each geographic pairing may appear in a data release.
[width=\"80%\",format=\"csv\",cols=\"<2,<2,<4\",options=\"header\"]
|===================================================
include::variables_avail.csv[]
|===================================================
The reference region will always be either the origin or the destination. National tabulations contain records where both origin and destination are <<geolevel,geo_level>>=N; state tabulations contain records where <<geolevel,geo_level>> in (N,S); metro tabulations contain records where <<geolevel,geo_level>> in (N,S,B). Data may be suppressed for certain combinations of regions and quarters because the estimates do not meet Census Bureau publication standards.

" >> $asciifile
arg=variables_lags.csv
lagqwi=lags_qwi.csv
lagj2j=lags_j2j.csv
lagj2japp=lags_j2japp.csv

echo "
=== [[metadatalags]]Metadata on Indicator Availability
(link:${arg}[])

Each <<indicators,Indicator>> potentially requires leads and/or lags of data to be computed, and thus may not be available for certain time periods. Only two QWI will be available for all quarters of the time span described by +start+ and +end+ in the <<metadataqwij2j,version.txt>> files:  +EmpTotal+ and +Payroll+.  The date range for QWI, QWIR, J2J, and J2JR can be found in <<metadataqwij2j,version.txt>>; the date range for J2JOD can be found in <<metadataj2jod,avail.csv>>.

For each indicator, the following files contain the quarters of data required to be available relative to the overall date range described in the metadata for the release:

* link:${lagqwi}[]
* link:${lagj2j}[]

The files are structured as follows:
[width=\"80%\",format=\"csv\",cols=\"<2,<2,<4\",options=\"header\"]
|===================================================
include::$arg[]
|===================================================
<<<

" >> $asciifile


cat CHANGES_SCHEMA.txt >> $asciifile

echo "

<<<
*******************
Released: $(date '+%F')
*******************
" >> $asciifile
echo "$asciifile created"
asciidoctor -b html5 -a icons -a toc -a numbered -a linkcss -a toclevels=$toclevels -a sectnumlevels=$toclevels -a outfilesuffix=.html $asciifile
[[ -f $(basename $asciifile .asciidoc).html  ]] && echo "$(basename $asciifile .asciidoc).html created"
asciidoctor-pdf -a pdf-page-size=letter -a icons -a toc -a numbered -a outfilesuffix=.pdf $asciifile
[[ -f $(basename $asciifile .asciidoc).pdf  ]] && echo "$(basename $asciifile .asciidoc).pdf created"
#html2text $(basename $asciifile .asciidoc).html > $(basename $asciifile .asciidoc).txt
#[[ -f $(basename $asciifile .asciidoc).txt  ]] && echo "$(basename $asciifile .asciidoc).txt created"
echo "Removing tmp files"
rm -f $cwd/tmp.* #remove files made by mktemp
#rm tmp*
