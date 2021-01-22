 ####################################################
# Script : Properties								#
# Properties namespace 								#
# Author : Jean-Francois Gamache					#
# Version: 0.5										#
# Last Updated : July 07th, 2020					#
 ####################################################
 
 namespace eval Property {

	variable skin_T 	0.05
	variable stiff_T 	0.5
 
	proc initializePropCards {} {
	
		variable skin_T	
		variable stiff_T	

		# Create and assign skin properties
		*createmark comps 1 all
		set allComps [hm_getmark comps 1]

		foreach comp $allComps {
		
			set name [hm_getvalue component id=$comp dataname=name]
			set subname [string range $name 0 3]
			set id 	 $comp
			
			if {$subname == "Skin"} {
				eval *createentity 	properties id=$id cardimage=PSHELL name=$name
				eval *setvalue 		properties id=$id materialid={mats 1}
				eval *setvalue 		properties id=$id STATUS=1 95=$skin_T
				eval *createmark 	components 1 "by id" $id
				eval *propertyupdate components 1 $name			

			} else {
				eval *createentity 	properties id=$id cardimage=PSHELL name=$name
				eval *setvalue 		properties id=$id materialid={mats 1}
				eval *setvalue 		properties id=$id STATUS=1 95=$stiff_T
				eval *createmark components 1 "by id" $id
				eval *propertyupdate components 1 $name				
			}
		}





	}
 
 }
 