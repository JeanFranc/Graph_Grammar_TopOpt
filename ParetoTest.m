
clear all
clc
close all

addpath('Data')
addpath('Functions')

load ForParetoTest.mat

% Prepare the data set.

MyPareto = MyParetoSelection(Archive);