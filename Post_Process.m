clear all
close all
clc

addpath('Classes')
addpath('Functions')
addpath('Data')

% load FullPressure500.mat
% load FullCompression500_XSYM.mat
% load FullPressure500_SecondRun.mat
load FullCompression500_BUCKLING.mat

% Get all data.

TEMP_COMP = [];
for i = 1:length(Archive)
    TEMP_COMP(i,1) = Archive{i}.Bucklign;
    TEMP_COMP(i,2) = Archive{i}.Complexity;
    TEMP_COMP(i,3) = Archive{i}.Mass;
end

[~, sID] = sort(TEMP_COMP(:,1));

sortedCOMP = TEMP_COMP(sID,:);
TempArchive = Archive(sID);

ParetoID = paretoQS(sortedCOMP(:,[1 2]));

figure(1)
clf

subSize = ceil(sqrt(length(ParetoID)));

for i = 1:length(ParetoID)
    subplot(subSize,subSize,i)
    TempArchive{ParetoID(i)}.Layout.PlotGraph(0,0,Symmetry);
    
    t_label = sprintf('Complexity: %1.2f\nCompliance: %3.1f',...
        TempArchive{ParetoID(i)}.Complexity,...
        TempArchive{ParetoID(i)}.Compliance);
    
    set(gca,'YTickLabel',[]);
    set(gca,'XTickLabel',[]);
    
    xlabel(t_label)
    
end

figure(2)

scatter(TEMP_COMP(:,2),TEMP_COMP(:,1),'x')
ylabel('Compliance')
xlabel('Functional Complexity')
set(gca, 'FontName', 'Times New Roman','FontSize',12)

figure(3)
clf
plot(ConvergenceHistory,'x-')
ylabel('Compliance')
set(gca, 'FontName', 'Times New Roman','FontSize',12)