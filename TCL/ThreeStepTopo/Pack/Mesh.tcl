 ####################################################
# Script : Mesh										#
# Mesh namespace 									#
# Author : Jean-Francois Gamache					#
# Version: 0.5										#
# Last Updated : July 07th, 2020					#
 ####################################################
 
  namespace eval Mesh {

	variable meshSize 0.3
 
	proc meshEverything {} {
	
		variable meshSize
		*elementorder 1
		*createmark surfs 1 all
		eval *defaultremeshsurf 1 $meshSize 1 1 1 1 1 1 14 0 0 0 0		

	}
 
 }