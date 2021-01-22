 ####################################################
# Script : Step_1									#
# Launches the step_1 Analysis for skin buckling    #
# Author : Jean-Francois Gamache					#
# Version: 0.5										#
# Last Updated : July 08th, 2020					#
 ####################################################
 
namespace eval Steps {
 
	variable solver_path
	variable step1bool true
	variable step2bool false
	variable step3bool false
	variable loopFile  
	variable debugStream
	
	variable F_cr
	variable B_topo

	proc SimpleAnalysis {path name} {
		variable solver_path
	
		set home [hm_info -appinfo ALTAIR_HOME]
		set solver_path "$path/$name"
	
		hm_answernext "yes"
		*writefile "$solver_path.hm" 1	

		hm_answernext "yes"
		*feoutputwithdata "$home/templates/feoutput/optistruct/optistruct" "$solver_path.fem" 1 0 1 1 1
		exec "$home/hwsolvers/scripts/optistruct.bat" "$solver_path.fem" -optskip -checkel NO
	
		# printAllResponses $solver_path
	
	}

	proc getMeanStress {path} {
	
		set   stress_fID [open $path r]
		set   file_data [read $stress_fID]
		close $stress_fID		
		
		set sum_Stress 0
		set sum_i 0
		
		set stress_data [split $file_data "\n"]
		for {set i 2} {$i < [expr [llength $stress_data]-1]} {incr i} {
			set stress [lindex [lindex $stress_data $i] 1]
			set sum_Stress [expr $sum_Stress + $stress]
			incr sum_i
		}
		
		return [expr $sum_Stress/$sum_i]
	
	}

	proc printStressPerStiff {path} {
	
		set   stress_fID [open $path.strs r]
		set   file_data [read $stress_fID]
		close $stress_fID	
		set stress_data [split $file_data "\n"]
		set stress_data [lrange $stress_data 3 end]
		
		set numberOfStiff [llength $::Geometry::XVec]
		
		array unset 	Stress 
		array set 		Stress {}
		
		foreach line $stress_data {
		
			set elemID [lindex $line 0]
			
			if {$elemID > 1000000} {
			
				set id [string index $elemID 0]
				set stress [lindex $line 1]
				
				append Stress($id) " " "$stress" 

			}
		
		
		}	
		
		set   out_fID [open $path.strsSTAT w]
		foreach {name value} [array get Stress] {

			set MeanStress  [format %4.4E [average $value]]
			set sorted 		[lsort -real $value]
			
			set MaxStress 	[format %4.4E [lindex $sorted end]]
			set MinStress 	[format %4.4E [lindex $sorted 0]]
			set RangeStress [format %4.4E [expr $MaxStress-$MinStress]]
			
			puts $out_fID "Stiff $name : $MinStress $MeanStress $MaxStress $RangeStress"
			
		}
		close $out_fID	
	
	}

	proc average L {
		expr ([join $L +])/[llength $L]
	}

	proc launchStep1 {path name} {
	 
		variable solver_path
		variable step2bool
		variable loopFile
		variable debugStream
		variable F_cr
		variable B_topo
	 
		# Set the environnement variables
		set home [hm_info -appinfo ALTAIR_HOME]
		set solver_path "$path/$name"
		
		puts $debugStream "Solverpath: $solver_path"
		
		
		# Save the temp hm file. 
		hm_answernext "yes"
		*writefile "$solver_path.hm" 1
		
		# Launches optitruct
		hm_answernext "yes"
		*feoutputwithdata "$home/templates/feoutput/optistruct/optistruct" "$solver_path.fem" 1 0 1 1 1
		exec "$home/hwsolvers/scripts/optistruct.bat" "$solver_path.fem" -analysis -checkel NO
		
		# Read the current maximum buckling mode. 
		#set   loopFileID [open $loopFile r]
		#set   temp_buck [read $loopFileID]
		#close $loopFileID
		
		# Get the current mean stress value.
		#set meanStress [getMeanStress $solver_path.strs]
		#set F_cr [expr $meanStress * $buck1]
		#set B_topo [expr $::Property::skin_T / $F_cr ** (0.5)]
		
		# Ouputs to debug.
		#puts $debugStream "tempbuck : [lindex $temp_buck 0]"
		#puts $debugStream "This.F_cr : $F_cr"
		#puts $debugStream "B_topo : $B_topo"

		# If we find a new maximum, overwrite maximum file. 
		#if {$F_cr > $temp_buck} {	
		#	set   loopFileID [open $loopFile w]
		#	puts  $loopFileID $F_cr
		#	close $loopFileID
		#}

		# Checks if the new buckling is acceptable for a step2 sub-optimization. 
		#if {$F_cr > [expr 0.75 * $temp_buck]} {
		set step2bool true
		#} 

		puts $debugStream "Step 1 Completed"
	 
		# printStressPerStiff $solver_path
		printAllBucklingModes $solver_path
	 
	}
		
