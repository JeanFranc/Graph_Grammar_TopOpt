 ####################################################
# Script : Geometry									#
# Set of functions to deal with geometry			#
# Author : Jean-Francois Gamache					#
# Version: 0.9.9									#
# Last Updated : January 18th, 2021					#
 ####################################################
 
 namespace eval Geometry {

	variable lineCount 0
    variable lineArray
	variable surfaceArray
	variable rightSideNodes 0 
	
	array unset lineArray
	array set 	lineArray {}
	array unset surfaceArray
	array set 	surfaceArray {}
	
	array unset sideNodes
	array set 	sideNodes {}
	
	variable PanelLength 25.0
	variable PanelHeight 17.0
	variable ThetaVec 	0.0
	variable XVec     [expr $PanelHeight / 2]
	variable stiffHeight 1.5
	
	variable XBeg		
	variable YBeg		
	variable XEnd		
	variable YEnd 		
	
	variable NumberOfRibs 3
	
	proc CreateLineAndAppend {x1 y1 z1 x2 y2 z2 name} {

		# Creates a line from 3D nodes.
		# Saves the ID to the lineArray.

		variable lineArray
		variable lineCount
		
		*clearmark lines 1
		incr lineCount
		*linecreatestraight $x1 $y1 $z1 $x2 $y2 $z2
		*createmarklast lines 1
		set id [hm_getmark lines 1]
		append lineArray($name) " " "$id"
		*clearmarkall 1
		
		return "$lineCount $name";
		
	}
	
	proc CreateLineAndAppend_xTheta {X Theta name} {

		# Creates a line from its center position X
		# and its angle Theta (in radian)

		variable lineArray
		variable lineCount
		variable sideNodes
		variable PanelHeight
		variable PanelLength
		
		*clearmark lines 1
		incr lineCount
		
		set px1 0
		set px2 $PanelLength
		
		set py1 [expr $X - $PanelLength*tan($Theta)/2]
		set py2 [expr $X + $PanelLength*tan($Theta)/2]
		
		*linecreatestraight $px1 $py1 0 $px2 $py2 0
		*createmarklast lines 1
		set id [hm_getmark lines 1]
		append lineArray(${name}_1) " " "$id"
		*clearmarkall 1
		
		append sideNodes($name) "$px1 $py1 $px2 $py2"
		
		return "$lineCount $name";
		
	}
	
	proc CreateLineAndAppend_xy {px1 py1 px2 py2 name} {
	
		variable lineArray
		variable lineCount
		variable sideNodes
		variable PanelHeight
		variable PanelLength	
		
		*clearmark lines 1
		incr lineCount
	
		*linecreatestraight $px1 $py1 0 $px2 $py2 0
		*createmarklast lines 1
		set id [hm_getmark lines 1]
		append lineArray(${name}_1) " " "$id"
		*clearmarkall 1
		
		append sideNodes($name) "$px1 $py1 $px2 $py2"
		
		return "$lineCount $name";
	
	}
	
	proc CreateSplineAndAppend_xTheta {X Theta name} {

		# Creates a line from its center position X
		# and its angle Theta (in radian)

		variable lineArray
		variable lineCount
		variable sideNodes
		variable PanelHeight
		variable PanelLength
		
		*clearmark lines 1
		incr lineCount
		
		set px1 0
		set px2 $PanelLength
		
		set py1 [expr $X - $PanelLength*tan($Theta)/2]
		set py2 [expr $X + $PanelLength*tan($Theta)/2]
		
		set px_M [expr ($px2 - $px1) / 2]
		set py_M $X
		
		set delta [expr $PanelLength /4]
		
		set px_M1 [expr $px_M - $delta]
		set px_M2 [expr $px_M + $delta]
		
		*createnode $px_M1 $py1 0
		*createnode $px_M2 $py2 0
		
		*linecreateconic $px1 $py1 0 $px_M $py_M 0 $px_M1 $py1 0 0.75
		*createmarklast lines 1
		set id1 [hm_getmark lines 1]
		*clearmark lines 1
		*linecreateconic $px2 $py2 0 $px_M $py_M 0 $px_M2 $py2 0 0.75
		*createmarklast lines 2
		set id2 [hm_getmark lines 2]
		*clearmark lines 2

		append lineArray(${name}_1) " " "$id1"	
		append lineArray(${name}_2) " " "$id2"

		append sideNodes($name) "$px1 $py1 $px2 $py2"
		
		return "$lineCount $name";
		
	}	
	
	proc CreateSurfaceAndAppend {lineList name} {

	# Creates a surface from lines and appends
	# the surface array. 

		variable surfaceArray
		*surfacemode 4
		hm_createmark lines 1 $lineList
		*splinesurface lines 1 1 1 3
		
		*createmarklast surfaces 1
		SurfaceAppend $name [hm_getmark surfaces 1]
		*clearmarkall 1		
	
	}
	
	proc SurfaceAppend {name ids} {
	
	# Checks if a surface exists in the data structure
	# If not, adds the id and key to the array. 
	
		variable surfaceArray
		
		foreach {id} $ids {
			set notExist true
			catch {
				foreach {idold} "$surfaceArray($name)" {
					if {$idold == $id} {
						set notExist false
					}
				}
			}
			if $notExist {
				append surfaceArray($name) " " "$id"
			}
		}
	}
	
	proc createComponent {name id } {
	
	# Creates a new geometry component. 
	
		eval *createentity comps id=$id name=$name
		eval *createmark components 1 $id	
	
	}
	
	proc createGeometry_xtheta {} {
	
	# Creates the skin from the PanelHeight and Lenght
	
		variable PanelHeight
		variable PanelLength
		variable lineArray
		variable surfaceArray
		variable XVec
		variable ThetaVec
		variable StiffHeight
		
		
		

		hm_answernext yes
		*deletemodel 

		# Create the skin component and set the colour to blue. 
		createComponent "Skin_temp" "1"

		# Creates the rectangle from the parameters. 
		set p_BottomLeft 	"0  			0    			0"
		set p_BottomRight 	"$PanelLength 	0    			0"
		set p_TopLeft	 	"0  			$PanelHeight 	0"
		set p_TopRight	 	"$PanelLength 	$PanelHeight 	0"	
	
		# Creates the outer bounds of the rectangle
		eval CreateLineAndAppend "$p_BottomLeft $p_BottomRight" "Outer_Bottom"
		eval CreateLineAndAppend "$p_BottomLeft $p_TopLeft"     "Outer_Left"
		eval CreateLineAndAppend "$p_TopLeft    $p_TopRight"    "Outer_Top"
		eval CreateLineAndAppend "$p_TopRight   $p_BottomRight" "Outer_Right"		

		# Creates the surface from the outer bounds.
		set temp_list "$::Geometry::lineArray(Outer_Bottom) $::Geometry::lineArray(Outer_Left) $::Geometry::lineArray(Outer_Top) $::Geometry::lineArray(Outer_Right)"
		CreateSurfaceAndAppend $temp_list "Skin_Web"
		
		# Create Lines at the middle and center boundary conditions.
		CreateLineAndAppend 0 [expr $PanelHeight/2] 0 $PanelLength [expr $PanelHeight/2] 0 "MiddleLine"
		CreateLineAndAppend [expr 1*$PanelLength/6] 0 0 [expr 1*$PanelLength/6] $PanelHeight 0 "CenterLine"
		CreateLineAndAppend [expr 3*$PanelLength/6] 0 0 [expr 3*$PanelLength/6] $PanelHeight 0 "CenterLine"
		CreateLineAndAppend [expr 5*$PanelLength/6] 0 0 [expr 5*$PanelLength/6] $PanelHeight 0 "CenterLine"

		# Create each stiffeners
		set i 1
		foreach x $XVec theta $ThetaVec {
		
			# Constant of penalization;
			#set a 100.0
			#set b 5.0
		
			#set T_Penal [expr ($b/$a)*$a**$theta - ($b/$a)*$a**(-$theta)]
			#set T_rad [expr $T_Penal * 3.141592 / 180]
			
			set T_rad [expr $theta * 3.141592 / 180]
			
			CreateLineAndAppend_xTheta $x $T_rad "Stiff_$i"
			incr i
			
		}		

	

		# Cut the skin for each stiffeners and boundary conditions. 
		set cutList ""
		foreach {name ID} [array get ::Geometry::lineArray] {
			append cutList " $ID"
		}
		
		*createmark surfaces 1 all
		eval *createmark lines 2 $cutList
		*createvector 1 0 0 1
		*surfacemarksplitwithlines 1 2 1 9 0
		*normalsoff 
		*clearmarkall
		#*createmark lines 1 all
		#*deletemark lines 1

		# Create a surface list before creating the blades. 
		*createmark surfs 1 all
		set allsurf [hm_getmark surf 1]
		set skinNumber [llength $allsurf]
			
		set stiff_i 100	
		# Create the blades
		foreach {stiff ID} [array get ::Geometry::lineArray] {
			if {[string range $stiff 0 3] == "Stif"} {
				#createComponent "Stiff_$stiff_i" $stiff_i 
				#set collName "Stiff_$stiff_i"
				#eval *currentcollector components $collName
				eval *createmark lines 1 $ID
				*createvector 1 0 0 1
				eval *surfacecreatedraglinealongvector 1 1 $StiffHeight 1 1 0 0 0		
				incr stiff_i
			}
		}
		
		*createmark lines 1 all
		*deletemark lines 1
		
		# Create the intersections
		*createmark surfaces 1 all
		*multi_surfs_lines_merge 1 0 0
		
		# # Move the surfaces to their own components. 
		*createmark surfs 1 all
		set allSurfs [hm_getmark surfs 1 all]
		set lend $skinNumber
		set newSurfs [lrange $allSurfs $lend end]

		*clearmark surfs 1

		# Move each skin sections to its own component. 
		set skin_i 200
		set foundFace ""
		foreach surf $allsurf {
			
			if {[lsearch $foundFace $surf] < 0} {
				*createmark surfs 1 $surf
				*appendmark surfs 1 "by face"
				
				set newFace [hm_getmark surfs 1]
				
				append foundFace " $newFace"

				createComponent "Skin_$skin_i" $skin_i 
				eval *movemark surfaces 1 "Skin_$skin_i"
				incr skin_i
			}
			
			set faces [hm_getmark surfs 1]

		}

		# # Move each skin sections to its own component. 
		# set skin_i 200 
		# foreach surf $allsurf { 
			# createComponent "Skin_$skin_i" $skin_i  
			# eval *createmark surfaces 1 $surf 
			# eval *movemark surfaces 1 "Skin_$skin_i" 
			# incr skin_i 
		# } 

		set stiff_i 100
		foreach blade $newSurfs {
			createComponent "Stif_$stiff_i" $stiff_i
			eval *createmark surfaces 1 $blade
			eval *movemark surfaces 1 "Stif_$stiff_i" 
			incr stiff_i
		}
		
		*createmark comps 1 "Skin_temp"
		*deletemark comps 1
		
		# Do the meshing of the Panel. 
		::Mesh::meshEverything
		
		# Delete the mesh outside the perimeter.
		catch {
			*createmark elements 1 "by box" 0.0 0.0 -100.0 $PanelLength $PanelHeight 100 0 outside 1 1 0
			*deletemark elems 1
		}
		
		# # Renumber the mesh for each stiffeners. 
		# set odd 0
		# set j 1
		# foreach surf $newSurfs {
			# *createmark elems 1 "by surface" $surf
			# set startid [expr $j * 1000000]
			# eval *renumbersolverid elements 1 $startid 1 0 0 0 0 0
			
			# if $odd {
				# set odd 0
				# incr j
			# } else {
				# set odd 1
			# }
		# }

	}
	
	proc createGeometry_xy {} {

	# Creates the skin from the PanelHeight and Lenght and 4 positions vectors. 

	variable PanelHeight
	variable PanelLength
	variable lineArray
	variable surfaceArray
	variable StiffHeight
	variable NumberOfRibs
	
	variable XBeg	
	variable YBeg		
	variable XEnd		
	variable YEnd 	

	hm_answernext yes
	*deletemodel 

	# Create the skin component and set the colour to blue. 
	createComponent "Skin_temp" "1"

	# Creates the rectangle from the parameters. 
	set p_BottomLeft 	"0  			0    			0"
	set p_BottomRight 	"$PanelLength 	0    			0"
	set p_TopLeft	 	"0  			$PanelHeight 	0"
	set p_TopRight	 	"$PanelLength 	$PanelHeight 	0"	

	# Creates the outer bounds of the rectangle
	eval CreateLineAndAppend "$p_BottomLeft $p_BottomRight" "Outer_Bottom"
	eval CreateLineAndAppend "$p_BottomLeft $p_TopLeft"     "Outer_Left"
	eval CreateLineAndAppend "$p_TopLeft    $p_TopRight"    "Outer_Top"
	eval CreateLineAndAppend "$p_TopRight   $p_BottomRight" "Outer_Right"		

	# Creates the surface from the outer bounds.
	set temp_list "$::Geometry::lineArray(Outer_Bottom) $::Geometry::lineArray(Outer_Left) $::Geometry::lineArray(Outer_Top) $::Geometry::lineArray(Outer_Right)"
	CreateSurfaceAndAppend $temp_list "Skin_Web"
	
	# Create cuts at centerlines.
	CreateLineAndAppend 0 [expr $PanelHeight/2] 0 $PanelLength [expr $PanelHeight/2] 0 "MiddleLine"

	# Create cuts at the ribs positions.
	set Ls [expr $PanelLength/$NumberOfRibs]
	
	for {set i 1} {$i <= $NumberOfRibs} {incr i} {
			set cut [expr $Ls*$i - $Ls / 2]
			CreateLineAndAppend $cut 0 0 $cut $PanelHeight 0 "CenterLine"
	}
	
	# If the number of cut is even, add a middle cut. 
	if  [expr {($NumberOfRibs % 2) == 0}] {
		CreateLineAndAppend [expr $PanelLength/2] 0 0 [expr $PanelLength/2] $PanelHeight 0 "CenterLine"
	}

	# Create each stiffeners
	set i 1
	foreach xb $XBeg xe $XEnd yb $YBeg ye $YEnd {
		set xbPos [expr $xb * $PanelLength]
		set xePos [expr $xe * $PanelLength]
		set ybPos [expr $yb * $PanelHeight]
		set yePos [expr $ye * $PanelHeight]
	
		CreateLineAndAppend_xy $xbPos $ybPos $xePos $yePos "Stiff_$i"
		incr i
	}		

	# Cut the skin for each stiffeners and boundary conditions. 
	set cutList ""
	foreach {name ID} [array get ::Geometry::lineArray] {
		append cutList " $ID"
	}
	
	*createmark surfaces 1 all
	eval *createmark lines 2 $cutList
	*createvector 1 0 0 1
	*surfacemarksplitwithlines 1 2 1 9 0
	*normalsoff 
	*clearmarkall
	#*createmark lines 1 all
	#*deletemark lines 1

	# Create a surface list before creating the blades. 
	*createmark surfs 1 all
	set allsurf [hm_getmark surf 1]
	set skinNumber [llength $allsurf]
		
	set stiff_i 100	
	# Create the blades
	foreach {stiff ID} [array get ::Geometry::lineArray] {
		if {[string range $stiff 0 4] == "Stiff"} {
			#createComponent "Stiff_$stiff_i" $stiff_i 
			#set collName "Stiff_$stiff_i"
			#eval *currentcollector components $collName
			eval *createmark lines 1 $ID
			*createvector 1 0 0 1
			eval *surfacecreatedraglinealongvector 1 1 $StiffHeight 1 1 0 0 0		
			incr stiff_i
		}
	}
	
	*createmark lines 1 all
	*deletemark lines 1
	
	# Create the intersections
	*createmark surfaces 1 all
	*multi_surfs_lines_merge 1 0 0
	
	# # Move the surfaces to their own components. 
	*createmark surfs 1 all
	set allSurfs [hm_getmark surfs 1 all]
	set lend $skinNumber
	set newSurfs [lrange $allSurfs $lend end]

	*clearmark surfs 1

	# Move each skin sections to its own component. 
	set skin_i 100
	set foundFace ""
	foreach surf $allsurf {
		
		if {[lsearch $foundFace $surf] < 0} {
			*createmark surfs 1 $surf
			*appendmark surfs 1 "by face"
			
			set newFace [hm_getmark surfs 1]
			
			append foundFace " $newFace"

			createComponent "Skin_$skin_i" $skin_i 
			eval *movemark surfaces 1 "Skin_$skin_i"
			incr skin_i
		}
		
		set faces [hm_getmark surfs 1]

	}

	# # Move each skin sections to its own component. 
	# set skin_i 200 
	# foreach surf $allsurf { 
		# createComponent "Skin_$skin_i" $skin_i  
		# eval *createmark surfaces 1 $surf 
		# eval *movemark surfaces 1 "Skin_$skin_i" 
		# incr skin_i 
	# } 

	set stiff_i 200
	foreach blade $newSurfs {
		createComponent "Stiff_$stiff_i" $stiff_i
		eval *createmark surfaces 1 $blade
		eval *movemark surfaces 1 "Stiff_$stiff_i" 
		incr stiff_i
	}
	
	*createmark comps 1 "Skin_temp"
	*deletemark comps 1
	
	# Do the meshing of the Panel. 
	::Mesh::meshEverything
	
	# Delete the mesh outside the perimeter.
	catch {
		*createmark elements 1 "by box" 0.0 0.0 -100.0 $PanelLength $PanelHeight 100 0 outside 1 1 0
		*deletemark elems 1
	}
	
	# # Renumber the mesh for each stiffeners. 
	# set odd 0
	# set j 1
	# foreach surf $newSurfs {
		# *createmark elems 1 "by surface" $surf
		# set startid [expr $j * 1000000]
		# eval *renumbersolverid elements 1 $startid 1 0 0 0 0 0
		
		# if $odd {
			# set odd 0
			# incr j
		# } else {
			# set odd 1
		# }
	# }

}
	
	proc createGeometry_xy_Combined {} {

	# Creates the skin from the PanelHeight and Lenght and 4 positions vectors. 
	variable PanelHeight
	variable PanelLength
	variable lineArray
	variable surfaceArray
	variable StiffHeight
	variable NumberOfRibs
	
	variable XBeg	
	variable YBeg		
	variable XEnd		
	variable YEnd 	

	hm_answernext yes
	*deletemodel 

	# Create the skin component and set the colour to blue. 
	createComponent "Skin_temp" "1"

	# Creates the rectangle from the parameters. 
	set p_BottomLeft 	"0  			0    			0"
	set p_BottomRight 	"$PanelLength 	0    			0"
	set p_TopLeft	 	"0  			$PanelHeight 	0"
	set p_TopRight	 	"$PanelLength 	$PanelHeight 	0"	

	# Creates the outer bounds of the rectangle
	eval CreateLineAndAppend "$p_BottomLeft $p_BottomRight" "Outer_Bottom"
	eval CreateLineAndAppend "$p_BottomLeft $p_TopLeft"     "Outer_Left"
	eval CreateLineAndAppend "$p_TopLeft    $p_TopRight"    "Outer_Top"
	eval CreateLineAndAppend "$p_TopRight   $p_BottomRight" "Outer_Right"		

	# Creates the surface from the outer bounds.
	set temp_list "$::Geometry::lineArray(Outer_Bottom) $::Geometry::lineArray(Outer_Left) $::Geometry::lineArray(Outer_Top) $::Geometry::lineArray(Outer_Right)"
	CreateSurfaceAndAppend $temp_list "Skin_Web"
	
	# Create cuts at centerlines.
	CreateLineAndAppend 0 [expr $PanelHeight/2] 0 $PanelLength [expr $PanelHeight/2] 0 "MiddleLine"

	# Create cuts at the ribs positions.
	if {$NumberOfRibs > 0} {
		set Ls [expr $PanelLength/$NumberOfRibs]
		
		for {set i 1} {$i <= $NumberOfRibs} {incr i} {
				set cut [expr $Ls*$i - $Ls / 2]
				CreateLineAndAppend $cut 0 0 $cut $PanelHeight 0 "CenterLine"
		}
	}
	
	# If the number of cut is even, add a middle cut. 
	if  [expr {($NumberOfRibs % 2) == 0}] {
		CreateLineAndAppend [expr $PanelLength/2] 0 0 [expr $PanelLength/2] $PanelHeight 0 "CenterLine"
	}

	# Create each stiffeners
	set i 1
	foreach xb $XBeg xe $XEnd yb $YBeg ye $YEnd {
		set xbPos [expr $xb * $PanelLength]
		set xePos [expr $xe * $PanelLength]
		set ybPos [expr $yb * $PanelHeight]
		set yePos [expr $ye * $PanelHeight]
	
		CreateLineAndAppend_xy $xbPos $ybPos $xePos $yePos "Stiff_$i"
		incr i
	}		

	# Cut the skin for each stiffeners and boundary conditions. 
	set cutList ""
	foreach {name ID} [array get ::Geometry::lineArray] {
		append cutList " $ID"
	}
	
	*createmark surfaces 1 all
	eval *createmark lines 2 $cutList
	*createvector 1 0 0 1
	*surfacemarksplitwithlines 1 2 1 9 0
	*normalsoff 
	*clearmarkall

	# Create a surface list before creating the blades. 
	*createmark surfs 1 all
	set skinSurf [hm_getmark surf 1]
	set skinNumber [llength $skinSurf]
		
	set stiff_i 100	
	# Create the blades
	foreach {stiff ID} [array get ::Geometry::lineArray] {
		if {[string range $stiff 0 3] == "Stif"} {
			eval *createmark lines 1 $ID
			*createvector 1 0 0 1
			eval *surfacecreatedraglinealongvector 1 1 $StiffHeight 1 1 0 0 0		
			incr stiff_i
		}
	}
	
	*createmark lines 1 all
	*deletemark lines 1
	
	# Create the intersections
	*createmark surfaces 1 all
	*multi_surfs_lines_merge 1 0 0
	
	## Move the surfaces to their own components. 
	*createmark surfs 1 all
	set allSurfs [hm_getmark surfs 1 all]
	set lend $skinNumber
	set newSurfs [lrange $allSurfs $lend end]

	*clearmark surfs 1

	# Move each skin sections to its own component. 
	set skin_i 100
	set foundFace ""
	foreach surf $skinSurf {
				
		# Check if face is already done, if not create it. 
		if {[lsearch $foundFace $surf] < 0} {
			*createmark surfs 1 $surf
			*appendmark surfs 1 "by face"
			
			set newFace [hm_getmark surfs 1]
			
			append foundFace " $newFace"

			createComponent "Skin_$skin_i" $skin_i 
			eval *movemark surfaces 1 "Skin_$skin_i"
			incr skin_i
		}
		
		set faces [hm_getmark surfs 1]

	}

	set stiff_i 200
	set foundFace ""
	
	foreach surf $newSurfs {
				
		# Check if face is already done, if not create it. 
		if {[lsearch $foundFace $surf] < 0} {
		
			*createmark surfs 1 $surf
			*appendmark surfs 1 "by face"
			
			set newFace [hm_getmark surfs 1]
			
			append foundFace " $newFace"

			createComponent "Stif_$stiff_i" $stiff_i
			eval *movemark surfaces 1 "Stif_$stiff_i"
			incr stiff_i
		}
		
		set faces [hm_getmark surfs 1]

	}
	
	*createmark comps 1 "Skin_temp"
	*deletemark comps 1
	
	# Mesh Everything.
	::Mesh::meshEverything
	
	# Delete the mesh outside the perimeter.
	catch {
		*createmark elements 1 "by box" 0.0 0.0 -100.0 $PanelLength $PanelHeight 100 0 outside 1 1 0
		*deletemark elems 1
	}

}

}