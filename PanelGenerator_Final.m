clear all
clc
addpath('Functions')
addpath('Classes')

%% Defines initial parameters.

PanelLength     = 60.0;
PanelHeight     = 50/3;
StiffHeight     = 1.5;
Matname         = 'Alum_7075';
young           = 10700000;
poisson         = 0.33;
rho             = 0.1;
Fcy             = 68000;
meshSize        = 0.5;
axialLoad       = -120120;

%% Initialize the list of layout codes.

MaxLayouts  = 10*16;
MaxV        = 10;
MaxH        = 10;

tic
AllCodes = createLayouts(MaxLayouts,MaxV, MaxH);
fprintf('Generating codes \t ... %1.1f seconds\n',toc);

%% Generate Graphs from codes.

AllLayouts = cell(length(AllCodes),1);
tic
parfor i = 1 : length(AllCodes)
    Temp = Layout_Class(AllCodes{i},PanelHeight,PanelLength);
    AllLayouts{i} = Temp.set_graph;
end
fprintf('Generating graphs \t ... %1.1f seconds\n',toc);

%% Sort by complexity.

CompTemp    = [];

for i = 1 : length(AllLayouts)
    CompTemp(i) = AllLayouts{i}.GeomComplex;
end

[Comps, ID] = sort(CompTemp);

SortedGraphs = {};
SortedGraphs = AllLayouts(ID);

%% Translate from graph to parametric file.

XBegs = {};
YBegs = {};
XEnds = {};
YEnds = {};
tic
% First, find the geometrical center of each stiffener.
for i = 1:length(SortedGraphs)
    ThisGraph = SortedGraphs{i}.Graph;
    EndNodes = ThisGraph.Edges.EndNodes;
    Nodes    = table2array(ThisGraph.Nodes);
    XBeg = [];YBeg = [];XEnd = []; YEnd = [];
    for j = 1:size(EndNodes,1)        
        XBeg(end+1) = Nodes(EndNodes(j,1),1);
        YBeg(end+1) = Nodes(EndNodes(j,1),2);
        XEnd(end+1) = Nodes(EndNodes(j,2),1);
        YEnd(end+1) = Nodes(EndNodes(j,2),2);
    end
    
    if ~isempty(EndNodes)
        XBegs{end+1} = XBeg;
        YBegs{end+1} = YBeg;
        XEnds{end+1} = XEnd;
        YEnds{end+1} = YEnd;
    end
end
fprintf('Translating codes \t ... %1.1f seconds\n',toc);

FR = {};
sens = {};

%% Run Hypermesh 
%  ===================================================================
%  In parallel, evaluate all Layouts, from simple to complex layouts. 
%  It also (Eventually) evaluates the functional complexity.
%  ===================================================================

Responses       = {};
Variables       = {};
Sensibilities   = {};

tic
warning off
parfor i = 1:length(SortedGraphs)

    XB =    XBegs{i};
    YB =    YBegs{i};
    XE =    XEnds{i};
    YE =    YEnds{i};

    % Specify run folder.
    folderName = sprintf('D:/Runs/Evaluation_%i',i); 

    % Specify parameters names and values. 
    
    % TO DO : Add the names and fields to a read me. 
    Names  = {'::Geometry::PanelLength', '::Geometry::PanelHeight', '::Geometry::XBeg', '::Geometry::YBeg', '::Geometry::XEnd', '::Geometry::YEnd', '::Geometry::StiffHeight', '::Material::Matname', '::Material::young ', '::Material::poisson', '::Material::rho', '::Material::Fcy', '::Mesh::meshSize ', '::BCs::axialLoad'};
    Values = {PanelLength, PanelHeight, XB, YB,XE,YE, StiffHeight, Matname, young, poisson, rho, Fcy, meshSize, axialLoad};

    % try
        [Responses{i}, Variables{i}, Sensibilities{i}] = RunHyperMesh(Names, Values, folderName,0);
    % end

    fprintf('Completed Solution %i\n',i)
    
end
toc
warning on

%% Format the outputs for post-processing.

Mass        =   zeros(length(Responses),1);
B1          =   zeros(length(Responses),1);

for i = 1:length(Responses)
   Mass(i)      = Responses{i}.mass;
   B1(i)        = Responses{i}.B_1;
end

SM_Ratio = B1 ./ Mass;

%% Check Sensibilities for compliance only.
% % 
% figure(1)
% for i = 1:length(Sensibilities)
%     clf
%     
%     VarNames = string(Sensibilities{i}.Properties.VariableNames);
%     CompList = startsWith(VarNames,'C');
%     
%     Temp1 = table2array(Sensibilities{i});
%     Temp = [Temp1(:,1:2),Temp1(:,CompList)];  
%     Temp = sortrows(Temp,1);
%     Temp = Temp(:,3:end);
% 
%     imshow(Temp,[],'InitialMagnification',4000)
%     title(SortedGraphs{i}.Code)
%     xlabel(i)
%     pause 
% end

%% Check Sensibilities.
% 
% figure(1)
% for i = 1:length(Sensibilities)
%     clf
%     Temp = table2array(Sensibilities{i});
%     Temp = sortrows(Temp,1);
%     Temp = Temp(:,2:end);
%     Temp = Temp ./ Temp(:,1);
%     Temp = Temp(:,2:end);
%     Temp = Temp ./ max(abs(Temp));
%     imshow(abs(Temp),[],'InitialMagnification',4000)
%     title(AllCodes(i))
%     pause 
% end