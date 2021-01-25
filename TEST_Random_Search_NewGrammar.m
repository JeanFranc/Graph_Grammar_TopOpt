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
SubSteps    = 8*2;
MaxLayouts  = 800;

% Initialize search
AllLayouts        = {};
AllLayouts{1}     = Layout_Class_V2();

%% Do Random-Search
tic

BAR = waitbar(0,'Generating new layouts...');

figure(1)
clf
while length(AllLayouts) <= MaxLayouts
   
    % Fill the Queue with randomly chosen existing layouts. 
    QueueID = randi(length(AllLayouts),SubSteps,1);

    % Use a parallel pool to create new layouts by using the queue as
    % starting points. 
    
    Queue = AllLayouts(QueueID);
    NewLayouts = cell(1,length(Queue));
    
%     parfor (i = 1:length(Queue),16)
    for i = 1:length(Queue)
        
        ThisLayout = Queue{i};
        
        % Get the list of possible type of actions, and its given list. 
        [Act_Bool, Act_List] = ThisLayout.ListPossibleActions;
        
        % Choose one random rule, amongst available ones. 
        PossibleMainActions = find(Act_Bool);
        Rand = randperm(length(PossibleMainActions),1);
        
        % Get list of available moves, from the chosen rule.
        Possible_List = Act_List{PossibleMainActions(Rand)};
        
        Action = Possible_List(randi(length(Possible_List)));
        
        NewLayouts{i} = ThisLayout.AppendRules(Action);
   
    end

    % Display New Results
    clf
    for i = 1 : length(NewLayouts)
        subplot(4,4,i)
        NewLayouts{i}.PlotGraph;
    end
    pause(0.25)
    
    % Extract from parallel runs;
    AllLayouts = [AllLayouts,NewLayouts];
    
    % Try to eliminate doublons
    msg = sprintf('Generating New Layouts... (%1.2f seconds elapsed)',toc);
    waitbar(length(AllLayouts) / MaxLayouts, BAR,msg)
    
end

close(BAR);

fprintf('Generated %i Layouts in %1.2f seconds\n',length(AllLayouts),toc);