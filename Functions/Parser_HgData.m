function [Labels,Responses, Variables] = Parser_HgData(filePath)

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
   DesignVariables(i) = Temp2(3);
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

LinesOfInterest = 2 + length(DesignVariables) + length(Resp1) + length(Resp2);
LineStart       = find(contains(tlines,'    0'));

%Find last iteration.
LastIter        = floor((length(tlines)-LineStart) / LinesOfInterest)-1;
LastIterLine    = LineStart + LastIter*(LinesOfInterest+1) + 1;

% Find responses:
Iter = LastIterLine+length(DesignVariables)+2:LastIterLine+LinesOfInterest-1;
Responses = zeros(length(Iter),1);

for i = 1:length(Iter)
    Responses(i) = str2double(tlines{Iter(i)});
end
% Labels = string([DesignVariables,'Objective','Violation',Resp1,Resp2]);
Labels = string([Resp1,Resp2]);

% Find variables:
Iter = LastIterLine:LastIterLine+length(DesignVariables)-1;
Variables = zeros(length(Iter),1);

for i = 1:length(Iter)
    Variables(i) = str2double(tlines{Iter(i)});
end

end

