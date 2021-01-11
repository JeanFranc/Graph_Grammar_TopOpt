function [responses, variables, sensibilities] = RunHyperMesh(Names,Values, folderName,Optim, echo)

% Make sure that the targeted folder is empty. 
try
    rmdir(folderName,'s')
end
mkdir(folderName)

% Create the new parametric files in the new folder.
CreateParam(Names, Values,folderName)

if Optim
    source = "C:\Users\JfGam\Dropbox\Documents\02 Polytechnique\01 - Doctorat\21 Code\Hypermesh-TCL\MultiStep_Optimization\ThreeStepTopo\Main_Sizing.tcl";
else
    source = "C:\Users\JfGam\Dropbox\Documents\02 Polytechnique\01 - Doctorat\21 Code\Hypermesh-TCL\MultiStep_Optimization\ThreeStepTopo\Main.tcl";
end

% Run Optistruct with the updated variable vector, and check if outputs. 
if echo
    command = strcat('"C:/Program Files/Altair/2019/hm/bin/win64/hmbatch.exe" -tcl "', source, '" "', folderName, '"');
else
    command = strcat('"C:/Program Files/Altair/2019/hm/bin/win64/hmbatch.exe" -tcl "', source,'" "', folderName, '" > NUL');
end

try
    system(command);
catch
    error(folderName)
end

% Read Responses 1.
if Optim
    fileName        = strcat(folderName, '/Sensi_1.hgdata');
    [~,responses, variables] = Parser_HgData(fileName); 
    sensibilities   = NaN;
else
    fileName        = strcat(folderName, '/Sensi_1.responses.txt');
    responses       = readtable(fileName);
    
    fileName        = strcat(folderName, '/Sensi_1.DPs.txt');
    variables       = readtable(fileName);
    
    fileName        = strcat(folderName, '/Sensi_1.sensitivities.txt');
    sensibilities   = readtable(fileName);
end


end

