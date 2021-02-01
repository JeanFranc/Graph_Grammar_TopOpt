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
MaxLayouts  = 8*30;
ArchiveSize = 20;

% Initialize Layout. 
Init.Layout       = Layout_Fixed_Grid(5,5);
Init.Code         = Init.Layout.getCode;

[Init.Compliance, Init.Mass, Init.Complexity,Init.Sensibility]  = Init.Layout.EvaluatePerformance("D:\\Runs\\Evaluation_PreRun",[1 1]);

%% Start Burst Search.

% Initialize Archive.
Archive     = {};
Archive{1}  = Init;

% Initialize Registry. 
CodeRegistry        = {};
CodeRegistry{1}     = Init.Code;

tic
while length(CodeRegistry) <= MaxLayouts
    
    % Fill the Queue with randomly chosen existing layouts from the archive. 
    QueueID = randi(length(Archive),SubSteps,1);
    Queue   = Archive(QueueID);
    
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
        
        % Generate new layouts until it is a new one. 
        GeneratingNewLayout = true;
        while GeneratingNewLayout
        
        % Load the old layout in memory. 
        ThisLayout = Queue{i}.Layout;
        
        % Extract the possible moves.
        Act_List   = ThisLayout.ListOfPossibleActions;
        
        % Decide randomly on one of the possible connections. 
        Rand    = randperm(size(Act_List,1),1);
        N1      = Act_List{Rand,1};
        N2      = Act_List{Rand,2};
        
        NewLayout     = ThisLayout.CreateStiffener(N1,N2);
        NewCode       = NewLayout.getCode;       
        
        isNew = ~any(ismember(CodeRegistry,NewCode));
        
            if isNew
                % Add the new layout to the burst.
                GeneratingNewLayout = false;
                Burst{i}.Layout     = NewLayout;
                Burst{i}.Code       = NewCode;
                
                % Add the new Layout to the registry.
                CodeRegistry{end+1}     = NewCode;
                
            else
                GeneratingNewLayout = true;
            end
        
        end

    end
    
    % Evaluate the performance of the new layouts. 
    parfor (i = 1:length(Burst),8)

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
    beep
    
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
    
%     % Rebuild the archive with the new results. 
%     TempArchive = [Archive;Burst];
%     p = [];
%     
%     % Build the ParetoFrontier.
%     for i = 1:length(TempArchive)
%        p(i,1) = TempArchive{i}.Compliance;
%        p(i,2) = TempArchive{i}.Complexity;
%     end
%     [idxs] = paretoQS(p);
%     Archive = TempArchive(idxs);
        
    % Display the result of this burst. 
    figure(1)
    clf
    for i = 1:length(Archive)
        try
            subplot(5,5,i)
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
    
end

toc
