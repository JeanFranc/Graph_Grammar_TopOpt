
classdef Layout_Class_V2
    
    properties
        
        Code            = '';
        EdgeIt          = 5;
        NodeIt          = 5;
        
        maxSplit        = 1;
        maxNodes        = 20;
        maxEdges        = 20;
        
        maxEdgePerNode  = 6;
        minEdgeLength   = 0.2;
        
    end
    
    properties(SetAccess=private)
        Graph
    end
    
    % Current Rules:
    
    % T1: Split Edge XXX, N Times - T1-XXX-NN
    % T2: Delete Node XXX - T2-XXX
    % T3: Add Edge to Nodes XXX and YYY - T3-XXX-YYY
    % T4: Remove Edge XXX - T4-XXX
    % T5: Add Mirror X-Y - T5-X-Y                   [Not Implemented]
    
    methods
        
        function obj = Layout_Class_V2()
            
            InitNodes = [   0, 0;... % 1-BottomLeft
                1, 0;... % 2-BottomRight
                1, 1;... % 3-TopRight
                0, 1];   % 4-TopLeft
            
            Adj = [ 0 1 0 1;...
                1 0 1 0;...
                0 1 0 1;...
                1 0 1 0];
            
            NodeTable = array2table(InitNodes,'VariableNames',{'X','Y'});
            InitGraph = graph(Adj, NodeTable);
            
            InitGraph.Nodes.Name = {'BL'; 'BR'; 'TR'; 'TL'};
            InitGraph.Edges.Name = [1; 2; 3; 4];
            InitGraph.Edges.Length = {1.0;1.0;1.0;1.0};
            
            obj.Graph           = InitGraph;
            
        end
        
        function obj = PlotGraph(obj)
            
            Names     = string(obj.Graph.Nodes.Name);
            Pos       = table2array([obj.Graph.Nodes(:,'X'),obj.Graph.Nodes(:,'Y')]);
            
            scatter(Pos(:,1), Pos(:,2))
            labelpoints(Pos(:,1),Pos(:,2),Names);
            axis([-0.5 1.5 -0.5 1.5])
            hold all
            
            EndNodes = obj.Graph.Edges.EndNodes;
            
            for i = 1:size(EndNodes,1)
                Point1 = obj.Graph.findnode(EndNodes(i,1));
                Point2 = obj.Graph.findnode(EndNodes(i,2));
                line([Pos(Point1,1) Pos(Point2,1)], [Pos(Point1,2) Pos(Point2,2)])
            end
            
        end
        
        function Params = Graph2Param(obj)
            
            ThisGraph = obj.Graph;
            EndNodes = ThisGraph.Edges.EndNodes;
            
            Names     = string(obj.Graph.Nodes.Name);
            Pos       = table2array([obj.Graph.Nodes(:,'X'),obj.Graph.Nodes(:,'Y')]);
            
            XBeg = [];YBeg = [];XEnd = []; YEnd = [];
            
            for i = 1:size(EndNodes,1)
                
                Point1 = obj.Graph.findnode(EndNodes(i,1));
                Point2 = obj.Graph.findnode(EndNodes(i,2));
                
                XBeg(end+1) = Pos(Point1,1);
                YBeg(end+1) = Pos(Point1,2);
                XEnd(end+1) = Pos(Point2,1);
                YEnd(end+1) = Pos(Point2,2);
                
            end
            
            Params = [XBeg;YBeg;XEnd;YEnd];
            
        end
        
        function obj = AppendRules(obj, InputString)
            
            Rules       = split(InputString,',');
            
            for i = 1:length(Rules)
                
                ParsedRules = split(Rules(i),'-');
                
                switch ParsedRules{1}
                    case 'T1'
                        obj = obj.ApplyT1(str2double(ParsedRules{2}),str2double(ParsedRules{3}));
                    case 'T2'
                        obj = obj.ApplyT2(ParsedRules{2});
                    case 'T3'
                        obj = obj.ApplyT3(ParsedRules{2},ParsedRules{3});
                    case 'T4'
                        obj = obj.ApplyT4(str2double(ParsedRules{2}));
                    otherwise
                        error('%s rule is not an implemented rule.', ParsedRules{1})
                end
                
            end
            
            if isempty(obj.Code)
                obj.Code = InputString{1};
            else
                obj.Code = [obj.Code ',' InputString{1}];
            end
            
        end
        
        function [ActionBool, ActionList] = ListPossibleActions(obj)
            
            ThisGraph = obj.Graph;
            ActionBool   = zeros(4,1);
            ActionList   = cell(4,1);
            
            LengthOfEdges = cell2mat(ThisGraph.Edges.Length);
            
            if isempty(LengthOfEdges)
                LengthOfEdges = 1;
            end
            
            % Measure the possibilities for T1: SplitEdges.
            if ~isempty(ThisGraph.Edges.Name) && length(ThisGraph.Edges.Name) < obj.maxNodes && min(LengthOfEdges) >= obj.minEdgeLength
                ActionBool(1) = true;
                Temp = cell(height(ThisGraph.Edges)*obj.maxSplit,1);
                it = 1;
                for i = 1:height(ThisGraph.Edges)
                    for j = 1:obj.maxSplit
                        str = sprintf('T1-%i-%i',ThisGraph.Edges.Name(i),j);
                        Temp{it} = str;
                        it = it + 1;
                    end
                end
                ActionList{1} = Temp;
            else
                ActionBool(1) = false;
                ActionList{1} = 0;
            end
            
            % Measure the possibilities for T2: DeleteNode.
            if height(ThisGraph.Nodes) > 4
                
                ActionBool(2) = true;
                Temp = cell(height(ThisGraph.Nodes) - 4,1);
                it = 1;
                for i = 1:length(ThisGraph.Nodes.Name)
                    name = ThisGraph.Nodes.Name{i};
                    if strcmp(name(1),'N')
                        str = sprintf('T2-%s',name);
                        Temp{it} = str;
                        it = it + 1;
                    end
                end
                
                ActionList{2} = Temp;
                
            else
                ActionBool(2)   = false;
                ActionList{2}      = 0;
            end

            % Measure the possibilities for T3: AddEdge.
            
            if length(ThisGraph.Edges.Name) < obj.maxEdges && min(LengthOfEdges) >= obj.minEdgeLength
                ActionBool(3) = true;
                
                Combinations = string(nchoosek(ThisGraph.Nodes.Name,2));
                Existing     = string(ThisGraph.Edges.EndNodes);
                
                ToRemove = zeros(size(Combinations,1),1);
                for i = 1:size(Combinations,1)
                    %Check if anylines contains "new" combinations.
                    test  = contains(Existing, Combinations(i,:));
                    if any(all(test,2))
                        ToRemove(i) = 1;
                    else
                        ToRemove(i) = 0;
                    end
                end
                
                NewCombinations = Combinations(~ToRemove,:);

                Temp = cell(size(NewCombinations,1),1);
                for i = 1:size(NewCombinations,1)
                    str = sprintf('T3-%s-%s',NewCombinations(i,1),NewCombinations(i,2));
                    Temp{i} = str;
                end
                
                ActionList{3} = Temp;
                
            else
                ActionBool(3) = false;
                ActionList{3} = 0;
            end
            
            if height(ThisGraph.Edges) > 0
                ActionBool(4) = true;
                Temp = cell(height(ThisGraph.Edges),1);
                for i = 1:length(ThisGraph.Edges.Name)
                    name = ThisGraph.Edges.Name(i);
                    str = sprintf('T4-%i',name);
                    Temp{i} = str;
                end
                
                ActionList{4} = Temp;
            else
                ActionBool(4) = false; 
                ActionList{4} = 0;
            end
            
        end
        
    end
    
    methods(Access=private)
        
        function obj = ApplyT1(obj, EdgeName, NumberOfPoints)
            
            if isfloat(EdgeName)
                
                ThisGraph = obj.Graph;
                
                % Extract positions from the edge.
                ToSplit      = find(ThisGraph.Edges.Name==EdgeName);
                EndNode1     = ThisGraph.Edges.EndNodes(ToSplit,1);
                EndNode2     = ThisGraph.Edges.EndNodes(ToSplit,2);
                
                EndNode1_ID  = ThisGraph.findnode(EndNode1);
                EndNode2_ID  = ThisGraph.findnode(EndNode2);
                
                EndNode1_Pos = [ThisGraph.Nodes.X(EndNode1_ID),ThisGraph.Nodes.Y(EndNode1_ID)];
                EndNode2_Pos = [ThisGraph.Nodes.X(EndNode2_ID),ThisGraph.Nodes.Y(EndNode2_ID)];
                
                XX = linspace(EndNode1_Pos(1),EndNode2_Pos(1),NumberOfPoints+2);
                YY = linspace(EndNode1_Pos(2),EndNode2_Pos(2),NumberOfPoints+2);
                
                Names       = cell(length(XX),1);
                Names(1)    = EndNode1;
                Names(end)  = EndNode2;
                
                % Create the new Nodes.
                for i = 2:length(XX)-1
                    newName         = {['N',num2str(obj.NodeIt)]};
                    obj.NodeIt      = obj.NodeIt + 1;
                    
                    % Add the new node to the this Graph.
                    newNode         = table(XX(i),YY(i),newName,'VariableNames',{'X','Y','Name'});
                    ThisGraph       = addnode(ThisGraph,newNode);
                    Names(i)        = newName;
                end
                
                Names = string(Names);
                
                % Create the new Edges.
                for i = 1:length(Names)-1
                    EdgeLength      = {sqrt((XX(i) - XX(i+1))^2 + (YY(i) - YY(i+1))^2)};
                    EndNodes        = {char(Names(i)), char(Names(i+1))};
                    newEdge         = table(EndNodes,1,obj.EdgeIt,EdgeLength,'VariableNames',{'EndNodes','Weight','Name','Length'});
                    obj.EdgeIt      = obj.EdgeIt + 1;
                    ThisGraph       = ThisGraph.addedge(newEdge);
                end
                
                % Delete the old Edge.
                ThisGraph = ThisGraph.rmedge(ToSplit);
                
                
                obj.Graph = ThisGraph;
                
            else
                error('$$$ MONEY OVER HERE $$$')
            end
            
        end
        
        function obj = ApplyT2(obj, NodeName)
            
            if ischar(NodeName)
                obj.Graph = obj.Graph.rmnode(NodeName);
            end
            
        end
        
        function obj = ApplyT4(obj, EdgeName)
            
            if isfloat(EdgeName)
                
                Names = obj.Graph.Edges.Name;
                ID    = find(Names == EdgeName);
                obj.Graph = obj.Graph.rmedge(ID);
                
            end
            
        end
        
        function obj = UpdateCrossing(obj)
            
            ThisGraph = obj.Graph;
            
            % Read the data from the ThisGraph.
            Points      = table2array([ThisGraph.Nodes(:,'X'),ThisGraph.Nodes(:,'Y')]);
            EndNodes    = table2array(ThisGraph.Edges(:,'EndNodes'));
            EdgeLabels  = ThisGraph.Edges.Name;
            
            for i = 1:size(EndNodes,1)
                Node1 = ThisGraph.findnode(EndNodes(i,1));
                Node2 = ThisGraph.findnode(EndNodes(i,2));
                ALL_LINES(i,:) = [Points(Node1,1),Points(Node1,2),Points(Node2,1),Points(Node2,2)];
            end
            
            % Find Intersections of each lines.
            InterPoints = [];
            NewCrosses  = [];
            
            for i = 1:size(ALL_LINES,1)
                
                ToCheck         = ALL_LINES(i,:);
                CurrentLabel    = EdgeLabels(i);
                
                Inter_Struct    = lineSegmentIntersect(ToCheck,ALL_LINES);
                
                Adj = Inter_Struct.intAdjacencyMatrix;
                XX  = Inter_Struct.intMatrixX;
                YY  = Inter_Struct.intMatrixY;
                
                Pos             = [XX(Adj)',YY(Adj)'];
                CrossLabels     = EdgeLabels(Adj);
                
                % Append the intersection points with the current label and
                % the edges it crosses.
                for j = 1:length(CrossLabels)
                    InterPoints = [InterPoints ; CurrentLabel, CrossLabels(j),Pos(j,:)];
                end
                
            end
            
            % Check for new crossings.
            if ~isempty(InterPoints)
                NewCrosses  = InterPoints(~ismember(InterPoints(:,3:4),Points,'rows'),:);
            end
            
            if ~isempty(NewCrosses)
                
                % Identify new crossings with their Edges.
                [~, ID2, ID3] = unique(round(NewCrosses(:,3:4),3,'significant'),'rows');
                CrossedEdges = {};
                for i = 1:max(ID3)
                    E_Temp      = NewCrosses(ID3==i,1:2);
                    
                    % Edges that are part of intersection.
                    CrossedEdges{i,1}   = unique(E_Temp(:))';
                    
                    % Position of Intersection.
                    CrossedEdges{i,2}   = NewCrosses(ID2(i),3:4);
                end
                
                % Identify how the edges are split by the Nodes.
                [UniqueEdges] = unique(NewCrosses(:,1:2));
                
                % Create new Nodes. 
                NewNodes = {};
                for i = 1:size(CrossedEdges,1)
                    
                    newName      = {['N',num2str(obj.NodeIt)]};
                    obj.NodeIt = obj.NodeIt + 1;      
                    NewNodes{end+1} = newName{1};
                    
                    newNode = table(CrossedEdges{i,2}(1),CrossedEdges{i,2}(2),newName,'VariableNames',{'X','Y','Name'});
                    ThisGraph   = addnode(ThisGraph,newNode);
                    
                end
                
                % Identify new points per edges positions. 
                CrossedEdges_2 = cell(size(CrossedEdges,1),2);
                for i = 1:length(UniqueEdges)
                    CrossedEdges_2{i,1} = UniqueEdges(i);
                    for j = 1:size(CrossedEdges,1)
                        if any(CrossedEdges_2{i,1} == CrossedEdges{j,1})
                            CrossedEdges_2{i,2} = [CrossedEdges_2{i,2}, j];
                        end
                    end
                end
                
                Names = ThisGraph.Edges.Name;
                
                % Create new Edges. 
                for i = 1:size(CrossedEdges_2,1)
                    
                    % Find position of new Nodes;
                    NNTemp = NewNodes(CrossedEdges_2{i,2});
                    
                    NN_Pos = [];
                    for j = 1:length(NNTemp)
                        NN_ID = ThisGraph.findnode(NNTemp{j});
                        NN_Pos(j,1) = ThisGraph.Nodes.X(NN_ID);
                        NN_Pos(j,2) = ThisGraph.Nodes.Y(NN_ID);
                    end
                    % Find endnodes of current edges. 
                    EdgeID          = find(Names == CrossedEdges_2{i,1});
                    This_EndNodes   = ThisGraph.Edges.EndNodes(EdgeID,:);

                    EndNode1_ID  = ThisGraph.findnode(This_EndNodes(1));
                    EndNode2_ID  = ThisGraph.findnode(This_EndNodes(2));
                    
                    EndNode1_Pos = [ThisGraph.Nodes.X(EndNode1_ID),ThisGraph.Nodes.Y(EndNode1_ID)];
                    EndNode2_Pos = [ThisGraph.Nodes.X(EndNode2_ID),ThisGraph.Nodes.Y(EndNode2_ID)];
                
                    EdgeVector   = [EndNode2_Pos(1) - EndNode1_Pos(1), EndNode2_Pos(2) - EndNode1_Pos(2)];

                    % Sort using vectorial projection;
                    [~,ID2] = sort(NN_Pos * EdgeVector');

                    SortedNewNodes = [This_EndNodes(1),NNTemp(ID2),This_EndNodes(2)];
                    
                    for j = 1:length(SortedNewNodes)-1
     
                        Node1_ID  = ThisGraph.findnode(SortedNewNodes(j));
                        Node2_ID  = ThisGraph.findnode(SortedNewNodes(j+1));
                        
                        Pos1 = [ThisGraph.Nodes.X(Node1_ID),ThisGraph.Nodes.Y(Node1_ID)];
                        Pos2 = [ThisGraph.Nodes.X(Node2_ID),ThisGraph.Nodes.Y(Node2_ID)];

                        % Create the new edge between the nodes.
                        EdgeLength  = {norm(Pos1-Pos2)};

                        newEdge = table({SortedNewNodes{j}, SortedNewNodes{j+1}},1,obj.EdgeIt,EdgeLength,'VariableNames',{'EndNodes','Weight','Name','Length'});
                        obj.EdgeIt = obj.EdgeIt + 1;
                        ThisGraph = ThisGraph.addedge(newEdge);
                
                    end
                    
                end
                
                %Delete the old edges.
                for i = 1:size(CrossedEdges,1)
                    for j = 1:length(CrossedEdges{i,1})
                        Names = ThisGraph.Edges.Name;
                        ToRemove = find(Names == CrossedEdges{i,1}(j));
                        ThisGraph = ThisGraph.rmedge(ToRemove);
                    end
                end

            end
            
            obj.Graph = ThisGraph;
            
        end
        
        function obj = ApplyT3(obj, Node1, Node2)
            
            if ischar(Node1) && ischar(Node2)
                
                ThisGraph = obj.Graph;
                
                EdgeNum = obj.EdgeIt;
                obj.EdgeIt = obj.EdgeIt + 1;
                
                Node1_ID  = ThisGraph.findnode(Node1);
                Node2_ID  = ThisGraph.findnode(Node2);
                
                Pos1 = [ThisGraph.Nodes.X(Node1_ID),ThisGraph.Nodes.Y(Node1_ID)];
                Pos2 = [ThisGraph.Nodes.X(Node2_ID),ThisGraph.Nodes.Y(Node2_ID)];
                
                % Create the new edge between the nodes.
                EdgeLength  = {norm(Pos1-Pos2)};
                newEdge = table({Node1 Node2},1,EdgeNum, EdgeLength,'VariableNames',{'EndNodes','Weight','Name','Length'});
                obj.Graph = obj.Graph.addedge(newEdge);
                
                % Check for crossings.
                obj = obj.UpdateCrossing;
                
            else
                error('$$$ MONEY OVER HERE $$$')
            end
            
        end

    end
    
end
