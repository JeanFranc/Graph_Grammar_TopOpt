%% Prepare WorkSpace

clear all
close all
clc

addpath('Classes')
addpath('Functions')
addpath('TCL')

%% Initialize Parameters
% Structural Parameters
Buckling = 1;
Symmetry = [1 1];

% Search Parameters
SubSteps    = 8; % Burst Size;
MaxLayouts  = 500;
maxEdges    = 20;
r           = 3;

% Initialize Layout. 
Init.Layout       = Layout_Fixed_Grid(4,4);
Init.Code         = Init.Layout.getCode;

[Init.Buckling, Init.Mass, Init.Complexity,Init.Sensi]  = Init.Layout.EvaluatePerformance("D:\\Runs\\Evaluation_PreRun",Symmetry,Buckling);

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

ConvergenceHistory = [];
ConvI              = 1;

while length(CodeRegistry) <= MaxLayouts
    
    clc
    
    TEMP_COMP = [];
    for i = 1:length(Archive)
       TEMP_COMP(i,1) = Archive{i}.Mass;
    end
    
    ConvergenceHistory(ConvI) = min(TEMP_COMP);
    ConvI = ConvI + 1;
    
    
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
        
        % Ensures that the pareto contains at least N/r.
        TruePareto = {};
        while length(TruePareto) < SubSteps/r
            
            % Build the model for Pareto Evaluation.
            p = [];
            for i = 1:length(TempArchive)
               p(i,1) = TempArchive{i}.Mass;
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


    
    figure(420)
    clf
    plot(ConvergenceHistory,'x-')
    
%     QueueID_Pareto  = randi(length(TruePareto),SubSteps,1);
%     if length(TruePareto) > SubSteps
    QueueID_Pareto  = randperm(length(TruePareto),min(length(TruePareto),SubSteps))';
    LL = SubSteps - length(QueueID_Pareto);
    QueueID_Pareto  = [QueueID_Pareto;randi(length(TruePareto),LL,1)];
%     else
%         QueueID_Pareto  = randperm(length(TruePareto),SubSteps);
%     end
%     QueueID_Pareto  = randperm(length(TruePareto),
    Queue           = TruePareto(QueueID_Pareto);
    
    % Display the current Queue
    figure(100)
    clf
    for i = 1:length(Queue)
        try
            subplot(2,4,i)
            Queue{i}.Layout.PlotGraph(0,0,Symmetry);
            xlabel(Queue{i}.Mass)
            ylabel(Queue{i}.Complexity)
        end
    end

    % Initialize the memory for this burst. 
    Burst   = cell(length(Queue),1);
    for i = 1:length(Burst)
       Burst{i}.Code        = '';
       Burst{i}.Sensi       = [];
       Burst{i}.Buckling    = [];
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
            xlabel(TruePareto{i}.Mass)
            ylabel(TruePareto{i}.Buckling)
        end
    end
    
    % Display the last burst
    figure(6969)
    clf
    for i = 1:length(Burst)
        try
            subplot(4,4,i)
            Burst{i}.Layout.PlotGraph(0,0,Symmetry);
            xlabel(Burst{i}.Mass)
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
            [Burst{i}.Buckling, Burst{i}.Mass, Burst{i}.Complexity, Burst{i}.Sensi] = Burst{i}.Layout.EvaluatePerformance(filename,Symmetry,Buckling);
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
       p(i,1) = Burst{i}.Mass;
       p(i,2) = Burst{i}.Complexity;
    end
    
    b = [];
    for i = 1:length(Archive)
       b(i,1) = Archive{i}.Mass;
       b(i,2) = Archive{i}.Complexity;
    end
    
    figure(2)
    clf
    scatter(p(:,2),p(:,1),'ro')
    hold on
    scatter(b(:,2),b(:,1),'bx')
    title('Archive of the Exploration.')
    ylabel('Mass')
    xlabel('Complexity')
    pause(0.005) % Pause to update figures
             
    beep
    
end

toc
