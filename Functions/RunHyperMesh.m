function [responses, variables, sensibilities] = RunHyperMesh(Names,Values, folderName, echo)

% Make sure that the targeted folder is empty. 
try
    rmdir(folderName,'s')
end
mkdir(folderName)

% Create the new parametric files in the new folder.
CreateParam(Names, Values,folderName)

% Run Optistruct with the updated variable vector, and check if outputs. 
if echo
    command = strcat('"C:/Program Files/Altair/2019/hm/bin/win64/hmbatch.exe" -tcl "C:\Users\JfGam\Dropbox\Documents\02 Polytechnique\01 - Doctorat\21 Code\Hypermesh-TCL\MultiStep_Optimization\ThreeStepTopo\Main.tcl"', ' "', folderName, '"');
else
    command = strcat('"C:/Program Files/Altair/2019/hm/bin/win64/hmbatch.exe" -tcl "C:\Users\JfGam\Dropbox\Documents\02 Polytechnique\01 - Doctorat\21 Code\Hypermesh-TCL\MultiStep_Optimization\ThreeStepTopo\Main.tcl"', ' "', folderName, '" > NUL');
end

try
    system(command);
catch
    error(folderName)
end

% Read Responses 1.
fileName        = strcat(folderName, '/Sensi_1.responses.txt');
responses       = readtable(fileName);

% Read DPs 1.
fileName        = strcat(folderName, '/Sensi_1.DPs.txt');
variables       = readtable(fileName);

% Read Sensi 1.
fileName        = strcat(folderName, '/Sensi_1.sensitivities.txt');
sensibilities   = readtable(fileName);

end

