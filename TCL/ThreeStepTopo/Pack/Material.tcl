 ####################################################
# Script : Material									#
# Material namespace 								#
# Author : Jean-Francois Gamache					#
# Version: 0.5										#
# Last Updated : July 07th, 2020					#
 ####################################################
 
namespace eval Material {

	variable young 		10700000 ;	# [psi]
	variable poisson 	0.33 	;	# [--]
	variable rho 		0.1; 		# [lb/in^3]	
	variable Fcy 		60000;      # [psi]
	variable Matname 	Alum_7075
 
	proc initializeMatCard {} {
	
		variable young 		
		variable poisson 	
		variable rho 		
		variable Matname

		eval *createentity mats cardimage=MAT1 name=$Matname
		# Young's Modulus
		eval *attributeupdatedouble materials 1 1 1 1 0 $young
		# Poisson Ratio
		eval *attributeupdatedouble materials 1 3 1 1 0 $poisson	
		# Density
		eval *attributeupdatedouble materials 1 4 1 1 0 $rho		

	}
 
 }