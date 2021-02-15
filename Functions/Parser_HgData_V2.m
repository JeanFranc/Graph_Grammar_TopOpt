function [Labels, Responses, DPs] = Parser_HgData_V2(filePath)

fid = fopen(filePath);
tline = fgetl(fid);
tlines = cell(0,1);
while ischar(tline)
    tlines{end+1,1} = tline;
    tline = fgetl(fid);
end
fclose(fid);

Objective = contains(tlines,'Objective');
Violation = contains(tlines,'Maximum Constraint Violation');
DESIGN = contains(tlines,'Design Variable    ');
DRESP1 = contains(tlines,'DRESP1     ');
DRESP2 = contains(tlines,'DRESP2     ');

DesignLines = tlines(DESIGN);
Resp1Lines  = tlines(DRESP1);
Resp2Lines  = tlines(DRESP2);

DesignVariables     = {};
Resp1               = {};
Resp2               = {};

for i = 1:length(DesignLines)
   Temp = DesignLines{i}; 
   Temp2 = split(Temp);
   DesignVariables(i) = Temp2(4);
end

for i = 1:length(Resp1Lines)
   Temp = Resp1Lines{i}; 
   Temp2 = split(Temp);
   Resp1(i) = Temp2(2);
end

for i = 1:length(Resp2Lines)
   Temp = Resp2Lines{i}; 
   Temp2 = split(Temp);
   Resp2(i) = Temp2(2);
end

% Extract the Responses
Total_LINES      = 2 + length(DesignVariables) + length(Resp1) + length(Resp2);
RESP1START      = length(tlines) - Total_LINES + length(DesignVariables) +2 ;
RESP1Iter       = RESP1START+1:RESP1START+length(Resp1Lines);
Responses       = zeros(length(RESP1Iter),1);
for i = 1:length(RESP1Iter)
    Responses(i) = str2double(tlines{RESP1Iter(i)});
end

% Extract the labels of the responses
Labels = "";
for i = 1 : length(Resp1Lines)
    str = Resp1Lines(i);
    sp  = split(str);
    Labels(i,1) = string(strjoin(sp(3:end)));
end

% Extract the Design Variables
DPSTART      = length(tlines) - Total_LINES ;
DPIter       = DPSTART+1:DPSTART+length(DesignVariables);
DPs          = zeros(length(DesignVariables),1);
for i = 1:length(DPIter)
    DPs(i) = str2double(tlines{DPIter(i)});
end

end

