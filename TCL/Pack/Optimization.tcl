 ####################################################
# Script : Optimization								#
# Set-ups different optimization parameters		    #
# Author : Jean-Francois Gamache					#
# Version: 0.5										#
# Last Updated : July 08th, 2020					#
 ####################################################
 
 
namespace eval Optimization {
 
	variable handleList " "
	variable MassCon   
 
 proc setOptimizationCards {} {
	
		if {$::General::Sizing} {
			set TempBuck 1.0
			set TempStress $::Material::Fcy
		} else {
			set TempBuck 1000.0
			set TempStress [expr 100*$::Material::Fcy]
		}
	
		# Add the mass response
		*createarray 6 0 0 0 0 0 0
		*createdoublearray 6 0 0 0 0 0 0
		*optiresponsecreate "mass" 29 0 0 0 0 0 6 0 0 0 1 6 1 6
		*optiresponsesetequationdata1 "mass" 0 0 0 0 1 0
		*optiresponsesetequationdata2 "mass" 0 0 1 0
		*optiresponsesetequationdata3 "mass" 0 0 1 0
		*optiresponsesetequationdata4 "mass" 0 0 0 0 1 0 1 0

		# Add the minimum stress variable.
		*createmark props 1 all
		set allProps [hm_getmark props 1]
		
		set att "props $allProps"
		eval *createentity optiresponses name=Tot_Stress id=2 response=9  attribute1_list={$att} responsegroup2="both surfaces"
		
		eval *createentity optiresponses name=Mean_Stress id=3 response=35 attribute_b_selection_optifunction=9 dresp1vrid=2
		eval *setvalue optiresponses id=3 ROW=0 STATUS=2 drespvopttable= {ALL}	

		# Add a constraint on all components
		set id4000 4000
		set id5000 5000
		set id6000 6000
		
		foreach prop $allProps {
		
			# Create max Stress response. 
		
			set nameTemp "S_$prop"
			set nameTemp2 "A_$prop"
			
			set att "props $prop"
			eval *createentity optiresponses name=$nameTemp id=$id4000 response=9  attribute1_list={$att} responsegroup2="both surfaces"

			eval *createentity optiresponses name=$nameTemp2 id=$id5000 response=35 attribute_b_selection_optifunction=8 dresp1vrid=$id4000
			eval *setvalue optiresponses id=$id5000 ROW=0 STATUS=2 drespvopttable= {ALL}	
			
			if {$::General::Stress} {
			*createentity opticonstraints name=$nameTemp2 id=$id5000 
			set response2 "optiresponses $id5000"
			eval *setvalue opticonstraints id=$id5000 responseid={$response2}
			eval *setvalue opticonstraints id=$id5000 STATUS=2 upperoption=1
			eval *setvalue opticonstraints id=$id5000 STATUS=1 upperbound=$TempStress	
			eval *setvalue opticonstraints id=$id5000 STATUS=2 loadsteplist={loadsteps 1}
			}

			incr id4000
			incr id5000

			# Create Compliance Response.
			
			set name_6 "C_$prop"

			set att "props $prop" 
			eval *createentity optiresponses name=$name_6 id=$id6000 response=31 property_attrib_b=1 attribute1_list={$att} 
			
			if {$::General::Complexity} {
				*createentity opticonstraints name=$name_6 id=$id6000 
				set response3 "optiresponses $id6000"
				*setvalue opticonstraints id=$id6000 responseid={$response3}
				*setvalue opticonstraints id=$id6000 STATUS=2 upperoption=1
				*setvalue opticonstraints id=$id6000 STATUS=1 upperbound=0.0001	
				*setvalue opticonstraints id=$id6000 STATUS=2 loadsteplist={loadsteps 1}			
			}
			
			incr id6000
			
		}

		if {$::General::Buckling} {

			set Alpha 1.01

			# Add the buckling eigenvalue responses
			for {set i 1} {$i <= 60} {incr i} {
			
				set name "B_$i"
				set id [expr 1000 + $i]
				eval *createentity optiresponses name=$name id=$id response=6 modenumber=$i
				
				# Create the eigenvalue constraint. V1		
				*createarray 1 2
				eval *opticonstraintcreate $name $id 0 $TempBuck 1e+20 1 1
				set TempBuck [expr $TempBuck * $Alpha]
				set TempBuck [expr $TempBuck * $Alpha]

			}

		}

		# Create the design variable for each sections. 
		*createmark props 1 all
		set allProps [hm_getmark props 1]
		
		foreach prop $allProps {
		
			set name [hm_getvalue property id=$prop dataname=name]
			set subname [string range $name 0 3]
			
			if {$subname == "Skin"} {
				eval *createentity designvariable name=$name id=$prop initialvalue=0.05 lowerbound=0.05 upperbound=0.5
			} elseif {$subname == "Stif"} {
				eval *createentity designvariable name=$name id=$prop initialvalue=0.50 lowerbound=0.05 upperbound=0.5
			}
			eval *createentity dvprels name=$name id=$prop property=1 propertyid={props $prop} desvarlist=$prop	
		
		}

		# Removes the screening of constraints.
		*createentity optidscreens 
		*setvalue optidscreens id=1 STATUS=2 autotoggle=1
		*setvalue optidscreens id=1 STATUS=2 autolevel=0
		*setvalue optidscreens id=1 STATUS=2 EquaToggle=1
		*setvalue optidscreens id=1 STATUS=2 EquaMaxc=300
		*setvalue optidscreens id=1 STATUS=2 EquaThreshold=-0.5
		*setvalue optidscreens id=1 STATUS=2 lamatoggle=1
		*setvalue optidscreens id=1 STATUS=2 lamathreshold=-0.5
		*setvalue optidscreens id=1 STATUS=2 lamamaxc=200
		*setvalue optidscreens id=1 STATUS=2 CompToggle=1
		*setvalue optidscreens id=1 STATUS=2 CompThreshold=-0.5
		*setvalue optidscreens id=1 STATUS=2 CompMaxc=300
		
		# Create the objective
		*optiobjectivecreate 1 0 0

		# Create the sensitivity output.
		*cardcreate "OUTPUT"
		*startnotehistorystate {Attached attributes to card}
		*attributeupdateint cards 1 3850 1 0 0 1
		*attributeupdatestring cards 1 130 1 0 0 "0"
		*createstringarray 1 "ASCSENS"
		*attributeupdatestringarray cards 1 3851 1 2 0 1 1
		*createstringarray 1 "ALL"
		*attributeupdatestringarray cards 1 3854 1 2 0 1 1
		*createstringarray 1 "FL"
		*attributeupdatestringarray cards 1 3852 1 2 0 1 1
		*endnotehistorystate {Attached attributes to card}

	}
 
