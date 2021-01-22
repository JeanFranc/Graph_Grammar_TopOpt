 ###################################################
# Script : Complexity								#
# This namespace includes functions to evaluate 	#
# the complexity of the proposed topology			#
# Author : Jean-Francois Gamache					#
# Version: 0.5										#
# Last Updated : July 07th, 2020					#
 ###################################################
 
 namespace eval Complexity {
	
	
	proc evaluateComplexity_V1 {path name} {
	
		# Set Optimization Controls
		*opticontrolcreate80sr1 1 0 0 0 0 0.6 0 0.01 0 1 0 0 0 0 0 0.005 0 0.5 0 0.2 0 0.5 1 0 0 10 0 0 0 0 0 0 0 0 1 0 1 0
		*opticontrolupdateeslparameters 0 30 0 1 0 0.3
		*opticontrolupdateoptimizationparameters 0 2 0 "MFD" 0 20 0 20 0 1
		*opticontrolupdateremeshparameters 0 0
		*opticontrolupdateapproxparameters 0 "FULL"
		*opticontrolupdatebarconparameters 0 "REQUIRED"
		*opticontrolupdatecontolparameters 0 1
		*opticontrolupdatetopdiscparameters 0 "NO"
		*opticontrolupdatetopdvparameters 0 "ALTER"
		*opticontrolupdatetoprstparameters 0 "STRICT"
		*opticontrolupdatemanthrparameters 0 1

		### This sections runs it for the small skin. 

		# Set the environnement variables
		set home [hm_info -appinfo ALTAIR_HOME]
		set solver_path "$path/$name\_1"
		
		# Save the temp hm file. 
		hm_answernext "yes"
		*writefile "$solver_path.hm" 1
		
		# Launches optitruct and solves the problem once. 
		hm_answernext "yes"
		*feoutputwithdata "$home/templates/feoutput/optistruct/optistruct" "$solver_path.fem" 1 0 1 1 1
		exec "$home/hwsolvers/scripts/optistruct.bat" "$solver_path.fem" -checkel NO

		#::Steps::printAllBucklingModes $solver_path
		::Steps::printAllResponses 			$solver_path
		::Steps::printAllDesignVariables 	$solver_path
		::Steps::printSensibilities 		$solver_path

		
		# ### This sections runs it for the bigger skin. 
		
		# # Change the values of the skin
		# *createmark designvariables 1 all
		# set allVars [hm_getmark designvariables 1]		
		
		# foreach var $allVars {
		
			# set tname [hm_getvalue designvariables id=$var dataname=name]
			# set subname [string range $tname 0 3]
			
			# if {$subname == "Skin"} {
				# eval *setvalue designvariables id=$var initialvalue=0.5
			# } 
			
			# if {$subname == "Stif"} {
				# eval *setvalue designvariables id=$var initialvalue=0.05
			# }
			
		# }
		
		# set solver_path "$path/$name\_2"
		
		# # Save the temp hm file. 
		# hm_answernext "yes"
		# *writefile "$solver_path.hm" 1
		
		# # Launches optitruct and solves the problem once. 
		# hm_answernext "yes"
		# *feoutputwithdata "$home/templates/feoutput/optistruct/optistruct" "$solver_path.fem" 1 0 1 1 1
		# exec "$home/hwsolvers/scripts/optistruct.bat" "$solver_path.fem" -checkel NO

		# # ::Steps::printAllBucklingModes $solver_path
		# ::Steps::printAllResponses $solver_path
		# ::Steps::printAllDesignVariables $solver_path
		
		# set fileName $solver_path.0.asens
		# set fileID [open $fileName r]
		# set file_data [read $fileID]
		# close $fileID
		
		# set parsed_data [split $file_data "\n"]
		
		# array unset container
		# array set container {}
		
		# set labelList " "
		
		# # Parse the data for each design variables. 
		# foreach line $parsed_data {
		
			# if {[lindex $line 0] == "Label:"} {
				# for {set i 1} {$i<[llength $line]} {incr i} {
					# append labelList " [lindex $line $i]"
				# }				
			
			
			# }
		
			# if {[lindex $line 0] == "DESVAR"} {
				# set key [lindex $line 1]
				# for {set i 2} {$i<[llength $line]} {incr i} {
					# append container($key) " [lindex $line $i]"
				# }	
			# }	
		# }
		
		# set fileName "$solver_path.sensitivities.txt"
		# set fileID [open $fileName w]
		# puts $fileID "Label : $labelList"
		# foreach {key value} [array get container] {
			# puts $fileID "$key : $value"
		# }
		# close $fileID
		
		
		#### UNCOMMENT FOR PYTHON USAGE ####
		##############################################################
		
		# set 	dirPath 	[file dirname [info script]]
		# set 	coupling 	[exec $dirPath/Pack/Complex.bat $path $fileName]

		# set fp [open $path/Coupling.txt w]
		
		# puts $fp "The coupling is : $coupling"
		# close $fp
		
		#######################################################
		
		# # Sum for each buckling mode, by type of geometry.
		
		# array unset MaxStiff
		# array unset MaxSkin
		# array unset Coupling
		
		# set temp [array get container]
		
		# set buckLength [llength [lindex $temp 1]]
		# incr buckLength -1
		
		# set zeros 0
		
		# for {set i 1} {$i < $buckLength} {incr i} {
			# append zeros " 0"
		# }
		
		# set MaxStiff $zeros
		# set MaxSkin  $zeros

		# # Find the max for each eigenvalue vector. 
		
		# foreach {key data} [array get container] {
			# # <200  ==> Stiffeners_Thicknesses
			# # >=200 ==> Skin_Thicknesses
			
			# # Remove mass from the list. 
			# set data2 [lrange $data 1 end] 
			
			# if {$key < 200} {
				# set j 0
				
				# foreach buckMode $data2 {
					# lset MaxStiff $j [expr max([lindex $MaxStiff $j],abs($buckMode))]
					# incr j
				# }
			# } elseif {$key >= 200} {
				# set j 0
				# foreach buckMode $data2 {
					# lset MaxSkin $j [expr max([lindex $MaxSkin $j],abs($buckMode))]
					# incr j
				# }			
			# } else {
				# error "WTF"
			# }
		
		# }

		# set Coupling 0

		# # Find the coupling ratio for each buckling modes. 
		# for {set i 0} {$i < [llength $MaxStiff]} {incr i} {
			# set thisStiff [lindex $MaxStiff $i]
			# set thisSkin  [lindex $MaxSkin $i]
			
			# set CouplingTemp [expr abs($thisSkin/$thisStiff-1)]
			# set Coupling [expr $Coupling + $CouplingTemp]
		
		# }

		# set fileID [open $solver_path.complexity w]
		# puts $fileID "Complexity : $Coupling"
		# close $fileID
	
	}
	
	proc evaluateComplexity_V1_Sizing {path name} {

		# Set Optimization Controls
		*opticontrolcreate80sr1 1 30 0 0 0 0.6 0 0.01 0 1 0 0 0 0 0 0.005 0 0.5 0 0.2 0 0.5 1 0 0 10 0 0 0 0 0 0 0 0 1 0 1 0
		*opticontrolupdateeslparameters 0 30 0 1 0 0.3
		*opticontrolupdateoptimizationparameters 0 2 0 "SQP" 0 20 0 20 0 1
		*opticontrolupdateremeshparameters 0 0
		*opticontrolupdateapproxparameters 0 "FULL"
		*opticontrolupdatebarconparameters 0 "REQUIRED"
		*opticontrolupdatecontolparameters 0 1
		*opticontrolupdatetopdiscparameters 0 "NO"
		*opticontrolupdatetopdvparameters 0 "ALTER"
		*opticontrolupdatetoprstparameters 0 "STRICT"
		*opticontrolupdatemanthrparameters 0 1

		# Set the environnement variables
		set home [hm_info -appinfo ALTAIR_HOME]
		set solver_path "$path/$name\_1"
		
		# Save the temp hm file. 
		hm_answernext "yes"
		*writefile "$solver_path.hm" 1
		
		# Launches optitruct and solves the problem once. 
		hm_answernext "yes"
		*feoutputwithdata "$home/templates/feoutput/optistruct/optistruct" "$solver_path.fem" 1 0 1 1 1
		exec "$home/hwsolvers/scripts/optistruct.bat" "$solver_path.fem" -checkel NO

		#::Steps::printAllBucklingModes $solver_path
		::Steps::printAllResponses 			$solver_path
		::Steps::printAllDesignVariables 	$solver_path
		::Steps::printSensibilities 		$solver_path
		
	}
	
	proc evaluateComplexity_V2 {} {
	
		set home [hm_info -appinfo ALTAIR_HOME]
		
		set variableN [expr [llength $::Geometry::ThetaVec]]
		
		set permX 		$::Geometry::XVec
		set permTheta 	$::Geometry::ThetaVec

		# Evaluate baseline.

		::Geometry::createGeometry_xtheta 
		::Material::createMatCard
		::Property::createPropCard
		::BCs::setStandardPanel
		::LoadSteps::setStaticAnalysis
		::LoadSteps::setLinearBuckling
		::Steps::launchStep1 Step1
		
		# # Set Header 
		# set header "Header  \t\t"
		# for {set i 1} {$i <= 30} {incr i} {
			# append header "dB$i\t"
		# }
		
		set fID [open "[pwd]/ComplexityTable.txt" w]
		# puts $fID $header
		set buck1 [readBuckling Step1]
		#set line1 "Baseline $buck1"
		#puts $fID $line1
		
		set dT 0.05
		
		# Evaluate the sensitivity. 
		for {set i 0} {$i < $variableN} {incr i} {
			
			# Set the vector + dT for Xi.
			set tempXVEC $permX			
			set tempXVEC [lreplace $tempXVEC $i $i [expr [lindex $tempXVEC $i] + $dT]]						
			set ::Geometry::XVec $tempXVEC
			set ::Geometry::ThetaVec $permTheta
		
			# Regenerate the problem for X_i
			::Geometry::createGeometry_xtheta 
			::Material::createMatCard
			::Property::createPropCard
			::BCs::setStandardPanel
			::LoadSteps::setStaticAnalysis
			::LoadSteps::setLinearBuckling
			::Steps::launchStep1 X_$i
			set buck [readBuckling X_$i]
			# set line "Buck X_$i ; $buck"
			# puts $fID $line
					
			# Calculate the gradients
			set grad ""
			for {set j 0} {$j < 30} {incr j} {
				set buck_temp [lindex $buck $j]
				set buck_perm [lindex $buck1 $j]
			#	puts "$j : $buck_temp, $buck_perm"
				set grad_temp [expr ($buck_temp - $buck_perm) / $dT ]
				append grad [format "%1.7E " "$grad_temp"]
			}
			set line "Gradient_X_$i $grad"
			puts $fID $line
			
			# Set the vector + dT for Theta_i.
			set tempXTHETA $permTheta			
			set tempXTHETA [lreplace $tempXTHETA $i $i [expr [lindex $tempXTHETA $i] + $dT]]		
			set ::Geometry::XVec $permX			
			set ::Geometry::ThetaVec $tempXTHETA
			
			# Regenerate the problem for Theta_i
			::Geometry::createGeometry_xtheta 
			::Material::createMatCard
			::Property::createPropCard
			::BCs::setStandardPanel
			::LoadSteps::setStaticAnalysis
			::LoadSteps::setLinearBuckling
			::Steps::launchStep1 Theta_$i
			set buck [readBuckling Theta_$i]
			#set line "Buck Theta_$i ; $buck"
				
			# Calculate the gradients
			set grad ""
			for {set j 0} {$j < 30} {incr j} {
				set buck_temp [lindex $buck $j]
				set buck_perm [lindex $buck1 $j]
				set grad_temp [expr ($buck_temp - $buck_perm) / $dT ]
				append grad [format "%1.7E " "$grad_temp"]
			}
			set line "Gradient_Theta_$i $grad"			
			puts $fID $line		
		}
		
		close $fID
		
		# Reread the file, by column.
		set fp [open "[pwd]/ComplexityTable.txt" r]
		set file_data [read $fp]
		close $fp
		set data [split $file_data "\n"]
		
		# Find the max of each column		
		set new_max [lindex $data 0]
		
		for {set i 0} {$i < [expr [llength $::Geometry::XVec] * 2]} {incr i} {
			for {set j 1} {$j < 31} {incr j} {
				set this_grad [lindex [lindex $data $i] $j]
				set new_max [lreplace $new_max $j $j [expr max([lindex $new_max $j],abs($this_grad))]]
			}
		}
		
		# Normalize and sum the data by column	
		set sum "SUM: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
		for {set i 0} {$i < [expr [llength $::Geometry::XVec] * 2]} {incr i} {
			for {set j 1} {$j < 31} {incr j} {
				set norm_grad [expr abs([lindex [lindex $data $i] $j]) / [lindex $new_max $j]]
				set sum [lreplace $sum $j $j [expr [lindex $sum $j] + $norm_grad]]
			}
		}		
		
		
		
		set comp_index 0
		
		# Create the complexity index.
		for {set j 1} {$j < 31} {incr j} {
			set this_grad [lindex $sum $j]
			#set temp [expr sqrt($this_grad**2)-1]
		
			set comp_index [expr $comp_index + $this_grad*1/$j]
		}
		
		set fileid [open [pwd]/Complexity_Index.txt w]
		puts $fileid "Complexity : $comp_index"
		close $fileid
	
	}
  
	proc readBuckling {name} {
	
		set solver_path [pwd]/$name
	
		set fp [open $solver_path.out r]
		set file_data [read $fp]
		close $fp
		set data [split $file_data "\n"]
		
		# Find the keyword buckling.
		set firstBuck [lsearch $data  " Subcase  Mode  Buckling Eigenvalue"]
		
		set buck ""		
		for {set i 1} {$i <= 30} {incr i} {
			append buck "[format "%1.7E" [lindex [lindex $data [expr $firstBuck + $i]] 2]] "
		}
		
		return $buck
	
	
	}
  
 }