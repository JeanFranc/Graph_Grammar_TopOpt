clear all
close all
clc

addpath('Classes')
addpath('Functions')
addpath('TCL')

%%

figure(1)
clf
InitLayout  = Layout_Fixed_Grid(5,5);
InitLayout.PlotGraph(1,0,[1 1]);
pause(0.05)

New         = InitLayout.CreateStiffener('N1','N24');
clf
New.PlotGraph(1,0,[1 1]);
pause(0.05)
% 
% [Compliance, Mass, Sensi] = New.EvaluatePerformance("D:\Runs\Test6969", [1 1]);
% 
% Actions = New.ListOfPossibleActions;

New         = New.CreateStiffener('N5','N13');
clf
New.PlotGraph(1,0,[1 1]);
pause(0.05)

clf
New         = New.CreateStiffener('N5','N21');
New.PlotGraph(1,0,[1 1]);
pause(0.05)

clf
New         = New.CreateStiffener('N3','N23');
New.PlotGraph(1,0,[1 1]);
pause(0.05)

clf
New         = New.CreateStiffener('N2','N22');
New.PlotGraph(1,0,[1 1]);
pause(0.05)


%%
figure(2)
clf
InitLayout  = Layout_Fixed_Grid(11,11);
InitLayout.PlotGraph;
pause(0.05)

clf
New = InitLayout.CreateStiffener('N11','N111');
New.PlotGraph;
pause(0.05)

clf
New = New.CreateStiffener('N5','N117');
New.PlotGraph;
pause(0.05)

clf
New = New.CreateStiffener('N6','N39');
New.PlotGraph;
pause(0.05)

%%


figure(1)
clf
InitLayout  = Layout_Fixed_Grid(8,8);
InitLayout.PlotGraph(1,0,[1 1]);
pause(0.05)

New         = InitLayout.CreateStiffener('N16','N58');
clf
New.PlotGraph(1,0,[1 1]);
pause(0.05)

New         = New.CreateStiffener('N1','N37');
clf
New.PlotGraph(1,0,[1 1]);
pause(0.05)

[Compliance, Mass, Sensi] = New.EvaluatePerformance("D:\Runs\Test6969", [1 1]);