	proc launchStep2 {} {
	
		variable debugStream
		
		# Set the environnement variables
		set home [hm_info -appinfo ALTAIR_HOME]
		set solver_path "[pwd]/Step2"
				
		# Launches optitruct
		hm_answernext "yes"
		*feoutputwithdata "$home/templates/feoutput/optistruct/optistruct" "$solver_path.fem" 1 0 1 1 1
		exec "$home/hwsolvers/scripts/optistruct.bat" "$solver_path.fem" -checkel NO -tmpdir "Z:\\"
		
		puts $debugStream "Step 2 Completed"
		
		set step3bool true
		
	}
	
	proc prepareStep3 {} {
		
		variable debugStream
		
		puts $debugStream "Preparing Step 03"
		
		# Create the Non-Linear Material Table.
		*collectorcreate loadcols "Alu7075Table" "" 7
		*createmark loadcols 2 "Alu7075Table"
		set home [hm_info -appinfo ALTAIR_HOME]
		*dictionaryload loadcols 2 "$home/templates/feoutput/optistruct/optistruct" "TABLES1"
		#*createmark loadcols 2 "Alu7075Table"
		#*clearmark loadcols 2
		*attributeupdateint loadcols 4 4271 1 0 0 100
		*createdoublearray 100 0 2.46493e-23 4.79723e-21 2.01927e-19 3.67303e-18 3.92989e-17 \
		  2.91534e-16 1.65418e-15 7.64833e-15 3.00894e-14 1.03877e-13 3.21937e-13 9.11334e-13 \
		  2.38824e-12 5.85599e-12 1.35511e-11 2.98023e-11 6.26551e-11 1.26535e-10 2.46493e-10 \
		  4.64799e-10 8.5096e-10 1.51662e-09 2.6373e-09 4.48368e-09 7.46565e-09 1.21939e-08 \
		  1.95645e-08 3.08737e-08 4.79723e-08 7.3471e-08 1.1101e-07 1.65613e-07 2.44141e-07 \
		  3.55876e-07 5.13271e-07 7.32886e-07 1.03658e-06 1.45296e-06 2.01927e-06 2.78358e-06 \
		  3.80763e-06 5.17016e-06 6.97106e-06 9.33634e-06 1.24241e-05 1.64318e-05 2.16048e-05 \
		  2.82464e-05 3.67303e-05 4.75145e-05 6.11586e-05 7.8343e-05 9.98925e-05 0.000126803 \
		  0.000160272 0.000201738 0.000252917 0.000315857 0.000392989 0.000487194 0.000601875 \
		  0.000741039 0.000909398 0.001112469 0.001356705 0.00164963 0.002 0.002417978 \
		  0.002915336 0.003505683 0.004204715 0.005030502 0.006003804 0.007148428 0.008491625 \
		  0.010064531 0.011902658 0.014046442 0.016541846 0.019441035 0.022803117 0.026694963 \
		  0.031192117 0.036379788 0.042353958 0.049222585 0.057106937 0.06614305 0.076483324 \
		  0.088298277 0.101778462 0.117136559 0.13460966 0.154461767 0.176986508 0.202510094 \
		  0.231394544 0.264041177 0.300894418
		*attributeupdatedoublearray loadcols 4 4269 1 2 0 1 100
		*createdoublearray 100 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000 \
		  11000 12000 13000 14000 15000 16000 17000 18000 19000 20000 21000 22000 23000 \
		  24000 25000 26000 27000 28000 29000 30000 31000 32000 33000 34000 35000 36000 \
		  37000 38000 39000 40000 41000 42000 43000 44000 45000 46000 47000 48000 49000 \
		  50000 51000 52000 53000 54000 55000 56000 57000 58000 59000 60000 61000 62000 \
		  63000 64000 65000 66000 67000 68000 69000 70000 71000 72000 73000 74000 75000 \
		  76000 77000 78000 79000 80000 81000 82000 83000 84000 85000 86000 87000 88000 \
		  89000 90000 91000 92000 93000 94000 95000 96000 97000 98000 99000 100000
		*attributeupdatedoublearray loadcols 4 4270 1 2 0 1 100

		# Apply the material non-linearities to the MAT CARD.
		*startnotehistorystate {Modified MATS1 of material}
		*setvalue mats id=1 STATUS=2 4417=1
		*endnotehistorystate {Modified MATS1 of material}
		*startnotehistorystate {Attached attributes to material "Alum_7075"}
		*setvalue mats id=1 STATUS=0 4418={loadcols 0}
		*setvalue mats id=1 STATUS=0 4419="NLELAST"
		*setvalue mats id=1 STATUS=0 4420=0
		*setvalue mats id=1 STATUS=0 4421=1
		*setvalue mats id=1 STATUS=2 8090=0
		*setvalue mats id=1 STATUS=0 4422=1
		*setvalue mats id=1 STATUS=0 4423=0
		*setvalue mats id=1 STATUS=0 749=0
		*endnotehistorystate {Attached attributes to material "Alum_7075"}
		*mergehistorystate "" ""
		*startnotehistorystate {Modified TID of material from 0 to 4}
		*setvalue mats id=1 STATUS=1 4418={loadcols 4}
		*endnotehistorystate {Modified TID of material from 0 to 4}
		*setvalue mats id=1 STATUS=1 4419="PLASTIC"
		*startnotehistorystate {Modified YF of material}
		*setvalue mats id=1 STATUS=1 4421=1
		*endnotehistorystate {Modified YF of material}
		*startnotehistorystate {Modified TYPSTRN of material}
		*setvalue mats id=1 STATUS=1 749=1
		*endnotehistorystate {Modified TYPSTRN of material}

		# Delete Everything Optimization
		*startnotehistorystate {Deleted Entities}
		*createmark opticontrols 1
		*clearmark opticontrols 1
		*createmark opticontrols 1 "optistruct_opticontrol"
		*deletemark opticontrols 1
		*createmark optiresponses 1
		*clearmark optiresponses 1
		*createmark optiresponses 1 all
		*deletemark optiresponses 1
		*createmark dvprels 1
		*clearmark dvprels 1
		*createmark dvprels 1 all
		*deletemark dvprels 1
		*createmark designvars 1
		*clearmark designvars 1
		*createmark designvars 1 all
		*deletemark designvars 1
		*createmark dequations 1
		*clearmark dequations 1
		*createmark dequations 1 all
		*deletemark dequations 1
		*endnotehistorystate {Deleted Entities}

		# Set the NLPARM card.
		*createentity loadcols includeid=0 name=NLPARM
		*setvalue loadcols id=5 cardimage="NLPARM"
		*startnotehistorystate {Modified NINC of loadcol}
		*endnotehistorystate {Modified NINC of loadcol}
		*startnotehistorystate {Modified NINC of loadcol}
		*setvalue loadcols id=5 STATUS=1 4113=50
		*endnotehistorystate {Modified NINC of loadcol}
		*setvalue loadcols id=5 STATUS=1 4089="PW"
		*startnotehistorystate {Modified EPSU of loadcol}
		*endnotehistorystate {Modified EPSU of loadcol}
		*startnotehistorystate {Modified EPSU of loadcol}
		*setvalue loadcols id=5 STATUS=1 4090=0.01
		*endnotehistorystate {Modified EPSU of loadcol}
		*startnotehistorystate {Modified EPSP of loadcol}
		*endnotehistorystate {Modified EPSP of loadcol}
		*startnotehistorystate {Modified EPSP of loadcol}
		*setvalue loadcols id=5 STATUS=1 4091=0.01
		*endnotehistorystate {Modified EPSP of loadcol}
		*startnotehistorystate {Modified EPSW of loadcol}
		*endnotehistorystate {Modified EPSW of loadcol}
		*startnotehistorystate {Modified EPSW of loadcol}
		*setvalue loadcols id=5 STATUS=1 4092=1e-07
		*endnotehistorystate {Modified EPSW of loadcol}
		*startnotehistorystate {Modified TTERM of loadcol}
		*endnotehistorystate {Modified TTERM of loadcol}
		*startnotehistorystate {Modified TTERM of loadcol}
		*setvalue loadcols id=5 STATUS=1 10201=1
		*endnotehistorystate {Modified TTERM of loadcol}

		# Set the NLOUT card.
		*createentity loadcols includeid=0 name=NLOUT
		*setvalue loadcols id=6 cardimage="NLOUT"
		*startnotehistorystate {Modified NINT of loadcol}
		*setvalue loadcols id=6 STATUS=2 9877=1
		*endnotehistorystate {Modified NINT of loadcol}
		*startnotehistorystate {Attached attributes to loadcol "NLOUT"}
		*setvalue loadcols id=6 STATUS=0 9878=10
		*endnotehistorystate {Attached attributes to loadcol "NLOUT"}
		*mergehistorystate "" ""
		*startnotehistorystate {Modified SVNONCNV of loadcol}
		*setvalue loadcols id=6 STATUS=2 9879=1
		*endnotehistorystate {Modified SVNONCNV of loadcol}
		*startnotehistorystate {Attached attributes to loadcol "NLOUT"}
		*setvalue loadcols id=6 STATUS=2 9880="NO"
		*endnotehistorystate {Attached attributes to loadcol "NLOUT"}
		*mergehistorystate "" ""
		*startnotehistorystate {Modified VALUE of loadcol}
		*endnotehistorystate {Modified VALUE of loadcol}
		*startnotehistorystate {Modified VALUE of loadcol}
		*setvalue loadcols id=6 STATUS=1 9878=1
		*endnotehistorystate {Modified VALUE of loadcol}
		*setvalue loadcols id=6 STATUS=2 9880="YES"

		# Set the NLADAPT Card.
		*createentity loadcols includeid=0 name=NLADAPT
		*setvalue loadcols id=7 cardimage="NLADAPT"
		*startnotehistorystate {Modified DTMIN of loadcol}
		*setvalue loadcols id=7 STATUS=2 9859=1
		*endnotehistorystate {Modified DTMIN of loadcol}
		*startnotehistorystate {Attached attributes to loadcol "NLADAPT"}
		*setvalue loadcols id=7 STATUS=2 9860=0
		*endnotehistorystate {Attached attributes to loadcol "NLADAPT"}
		*mergehistorystate "" ""
		*startnotehistorystate {Modified DTMAX of loadcol}
		*setvalue loadcols id=7 STATUS=2 9857=1
		*endnotehistorystate {Modified DTMAX of loadcol}
		*startnotehistorystate {Attached attributes to loadcol "NLADAPT"}
		*setvalue loadcols id=7 STATUS=2 9858=0
		*endnotehistorystate {Attached attributes to loadcol "NLADAPT"}
		*mergehistorystate "" ""
		*startnotehistorystate {Modified VALUE of loadcol}
		*setvalue loadcols id=7 STATUS=2 9858=0.1
		*endnotehistorystate {Modified VALUE of loadcol}
		*startnotehistorystate {Modified VALUE of loadcol}
		*setvalue loadcols id=7 STATUS=2 9860=0.05
		*endnotehistorystate {Modified VALUE of loadcol}


		# Create the loadstep.
		*createentity loadsteps includeid=0 name=loadstep1
		*createmark loadsteps 1 "loadstep1"
		*clearmark loadsteps 1
		*startnotehistorystate {Renamed Loadsteps from "loadstep1" to "NON_LIN_STAT"}
		*setvalue loadsteps id=3 name=NON_LIN_STAT
		*endnotehistorystate {Renamed Loadsteps from "loadstep1" to "NON_LIN_STAT"}
		*startnotehistorystate {Modified Analysis type of loadstep}
		*setvalue loadsteps id=3 STATUS=2 OS_TYPE=9
		*setvalue loadsteps id=3 4709=9 STATUS=1
		*setvalue loadsteps id=3 STATUS=2 4059=1
		*setvalue loadsteps id=3 STATUS=2 4060=NLSTAT
		*setvalue loadsteps id=3 707=0 STATUS=0
		*setvalue loadsteps id=3 9293={Loadcols 0} STATUS=0
		*endnotehistorystate {Modified Analysis type of loadstep}
		*startnotehistorystate {Attached attributes to loadstep "NON_LIN_STAT"}
		*setvalue loadsteps id=3 STATUS=2 3240=1
		*setvalue loadsteps id=3 STATUS=2 289=0
		*setvalue loadsteps id=3 STATUS=2 288=0
		*setvalue loadsteps id=3 STATUS=2 710=0
		*setvalue loadsteps id=3 STATUS=2 4034=0
		*setvalue loadsteps id=3 STATUS=2 4037=0
		*setvalue loadsteps id=3 STATUS=2 9891=0
		*setvalue loadsteps id=3 STATUS=2 10089=0
		*setvalue loadsteps id=3 STATUS=2 10079=0
		*setvalue loadsteps id=3 STATUS=2 9599=0
		*setvalue loadsteps id=3 STATUS=2 10701=0
		*setvalue loadsteps id=3 STATUS=2 8142=0
		*setvalue loadsteps id=3 STATUS=2 4722=0
		*setvalue loadsteps id=3 STATUS=2 10839=0
		*setvalue loadsteps id=3 STATUS=2 7408=0
		*setvalue loadsteps id=3 STATUS=2 4152=0
		*setvalue loadsteps id=3 STATUS=2 4973=0
		*setvalue loadsteps id=3 STATUS=2 351=0
		*setvalue loadsteps id=3 STATUS=2 3292=0
		*endnotehistorystate {Attached attributes to loadstep "NON_LIN_STAT"}
		*mergehistorystate "" ""
		*startnotehistorystate {Modified SPC of loadstep from 0 to 1}
		*setvalue loadsteps id=3 STATUS=2 OS_SPCID={loadcols 1}
		*setvalue loadsteps id=3 STATUS=2 4143=1
		*setvalue loadsteps id=3 4144=1 STATUS=1
		*setvalue loadsteps id=3 4145={Loadcols 1} STATUS=1
		*endnotehistorystate {Modified SPC of loadstep from 0 to 1}
		*startnotehistorystate {Modified LOAD of loadstep from 0 to 2}
		*setvalue loadsteps id=3 STATUS=2 OS_LOADID={loadcols 2}
		*setvalue loadsteps id=3 STATUS=2 4143=1
		*setvalue loadsteps id=3 4146=1 STATUS=1
		*setvalue loadsteps id=3 4147={Loadcols 2} STATUS=1
		*setvalue loadsteps id=3 7763=0 STATUS=0
		*setvalue loadsteps id=3 7740={Loadcols 0} STATUS=0
		*endnotehistorystate {Modified LOAD of loadstep from 0 to 2}
		*startnotehistorystate {Modified NLPARM LGDISP of loadstep from 0 to 4}
		*setvalue loadsteps id=3 STATUS=2 OS_NLPARM_LGDISPID={loadcols 5}
		*setvalue loadsteps id=3 STATUS=2 4143=1
		*setvalue loadsteps id=3 9930=1 STATUS=1
		*setvalue loadsteps id=3 9931={Loadcols 5} STATUS=1
		*setvalue loadsteps id=3 4186=0 STATUS=0
		*setvalue loadsteps id=3 4187={Loadcols 0} STATUS=0
		*endnotehistorystate {Modified NLPARM LGDISP of loadstep from 0 to 4}
		*startnotehistorystate {Modified NLADAPT of loadstep from 0 to 6}
		*setvalue loadsteps id=3 STATUS=2 OS_NLADAPTID={loadcols 7}
		*setvalue loadsteps id=3 STATUS=2 4143=1
		*setvalue loadsteps id=3 9868=1 STATUS=1
		*setvalue loadsteps id=3 9867={Loadcols 7} STATUS=1
		*endnotehistorystate {Modified NLADAPT of loadstep from 0 to 6}
		*startnotehistorystate {Modified NLOUT of loadstep from 0 to 5}
		*setvalue loadsteps id=3 STATUS=2 OS_NLOUTID={loadcols 6}
		*setvalue loadsteps id=3 STATUS=2 4143=1
		*setvalue loadsteps id=3 9875=1 STATUS=1
		*setvalue loadsteps id=3 9881={Loadcols 6} STATUS=1
		*endnotehistorystate {Modified NLOUT of loadstep from 0 to 5}

		# Create DTI card (Defines units for non-linear analysis)
		*startnotehistorystate {Modified control card}
		*cardcreate "DTI_UNITS"
		*startnotehistorystate {Attached attributes to card}
		*attributeupdatestring cards 1 4832 1 2 0 "SLUG"
		*attributeupdatestring cards 1 4833 1 2 0 "LBF"
		*attributeupdatestring cards 1 4834 1 2 0 "IN"
		*attributeupdatestring cards 1 4835 1 2 0 "S"
		*endnotehistorystate {Attached attributes to card}
		*endnotehistorystate {Modified control card}
		*startnotehistorystate {Modified control card}

		# Pre-Deform with the first buckling mode to help the non-linear analysis. 
		ApplyPreDeformation

		# Apply the design variables from the STEP 2 Optimization. 
		
		set solver_path "[pwd]/Step2"

		set fp [open $solver_path.hist r]
		set file_data [read $fp]
		close $fp
		set data [split $file_data "\n"]

		set OptimStep [lindex [lindex $data end-1] 0]
		set skinT 		[lindex [lindex $data end-1] 3]
		eval *setvalue props id=1 STATUS=1 95=$skinT
		set stiffT 		[lindex [lindex $data end-1] 4]
		eval *setvalue props id=2 STATUS=1 95=$stiffT
		set ShapeStiff 	[lindex [lindex $data end-1] 5]
		*createmark shapes 1 "StiffHeight"
		eval *morphshapeapply shapes 1 $ShapeStiff
		


	}
	
