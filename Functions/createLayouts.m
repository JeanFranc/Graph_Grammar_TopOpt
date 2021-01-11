function [AllCodes] = createLayouts(MaxLayouts,MaxV, MaxH)

% Initializing temporary variables.
AllCodes        = {};
AllCodes{1}     = '1 0 X X';
change          = Inf;

while length(AllCodes) <= MaxLayouts && change > 0
   
    Queue = randi(length(AllCodes),25,1);
    Queue = unique(Queue);
    
    currentSize = length(AllCodes);
    
    for i = 1:length(Queue)
        
        % Parse the string for decisions.
        Inputs = regexp(AllCodes{Queue(i)},' ','split');
        
        HX = str2double(Inputs{1});
        VX = str2double(Inputs{2});
        
        HC_Mat = [];
        for j = 1:length(Inputs{3})/2
            HC_Mat(j,:) = [str2double(Inputs{3}(2*j-1)), str2double(Inputs{3}(2*j))];
        end
        
        VC_Mat = [];
        for j = 1:length(Inputs{4})/2
            VC_Mat(j,:) = [str2double(Inputs{4}(2*j-1)), str2double(Inputs{4}(2*j))];
        end
        
        % Evaluate what is possible from current position.
        PosOptions = zeros(1,4);
        
        % Can we add stiffeners ?
        PosOptions(1) = max(MaxH-HX,0);
        PosOptions(2) = max(MaxV-VX,0);
        
        % Can we cross existing stiffeners ?
        PosOptions(3) = HX * (HX - 1) / 2 - size(HC_Mat,1);
        PosOptions(4) = VX * (VX - 1) / 2 - size(VC_Mat,1);
        
        % Can we remove existing stiffeners ?
        %         PosOptions(5) = HX;
        %         PosOptions(6) = VX;
        
        % Decide randomly which action to take from current position.
        FindOptions         = find(PosOptions ~= 0);
        RandDecision        = randi(length(FindOptions));
        TrueDecision        = FindOptions(RandDecision);
        
        % Create a new code.
        if TrueDecision == 1
            NewCode = sprintf('%s %s %s %s',num2str(HX+1),Inputs{2},Inputs{3},Inputs{4});
        elseif TrueDecision == 2
            NewCode = sprintf('%s %s %s %s',Inputs{1},num2str(VX+1),Inputs{3},Inputs{4});
        elseif TrueDecision == 3
            C = nchoosek( 1:HX ,2);
            if ~isempty(HC_Mat)
                Temp = ~ismember(C, HC_Mat,'rows');
                NewComb = C(Temp,:);
            else
                NewComb = C;
            end
            Decision = randi(size(NewComb,1));
            Temp    = sprintf('%s',num2str([reshape(HC_Mat',1,numel(HC_Mat)),NewComb(Decision,:)]));
            Temp    = Temp(~isspace(Temp));
            NewCode = sprintf('%s %s %s %s',Inputs{1},Inputs{2},Temp,Inputs{4});
        elseif TrueDecision == 4
            C = nchoosek( 1:VX ,2);
            if ~isempty(VC_Mat)
                Temp = ~ismember(C, VC_Mat,'rows');
                NewComb = C(Temp,:);
            else
                NewComb = C;
            end
            Decision = randi(size(NewComb,1));
            Temp    = sprintf('%s',num2str([reshape(VC_Mat',1,numel(VC_Mat)),NewComb(Decision,:)]));
            Temp    = Temp(~isspace(Temp));
            NewCode = sprintf('%s %s %s %s',Inputs{1},Inputs{2},Inputs{3},Temp);
        end
        
        % Check if the code already exists.
        %Test        = strfind(AllCodes,NewCode);
        if ~contains(AllCodes, NewCode)%cellfun('isempty',Test)
            AllCodes{end+1} = NewCode;
        end
    end
    
    change = length(AllCodes) - currentSize;    
    
    
end

end

