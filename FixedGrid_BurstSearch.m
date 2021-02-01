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
MaxLayouts  = 8*10;

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
    tic
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
    
    clc
    beep
    
    % Rebuild the archive with the new results. 
    TempArchive = [Archive;Burst];
    p = [];
    
    % Build the ParetoFrontier.
    for i = 1:length(TempArchive)
       p(i,1) = TempArchive{i}.Compliance;
       p(i,2) = TempArchive{i}.Complexity;
    end
    [idxs] = paretoQS(p);
    Archive = TempArchive(idxs);
        
    % Display the result of this burst. 
    figure(1)
    clf
    for i = 1:length(Archive)
        subplot(1,8,i)
        Archive{i}.Layout.PlotGraph(0,0,[1 1])
    end
    
    figure(2)
    clf
    scatter(p(:,2),p(:,1),'r')
    hold on
    scatter(p(idxs,2),p(idxs,1),'b')
    xlabel('TESTING ZONE')
    pause(0.005) % Pause to update figures
    
end