	proc launchStep3 {} {
		variable debugStream
		puts $debugStream "Launching eventual Step 3"
	}
	
	proc fmtnum number {
		lassign [split [format %.9E $number] E] mantissa exponent
		return [format %1.2f $mantissa]E[format %+03d $exponent]
	}
	
	proc ApplyPreDeformation {} {
	
	

		set solver_path "[pwd]/Step2"

		set fp [open $solver_path.hist r]
		set file_data [read $fp]
		close $fp

		set data [split $file_data "\n"]


		set OptimStep [lindex [lindex $data end-1] 0]
		set OptimStep [format %i $OptimStep]
		
		set buck1 [lindex [lindex $data end-1] 7]
		set buck1 [fmtnum $buck1]

		set tester 0
		set tester2 0

		set tester [catch {

			set input "S2 - B1= $buck1 \[$OptimStep\]"
			*analysisfileset "$solver_path.res"
			*inputsimulation $input "Buckling Mode"
			*createmark nodes 1 "all"
			*applyresults nodes 1 0.002 "total disp"
			*freesimulation 

		}]


		if {$tester == 1} {
			set tester2 [catch {
				set buck2 [expr $buck1 + 0.00001]
				set buck3 [fmtnum $buck2]
				set input "S2 - B1= [fmtnum $buck3] \[$OptimStep\]"
				*analysisfileset "$solver_path.res"
				*inputsimulation $input "Buckling Mode"
				*createmark nodes 1 "all"
				*applyresults nodes 1 0.002 "total disp"
				*freesimulation 
			}]
		}


		if {$tester2 == 1} {

			set buck2 [expr $buck1 - 0.00001]
			set buck3 [fmtnum $buck2]
			set input "S2 - B1= [fmtnum $buck3] \[$OptimStep\]"
			*analysisfileset "$solver_path.res"
			*inputsimulation $input "Buckling Mode"
			*createmark nodes 1 "all"
			*applyresults nodes 1 0.002 "total disp"
			*freesimulation 

		}	
	
	}
	
