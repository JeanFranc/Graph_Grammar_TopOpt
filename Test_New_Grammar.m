clear all
close all
clc

addpath('Classes')
addpath('Functions')

% Initial Testing.

figure(1)
clf
InitLayout = Layout_Class_V2;
InitLayout.PlotGraph;
pause(0.25)

clf
SplitSides = InitLayout.AppendRules('T1-02-03,T1-03-03');
SplitSides.PlotGraph;
pause(0.25)

clf
FourBar    = SplitSides.AppendRules('T3-N7-N10,T3-N6-N9,T3-N5-N8');
FourBar.PlotGraph;
pause(0.25)

clf
Just_A_X = SplitSides.AppendRules('T3-BR-TL,T3-BL-TR');
Just_A_X.PlotGraph;
pause(0.25)

%%

Tester = FourBar.AppendRules('T3-BR-TL');
clf
Tester.PlotGraph;
pause(0.25)

% Tester = FourBar.AppendRules('T3-BR-TL,T3-BL-TR');

%% Output format for Hypermesh.

ToTest = Just_A_X;
Params = ToTest.Graph2Param;

% Panel Properties
PanelLength     = 60.0;
PanelHeight     = 20.0;
StiffHeight     = 1.5;
Symmetry        = [1 0];

% Material Properties
Matname         = 'Alum_7075';
young           = 10700000;
poisson         = 0.33;
rho             = 0.1;
Fcy             = 68000;

% Mesh Properties
meshSize        = 0.5;

% Boundary Conditions
LoadType        = "PureShear";
Load            = 120120;

% LoadType        = "Pressure";
% Load            = 10;

NumberOfRibs    = 2;
SideConditions  = "SimplySupported";

% Analysis, Sizing, Sensibilities Properties.
G_Buckling        = 0;
G_Stress          = 0;
G_Sizing          = 0;
G_Complexity      = 1;

XB =    Params(1,:);
YB =    Params(2,:);
XE =    Params(3,:);
YE =    Params(4,:);

% Specify run folder.
folderName = sprintf('D:/Runs/Evaluation_%i',1);

% Specify parameters names and values.
Names  = {  '::Geometry::PanelLength',  ...
            '::Geometry::PanelHeight',  ...
            '::Geometry::NumberOfRibs', ...
            '::Geometry::XBeg',         ...
            '::Geometry::YBeg',         ...
            '::Geometry::XEnd',         ...
            '::Geometry::YEnd',         ...
            '::Geometry::StiffHeight',  ...
            '::Material::Matname',      ...
            '::Material::young ',       ...
            '::Material::poisson',      ...
            '::Material::rho',          ...
            '::Material::Fcy',          ...
            '::Mesh::meshSize ',        ...
            '::BCs::Load',              ...
            '::BCs::LoadType',          ...
            '::BCs::SideConditions',    ...
            '::General::Buckling',      ...
            '::General::Stress',        ...
            '::General::Sizing', 		...
            '::General::Complexity'     };

Values = {  PanelLength,    ...
            PanelHeight,    ...
            NumberOfRibs,   ...
            XB,             ...
            YB,             ...
            XE,             ...
            YE,             ...
            StiffHeight,    ...
            Matname,        ...
            young,          ...
            poisson,        ...
            rho,            ...
            Fcy,            ...
            meshSize,       ...
            Load,           ...
            LoadType,       ...
            SideConditions, ...
            G_Buckling,     ...
            G_Stress,       ...
            G_Sizing,       ...
            G_Complexity    };

%% Run Hypermesh.

% Echo = 0;
% tic
% [Responses,Labels, Variables, Sensibilities] = RunHyperMesh(Names, Values, folderName,Echo);
% toc
% 
% Sens = table2array(Sensibilities);
% Sens = Sens(:,3:end);
% 
% figure(190)
% clf
% imshow(Sens,[],'InitialMagnification',4000);