	proc setStep2Optimization {} {
	
		# Add the mass response
		*createarray 6 0 0 0 0 0 0
		*createdoublearray 6 0 0 0 0 0 0
		*optiresponsecreate "mass" 29 0 0 0 0 0 6 0 0 0 1 6 1 6
		*optiresponsesetequationdata1 "mass" 0 0 0 0 1 0
		*optiresponsesetequationdata2 "mass" 0 0 1 0
		*optiresponsesetequationdata3 "mass" 0 0 1 0
		*optiresponsesetequationdata4 "mass" 0 0 0 0 1 0 1 0

		# Add the minimum stress variable.
		*createmark props 1 all
		set allProps [hm_getmark props 1]
		
		set att "props $allProps"
		eval *createentity optiresponses name=Tot_Stress id=2 response=9  attribute1_list={$att} responsegroup2="both surfaces"
		
		eval *createentity optiresponses name=Mean_Stress id=3 response=35 attribute_b_selection_optifunction=9 dresp1vrid=2
		eval *setvalue optiresponses id=3 ROW=0 STATUS=2 drespvopttable= {ALL}	
		
		# Create P_CR equation.
		*createentity dequations name=Multiplication id=1 number_of_lines=1
		*setvalue dequations id=1 ROW=0 STATUS=2 equationstring= {f(x,y)=x*y}
		
		# Add a constraint on all components
		set id4000 4000
		set id5000 5000
		set id6000 6000
		
		foreach prop $allProps {
		
			# Create max Stress response. 
		
			set nameTemp "S_$prop"
			set nameTemp2 "A_$prop"
			
			set att "props $prop"
			eval *createentity optiresponses name=$nameTemp id=$id4000 response=9  attribute1_list={$att} responsegroup2="both surfaces"

			eval *createentity optiresponses name=$nameTemp2 id=$id5000 response=35 attribute_b_selection_optifunction=8 dresp1vrid=$id4000
			eval *setvalue optiresponses id=$id5000 ROW=0 STATUS=2 drespvopttable= {ALL}	
			
			*createentity opticonstraints name=$nameTemp2 id=$id5000 
			set response2 "optiresponses $id5000"
			*setvalue opticonstraints id=$id5000 responseid={$response2}
			*setvalue opticonstraints id=$id5000 STATUS=2 upperoption=1
			*setvalue opticonstraints id=$id5000 STATUS=1 upperbound=100	
			*setvalue opticonstraints id=$id5000 STATUS=2 loadsteplist={loadsteps 1}
			incr id4000
			incr id5000
			
			# Create Compliance Response.
			
			set name_6 "C_$prop"

			set att "props $prop" 
			eval *createentity optiresponses name=$name_6 id=$id6000 response=31 property_attrib_b=1 attribute1_list={$att} 
			
			*createentity opticonstraints name=$name_6 id=$id6000 
			set response3 "optiresponses $id6000"
			*setvalue opticonstraints id=$id6000 responseid={$response3}
			*setvalue opticonstraints id=$id6000 STATUS=2 upperoption=1
			*setvalue opticonstraints id=$id6000 STATUS=1 upperbound=0.0001	
			*setvalue opticonstraints id=$id6000 STATUS=2 loadsteplist={loadsteps 1}			
			
			
			incr id6000
			
			
		}

		# Add the buckling eigenvalue responses
		for {set i 1} {$i <= 60} {incr i} {
			set name "B_$i"
			set id [expr 1000 + $i]
			eval *createentity optiresponses name=$name id=$id response=6 modenumber=$i
			
			# Create the eigenvalue constraint. V1		
			*createarray 1 2
			eval *opticonstraintcreate $name $id 0 50 1e+20 1 1
			
			# Create the eigenvalue constraint. V2		
			# set response2 "optiresponses $id"
			# *createentity opticonstraints name=$name id=$id 
			# *setvalue opticonstraints id=$id responseid={$response2}
			# *setvalue opticonstraints id=$id STATUS=2 loweroption=1
			# *setvalue opticonstraints id=$id STATUS=1 lowerbound=50.0
			# *setvalue opticonstraints id=$id STATUS=2 loadsteplist={loadsteps 2}
			
			# # Create the P_CR Constraint. 
			
			# set name2 "P_$i"
			# set id2 [expr 2000 + $i]
			# eval *createentity optiresponses name=$name2 id=$id2 response=35 functionid={dequations 1}
			
			# set responses "optiresponses 3 $id"
			# set loadsteps "loadsteps 1-2"
			
			# *setvalue optiresponses id=$id2 STATUS=2 responselist={$responses}
			# *setvalue optiresponses id=$id2 STATUS=2 function_loadsteplist={$loadsteps}			

			# set response2 "optiresponses $id2" 
			# *createentity opticonstraints name=$name2 id=$id2  
			# *setvalue opticonstraints id=$id2 responseid={$response2} 
			# *setvalue opticonstraints id=$id2 STATUS=2 loweroption=1 
			# *setvalue opticonstraints id=$id2 STATUS=1 lowerbound=500000 

		}

		# Create the design variable for each sections. 
		*createmark props 1 all
		set allProps [hm_getmark props 1]
		
		foreach prop $allProps {
		
			set name [hm_getvalue property id=$prop dataname=name]
			set subname [string range $name 0 3]
			
			if {$subname == "Skin"} {
				eval *createentity designvariable name=$name id=$prop initialvalue=0.05 lowerbound=0.05 upperbound=0.5
			} elseif {$subname == "Stif"} {
				eval *createentity designvariable name=$name id=$prop initialvalue=0.50 lowerbound=0.05 upperbound=0.5
			}
			eval *createentity dvprels name=$name id=$prop property=1 propertyid={props $prop} desvarlist=$prop	
		
		}

		# Removes the screening of constraints.
		*createentity optidscreens 
		*setvalue optidscreens id=1 STATUS=2 autotoggle=1
		*setvalue optidscreens id=1 STATUS=2 autolevel=0
		*setvalue optidscreens id=1 STATUS=2 EquaToggle=1
		*setvalue optidscreens id=1 STATUS=2 EquaMaxc=300
		*setvalue optidscreens id=1 STATUS=2 EquaThreshold=-0.5
		*setvalue optidscreens id=1 STATUS=2 lamatoggle=1
		*setvalue optidscreens id=1 STATUS=2 lamathreshold=-0.5
		*setvalue optidscreens id=1 STATUS=2 lamamaxc=200
		*setvalue optidscreens id=1 STATUS=2 CompToggle=1
		*setvalue optidscreens id=1 STATUS=2 CompThreshold=-0.5
		*setvalue optidscreens id=1 STATUS=2 CompMaxc=300

		# # Create the morphing domains
		# *morphcreatedomaindc elements 0 -1 0 0 0 0
		# *morphstoredomains 1
		# *createmark elements 1 all
		# *morphcreatedomaindc elements 1 2 0 0 0 1
		# *createmark domains 1 all
		# *morphreparam domains 1

		# # Creates the shape for stiffener height
		# *createmark handles 1 all
		# set h1 [hm_getmark handles 1]
		# variable handleList

		# set id 300

		# foreach handle $h1 {
			# set grid 		[hm_getentityvalue handle $handle grid 0]
			# set gridCoordz  [hm_getentityvalue node $grid globalz 0]	
			# if {$gridCoordz > 0.0} {
				# #append handleList " $handle"
				# eval *createmark handles 1 $handle
				# *morphhandlepertxyz handles 1 0 0 1 0 0 2
				# eval *morphshapecreatecolor "StiffHeight_$id" 0 10
				# *createmarklast shapes 1
				# set shapeID [hm_getmark shapes 1]
				# *clearmark shapes 1
				# *morphdoshape 3	
				# *createentity designvars id=$id config=115 initialvalue=0.0 lowerbound=-1.0 upperbound=1.0 shapeid=$shapeID name=Height_$id
				# #eval *shpdesvarcreatewithddvalfield "Stiff_Height_$id" 2 0.5 0 -1 1 0
				# incr id
			# }
		# }

		# # Create the shape design variable. (Only one variable)
		# eval *createmark handles 1 $handleList
		# *morphhandlepertxyz handles 1 0 0 1 0 0 2
		# *morphshapecreatecolor "StiffHeight" 0 10
		# *morphdoshape 3		
		# *shpdesvarcreatewithddvalfield "Stiff_Height" 2 0.5 0 -1 1 0
		
		#*createmark shapes 1 "StiffHeight"
		#eval *morphshapeapply shapes 1 -1
		
		# Create the objective
		*optiobjectivecreate 1 0 0

		# Create the sensitivity output.
		*cardcreate "OUTPUT"
		*startnotehistorystate {Attached attributes to card}
		*attributeupdateint cards 1 3850 1 0 0 1
		*attributeupdatestring cards 1 130 1 0 0 "0"
		*createstringarray 1 "ASCSENS"
		*attributeupdatestringarray cards 1 3851 1 2 0 1 1
		*createstringarray 1 "ALL"
		*attributeupdatestringarray cards 1 3854 1 2 0 1 1
		*createstringarray 1 "FL"
		*attributeupdatestringarray cards 1 3852 1 2 0 1 1
		*endnotehistorystate {Attached attributes to card}

	}
	
