clear all
close all
clc

addpath('Classes')
addpath('Functions')
addpath('Data')

% load FullPressure500.mat
% load FullCompression500_XSYM.mat
% load FullPressure500_SecondRun.mat
% load FullCompression500_BUCKLING.mat
load FullCompression500_BUCKLING_MASS.mat

% Get all data.

TEMP_COMP = [];
for i = 1:length(Archive)
    TEMP_COMP(i,1) = Archive{i}.Buckling;
    TEMP_COMP(i,2) = Archive{i}.Complexity;
    TEMP_COMP(i,3) = Archive{i}.Mass;
end

[~, sID] = sort(TEMP_COMP(:,3));

sortedCOMP = TEMP_COMP(sID,:);
TempArchive = Archive(sID);

ParetoID = paretoQS(sortedCOMP(:,[2 3]));

figure(1)
clf

subSize = ceil(sqrt(length(ParetoID)));

for i = 1:length(ParetoID)
    subplot(subSize,subSize,i)
    TempArchive{ParetoID(i)}.Layout.PlotGraph(0,0,Symmetry);
    
    t_label = sprintf('Complexity: %1.2f\nBuckling: %3.2f\nMass: %3.2f',...
        TempArchive{ParetoID(i)}.Complexity,...
        TempArchive{ParetoID(i)}.Buckling,...
        TempArchive{ParetoID(i)}.Mass);
    
    set(gca,'YTickLabel',[]);
    set(gca,'XTickLabel',[]);
    
    xlabel(t_label)
    
end

figure(2)

scatter(TEMP_COMP(:,2),TEMP_COMP(:,3),'x')
ylabel('Buckling')
xlabel('Functional Complexity')
set(gca, 'FontName', 'Times New Roman','FontSize',12)

figure(3)
clf
plot(ConvergenceHistory,'x-')
ylabel('Buckling')
set(gca, 'FontName', 'Times New Roman','FontSize',12)