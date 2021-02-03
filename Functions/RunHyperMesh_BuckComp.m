function [Buckling, Mass, Sensi] = RunHyperMesh_BuckComp(Names,Values, folderName, echo)

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

TCL_Script = [pwd,'\TCL\Main_For_Grammar.tcl'];

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

% Extract the compliance. 
fileName            = strcat(folderName, '\Prelim_Sizing.hgdata');
[~,Responses]       = Parser_HgData_V2(fileName); 
Buckling            = Responses(2);
Mass                = Responses(1);

% Extract the sensitivities.
fileName        = strcat(folderName, '\Complex_Anal.sensitivities.txt');
sensibilities   = sortrows(readtable(fileName),1);
sensibilities   = sensibilities(sensibilities.Mass ~= 0,:);

Mat = table2array(sensibilities);
Mas = Mat(:,2);
Mat = Mat(:,3:end);

Sensi = Mat ./ Mas;



end

