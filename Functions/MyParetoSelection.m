function [MyPareto] = MyParetoSelection(Archive)


nbins     = 3;
ncores    = 8;
BinsSizes = [4,3,1];

for i = 1:length(Archive)
    Resp(i,1) = Archive{i}.Compliance;
    Complexity(i,1) = Archive{i}.Complexity;
end

% Division of simple to complex solutions.
Range = max(Complexity)-min(Complexity);
Bins  = min(Complexity):Range/nbins:max(Complexity);

MyPareto = {};

for i = 1:length(Bins) - 1
    
    beging = Bins(i);
    ending = Bins(i+1);
    
    ThisBinRange = find(Complexity >= beging & Complexity < ending);
    TempArchive  = Archive(ThisBinRange);
    
    p = [Complexity(ThisBinRange), Resp(ThisBinRange)];
    
    [idxs]        = paretoQS(p);
    try
        ThisCombo     = randperm(length(idxs),BinsSizes(i));
        MyPareto      = [MyPareto; TempArchive(ThisCombo)];
    catch
        try
            IDx             = randi(length(idxs),BinsSizes(i),1);
            MyPareto     = [MyPareto; TempArchive(IDx)];
        end
    end
    
    
    
end


end

% figure(1)
% clf
% color = [zeros(nbins,1),linspace(1,0,nbins)',linspace(0,1,nbins)'];
%
% for i = 1:length(MyPareto)
%     p = [];
%     This = MyPareto{i};
%     for j = 1:length(This)
%         p(j,1) = This{j}.Compliance;
%         p(j,2) = This{j}.Complexity;
%     end
%     scatter(p(:,2),p(:,1),10,color(i,:))
%     hold all
% end