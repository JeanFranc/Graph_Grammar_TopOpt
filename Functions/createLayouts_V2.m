function [AllCodes] = createLayouts_V2(MaxLayouts)

% Initialize list and variables.
AllGraphs{1}     = Layout_Class_V2('');
change          = Inf;

while length(AllCodes) <= MaxLayouts && change > 0
   
    Queue = randi(length(AllCodes),25,1);
    Queue = unique(Queue);
    
    currentSize = length(AllCodes);
    
    for i = 1:length(Queue)
        InitialInputs = AllCodes{Queue(i)};
        
        
    end
    
    change = length(AllCodes) - currentSize;    
    
    
end

end

