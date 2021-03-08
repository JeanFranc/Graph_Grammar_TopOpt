clear all
close all
clc

addpath('Classes')
addpath('Functions')
addpath('Data')

% load BigPressure_Archive.mat
load ForParetoTest.mat

COMP  = zeros(length(Archive),1);
COMP2 = zeros(length(Archive),1);
deti = zeros(length(Archive),1);

Sensi = {};
for i = 2:length(Archive)
    
    Sensi{i-1} = Archive{i}.Sensi;
    
    % Try to identify Superfluous Information.
    
    DP_NORM = [];
    for j = 1:size(Sensi{i-1},1)
       Vect_DP = Sensi{i-1}(j,:); 
       DP_NORM(j,1) = norm(Vect_DP);
    end
    
    CurrentComplexity = Archive{i}.Complexity;
    
    %SuperFluousInformation
    tol = 0.10;
    SupInfo = find(DP_NORM./max(DP_NORM) > tol); 
    
    figure(1)
    clf
    subplot(2,2,1)
    Archive{i}.Layout.PlotGraph(0,0,[1,1]);    
    subplot(2,2,2)
    imshow(Sensi{i-1},[],'InitialMagnification',4000);
    subplot(2,2,[3,4])
    plot(DP_NORM./max(DP_NORM),'x')
    
    NewComp = (length(DP_NORM) - length(SupInfo))/length(DP_NORM);

    
    if NewComp ~= 0
        disp(NewComp)
        disp('HERE')
    end
    
    xlabel(NewComp)
    ylim([0,1])
    
    
    
 end

