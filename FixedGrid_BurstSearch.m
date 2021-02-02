%% Prepare WorkSpace

clear all
close all
clc

addpath('Classes')
addpath('Functions')
addpath('TCL')

%% Initialize Parameters
% Structural Parameters

% Search Parameters
SubSteps    = 8; % Burst Size;
MaxLayouts  = 80;
ArchiveSize = 10;

% Initialize Layout. 
Init.Layout       = Layout_Fixed_Grid(3,3);
Init.Code         = Init.Layout.getCode;

[Init.Compliance, Init.Mass, Init.Complexity,Init.Sensibility]  = Init.Layout.EvaluatePerformance("D:\\Runs\\Evaluation_PreRun",[1 1]);

%% Start Burst Search.

% Initialize Archive.
Archive     = {};
Archive{1}  = Init;

% Initialize Registry. 
CodeRegistry        = {};
CodeRegistry{1}     = Init.Code;

% Completed Registry.
CompletedRegistry        = {};


tic
while length(CodeRegistry) <= MaxLayouts
    
    % TWO MODE STRATEGY. Half the substep is from the "BEST" pareto. The
    % rest is from randomly chosen from the archive.
    
    if ~isempty(CompletedRegistry)
        CompletedRegistry = unique(CompletedRegistry);
        TempArchive = {};
        for i = 1:length(Archive)
            if ~any(ismember(Archive{i}.Code, CompletedRegistry))
                TempArchive{end+1} =  Archive{i};
            end
        end
        
        if isempty(TempArchive)
           break; 
        end
        
    else
        TempArchive = Archive;
    end
    
    p = [];
    for i = 1:length(TempArchive)
        p(i,1) = TempArchive{i}.Compliance;
        p(i,2) = TempArchive{i}.Complexity;
    end
    % Evaluate the pareto components. 
    [idxs] = paretoQS(p);  
    TruePareto = TempArchive(idxs);
    
    
    % Fill the Queue from the Archive.
    QueueID_Pareto  = randi(length(TruePareto),floor(SubSteps/2),1);
    QueueID_Randi   = randi(length(TempArchive),floor(SubSteps/2),1);
    Queue           = [reshape(TempArchive(QueueID_Randi), 1,length(QueueID_Randi)),reshape(TruePareto(QueueID_Pareto),1,length(QueueID_Pareto))];
    
    % Initialize the memory for this burst. 
    Burst   = cell(length(Queue),1);
    for i = 1:length(Burst)
       Burst{i}.Code        = '';
       Burst{i}.Sensi       = [];
       Burst{i}.Compliance  = [];
       Burst{i}.Mass        = [];
       Burst{i}.Complexity  = [];
    end
    
    % Generate new layouts until there is "SubSteps" new layouts. 
    for i = 1:length(Queue)
        
        % Create new shit
        NewLayout = Queue{i}.Layout.CreateNewAction(CodeRegistry);
        
        if ~isempty(NewLayout)
            Burst{i}.Layout             = NewLayout;
            Burst{i}.Code               = NewLayout.getCode;
            CodeRegistry{end+1}         = Burst{i}.Code;
        else
            CompletedRegistry{end+1}    = Queue{i}.Layout.getCode;
        end

    end
    
    Burst      = Burst(~cellfun('isempty',Burst));
    
    figure(6969)
    clf
    for i = 1:length(Burst)
        try
            subplot(4,4,i)
            Burst{i}.Layout.PlotGraph(0,0,[1 1]);
        catch
            disp('WTF?')
        end
    end
    pause(0.05)
    
    % Evaluate the performance of the new layouts. 
    parfor (i = 1:length(Burst),8)
%     for i = 1:length(Burst)

        try
            filename = sprintf("D:\\Runs\\Evaluation_%i",i);
            [Burst{i}.Compliance, Burst{i}.Mass, Burst{i}.Complexity, Burst{i}.Sensi] = Burst{i}.Layout.EvaluatePerformance(filename,[1 1]);
            fprintf('Evaluation %i completed. \n',i)
        catch Exception
             beep
             fprintf('Fuck up in evaluation %i. \n',i)
             disp(Exception)
             Burst{i} = {};
        end
        
    end
    
    Burst      = Burst(~cellfun('isempty',Burst));
    
    clc
    
    
    % Rebuild the archive with the new results. 
    NewArchive  = [Archive;Burst];
    Archive     = {};
    
    p = [];
    for i = 1:length(NewArchive)
       p(i,1) = NewArchive{i}.Compliance;
       p(i,2) = NewArchive{i}.Complexity;
    end
    
    figure(2)
    clf
    scatter(p(:,2),p(:,1),'ro')
    hold on
    xlabel('TESTING ZONE')
    pause(0.005) % Pause to update figures
    
    % If the Archive is still small, just add everything to the archive. 
    if length(NewArchive) < ArchiveSize
        Archive = NewArchive;
    else
        TempArchive = NewArchive;
        while length(Archive) < ArchiveSize
            
            % Build the model for Pareto Evaluation.
            p = [];
            for i = 1:length(TempArchive)
               p(i,1) = TempArchive{i}.Compliance;
               p(i,2) = TempArchive{i}.Complexity;
            end
            
            % Evaluate the pareto components. 
            [idxs] = paretoQS(p);
            
            % Add the pareto components to the Archive.
            Archive = [Archive; TempArchive(idxs)];
            ID      = zeros(length(TempArchive),1);
            ID(idxs)= 1;
            TempArchive = TempArchive(~ID);
        end
    
    end
    
        
    % Display the result of this burst. 
    figure(1)
    clf
    for i = 1:length(Archive)
        try
            subplot(3,5,i)
            Archive{i}.Layout.PlotGraph(0,0,[1 1]);
            xlabel(Archive{i}.Compliance)
            ylabel(Archive{i}.Complexity)
        end
    end
   
    p = [];
    for i = 1:length(Archive)
       p(i,1) = Archive{i}.Compliance;
       p(i,2) = Archive{i}.Complexity;
    end
    
    figure(2)
    scatter(p(:,2),p(:,1),'bx')
    xlabel('TESTING ZONE')
    pause(0.005) % Pause to update figures
    
    beep
    
end

figure(1)
clf
for i = 1:length(Archive)
    try
        subplot(3,5,i)
        Archive{i}.Layout.PlotGraph(0,0,[1 1]);
        xlabel(Archive{i}.Compliance)
        ylabel(Archive{i}.Complexity)
    end
end

toc
