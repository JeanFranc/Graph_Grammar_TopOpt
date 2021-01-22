 ####################################################
# Script : SourceIndex								#
# Loads every namespace into the main script		#
# Author : Jean-Francois Gamache					#
# Version: 1.0										#
# Last Updated : July 25th, 2016					#
 ####################################################

set path [file dirname [info script]]
set currentPath [pwd]
cd $path

set modules [glob *.tcl]

foreach module $modules {
	if {$module != "." && $module != "SourceIndex.tcl"} {
		source "$path/$module"
	}
}

cd $currentPath
