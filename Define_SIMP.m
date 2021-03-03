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

SIMP    = Init.Layout.CreateStiffener('N1','N25');
SIMP    = SIMP.CreateStiffener('N3','N11');
SIMP    = SIMP.CreateStiffener('N20','N19');
SIMP    = SIMP.CreateStiffener('N24','N19');
SIMP    = SIMP.CreateStiffener('N13','N10');
SIMP    = SIMP.CreateStiffener('N13','N22');
SIMP    = SIMP.CreateStiffener('N22','N21');
SIMP    = SIMP.CreateStiffener('N5','N10');

figure(2)
clf
SIMP.PlotGraph(0,0,[1,1])
set(gca,'YTickLabel',[]);
set(gca,'XTickLabel',[]);    

[Test.Compliance, Test.Mass, Test.Complexity,Test.Sensi]  = SIMP.EvaluatePerformance("D:\\Runs\\Evaluation_PreRun",[1,1],0);
