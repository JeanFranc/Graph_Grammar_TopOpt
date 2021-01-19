classdef Layout_Class_V2
    
    properties
        Code            = '';
        EdgeIt          = 5;
        NodeIt          = 5;
    end
    
    properties(SetAccess=private)
        Graph
    end
    
    % Rules:
    
    % T1: Split Edge XXX, N Times - T1-XXX-NN
    % T2: Delete Node XXX - T2-XXX                   
    % T3: Add Edge to Nodes XXX and YYY - T3-XXX-YYY
    % T4: Remove Edge XXX - T4-XXX                  [Not Implemented]
    % T5: Add Mirror X-Y - T5-X-Y                   [Not Implemented]
    
    methods
        
        function obj = Layout_Class_V2()
            
            % 0) Create the base graph.
            
            Names = ['BL';'BR';'TR';'TL'];
            
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
                obj.Code = InputString;
            else
                obj.Code = [obj.Code ',' InputString];
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
                    newEdge = table([Names(i), Names(i+1)],1,obj.EdgeIt,'VariableNames',{'EndNodes','Weight','Name'});
                    obj.EdgeIt = obj.EdgeIt + 1;
                    ThisGraph = ThisGraph.addedge(newEdge);
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
            NewCrosses  = InterPoints(~ismember(InterPoints(:,3:4),Points,'rows'),:);
            
            % Identify new nodes with their Edges.
            [~, ID2, ID3] = unique(round(NewCrosses(:,3:4),3,'significant'),'rows');
            CrossedEdges = {};
            for i = 1:max(ID3)
                E_Temp      = NewCrosses(ID3==i,1:2);
                
                % Edges that are part of intersection.
                CrossedEdges{i,1}   = unique(E_Temp(:))';
                
                % Position of Intersection.
                CrossedEdges{i,2}   = NewCrosses(ID2(i),3:4);
            end
            
            % Create new Points and adjust Edges.
            for i = 1:size(CrossedEdges,1)
                
                newName      = {['N',num2str(obj.NodeIt)]};
                obj.NodeIt = obj.NodeIt + 1;
                
                % Create new Node in the Graph.
                newNode = table(CrossedEdges{i,2}(1),CrossedEdges{i,2}(2),newName,'VariableNames',{'X','Y','Name'});
                ThisGraph   = addnode(ThisGraph,newNode);
                
                Names = ThisGraph.Edges.Name;
                
                % Find the Existing EndNodes.
                EN = {};
                for j = 1:length(CrossedEdges{i,1})
                    ToSearch = find(Names == CrossedEdges{i,1}(j));
                    Temp = ThisGraph.Edges.EndNodes(ToSearch,:);
                    EN(j,:) = Temp;
                end
                
                % Create and append the new Edges.
                EN = EN(:);
                for j = 1:length(EN)
                    newEdge = table({EN{j}, newName{1}},1,obj.EdgeIt,'VariableNames',{'EndNodes','Weight','Name'});
                    obj.EdgeIt = obj.EdgeIt + 1;
                    ThisGraph = ThisGraph.addedge(newEdge);
                end
                
            end
            
            % Delete the old edges.
            for i = 1:size(CrossedEdges,1)
                for j = 1:length(CrossedEdges{i,1})
                    Names = ThisGraph.Edges.Name;
                    ToRemove = find(Names == CrossedEdges{i,1}(j));
                    ThisGraph = ThisGraph.rmedge(ToRemove);
                end
            end
            
            obj.Graph = ThisGraph;
            
        end
        
        function obj = ApplyT3(obj, Node1, Node2)
            
            if ischar(Node1) && ischar(Node2)
                
                EdgeNum = obj.EdgeIt;
                obj.EdgeIt = obj.EdgeIt + 1;
                
                % Create the new edge between the nodes.
                newEdge = table({Node1 Node2},1,EdgeNum,'VariableNames',{'EndNodes','Weight','Name'});
                obj.Graph = obj.Graph.addedge(newEdge);
                
                % Check for crossings.
                obj = obj.UpdateCrossing;
                
            else
                error('$$$ MONEY OVER HERE $$$')
            end
            
        end
        
        
        
        
    end
    
    
end

