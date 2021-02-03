 ####################################################
# Script : LoadSteps								#
# LoadSteps namespace 								#
# Author : Jean-Francois Gamache					#
# Version: 0.5										#
# Last Updated : July 07th, 2020					#
 ####################################################
 
namespace eval LoadSteps {

proc setStaticAnalysis {} {

	*createentity loadsteps includeid=0 name=loadstep1
	*createmark loadsteps 1 "loadstep1"
	*clearmark loadsteps 1
	*startnotehistorystate {Renamed Loadsteps from "loadstep1" to "StaticAnalysis"}
	*setvalue loadsteps id=1 name=StaticAnalysis
	*endnotehistorystate {Renamed Loadsteps from "loadstep1" to "StaticAnalysis"}
	*startnotehistorystate {Modified Analysis type of loadstep}
	*setvalue loadsteps id=1 4709=1 STATUS=1
	*setvalue loadsteps id=1 STATUS=2 4059=1
	*setvalue loadsteps id=1 STATUS=2 4060=STATICS
	*setvalue loadsteps id=1 707=0 STATUS=0
	*setvalue loadsteps id=1 9293={Loadcols 0} STATUS=0
	*endnotehistorystate {Modified Analysis type of loadstep}
	*startnotehistorystate {Attached attributes to loadstep "StaticAnalysis"}
	*setvalue loadsteps id=1 STATUS=2 3240=1
	*setvalue loadsteps id=1 STATUS=2 289=0
	*setvalue loadsteps id=1 STATUS=2 288=0
	*setvalue loadsteps id=1 STATUS=2 4347=0
	*setvalue loadsteps id=1 STATUS=2 4034=0
	*setvalue loadsteps id=1 STATUS=2 4037=0
	*setvalue loadsteps id=1 STATUS=2 9891=0
	*setvalue loadsteps id=1 STATUS=2 10701=0
	*setvalue loadsteps id=1 STATUS=2 8142=0
	*setvalue loadsteps id=1 STATUS=2 4722=0
	*setvalue loadsteps id=1 STATUS=2 10839=0
	*setvalue loadsteps id=1 STATUS=2 3391=0
	*setvalue loadsteps id=1 STATUS=2 3396=0
	*setvalue loadsteps id=1 STATUS=2 7408=0
	*setvalue loadsteps id=1 STATUS=2 8897=0
	*setvalue loadsteps id=1 STATUS=2 4152=0
	*setvalue loadsteps id=1 STATUS=2 4973=0
	*setvalue loadsteps id=1 STATUS=2 351=0
	*setvalue loadsteps id=1 STATUS=2 3292=0
	*endnotehistorystate {Attached attributes to loadstep "StaticAnalysis"}
	*mergehistorystate "" ""
	*drawlistresetstyle 
	*startnotehistorystate {Modified SPC of loadstep from 0 to 1}
	*setvalue loadsteps id=1 STATUS=2 4143=1
	*setvalue loadsteps id=1 4144=1 STATUS=1
	*setvalue loadsteps id=1 4145={Loadcols 1} STATUS=1
	*endnotehistorystate {Modified SPC of loadstep from 0 to 1}
	*startnotehistorystate {Modified LOAD of loadstep from 0 to 2}
	*setvalue loadsteps id=1 STATUS=2 4143=1
	*setvalue loadsteps id=1 4146=1 STATUS=1
	*setvalue loadsteps id=1 4147={Loadcols 2} STATUS=1
	*setvalue loadsteps id=1 7763=0 STATUS=0
	*setvalue loadsteps id=1 7740={Loadcols 0} STATUS=0
	*endnotehistorystate {Modified LOAD of loadstep from 0 to 2}
	*startnotehistorystate {Modified OUTPUT of loadstep}
	*setvalue loadsteps id=1 STATUS=2 351=1
	*endnotehistorystate {Modified OUTPUT of loadstep}
	*startnotehistorystate {Attached attributes to loadstep "StaticAnalysis"}
	*setvalue loadsteps id=1 STATUS=2 3321=0
	*setvalue loadsteps id=1 STATUS=2 9630=0
	*setvalue loadsteps id=1 STATUS=2 9307=0
	*setvalue loadsteps id=1 STATUS=2 9317=0
	*setvalue loadsteps id=1 STATUS=2 9327=0
	*setvalue loadsteps id=1 STATUS=2 4119=0
	*setvalue loadsteps id=1 STATUS=2 4114=0
	*setvalue loadsteps id=1 STATUS=2 7121=0
	*setvalue loadsteps id=1 STATUS=2 2938=0
	*setvalue loadsteps id=1 STATUS=2 10688=0
	*setvalue loadsteps id=1 STATUS=2 2385=0
	*setvalue loadsteps id=1 STATUS=2 4052=0
	*setvalue loadsteps id=1 STATUS=2 3712=0
	*setvalue loadsteps id=1 STATUS=2 274=0
	*setvalue loadsteps id=1 STATUS=2 3057=0
	*setvalue loadsteps id=1 STATUS=2 10833=0
	*setvalue loadsteps id=1 STATUS=2 7113=0
	*setvalue loadsteps id=1 STATUS=2 8500=0
	*setvalue loadsteps id=1 STATUS=2 2419=0
	*setvalue loadsteps id=1 STATUS=2 8493=0
	*setvalue loadsteps id=1 STATUS=2 9709=0
	*setvalue loadsteps id=1 STATUS=2 3809=0
	*setvalue loadsteps id=1 STATUS=2 7125=0
	*setvalue loadsteps id=1 STATUS=2 4877=0
	*setvalue loadsteps id=1 STATUS=2 9337=0
	*setvalue loadsteps id=1 STATUS=2 9347=0
	*setvalue loadsteps id=1 STATUS=2 9357=0
	*setvalue loadsteps id=1 STATUS=2 3325=0
	*setvalue loadsteps id=1 STATUS=2 7093=0
	*setvalue loadsteps id=1 STATUS=2 3333=0
	*setvalue loadsteps id=1 STATUS=2 2423=0
	*setvalue loadsteps id=1 STATUS=2 4887=0
	*setvalue loadsteps id=1 STATUS=2 4047=0
	*setvalue loadsteps id=1 STATUS=2 9275=0
	*setvalue loadsteps id=1 STATUS=2 5463=0
	*setvalue loadsteps id=1 STATUS=2 8949=0
	*setvalue loadsteps id=1 STATUS=2 10440=0
	*setvalue loadsteps id=1 STATUS=2 7329=0
	*setvalue loadsteps id=1 STATUS=2 7333=0
	*setvalue loadsteps id=1 STATUS=2 2427=0
	*setvalue loadsteps id=1 STATUS=2 8153=0
	*setvalue loadsteps id=1 STATUS=2 8150=0
	*setvalue loadsteps id=1 STATUS=2 8144=0
	*setvalue loadsteps id=1 STATUS=2 3642=0
	*setvalue loadsteps id=1 STATUS=2 2431=0
	*setvalue loadsteps id=1 STATUS=2 7337=0
	*setvalue loadsteps id=1 STATUS=2 7117=0
	*setvalue loadsteps id=1 STATUS=2 3329=0
	*endnotehistorystate {Attached attributes to loadstep "StaticAnalysis"}
	*mergehistorystate "" ""
	*startnotehistorystate {Modified STRESS of loadstep}
	*setvalue loadsteps id=1 STATUS=2 2431=1
	*endnotehistorystate {Modified STRESS of loadstep}
	*startnotehistorystate {Attached attributes to loadstep "StaticAnalysis"}
	*setvalue loadsteps id=1 STATUS=0 1923=1
	*startnotehistorystate {Updated string array}
	*setvalue loadsteps id=1 ROW=0 STATUS=2 4873= {        }
	*endnotehistorystate {Updated string array}
	*startnotehistorystate {Updated string array}
	*setvalue loadsteps id=1 ROW=0 STATUS=2 4325= {        }
	*endnotehistorystate {Updated string array}
	*startnotehistorystate {Updated string array}
	*setvalue loadsteps id=1 ROW=0 STATUS=2 3386= {        }
	*endnotehistorystate {Updated string array}
	*startnotehistorystate {Updated string array}
	*setvalue loadsteps id=1 ROW=0 STATUS=2 3387= {        }
	*endnotehistorystate {Updated string array}
	*startnotehistorystate {Updated string array}
	*setvalue loadsteps id=1 ROW=0 STATUS=2 4839= {        }
	*endnotehistorystate {Updated string array}
	*startnotehistorystate {Updated string array}
	*setvalue loadsteps id=1 ROW=0 STATUS=2 1221= {        }
	*endnotehistorystate {Updated string array}
	*startnotehistorystate {Updated string array}
	*setvalue loadsteps id=1 ROW=0 STATUS=2 11070= {        }
	*endnotehistorystate {Updated string array}
	*startnotehistorystate {Updated string array}
	*setvalue loadsteps id=1 ROW=0 STATUS=2 2295= {        }
	*endnotehistorystate {Updated string array}
	*startnotehistorystate {Updated string array}
	*setvalue loadsteps id=1 ROW=0 STATUS=2 8136= {        }
	*endnotehistorystate {Updated string array}
	*startnotehistorystate {Updated string array}
	*setvalue loadsteps id=1 ROW=0 STATUS=2 8430= {        }
	*endnotehistorystate {Updated string array}
	*startnotehistorystate {Updated string array}
	*setvalue loadsteps id=1 ROW=0 STATUS=2 9932= {        }
	*endnotehistorystate {Updated string array}
	*startnotehistorystate {Updated string array}
	*setvalue loadsteps id=1 ROW=0 STATUS=2 8429= {        }
	*endnotehistorystate {Updated string array}
	*setvalue loadsteps id=1 STATUS=0 9254={0}
	*setvalue loadsteps id=1 STATUS=0 9255={0}
	*setvalue loadsteps id=1 STATUS=0 9280={0}
	*setvalue loadsteps id=1 STATUS=0 9281={0}
	*startnotehistorystate {Updated string array}
	*setvalue loadsteps id=1 ROW=0 STATUS=2 11072= {        }
	*endnotehistorystate {Updated string array}
	*startnotehistorystate {Updated string array}
	*setvalue loadsteps id=1 ROW=0 STATUS=2 2432= {YES}
	*endnotehistorystate {Updated string array}
	*endnotehistorystate {Attached attributes to loadstep "StaticAnalysis"}
	*mergehistorystate "" ""
	
	# # Ask for stress output. 
	# *startnotehistorystate {Modified FORMAT of loadstep}
	# *setvalue loadsteps id=1 ROW=0 STATUS=2 4325= {OPTI}
	# *endnotehistorystate {Modified FORMAT of loadstep}
	# *startnotehistorystate {Modified FORM of loadstep}
	# *setvalue loadsteps id=1 ROW=0 STATUS=2 3386= {REAL}
	# *endnotehistorystate {Modified FORM of loadstep}
	# *startnotehistorystate {Modified TYPE of loadstep}
	# *setvalue loadsteps id=1 ROW=0 STATUS=2 3387= {VON}
	# *endnotehistorystate {Modified TYPE of loadstep}
	# *startnotehistorystate {Modified LOCATION of loadstep}
	# *setvalue loadsteps id=1 ROW=0 STATUS=2 4839= {CENTER}
	# *endnotehistorystate {Modified LOCATION of loadstep}

	
}

proc setLinearBuckling {} {

	# Create the EIGRL cardimage
	*createentity loadcols includeid=3 name=EIGRL
	*setvalue loadcols id=3 cardimage="EIGRL"
	*setvalue loadcols id=3 STATUS=1 802=1E-12
	*setvalue loadcols id=3 STATUS=1 804=15

	# Create the buckling loadsteps
	*createentity loadsteps includeid=2 name=LinBuck
	*startnotehistorystate {Modified Analysis type of loadstep}
	*setvalue loadsteps id=2 4709=4 STATUS=1
	*setvalue loadsteps id=2 STATUS=2 4059=1
	*setvalue loadsteps id=2 STATUS=2 4060=BUCK
	*setvalue loadsteps id=2 707=0 STATUS=0
	*setvalue loadsteps id=2 9293={Loadcols 0} STATUS=0
	*endnotehistorystate {Modified Analysis type of loadstep}
	*startnotehistorystate {Attached attributes to loadstep "Buckling"}
	*setvalue loadsteps id=2 STATUS=2 3240=1
	*setvalue loadsteps id=2 STATUS=2 289=0
	*setvalue loadsteps id=2 STATUS=2 288=0
	*setvalue loadsteps id=2 STATUS=2 4034=0
	*setvalue loadsteps id=2 STATUS=2 4037=0
	*setvalue loadsteps id=2 STATUS=2 4230=0
	*setvalue loadsteps id=2 STATUS=2 10701=0
	*setvalue loadsteps id=2 STATUS=2 8142=0
	*setvalue loadsteps id=2 STATUS=2 4722=0
	*setvalue loadsteps id=2 STATUS=2 10839=0
	*setvalue loadsteps id=2 STATUS=2 351=0
	*setvalue loadsteps id=2 STATUS=2 3292=0
	*endnotehistorystate {Attached attributes to loadstep "Buckling"}
	*startnotehistorystate {Modified SPC of loadstep from 0 to 1}
	*setvalue loadsteps id=2 STATUS=2 4143=1
	*setvalue loadsteps id=2 4144=1 STATUS=1
	*setvalue loadsteps id=2 4145={Loadcols 1} STATUS=1
	*endnotehistorystate {Modified SPC of loadstep from 0 to 1}
	*startnotehistorystate {Modified STATSUB BUCKLING of loadstep from 0 to 1}
	*setvalue loadsteps id=2 STATUS=2 4143=1
	*setvalue loadsteps id=2 3800=1 STATUS=1
	*setvalue loadsteps id=2 3801={Loadsteps 1} STATUS=1
	*endnotehistorystate {Modified STATSUB BUCKLING of loadstep from 0 to 1}
	*startnotehistorystate {Modified METHOD  STRUCT of loadstep from 0 to 3}
	*setvalue loadsteps id=2 STATUS=2 4143=1
	*setvalue loadsteps id=2 5415=1 STATUS=1
	*setvalue loadsteps id=2 4966={Loadcols 3} STATUS=1
	*endnotehistorystate {Modified METHOD  STRUCT of loadstep from 0 to 3}	

}

}