	proc setJustSizing {} {
	
		# Add the mass response
		*createarray 6 0 0 0 0 0 0
		*createdoublearray 6 0 0 0 0 0 0
		*optiresponsecreate "mass" 29 0 0 0 0 0 6 0 0 0 1 6 1 6
		*optiresponsesetequationdata1 "mass" 0 0 0 0 1 0
		*optiresponsesetequationdata2 "mass" 0 0 1 0
		*optiresponsesetequationdata3 "mass" 0 0 1 0
		*optiresponsesetequationdata4 "mass" 0 0 0 0 1 0 1 0

		# Add the minimum stress variable.
		*createmark props 1 all
		set allProps [hm_getmark props 1]
		
		set att "props $allProps"
		eval *createentity optiresponses name=Tot_Stress id=2 response=9  attribute1_list={$att} responsegroup2="both surfaces"
		
		eval *createentity optiresponses name=Mean_Stress id=3 response=35 attribute_b_selection_optifunction=9 dresp1vrid=2
		eval *setvalue optiresponses id=3 ROW=0 STATUS=2 drespvopttable= {ALL}	
		
		# Create P_CR equation.
		*createentity dequations name=Multiplication id=1 number_of_lines=1
		*setvalue dequations id=1 ROW=0 STATUS=2 equationstring= {f(x,y)=x*y}
		
		# Add a constraint on all components
		set id4000 4000
		set id5000 5000
		set id6000 6000
		
		foreach prop $allProps {
		
			# Create max Stress response. 
		
			set nameTemp "S_$prop"
			set nameTemp2 "A_$prop"
			
			set att "props $prop"
			eval *createentity optiresponses name=$nameTemp id=$id4000 response=9  attribute1_list={$att} responsegroup2="both surfaces"

			eval *createentity optiresponses name=$nameTemp2 id=$id5000 response=35 attribute_b_selection_optifunction=8 dresp1vrid=$id4000
			eval *setvalue optiresponses id=$id5000 ROW=0 STATUS=2 drespvopttable= {ALL}	
			
			*createentity opticonstraints name=$nameTemp2 id=$id5000 
			set response2 "optiresponses $id5000"
			*setvalue opticonstraints id=$id5000 responseid={$response2}
			*setvalue opticonstraints id=$id5000 STATUS=2 upperoption=1
			*setvalue opticonstraints id=$id5000 STATUS=1 upperbound=40000	
			*setvalue opticonstraints id=$id5000 STATUS=2 loadsteplist={loadsteps 1}
			incr id4000
			incr id5000
			
			# Create Compliance Response.
			
			set name_6 "C_$prop"

			set att "props $prop" 
			eval *createentity optiresponses name=$name_6 id=$id6000 response=31 property_attrib_b=1 attribute1_list={$att} 
			
			# *createentity opticonstraints name=$name_6 id=$id6000 
			# set response3 "optiresponses $id6000"
			# *setvalue opticonstraints id=$id6000 responseid={$response3}
			# *setvalue opticonstraints id=$id6000 STATUS=2 upperoption=1
			# *setvalue opticonstraints id=$id6000 STATUS=1 upperbound=0.0001	
			# *setvalue opticonstraints id=$id6000 STATUS=2 loadsteplist={loadsteps 1}			
			
			
			incr id6000
			
			
		}

		set Temp 1.0
		set Alpha 1.01

		# Add the buckling eigenvalue responses
		for {set i 1} {$i <= 60} {incr i} {
		
			set name "B_$i"
			set id [expr 1000 + $i]
			eval *createentity optiresponses name=$name id=$id response=6 modenumber=$i
			
			# Create the eigenvalue constraint. V1		
			*createarray 1 2
			eval *opticonstraintcreate $name $id 0 $Temp 1e+20 1 1
			set Temp [expr $Temp * $Alpha]
			set Temp [expr $Temp * $Alpha]

		}

		# Create the design variable for each sections. 
		*createmark props 1 all
		set allProps [hm_getmark props 1]
		
		foreach prop $allProps {
		
			set name [hm_getvalue property id=$prop dataname=name]
			set subname [string range $name 0 3]
			
			if {$subname == "Skin"} {
				eval *createentity designvariable name=$name id=$prop initialvalue=0.05 lowerbound=0.05 upperbound=0.5
			} elseif {$subname == "Stif"} {
				eval *createentity designvariable name=$name id=$prop initialvalue=0.50 lowerbound=0.05 upperbound=0.5
			}
			eval *createentity dvprels name=$name id=$prop property=1 propertyid={props $prop} desvarlist=$prop	
		
		}

		# Removes the screening of constraints.
		*createentity optidscreens 
		*setvalue optidscreens id=1 STATUS=2 autotoggle=1
		*setvalue optidscreens id=1 STATUS=2 autolevel=0
		*setvalue optidscreens id=1 STATUS=2 EquaToggle=1
		*setvalue optidscreens id=1 STATUS=2 EquaMaxc=300
		*setvalue optidscreens id=1 STATUS=2 EquaThreshold=-0.5
		*setvalue optidscreens id=1 STATUS=2 lamatoggle=1
		*setvalue optidscreens id=1 STATUS=2 lamathreshold=-0.5
		*setvalue optidscreens id=1 STATUS=2 lamamaxc=200
		*setvalue optidscreens id=1 STATUS=2 CompToggle=1
		*setvalue optidscreens id=1 STATUS=2 CompThreshold=-0.5
		*setvalue optidscreens id=1 STATUS=2 CompMaxc=300
		
		# Create the objective
		*optiobjectivecreate 1 0 0

		# Create the sensitivity output.
		*cardcreate "OUTPUT"
		*startnotehistorystate {Attached attributes to card}
		*attributeupdateint cards 1 3850 1 0 0 1
		*attributeupdatestring cards 1 130 1 0 0 "0"
		*createstringarray 1 "ASCSENS"
		*attributeupdatestringarray cards 1 3851 1 2 0 1 1
		*createstringarray 1 "ALL"
		*attributeupdatestringarray cards 1 3854 1 2 0 1 1
		*createstringarray 1 "FL"
		*attributeupdatestringarray cards 1 3852 1 2 0 1 1
		*endnotehistorystate {Attached attributes to card}	
	
	}
 
