 ####################################################
# Script : BCs										#
# Boundary Conditions namespace 					#
# Author : Jean-Francois Gamache					#
# Version: 0.5										#
# Last Updated : July 07th, 2020					#
 ####################################################
 
   namespace eval BCs {

	variable Load -120120
	variable SideConditions 	Infinite
	variable LoadType			AxialCompression


	proc setBCs {} {

	variable SideConditions 	
	variable LoadType			
		
		
		# Set boundary conditions from the chosen parameters.
		if [string equal $SideConditions "Infinite"] {
			InfiniteBCs
		} elseif [string equal $SideConditions "SimplySupported"] {
			SimplySupportedBCs
		} elseif [string equal $SideConditions "Clamped"] {
			ClampedBCs
		} elseif [string equal $SideConditions "None"] {
			*createentity loadcols name=SPC
			*createmark loadcols 1 "SPC"
			*setvalue loadcols mark=1 color=7
		} else {
			error "Side Conditions are not properly set.\nYour choices are : \n1) Infinite;\n2) SimplySupported;\n3) Clamped;\n4) None."
		}
		
		# Set BCs for the Ribs. 
		RibBCs
		
		# Set loads from the chosen parameters. 
		if [string equal $LoadType "AxialCompression"] {
			AxialLoad
		} elseif [string equal $LoadType "TransverseCompression"] {
			TransverseLoad
		} elseif [string equal $LoadType "PureShear"] {
			PureShear
		} elseif [string equal $LoadType "Pressure"] {
			PressureLoad
		} else {
			error "Load Type is not properly set.\nYour choices are : \n1) AxialCompression;\n2) TransverseCompression;\n3) PureShear;\n4) Pressure."
		}		
		
		
		
	}

	proc RibBCs {} {
	
		if {$::Geometry::NumberOfRibs > 0} {
	
			*currentcollector loadcols "SPC"
			
			set Ls [expr $::Geometry::PanelLength /$::Geometry::NumberOfRibs]
			
			for {set i 1} {$i <= $::Geometry::NumberOfRibs} {incr i} {
					set cut [expr $Ls*$i - $Ls / 2]
					eval *createmark nodes 1 \"by box\"  $cut 0 0 $cut $::Geometry::PanelHeight 0 0 inside 0 1 0.001
					*loadcreateonentity_curve nodes 1 3 1 -999999 -999999 0 -999999 -999999 -999999 0 0 0 0 0
			}		
		}
	}

	proc InfiniteBCs {} {
		
		*createentity loadcols name=SPC
		*createmark loadcols 1 "SPC"
		*setvalue loadcols mark=1 color=7

		# Create the BCs at symmetry
		eval "*createmark nodes 1 \"by box\"  0 0 0 0 $::Geometry::PanelHeight 100 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 -999999 -999999 -999999 -999999 0 -999999 0 0 0 0 0

		# Create the BCs at loaded side
		eval "*createmark nodes 1 \"by box\"  $::Geometry::PanelLength 0 0 $::Geometry::PanelLength $::Geometry::PanelHeight 100 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 -999999 -999999 -999999  -999999 0 -999999 0 0 0 0 0

		# Create the BCs at freeside side
		eval "*createmark nodes 1 \"by box\"  0 0 0 $::Geometry::PanelLength 0 100 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 -999999 -999999 -999999 0 -999999 -999999 0 0 0 0 0

		eval "*createmark nodes 1 \"by box\"  0 $::Geometry::PanelHeight 0 $::Geometry::PanelLength $::Geometry::PanelHeight 100 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 -999999 -999999 -999999 0 -999999 -999999 0 0 0 0 0

	}
	
	proc SimplySupportedBCs {} {
		
		*createentity loadcols name=SPC
		*createmark loadcols 1 "SPC"
		*setvalue loadcols mark=1 color=7

		# Create the BCs at symmetry
		eval "*createmark nodes 1 \"by box\"  0 0 0 0 $::Geometry::PanelHeight 0 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 -999999 -999999 0 -999999 -999999 -999999 0 0 0 0 0

		# Create the BCs at loaded side
		eval "*createmark nodes 1 \"by box\"  $::Geometry::PanelLength 0 0 $::Geometry::PanelLength $::Geometry::PanelHeight 0 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 -999999 -999999 0  -999999 -999999 -999999 0 0 0 0 0

		# Create the BCs at freeside side
		eval "*createmark nodes 1 \"by box\"  0 0 0 $::Geometry::PanelLength 0 0 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 -999999 -999999 0 -999999 -999999 -999999 0 0 0 0 0

		eval "*createmark nodes 1 \"by box\"  0 $::Geometry::PanelHeight 0 $::Geometry::PanelLength $::Geometry::PanelHeight 0 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 -999999 -999999 0 -999999 -999999 -999999 0 0 0 0 0

	}
	
	proc ClampedBCs {} {
		
		*createentity loadcols name=SPC
		*createmark loadcols 1 "SPC"
		*setvalue loadcols mark=1 color=7

		# Create the BCs at symmetry
		eval "*createmark nodes 1 \"by box\"  0 0 0 0 $::Geometry::PanelHeight 0 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 -999999 -999999 0 0 0 0 0 0 0 0 0

		# Create the BCs at loaded side
		eval "*createmark nodes 1 \"by box\"  $::Geometry::PanelLength 0 0 $::Geometry::PanelLength $::Geometry::PanelHeight 0 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 -999999 -999999 0  0 0 0 0 0 0 0 0

		# Create the BCs at freeside side
		eval "*createmark nodes 1 \"by box\"  0 0 0 $::Geometry::PanelLength 0 100 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 -999999 -999999 0 0 0 0 0 0 0 0 0

		eval "*createmark nodes 1 \"by box\"  0 $::Geometry::PanelHeight 0 $::Geometry::PanelLength $::Geometry::PanelHeight 100 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 -999999 -999999 0 0 0 0 0 0 0 0 0

	}
	
	proc AxialLoad {} {
	
		variable Load
	
		# Create the resistance to the axial force. 
		*currentcollector loadcols "SPC"
		eval "*createmark nodes 1 \"by box\"  0 0 0 0 $::Geometry::PanelHeight 100 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 0 -999999 -999999 -999999 -999999 -999999 0 0 0 0 0
		
		# Create the Y anchor at symmetry
		eval *createmark nodes 1 \"by box\"  0 [expr $::Geometry::PanelHeight/2] 0 0 [expr $::Geometry::PanelHeight/2] 0 0 inside 0 1 0.01
		*loadcreateonentity_curve nodes 1 3 1 -999999 0 -999999 -999999 -999999 -999999 0 0 0 0 0

		# Create the RBE2
		*createentity comps name=Rigids
		*createmark components 1 "Rigids"
		*setvalue comps mark=1 color=3

		eval *createmark nodes 1 \"by box\"  $::Geometry::PanelLength 0 0 $::Geometry::PanelLength $::Geometry::PanelHeight 50 0 inside 0 1 0.001
		*rigidlinkinodecalandcreate 1 0 0 1

		*createmark nodes 1 all
		set nodes [hm_getmark nodes 1]
		set RBE2_Node [lindex [lsort -real $nodes] end]

		*createmark nodes 1 "by id" $RBE2_Node
		*loadcreateonentity_curve nodes 1 3 1 -999999 0 0 0 0 0 0 0 0 0 0

		# Create the axial load and load collector
		*createentity loadcols name=AxialCompression
		*createmark loadcols 1 "AxialCompression"
		*setvalue loadcols mark=1 color=4

		*createmark nodes 1 "by id" $RBE2_Node
		eval *loadcreateonentity_curve nodes 1 1 1 -$Load -0 -0 0 0 -$Load 0 0 0 0 0		
	
	}
	
	proc TransverseLoad {} {
	
		variable Load
	
		# Create the resistance to the transverse force. 
		*currentcollector loadcols "SPC"
		eval "*createmark nodes 1 \"by box\"  0 0 0 $::Geometry::PanelLength 0 100 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 0 -999999 -999999 -999999 -999999 -999999 0 0 0 0 0
		
		# Create the Y anchor at symmetry
		eval *createmark nodes 1 \"by box\"  [expr $::Geometry::PanelLength/2] 0 0 [expr $::Geometry::PanelLength/2] 0 0 0 inside 0 1 0.01
		*loadcreateonentity_curve nodes 1 3 1 -999999 0 -999999 -999999 -999999 -999999 0 0 0 0 0

		# Create the RBE2 Collector
		*createentity comps name=Rigids
		*createmark components 1 "Rigids"
		*setvalue comps mark=1 color=3
	
		# Create the RBE2 Element
		eval *createmark nodes 1 \"by box\"  0 $::Geometry::PanelHeight 0 $::Geometry::PanelLength $::Geometry::PanelHeight 50 0 inside 0 1 0.001
		*rigidlinkinodecalandcreate 1 0 0 1

		# Find the node created at the COG of the RBE2.
		*createmark nodes 1 all
		set nodes [hm_getmark nodes 1]
		set RBE2_Node [lindex [lsort -real $nodes] end]

		# Apply stabilizing SPC at free node. 
		*createmark nodes 1 "by id" $RBE2_Node
		*loadcreateonentity_curve nodes 1 3 1 -999999 0 0 0 0 0 0 0 0 0 0
	
		# Create the load collector.
		*createentity loadcols name=TransverseCompression
		*createmark loadcols 1 "TransverseCompression"
		*setvalue loadcols mark=1 color=4

		# Apply the load at the RBE2 free node. 
		*createmark nodes 1 "by id" $RBE2_Node
		eval *loadcreateonentity_curve nodes 1 1 1 -$Load -0 -0 0 0 -$Load 0 0 0 0 0		
	
	}
 
	proc PureShear {} {
	
		variable Load 
		
		# Create the resistance to the shear force. 
		*currentcollector loadcols "SPC"
		
		# Left Side
		eval "*createmark nodes 1 \"by box\"  0 0 0 0 $::Geometry::PanelHeight 100 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 0 0 0 -999999 -999999 -999999 0 0 0 0 0
			
		# Create the BCs at freeside side.
		eval "*createmark nodes 1 \"by box\"  0 0 0 $::Geometry::PanelLength 0 100 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 0 -999999 0 -999999 -999999 -999999 0 0 0 0 0
		eval "*createmark nodes 1 \"by box\"  0 $::Geometry::PanelHeight 0 $::Geometry::PanelLength $::Geometry::PanelHeight 100 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 0 -999999 0 -999999 -999999 -999999 0 0 0 0 0

		# Create BCs at loaded side. 
		eval "*createmark nodes 1 \"by box\"  $::Geometry::PanelLength 0 0 $::Geometry::PanelLength $::Geometry::PanelHeight 100 0 inside 0 1 0.001"
		*loadcreateonentity_curve nodes 1 3 1 0 -999999 0 -999999 -999999 -999999 0 0 0 0 0
		
		# Create the RBE2 Collector
		*createentity comps name=Rigids
		*createmark components 1 "Rigids"
		*setvalue comps mark=1 color=3
		
		# Create the RBE2 Element
		eval *createmark nodes 1 \"by box\"  $::Geometry::PanelLength 0 0 $::Geometry::PanelLength $::Geometry::PanelHeight 50 0 inside 0 1 0.001
		*rigidlinkinodecalandcreate 1 0 0 2
	
		# Find the node created at the COG of the RBE2.
		*createmark nodes 1 all
		set nodes [hm_getmark nodes 1]
		set RBE2_Node [lindex [lsort -real $nodes] end]

		# Apply stabilizing SPC at free node. 
		*createmark nodes 1 "by id" $RBE2_Node
		*loadcreateonentity_curve nodes 1 3 1 0 -999999 0 0 0 0 0 0 0 0 0
	
		# Create the load collector.
		*createentity loadcols name=PureShear
		*createmark loadcols 1 "PureShear"
		*setvalue loadcols mark=1 color=4
	
		# Apply the load at the RBE2 free node. 
		*createmark nodes 1 "by id" $RBE2_Node
		eval *loadcreateonentity_curve nodes 1 1 1 0 $Load -0 0 0 0 $Load 0 0 0 0		
	
	}
 
	proc PressureLoad {} {
	
		variable Load
	
		# Create an anchor for in place displacement. 
		*currentcollector loadcols "SPC"

		# Create the Y anchor at symmetry
		eval *createmark nodes 1 \"by box\"  [expr $::Geometry::PanelLength/2] [expr $::Geometry::PanelHeight/2] 0 [expr $::Geometry::PanelLength/2] [expr $::Geometry::PanelHeight/2] 0 0 inside 0 1 0.01
		*loadcreateonentity_curve nodes 1 3 1 0 0 -999999 -999999 -999999 -999999 0 0 0 0 0
		
		# Create the load collector.
		*createentity loadcols name=PureShear
		*createmark loadcols 1 "PureShear"
		*setvalue loadcols mark=1 color=4	
		
		# Create the pressure load
		eval *createmark elems 1 \"by box\"  0 0 0 $::Geometry::PanelLength $::Geometry::PanelHeight 0 0 inside 1 1 0
		*pressuresonentity_curve elements 1 1 0 0 1 $Load 30 1 0 0 0 0 0
	
	}
 
 }