## R CMD check results
0 errors ✔ | 1 warning ✖ | 2 notes ✖

### Warning
* checking top-level files ... WARNING  
  A complete check needs the 'checkbashisms' script.  
  This relates to optional checks for shell scripts. The package does not include shell scripts, so this warning can be disregarded.

### Notes
* checking for GNU extensions in Makefiles ... NOTE  
  GNU make is explicitly listed under `SystemRequirements` in DESCRIPTION.  

* checking sizes of PDF files under ‘inst/doc’ ... NOTE  
  GhostScript is not available on this local system, so the check could not be run.  
  CRAN servers will perform this check as expected.

## Submission
This is an update from version 0.1.0.  
Changes include:  
* Updated maintainer email address.  
* Updated examples.  
* Added code handling missing data.  
* Added `pairmap` functionality, allowing the same statements to appear in multiple items.  
* Revised missing-data handling to allow response data with no missing values.