	proc setOptimNoBuck {} {
	
		# Add the mass response
		*createarray 6 0 0 0 0 0 0
		*createdoublearray 6 0 0 0 0 0 0
		*optiresponsecreate "mass" 29 0 0 0 0 0 6 0 0 0 1 6 1 6
		*optiresponsesetequationdata1 "mass" 0 0 0 0 1 0
		*optiresponsesetequationdata2 "mass" 0 0 1 0
		*optiresponsesetequationdata3 "mass" 0 0 1 0
		*optiresponsesetequationdata4 "mass" 0 0 0 0 1 0 1 0


		*createmark props 1 all
		set allProps [hm_getmark props 1]
		
		set att "props $allProps"
		set id6000 6000
		
		foreach prop $allProps {
			
			set name_6 "C_$prop"

			set att "props $prop" 
			eval *createentity optiresponses name=$name_6 id=$id6000 response=31 property_attrib_b=1 attribute1_list={$att} 
			
			*createentity opticonstraints name=$name_6 id=$id6000 
			set response3 "optiresponses $id6000"
			*setvalue opticonstraints id=$id6000 responseid={$response3}
			*setvalue opticonstraints id=$id6000 STATUS=2 upperoption=1
			*setvalue opticonstraints id=$id6000 STATUS=1 upperbound=0.0001	
			*setvalue opticonstraints id=$id6000 STATUS=2 loadsteplist={loadsteps 1}			
			
			
			incr id6000
			
		}

		# Create the design variable for each sections. 
		*createmark props 1 all
		set allProps [hm_getmark props 1]
		
		foreach prop $allProps {
		
			set name [hm_getvalue property id=$prop dataname=name]
			set subname [string range $name 0 3]
			
			if {$subname == "Skin"} {
				eval *createentity designvariable name=$name id=$prop initialvalue=0.05 lowerbound=0.05 upperbound=0.5
			} elseif {$subname == "Stif"} {
				eval *createentity designvariable name=$name id=$prop initialvalue=0.50 lowerbound=0.05 upperbound=0.5
			}
			eval *createentity dvprels name=$name id=$prop property=1 propertyid={props $prop} desvarlist=$prop	
		
		}

		# Removes the screening of constraints.
		*createentity optidscreens 
		*setvalue optidscreens id=1 STATUS=2 autotoggle=1
		*setvalue optidscreens id=1 STATUS=2 autolevel=0
		*setvalue optidscreens id=1 STATUS=2 EquaToggle=1
		*setvalue optidscreens id=1 STATUS=2 EquaMaxc=300
		*setvalue optidscreens id=1 STATUS=2 EquaThreshold=-0.5
		*setvalue optidscreens id=1 STATUS=2 lamatoggle=1
		*setvalue optidscreens id=1 STATUS=2 lamathreshold=-0.5
		*setvalue optidscreens id=1 STATUS=2 lamamaxc=200
		*setvalue optidscreens id=1 STATUS=2 CompToggle=1
		*setvalue optidscreens id=1 STATUS=2 CompThreshold=-0.5
		*setvalue optidscreens id=1 STATUS=2 CompMaxc=300
		
		# Create the objective
		*optiobjectivecreate 1 0 0

		# Create the sensitivity output.
		*cardcreate "OUTPUT"
		*startnotehistorystate {Attached attributes to card}
		*attributeupdateint cards 1 3850 1 0 0 1
		*attributeupdatestring cards 1 130 1 0 0 "0"
		*createstringarray 1 "ASCSENS"
		*attributeupdatestringarray cards 1 3851 1 2 0 1 1
		*createstringarray 1 "ALL"
		*attributeupdatestringarray cards 1 3854 1 2 0 1 1
		*createstringarray 1 "FL"
		*attributeupdatestringarray cards 1 3852 1 2 0 1 1
		*endnotehistorystate {Attached attributes to card}

	}
 
