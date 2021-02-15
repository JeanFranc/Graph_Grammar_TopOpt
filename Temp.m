clear all
clc

addpath('Data')
addpath('Functions')
addpath('Classes')

load BigPressure_Archive.mat

%%

p = [];
for i = 1:length(Archive)
    p(i,1) = Archive{i}.Compliance;
    p(i,2) = Archive{i}.Complexity;
end

[idxs]      = paretoQS(p);  
TruePareto  = TempArchive(idxs);

b = [];
for i = 1:length(TruePareto)
    b(i,1) = TruePareto{i}.Compliance;
    b(i,2) = TruePareto{i}.Complexity;
end

figure(1)
clf
scatter(p(:,2),p(:,1),'ro')
hold on
scatter(b(:,2),b(:,1),'bx')
xlabel('TESTING ZONE')
pause(0.005) % Pause to update figures

figure(2)
clf
for i = 1:length(TruePareto)
    try
        subplot(4,4,i)
        TruePareto{i}.Layout.PlotGraph(0,0,[1 1]);
        xlabel(TruePareto{i}.Compliance)
        ylabel(TruePareto{i}.Complexity)
    end
end