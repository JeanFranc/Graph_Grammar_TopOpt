clear all
close all
clc

addpath('Classes')
addpath('Functions')
addpath('Data')

Init.Layout       = Layout_Fixed_Grid(5,5);


[Init.Compliance, Init.Mass, Init.Complexity,Init.Sensibility, Init.DPs]  = Init.Layout.EvaluatePerformance("D:\\Runs\\Evaluation_PreRun",[1 1],0);

%%

figure(1)
clf
Init.Layout.PlotGraph(1,1,[1 1]);


%%

OneBar.Layout = Init.Layout.CreateStiffener('N5','N25');
[OneBar.Compliance, OneBar.Mass, OneBar.Complexity,OneBar.Sensibility, OneBar.DPs]  = OneBar.Layout.EvaluatePerformance("D:\\Runs\\Evaluation_PreRun",[1 1],0);

%%

figure(2)
clf
OneBar.Layout.PlotGraph(1,1,[1 1]);


%%


clear all
clc
close all

addpath('Data')

% load BigPressure_Archive.mat
load ShortCompressionArchive.mat

COMP  = zeros(length(Archive),1);
COMP2 = zeros(length(Archive),1);
deti = zeros(length(Archive),1);

for i = 2:length(Archive)
    Sensi = Archive{i}.Sensi;
    
%     deti(i) = log10(abs(det(Sensi)));
    Comp(i) = Archive{i}.Compliance;
    Cond(i) = log10(cond(Sensi));
    
    S = svd(Sensi);
    tol             = 0.05;
    Threshold       = tol* max(S);
    TrueRank        = rank(Sensi,Threshold);
%     New_Complexity(i)  = 1 / (TrueRank / rank(Sensi));
    New_Complexity(i)  = (rank(Sensi) - TrueRank) / rank(Sensi);
    
    WeakCond(i) = sum((1 - (S ./ max(S))).^2) / rank(Sensi);
    
    
    
%     figure(1)
%     clf
%     subplot(3,1,1)
%     Archive{i}.Layout.PlotGraph(0,0,[1 1]);
%     xlabel(deti(i));
%     subplot(3,1,2)
%     imshow(Sensi,[],'InitialMagnification',4000);
% %     xlabel(Cond(i))
%     subplot(3,1,3)
%     hist(S,100);
% %     str = sprintf('SVD %2.2E, Cond %2.2E', max(svd(Sensi)) / min(svd(Sensi)), cond(Sensi));
%     xlabel(WeakCond*100)
%  
%    pause(0.5)
%     
    
    
end

% figure(2)
% clf
% % scatter(Comp(2:end),log10(deti(2:end)))
% % labelpoints(Comp(2:end), log10(deti(2:end)), 2:length(Archive))
% 
% scatter(log10(deti(2:end)),Comp(2:end))
% labelpoints(log10(deti(2:end)),Comp(2:end),2:length(Archive))
% title('Determinant Complexity')
% 
figure(3)
clf
scatter(Cond(2:end),New_Complexity(2:end))
labelpoints(Cond(2:end),New_Complexity(2:end),2:length(Archive))
title('Conditionning Complexity')

figure(4)
clf
scatter(New_Complexity(2:end),Comp(2:end))
labelpoints(New_Complexity(2:end),Comp(2:end),2:length(Archive))
title('Rank Complexity')

figure(5)
clf
scatter(WeakCond(2:end),Comp(2:end))
labelpoints(WeakCond(2:end),Comp(2:end),2:length(Archive))
title('Weak Conditionning Complexity')

figure(6)
clf
scatter(WeakCond(2:end),Cond(2:end))
labelpoints(WeakCond(2:end),Cond(2:end),2:length(Archive))
title('Comparing Measures of Complexities')