	proc SetComplianceMassSizing {} {
	
		variable MassCon
	
		# Add the global Mass Response
		*createarray 6 0 0 0 0 0 0
		*createdoublearray 6 0 0 0 0 0 0
		*optiresponsecreate "Mass" 29 0 0 0 0 0 6 0 0 0 1 6 1 6
		*optiresponsesetequationdata1 "Mass" 0 0 0 0 1 0
		*optiresponsesetequationdata2 "Mass" 0 0 1 0
		*optiresponsesetequationdata3 "Mass" 0 0 1 0
		*optiresponsesetequationdata4 "Mass" 0 0 0 0 1 0 1 0

		# Add buckling if necessary.
		if {$::General::Buckling} {
			*createarray 6 0 0 0 0 0 0
			*createdoublearray 6 0 0 0 0 0 0
			*optiresponsecreate "Buck" 6 0 0 1 0 0 6 0 0 0 1 6 1 6
			*optiresponsesetequationdata1 "Buck" 0 0 0 0 1 0
			*optiresponsesetequationdata2 "Buck" 0 0 1 0
			*optiresponsesetequationdata3 "Buck" 0 0 1 0
			*optiresponsesetequationdata4 "Buck" 0 0 0 0 1 0 1 0
		} else {
			# Add the global Compliance Response
			*createarray 6 0 0 0 0 0 0
			*createdoublearray 6 0 0 0 0 0 0
			*optiresponsecreate "Comp" 31 0 0 0 0 0 6 0 0 0 1 6 1 6
			*optiresponsesetequationdata1 "Comp" 0 0 0 0 1 0
			*optiresponsesetequationdata2 "Comp" 0 0 1 0
			*optiresponsesetequationdata3 "Comp" 0 0 1 0
			*optiresponsesetequationdata4 "Comp" 0 0 0 0 1 0 1 0		
		}
		
		# Create the design variable for each properties. 
		*createmark props 1 all
		set allProps [hm_getmark props 1]
		
		foreach prop $allProps {
		
			set name [hm_getvalue property id=$prop dataname=name]
			set subname [string range $name 0 3]
			
			if {$subname == "Skin"} {
				eval *createentity designvariable name=$name id=$prop initialvalue=0.05 lowerbound=0.05 upperbound=0.5
			} elseif {$subname == "Stif"} {
				eval *createentity designvariable name=$name id=$prop initialvalue=0.50 lowerbound=0.05 upperbound=0.5
			}
			eval *createentity dvprels name=$name id=$prop property=1 propertyid={props $prop} desvarlist=$prop	
		
		}
		
		
		# # Create the morphing domains
		# *morphcreatedomaindc elements 0 -1 0 0 0 0
		# *morphstoredomains 1
		# *createmark elements 1 all
		# *morphcreatedomaindc elements 1 2 0 0 0 1
		# *createmark domains 1 all
		# *morphreparam domains 1

		# # Creates the shape for stiffener height
		# *createmark handles 1 all
		# set h1 [hm_getmark handles 1]
		# set handleList ""

		# foreach handle $h1 {
			# set grid 		[hm_getentityvalue handle $handle grid 0]
			# set gridCoordz  [hm_getentityvalue node $grid globalz 0]	
			# if {$gridCoordz > 1.0} {
				# append handleList "local$handle "
			# }
		# }

		# if {[llength $handleList] > 0} {

			# eval *createmark handles 1 $handleList
			# *morphhypermorph handles 1 0 0 1 1 1 1 0 1 1

			# set id 1
			# set id300 301

			# foreach handle $handleList {
			
				# set name "$handle-Z"
				# *shpdesvarcreate $name 1.0 0.0 -1.0 0.5 $id
				# eval *setvalue designvars name=$name STATUS=2 id={designvars $id300}
				
				# incr id
				# incr id300
			# }
		
		# }
		
		
		# Create the mass constraint.
		eval *opticonstraintcreate "MassCon" 1 1 -1e+20 $MassCon 1 0
		
		# Create the objective
		if {$::General::Buckling} { 
			*createarray 1 2
			*optidobjrefcreate "Buck" 2 1 -1 1 1 1
			*createarray 1 1
			*optiminmaxcreate 3 1 1
		} else {
			*optiobjectivecreate 2 0 1
		}
	
	
	}
 
