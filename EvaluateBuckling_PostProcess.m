clear all
close all
clc

addpath('Classes')
addpath('Functions')
addpath('Data')

load FullCompression500.mat

% Get all data.

TEMP_COMP = [];
for i = 1:length(Archive)
    TEMP_COMP(i,1) = Archive{i}.Compliance;
    TEMP_COMP(i,2) = Archive{i}.Complexity;
    TEMP_COMP(i,3) = Archive{i}.Mass;
end

[~, sID] = sort(TEMP_COMP(:,1));

sortedCOMP = TEMP_COMP(sID,:);
TempArchive = Archive(sID);

ParetoID = paretoQS(sortedCOMP(:,[1 2]));

subSize = ceil(sqrt(length(ParetoID)));

Buckling    = zeros(length(ParetoID),1);
Mass        = zeros(length(ParetoID),1);
Complexity  = zeros(length(ParetoID),1);
Sensi       = cell(length(ParetoID),1);

AllLayouts  = cell(length(ParetoID),1);

for i = 1:length(ParetoID)
    AllLayouts{i} = TempArchive{ParetoID(i)}.Layout;
end

parfor (i = 1:length(AllLayouts),8)
    
    subplot(subSize,subSize,i)
    TempLayout = AllLayouts{i};
    filename = sprintf("D:\\Runs\\Evaluation_%i",i);
    
    [Buckling(i), Mass(i), Complexity(i), Sensi{i}] = TempLayout.EvaluatePerformance(filename,[1 1],1);

end

%%

clear all

load Small_Buckling_Evaluations.mat

figure(1)
clf

subSize = ceil(sqrt(length(AllLayouts)));

TEMP_COMP = [];
for i = 1:length(Buckling)
    TEMP_COMP(i,1) = Buckling(i);
    TEMP_COMP(i,2) = Complexity(i);
    TEMP_COMP(i,3) = Mass(i);
end

[~, sID] = sort(TEMP_COMP(:,3));

TempLayouts     = AllLayouts(sID);
TempBuck        = Buckling(sID);
TempComplexity  = Complexity(sID);
TempMass        = Mass(sID);

for i = 1:length(TempLayouts)
    subplot(subSize,subSize,i)
    TempLayout = TempLayouts{i};
    TempLayout.PlotGraph(0,0,Symmetry);
    
    t_label = sprintf('Weight: %3.2f\nComplexity: %1.2f',...
        TempMass(i),...
        TempComplexity(i));
    
    set(gca, 'FontName', 'Times New Roman','FontSize',10)
    set(gca,'YTickLabel',[]);
    set(gca,'XTickLabel',[]);
    
    xlabel(t_label)
    
end