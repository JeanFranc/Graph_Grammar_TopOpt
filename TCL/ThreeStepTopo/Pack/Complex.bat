@ECHO OFF

set path=%~1
set file=%~2

cd %path%

call C:\Users\JfGam\anaconda3\Scripts\activate.bat C:\Users\JfGam\anaconda3 
python "C:\Users\JfGam\Dropbox\Documents\02 Polytechnique\01 - Doctorat\21 Code\Hypermesh-TCL\MultiStep_Optimization\ThreeStepTopo\Pack\Sens.py" %file%