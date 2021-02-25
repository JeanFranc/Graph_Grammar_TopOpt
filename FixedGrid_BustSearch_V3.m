%% Prepare WorkSpace

clear all
close all
clc

addpath('Classes')
addpath('Functions')
addpath('TCL')

%% Initialize Parameters
% Structural Parameters
Buckling = 0;
Symmetry = [1 1];

% Search Parameters
SubSteps    = 8; % Burst Size;
MaxLayouts  = 500;
maxEdges    = 20;
% ArchiveSize = 8;

% Initialize Layout. 
Init.Layout       = Layout_Fixed_Grid(5,5);
Init.Code         = Init.Layout.getCode;

[Init.Compliance, Init.Mass, Init.Complexity,Init.Sensi]  = Init.Layout.EvaluatePerformance("D:\\Runs\\Evaluation_PreRun",Symmetry,Buckling);

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
    
    clc
    
    % Check if a given layout as been completely explored 
    % So, check if it is a dead-end.
    % Often happens for the empty layout. 
    
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
    
    % If the Archive is still small, just add everything to the archive. 
    if length(TempArchive) < SubSteps
        TruePareto = TempArchive;
    else
        
        TruePareto = {};
        while length(TruePareto) < SubSteps/2
            
            % Build the model for Pareto Evaluation.
            p = [];
            for i = 1:length(TempArchive)
               p(i,1) = TempArchive{i}.Compliance;
               p(i,2) = TempArchive{i}.Complexity;
            end
            
            % Evaluate the pareto components. 
            [idxs] = paretoQS(p);
            
            TruePareto = [TruePareto; TempArchive(idxs)];
            ID          = zeros(length(TempArchive),1);
            ID(idxs)    = 1;
            TempArchive = TempArchive(~ID);
        end
    
    end

    QueueID_Pareto  = randi(length(TruePareto),SubSteps,1);
    Queue           = TruePareto(QueueID_Pareto);
    
    % Display the current Queue
    figure(100)
    clf
    for i = 1:length(Queue)
        try
            subplot(2,4,i)
            Queue{i}.Layout.PlotGraph(0,0,Symmetry);
            xlabel(Queue{i}.Compliance)
            ylabel(Queue{i}.Complexity)
        end
    end

    % Initialize the memory for this burst. 
    Burst   = cell(length(Queue),1);
    for i = 1:length(Burst)
       Burst{i}.Code        = '';
       Burst{i}.Sensi       = [];
       Burst{i}.Compliance    = [];
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
            
            % If the Layout goes above the maximum edges requirement,
            % Consider it a dead-end and do not start from it. 
            
            if height(Burst{i}.Layout.Graph.Edges) > maxEdges
                CompletedRegistry{end+1}    = Burst{i}.Layout.getCode;
            end
            
        else
            CompletedRegistry{end+1}    = Queue{i}.Layout.getCode;
        end
        
        

    end
    
    Burst      = Burst(~cellfun('isempty',Burst));
    
    % Display the current Pareto
    figure(1)
    clf
    for i = 1:length(TruePareto)
        try
            subplot(4,4,i)
            TruePareto{i}.Layout.PlotGraph(0,0,Symmetry);
            xlabel(TruePareto{i}.Compliance)
            ylabel(TruePareto{i}.Complexity)
        end
    end
    
    % Display the last burst
    figure(6969)
    clf
    for i = 1:length(Burst)
        try
            subplot(4,4,i)
            Burst{i}.Layout.PlotGraph(0,0,Symmetry);
            xlabel(Burst{i}.Compliance)
            ylabel(Burst{i}.Complexity)
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
            [Burst{i}.Compliance, Burst{i}.Mass, Burst{i}.Complexity, Burst{i}.Sensi] = Burst{i}.Layout.EvaluatePerformance(filename,Symmetry,Buckling);
            fprintf('Evaluation %i completed. \n',i)
        catch Exception
             beep
             fprintf('Fuck up in evaluation %i. \n',i)
             disp(Exception)
             Burst{i} = {};
        end
        
    end
    
    Burst      = Burst(~cellfun('isempty',Burst));
    
    % Rebuild the archive with the new results. 
    Archive  = [Archive;Burst];
    
    p = [];
    for i = 1:length(Burst)
       p(i,1) = Burst{i}.Compliance;
       p(i,2) = Burst{i}.Complexity;
    end
    
    b = [];
    for i = 1:length(Archive)
       b(i,1) = Archive{i}.Compliance;
       b(i,2) = Archive{i}.Complexity;
    end
    
    figure(2)
    clf
    scatter(p(:,2),p(:,1),'ro')
    hold on
    scatter(b(:,2),b(:,1),'bx')
    xlabel('TESTING ZONE')
    pause(0.005) % Pause to update figures
             
    beep
    
end

toc
