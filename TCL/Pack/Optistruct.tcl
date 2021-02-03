 ###################################################
# Script : Optistruct								#
# This namespace includes functions to evaluate 	#
# the of the proposed topology						#
# Author : Jean-Francois Gamache					#
# Version: 0.5										#
# Last Updated : January 18th, 2021					#
 ###################################################
 
 
 namespace eval Optistruct {

	proc RunOptistruct {path name} {
	
		if {$::General::Sizing} {
			*opticontrolcreate80sr1 1 30 0 0 0 0.6 0 0.01 0 1 0 0 0 0 0 0.005 0 0.5 0 0.2 0 0.5 1 0 0 10 0 0 0 0 0 0 0 0 1 0 1 0
		} else {
			*opticontrolcreate80sr1 1 0 0 0 0 0.6 0 0.01 0 1 0 0 0 0 0 0.005 0 0.5 0 0.2 0 0.5 1 0 0 10 0 0 0 0 0 0 0 0 1 0 1 0
		}
		
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
		exec "$home/hwsolvers/scripts/optistruct.bat" "$solver_path.fem" -checkel NO -nt 2
		
		::Steps::printAllResponses 			$solver_path
		::Steps::printAllDesignVariables 	$solver_path
		
		if {$::General::Complexity} {
			::Steps::printSensibilities 		$solver_path
		}
	}
	

	proc RunSizing {path name maxIter} {
	
		eval *opticontrolcreate80sr1 1 $maxIter 0 0 0 0.6 0 0.01 0 1 0 0 0 0 0 0.005 0 0.5 0 0.2 0 0.5 1 1 0 10 0 0 0 0 0 0 0 0 1 0 1 0

		# Set the environnement variables
		set home [hm_info -appinfo ALTAIR_HOME]
		set solver_path "$path/$name"
		
		# Save the temp hm file. 
		hm_answernext "yes"
		*writefile "$solver_path.hm" 1
		
		# Launches optitruct and solves the problem once. 
		hm_answernext "yes"
		*feoutputwithdata "$home/templates/feoutput/optistruct/optistruct" "$solver_path.fem" 1 0 1 1 1
		exec "$home/hwsolvers/scripts/optistruct.bat" "$solver_path.fem" -checkel NO
		
	}
	
	proc RunComplex {path name} {
	
		eval *opticontrolcreate80sr1 1 0 0 0 0 0.6 0 0.01 0 1 0 0 0 0 0 0.005 0 0.5 0 0.2 0 0.5 1 0 0 10 0 0 0 0 0 0 0 0 1 0 1 0

		# Set the environnement variables
		set home [hm_info -appinfo ALTAIR_HOME]
		set solver_path "$path/$name"
		
		# Save the temp hm file. 
		hm_answernext "yes"
		*writefile "$solver_path.hm" 1
		
		# Launches optitruct and solves the problem once. 
		hm_answernext "yes"
		*feoutputwithdata "$home/templates/feoutput/optistruct/optistruct" "$solver_path.fem" 1 0 1 1 1
		exec "$home/hwsolvers/scripts/optistruct.bat" "$solver_path.fem" -nt 2 -checkel NO
		
		
		
	}

}