	proc printAllBucklingModes {solver_path} {
	
		set fp [open $solver_path.out r]
		set file_data [read $fp]
		close $fp
		set data [split $file_data "\n"]
		
		# Find the keyword buckling.
		set firstBuck [lsearch $data  " Subcase  Mode  Buckling Eigenvalue"]
		
		set fp [open $solver_path.buck w]
		for {set i 1} {$i <= 60} {incr i} {			
			puts $fp "[format "%1.7E" [lindex [lindex $data [expr $firstBuck + $i]] 2]]"
		}
		close $fp
	
	}
	
	proc printSensibilities {solver_path} {
	
		set fileName $solver_path.0.asens
		set fileID [open $fileName r]
		set file_data [read $fileID]
		close $fileID
		
		set parsed_data [split $file_data "\n"]
		
		array unset container
		array set container {}
		
		set labelList " "
		
		# Parse the data for each design variables. 
		foreach line $parsed_data {
		
			if {[lindex $line 0] == "Label:"} {
				for {set i 1} {$i<[llength $line]} {incr i} {
					append labelList " [lindex $line $i]"
				}				
			
			
			}
		
			if {[lindex $line 0] == "DESVAR"} {
				set key [lindex $line 1]
				for {set i 2} {$i<[llength $line]} {incr i} {
					append container($key) " [lindex $line $i]"
				}	
			}	
		}
		
		set fileName "$solver_path.sensitivities.txt"
		set fileID [open $fileName w]
		puts $fileID "Label $labelList"
		foreach {key value} [array get container] {
			puts $fileID "$key $value"
		}
		close $fileID	
		
	}

