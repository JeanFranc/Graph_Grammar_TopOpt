clear all
close all

addpath('Data')

load('JustSensis.mat')

%% Check Sensibilities for compliance only. No manipulations
% 
figure(1)
for i = 1:length(Sensibilities)
    clf
    
    VarNames = string(Sensibilities{i}.Properties.VariableNames);
    CompList = startsWith(VarNames,'C');
    
    Temp1 = table2array(Sensibilities{i});
    Temp = [Temp1(:,1:2),Temp1(:,CompList)];  
    Temp = sortrows(Temp,1);
    Temp = Temp(:,3:end);

    imshow(Temp,[],'InitialMagnification',4000)
    title(SortedGraphs{i}.Code)
    xlabel(i)
    pause 
end 

%% Check Sensibilities for compliance only. No manipulations
% 
figure(1)
for i = 1:length(Sensibilities)
    clf
    
    VarNames = string(Sensibilities{i}.Properties.VariableNames);
    CompList = startsWith(VarNames,'C');
    
    Temp1 = table2array(Sensibilities{i});
    Temp = [Temp1(:,1:2),Temp1(:,CompList)];  
    Temp = sortrows(Temp,1);
    Temp = Temp(:,3:end);

    imshow(Temp,[],'InitialMagnification',4000)
    title(SortedGraphs{i}.Code)
    xlabel(i)
    pause 
end 