 proc SetBucklingMassSizing {} {
	
		# Add the global Mass Response
		*createarray 6 0 0 0 0 0 0
		*createdoublearray 6 0 0 0 0 0 0
		*optiresponsecreate "Mass" 29 0 0 0 0 0 6 0 0 0 1 6 1 6
		*optiresponsesetequationdata1 "Mass" 0 0 0 0 1 0
		*optiresponsesetequationdata2 "Mass" 0 0 1 0
		*optiresponsesetequationdata3 "Mass" 0 0 1 0
		*optiresponsesetequationdata4 "Mass" 0 0 0 0 1 0 1 0

		*createarray 6 0 0 0 0 0 0
		*createdoublearray 6 0 0 0 0 0 0
		*optiresponsecreate "Buck" 6 0 0 1 0 0 6 0 0 0 1 6 1 6
		*optiresponsesetequationdata1 "Buck" 0 0 0 0 1 0
		*optiresponsesetequationdata2 "Buck" 0 0 1 0
		*optiresponsesetequationdata3 "Buck" 0 0 1 0
		*optiresponsesetequationdata4 "Buck" 0 0 0 0 1 0 1 0

		# Create the design variable for each properties. 
		*createmark props 1 all
		set allProps [hm_getmark props 1]
		
		foreach prop $allProps {
		
			set name [hm_getvalue property id=$prop dataname=name]
			set subname [string range $name 0 3]
			
			if {$subname == "Skin"} {
				eval *createentity designvariable name=$name id=$prop initialvalue=0.05 lowerbound=0.05 upperbound=0.5
			} elseif {$subname == "Stif"} {
				eval *createentity designvariable name=$name id=$prop initialvalue=0.50 lowerbound=0.05 upperbound=0.5
			}
			eval *createentity dvprels name=$name id=$prop property=1 propertyid={props $prop} desvarlist=$prop	
		
		}

		# Create Buckling Constraint.
		*createarray 1 2
		*opticonstraintcreate "BuckCon" 2 0 1 1e+20 1 1
		
		# CreateMinMass Objective.
		*optiobjectivecreate 1 0 0
	
	
	}
 