	proc printAllResponses {solver_path} {
	
		set fp [open $solver_path.out r]
		set file_data [read $fp]
		close $fp
		set data [split $file_data "\n"]
		
		# Find the Retained Responses Trigger
		set RetainedPosition 	[lsearch $data  "                           RETAINED RESPONSES TABLE"]
		set ViolationPosition 	[lsearch $data  "                       MOST VIOLATED CONSTRAINTS TABLE"]
		
		set fp [open $solver_path.responses.txt w]
		
		# Write labels;
		for {set i [expr $RetainedPosition + 8]} {$i <= [expr $ViolationPosition - 3]} {incr i} {
			puts -nonewline $fp "[lindex [lindex $data [expr $i]] 2] "
		}
		puts $fp " "
		# Write values;
		for {set i [expr $RetainedPosition + 8]} {$i <= [expr $ViolationPosition - 3]} {incr i} {
			puts -nonewline $fp "[format "%1.7E" [lindex [lindex $data [expr $i]] 6]] "
		}		
		close $fp	
	
	}
	
	proc printAllDesignVariables {solver_path} {
	
		set fp [open $solver_path.out r]
		set file_data [read $fp]
		close $fp
		set data [split $file_data "\n"]
		
		set PositionVariables 	[lsearch $data  "Variable  Variable    Bound      Variable     Bound   "]
		set EndVariables 		[lsearch $data  "note: all design variables are at their bounds"]
	
		set fp [open $solver_path.DPs.txt w]
		# Write labels;
		for {set i [expr $PositionVariables + 3]} {$i <= [expr $EndVariables - 4]} {incr i} {
			puts -nonewline $fp "[lindex [lindex $data [expr $i]] 0] "
		}		
		puts $fp " "
		# Write values;
		for {set i [expr $PositionVariables + 3]} {$i <= [expr $EndVariables - 4]} {incr i} {
			puts -nonewline $fp "[format "%1.7E" [lindex [lindex $data [expr $i]] 3]] "
		}	
		
		close $fp			
	
	}

 }