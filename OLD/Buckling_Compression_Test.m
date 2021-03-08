clear all
close all
clc

addpath('Classes')
addpath('Functions')
addpath('Data')

Init.Layout       = Layout_Fixed_Grid(5,5);

figure(1)
clf
Init.Layout.PlotGraph(1,1,[1,1])

SIMP    = Init.Layout.CreateStiffener('N2','N22');
SIMP    = SIMP.CreateStiffener('N4','N24');

figure(2)
clf
SIMP.PlotGraph(0,0,[1,1]);

[Test.Buckling, Test.Mass, Test.Complexity,Test.Sensi]  = SIMP.EvaluatePerformance("D:\\Runs\\Evaluation_BuckTest",[1,1],1);
