clear all
clc
close all

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
    '::General::Complexity',    ...
    '::Optimization::MassCon'};


XBeg = [0 0 0 0];
XEnd = [1 1 1 1];

n       = 100;
LINS    = linspace(0.2,1,n);
Values = cell(1,n);

for i = 1:n
    
    YBeg = [0.2 LINS(i)-0.2 0.6 0.8];
    YEnd = [0.2 LINS(i) 0.6 0.8];
    
    Values{i} = {   20,                     ...
                    20,                     ...
                    0,                      ...
                    XBeg,                   ...
                    YBeg,                   ...
                    XEnd,                   ...
                    YEnd,                   ...
                    1.5,                    ...
                    'Alu7075',              ...
                    10700000,               ...
                    0.33,                   ...
                    0.1,                    ...
                    68000,                  ...
                    0.5,                    ...
                    120000,                 ...% Axial = 120000, Other = 10;
                    "AxialCompression",     ...% AxialCompression, TransverseCompression, PureShear, Pressure, Mario5Points.
                    "Infinite",             ...% Infinite, SimplySupported, Clamped, None.
                    0,                      ...
                    0,                      ...
                    1,                      ...
                    0,                      ...
                    5.0                     };
    
end

Struct = cell(1,n);

% for i = 1:length(Values)
parfor (i = 1:length(Values),8)
    
    folder = sprintf('D:/Runs/CompTest/Evaluation_%i',i);
    [Struct{i}.TotComp, Struct{i}.Mass, Struct{i}.Sensi, Struct{i}.DPs, Struct{i}.SingleCompliances] = RunHyperMesh_CompComp(Names, Values{i}, folder,0);
    
    disp(i)
    
end

beep

%% 
clc

% load Complexity_Tester.mat
% load Complexity_Tester_4bar.mat

RecognizedInformation       = []; 
AxiomaticInformation        = [];
SuperFluousInformation      = [];
Complexity                  = [];

for i = 1:length(Values)
    
    Sensi               = Struct{i}.Sensi;
    SingleCompliances   = Struct{i}.SingleCompliances;
    DPs                 = Struct{i}.DPs;
    
    S                           = svd(Sensi);
    RecognizedInformation(i)       = sum((1 - (S ./ max(S))).^2) / rank(Sensi); % WeightedEffectiveRank / NumberOfVariables.

    AxiomaticInformation(i)  = norm(Sensi) / (norm(SingleCompliances) / norm(DPs)); % Relative Conditionning Number.

    %SuperFluousInformation
    tol = 0.10;

    DP_NORM = [];
    for j = 1:size(Sensi,1)
       Vect_DP = Sensi(j,:); 
       DP_NORM(j,1) = norm(Vect_DP);
    end

    SupInfo = find(DP_NORM./max(DP_NORM) > tol); 

    SuperFluousInformation(i) = (length(DP_NORM) - length(SupInfo))/length(DP_NORM);

    Complexity(i) = norm([RecognizedInformation(i),AxiomaticInformation(i),SuperFluousInformation(i)]);


end

figure(1)
plot(linspace(0,1,n), RecognizedInformation, 'bx')
hold all
plot(linspace(0,1,n), AxiomaticInformation, 'mx')
plot(linspace(0,1,n), SuperFluousInformation, 'rx')
plot(linspace(0,1,n), Complexity, 'kx')

legend('Recognized','Axiomatic','Superfluous','Total')
ylim([0,1])
xlabel('Position')
ylabel('Complexity')