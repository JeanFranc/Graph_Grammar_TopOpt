# Includes namespaces functions

set 	dirPath [file dirname [info script]]
source 	$dirPath/Pack/SourceIndex.tcl

# Defines the file path of the input files, if called from a function or directly
if {[llength $::argv] < 3} {

	puts [pwd]
	set normalPath [pwd]
	set paramFile "$dirPath/DefaultParam.par"
	
} else {

	# # Uncomment for HyperStudy.
	# set normalPath  [pwd] 
	# set lastLine 	[lindex $::argv end] 
	# set lastLine 	[split $lastLine "/"] 
	# set paramFile	[lindex $lastLine end] 

	#Uncomment for MATLAB.
	set normalPath  [lindex $::argv end]
	set paramFile	"$normalPath\\Param.txt"
	
}

# Defines a debug stream to output messages to debug file. 
set debugStream [open $normalPath/Debug.txt w]
puts $debugStream "Starting Debug File \n"
puts $debugStream $paramFile

# Reads the parameter files
set Inputs [open $paramFile]
while {[gets $Inputs line] >= 0} {
	if [string compare [string index $line 0] "#"] {
		set [lindex $line 0] [lindex $line 1] 
	}
}

if {$::General::Sizing && $::General::Complexity} {
	error "Only sizing or complexity. Not both at the same time."
}

# Set the Optistruct Template
*templatefileset [file join [hm_info -appinfo ALTAIR_HOME] templates feoutput optistruct optistruct] 

set ::General::debugStream $debugStream

# Create the stiffened panels, in the components, and its mesh. 
::Geometry::createGeometry_xy

# Create the material cards for linear behaviour. 
::Material::initializeMatCard

::Property::initializePropCards

::BCs::setBCs

::LoadSteps::setStaticAnalysis

if {$::General::Buckling} {
	::LoadSteps::setLinearBuckling
}

# Launch the Analysis, by filtered steps. 

set ::Steps::step1bool false
set ::Steps::debugStream $debugStream

set name Sensi

if {$::General::Sizing || $::General::Complexity} {
	::Optimization::setOptimizationCards
}

::Optistruct::RunOptistruct $normalPath $name 

puts $debugStream "Closing Debug File"
close $debugStream

