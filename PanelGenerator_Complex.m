clear all
clc
close all
addpath('Functions')
addpath('Classes')

%% Defines initial parameters.

% Panel Properties
PanelLength     = 20.0;
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
LoadType        = "AxialCompression";
Load            = 120120;
NumberOfRibs    = 1;
SideConditions  = "SimplySupported";

% Analysis, Sizing, Sensibilities Properties.
G_Buckling        = 0;
G_Stress          = 0;
G_Sizing          = 0;
G_Complexity      = 1;

%% Initialize the list of layout codes.

MaxLayouts      = 100;

tic
AllLayouts = createLayouts(MaxLayouts);
fprintf('Generating codes \t ... %1.1f seconds\n',toc);