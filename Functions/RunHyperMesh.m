function [responses, resp_labels, variables, sensibilities] = RunHyperMesh(Names,Values, folderName, echo)

if isstring(folderName)
    folderName = char(folderName);
end

% Make sure that the targeted folder is empty. 
try
    rmdir(folderName,'s')
end
mkdir(folderName)

% Create the new parametric files in the new folder.
CreateParam(Names, Values,folderName)

TCL_Script = [pwd,'\TCL\Main.tcl'];

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

fileName        = strcat(folderName, '/Sensi_1.hgdata');
[resp_labels,responses, variables] = Parser_HgData(fileName); 

% Find if Complexity.
Comp_ID = contains(Names,'::General::Complexity');
COMP    = Values(Comp_ID);

if COMP{1}
    fileName        = strcat(folderName, '/Sensi_1.sensitivities.txt');
    sensibilities   = sortrows(readtable(fileName),1);
    sensibilities   = sensibilities(sensibilities.mass ~= 0,:);
else
    sensibilities = NaN;
end


end

