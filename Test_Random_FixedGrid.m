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
SubSteps    = 8;
MaxLayouts  = 8*30;

% Initialize search
AllLayouts        = {};
AllSensi          = {};
AllComp           = [];
AllComplexity     = [];
AllMass           = [];
AllLayouts{1}     = Layout_Fixed_Grid(5,5);

AllCodes = {};
AllCodes{1} = AllLayouts{1}.getCode;
[AllComp(1), AllMass(1), AllComplexity(1),~]  = AllLayouts{1}.EvaluatePerformance("D:\\Runs\\Evaluation_PreRun",[1 1]);

% Do Random-Search
tic
BAR = waitbar(0,'Generating new layouts...');
figure(2)
clf
while length(AllLayouts) <= MaxLayouts
    
    % Fill the Queue with randomly chosen existing layouts. 
    QueueID = randi(length(AllLayouts),SubSteps,1);

    % Use a parallel pool to create new layouts by using the queue as
    % starting points. 
    
    Queue = AllLayouts(QueueID);
    NewLayouts = cell(1,length(Queue));
    NewCodes   = cell(1,length(Queue));
    Sensi      = cell(1,length(Queue));
    Compliance = zeros(1,length(Queue));
    Mass       = zeros(1,length(Queue));
    Complexity = zeros(1,length(Queue));
    
    parfor (i = 1:length(Queue),8)
%     for i = 1:length(Queue)
        
        ThisLayout = Queue{i};
        
        % Get the list of possible type of actions, and its given list. 
        [Act_List] = ThisLayout.ListOfPossibleActions;
        
        Rand = randperm(size(Act_List,1),1);

        N1 = Act_List{Rand,1};
        N2 = Act_List{Rand,2};
        
        NewLayouts{i}     = ThisLayout.CreateStiffener(N1,N2);
        NewCodes{i}       = NewLayouts{i}.getCode;
        
        isNew = ~any(ismember(AllCodes,NewCodes{i}));
        
        if ~isNew 
            NewLayouts{i} = {};
            NewCodes{i}   = {};          
        else
            filename = sprintf("D:\\Runs\\Evaluation_%i",i);
            
            try
                [Compliance(i), Mass(i), Complexity(i), Sensi{i}] = NewLayouts{i}.EvaluatePerformance(filename,[1 1]);
                fprintf('Evaluation %i completed. \n',i)
            catch Exception
                 beep
                 fprintf('Fuck up in evaluation %i. \n',i)
                 disp(Exception)
                 NewLayouts{i} = {};
                 NewCodes{i}   = {};
            end
        end

    end
    
    clc
    
    % Display New Results
    figure(2)
    clf
    for i = 1 : length(NewLayouts)
        if ~isempty(NewLayouts{i})
            subplot(4,4,i)
            NewLayouts{i}.PlotGraph(0,0,[1,1]);
        end
    end
    
    figure(3)
    clf
    for i = 1 : length(Sensi)
        if ~isempty(Sensi{i})
            subplot(4,4,i)
            imshow(Sensi{i},[],'InitialMagnification',4000);
            ylabel(num2str(Complexity(i)))
            xlabel(num2str(Compliance(i)))
        end
    end   
    pause(0.05)
    
    beep
    
    NewLayouts      = NewLayouts(~cellfun('isempty',NewLayouts));
    NewCodes        = NewCodes(~cellfun('isempty',NewCodes));
    
    % Extract from parallel runs, and ensure unique new solutions.
    [~, ID2, ~] = unique(NewCodes);
    NewUnique       = zeros(size(NewCodes));
    NewUnique(ID2)  = 1;
    CheckAll        = ~ismember(NewCodes, AllCodes);
    CheckedNew      = all([CheckAll;NewUnique]);
    
    % Append the All Framework. 
    AllCodes        = [AllCodes,NewCodes(CheckedNew)];
    AllLayouts      = [AllLayouts,NewLayouts(CheckedNew)];
    AllSensi        = [AllSensi,Sensi(CheckedNew)];
    AllComp         = [AllComp,Compliance(CheckedNew)];
    AllMass         = [AllMass,Mass(CheckedNew)];
    AllComplexity   = [AllComplexity,Complexity(CheckedNew)];

    msg = sprintf('Generating New Layouts %i... (%1.2f seconds elapsed)',length(AllLayouts),toc);
    waitbar(length(AllLayouts) / MaxLayouts, BAR,msg)
    
end

close(BAR);
beep
fprintf('Generated %i Layouts in %1.2f seconds\n',length(AllLayouts),toc);


