function [responses, resp_labels, variables, sensibilities] = RunHyperMesh(Names,Values, folderName, echo)

% Make sure that the targeted folder is empty. 
try
    rmdir(folderName,'s')
end
mkdir(folderName)

% Create the new parametric files in the new folder.
CreateParam(Names, Values,folderName)

TCL_Script = "C:\Users\JfGam\Dropbox\Documents\02 Polytechnique\01 - Doctorat\21 Code\Hypermesh-TCL\MultiStep_Optimization\ThreeStepTopo\Main.tcl";

% Run Optistruct with the updated variable vector, and check if outputs. 
if echo
    command = strcat('"C:/Program Files/Altair/2019/hm/bin/win64/hmbatch.exe" -tcl "', TCL_Script, '" "', folderName, '"');
else
    command = strcat('"C:/Program Files/Altair/2019/hm/bin/win64/hmbatch.exe" -tcl "', TCL_Script,'" "', folderName, '" > NUL');
end

try
    system(command);
catch
    error(folderName)
end

% Find if Complexity.
Comp_ID = contains(Names,'::General::Complexity');
COMP    = Values(Comp_ID);
COMP    = COMP{1};

fileName        = strcat(folderName, '/Sensi_1.hgdata');
[resp_labels,responses, variables] = Parser_HgData(fileName); 

if COMP
    fileName        = strcat(folderName, '/Sensi_1.sensitivities.txt');
    sensibilities   = readtable(fileName);
else
    sensibilities = NaN;
end


end