	proc UnsetSizing {} {
		catch {
			*createmark optiresponses 1 all
			*deletemark optiresponses 1
		}
		
		catch {
			*createmark designvars 1 all
			*deletemark designvars 1 
		}
		
		catch {
			*createmark opticontrols 1 "optistruct_opticontrol"
			*deletemark opticontrols 1
		}
		
		catch {
			*createmark domains 1 all
			*deletemark domains 1
		}
		
		catch {
			*createmark shapes 1 all
			*deletemark shapes 1
		}
		
		catch {
			*createmark objectives 1 "objective"
			*deletemark objectives 1
		}
	}

	proc SetSensiAnalysis {normalPath p_name} {
		

		
		
		# Read the sized properties from p_name.
		set fp [open $normalPath/$p_name.hgdata]
		set file_Data [read $fp]
		close $fp
		set data_per_line [split $file_Data "\n"]
		
		set DesVars ""
		set Start ""
		set i 0
		set intValues ""
		
		foreach line $data_per_line {
		
			if {![string compare [lindex $line 0] "Design"] & [lindex $line 2] < 300} {
				append DesVars " [lindex $line 3]"
			}
	
			if [string is integer [lindex $line 0]] {
				append Start " $i"
				append intValues "[lindex $line 0] "
			}

			incr i
	
		}
	
		# Create the design variables with sized properties.
		set j 0
		for {set i [expr [lindex $Start end-1]+1]} {$i <= [lindex $Start end-1] + [llength $DesVars]} {incr i} {
			set name [lindex $DesVars $j]
			set value [lindex $data_per_line $i]
			set id [lindex [split $name "_"] 1]
			incr j
			
			eval *createentity designvariable name=$name id=$id initialvalue=$value lowerbound=0.05 upperbound=0.5
			eval *createentity dvprels name=$name id=$id property=1 propertyid={props $id} desvarlist=$id
			
			
		}
	
		# # Apply the shape deformations.
		# catch {
		
			# set shapeFile "$normalPath/$p_name.res"
			# set iteration [lindex $intValues end]
			
			# eval *analysisfileset $shapeFile
			# *inputsimulation "DESIGN \[$iteration\]" "Shape Change"
			# *createmark nodes 1 "all"
			# *applyresults nodes 1 1 "total disp"
			
		# }

		# *clearmark nodes 1

		# Create the global mass responses.
		*createarray 6 0 0 0 0 0 0
		*createdoublearray 6 0 0 0 0 0 0
		*optiresponsecreate "Mass" 29 0 0 0 0 0 6 0 0 0 1 6 1 6
		*optiresponsesetequationdata1 "Mass" 0 0 0 0 1 0
		*optiresponsesetequationdata2 "Mass" 0 0 1 0
		*optiresponsesetequationdata3 "Mass" 0 0 1 0
		*optiresponsesetequationdata4 "Mass" 0 0 0 0 1 0 1 0
		
		# Create the local compliances responses. 
		*createmark props 1 all
		set allProps [hm_getmark props 1]
		
		foreach prop $allProps {
			
			set name "C_$prop"
			set id $prop

			set att "props $prop" 
			eval *createentity optiresponses name=$name id=$id response=31 property_attrib_b=1 attribute1_list={$att} 
			
			*createentity opticonstraints name=$name id=$id 
			set response3 "optiresponses $id"
			*setvalue opticonstraints id=$id responseid={$response3}
			*setvalue opticonstraints id=$id STATUS=2 upperoption=1
			*setvalue opticonstraints id=$id STATUS=1 upperbound=1E-12
			*setvalue opticonstraints id=$id STATUS=2 loadsteplist={loadsteps 1}			

		
		}
		
		# Removes the screening of constraints.
		*createentity optidscreens 
		*setvalue optidscreens id=1 STATUS=2 autotoggle=1
		*setvalue optidscreens id=1 STATUS=2 autolevel=0
		*setvalue optidscreens id=1 STATUS=2 EquaToggle=1
		*setvalue optidscreens id=1 STATUS=2 EquaMaxc=300
		*setvalue optidscreens id=1 STATUS=2 EquaThreshold=-0.5
		*setvalue optidscreens id=1 STATUS=2 lamatoggle=1
		*setvalue optidscreens id=1 STATUS=2 lamathreshold=-0.5
		*setvalue optidscreens id=1 STATUS=2 lamamaxc=200
		*setvalue optidscreens id=1 STATUS=2 CompToggle=1
		*setvalue optidscreens id=1 STATUS=2 CompThreshold=-0.5
		*setvalue optidscreens id=1 STATUS=2 CompMaxc=300
		
		# Create the objective
		*optiobjectivecreate 1 0 0

		# Create the sensitivity output.
		*cardcreate "OUTPUT"
		*startnotehistorystate {Attached attributes to card}
		*attributeupdateint cards 1 3850 1 0 0 1
		*attributeupdatestring cards 1 130 1 0 0 "0"
		*createstringarray 1 "ASCSENS"
		*attributeupdatestringarray cards 1 3851 1 2 0 1 1
		*createstringarray 1 "ALL"
		*attributeupdatestringarray cards 1 3854 1 2 0 1 1
		*createstringarray 1 "FL"
		*attributeupdatestringarray cards 1 3852 1 2 0 1 1
		*endnotehistorystate {Attached attributes to card}
		
	
	}

}