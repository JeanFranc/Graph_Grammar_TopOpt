clear all
clc
addpath('Data')

% load Pressure_245.mat
load 248_Pressure.mat


figure(1)

for i = 1:length(AllLayouts)
   clf
   subplot(1,3,1)
   AllLayouts{i}.PlotGraph(0,0,[1,1]);
   subplot(1,3,2)
   imshow(AllSensi{i},[],'InitialMagnification',4000)
   xlabel(AllComp(i))
   subplot(1,3,3)
%    [S,V,D] = svd(AllSensi{i});
   V = svd(AllSensi{i});
   imshow(V,[],'InitialMagnification',4000)
%    xlabel(max(V,[],'all')-min(V,[],'all'))
    xlabel(-log10(min(V,[],'all') / max(V,[],'all')))
end

%%

clear all
clc
addpath('Data')

load Compression_244.mat
% load Pressure_245.mat
% load 248_Pressure.mat

% Compute Complexity.
Complexity = zeros(size(AllSensi));
for i = 1:length(AllSensi)
   if ~isempty(AllSensi{i})
%        V          = svd(AllSensi{i});
%        Complexity(i) = -log10(min(V,[],'all') / max(V,[],'all'));
       Complexity(i) = log10(cond(AllSensi{i}));
%        [~,T] = Reangularity(AllSensi{i});
%        Complexity(i) = quantile(T(T~=0),0.25);
%         [Xsub,~]=licols(AllSensi{i},0.0001);
%         Complexity(i) = cond(Xsub);

   else
       Complexity(i) = NaN;
   end
end

AllComp(AllComp == 0) = NaN;

figure(2)
clf
scatter(Complexity, log10(AllComp))
labelpoints(Complexity, log10(AllComp), string(1:length(AllSensi)))
title('Relation of complexity to performance for iso-mass panels')
xlabel('Complexity measure')
ylabel('Log10 of Compliance')
%%
[ID1, ID2] = sort(Complexity);

figure(3)
for j = 1:length(ID2)
   i = ID2(j);
   clf
   subplot(1,3,1)
   AllLayouts{i}.PlotGraph(0,0,[1,1]);
   subplot(1,3,2)
   imshow(AllSensi{i},[],'InitialMagnification',4000)
   xlabel(AllComp(i))
   subplot(1,3,3)
%    [S,V,D] = svd(AllSensi{i});
   V = svd(AllSensi{i});
   imshow(V,[],'InitialMagnification',4000)
%    xlabel(max(V,[],'all')-min(V,[],'all'))
    xlabel(Complexity(j))   
    
end



%% Test with reangularity.

clear all
close all
clc
addpath('Data')

load Pressure_245.mat

figure(1)
for i = 1:length(AllLayouts)
   clf
   subplot(1,3,1)
   AllLayouts{i}.PlotGraph(0,0,[1,1]);
   subplot(1,3,2)
   imshow(AllSensi{i},[],'InitialMagnification',4000)
   xlabel(AllComp(i))
   subplot(1,3,3)
%    [S,V,D] = svd(AllSensi{i});
   [R,T] = Reangularity(AllSensi{i});
   imshow(T,[],'InitialMagnification',4000);
   xlabel(quantile(T(T~=0),0.25))
end


%% Read compression results. 

clear all
close all
clc
addpath('Data')

load SimplySupported_Compression.mat

scatter(AllComplexity, log10(AllComp))
labelpoints(AllComplexity, log10(AllComp), string(1:length(AllComplexity)))
