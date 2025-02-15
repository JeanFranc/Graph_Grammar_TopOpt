
classdef Layout_Fixed_Grid
    
    properties(SetAccess=private)
        EdgeIt          = 1;
        NodeIt          = 1;
        n               = 5;
        m               = 5;
        Graph;
        PartialRadius;
    end
    
    % Current Rules:    
    % Create Stiffeners - 'NX', 'NY'
    
    methods
        
        function obj = Layout_Fixed_Grid(n,m)

            obj.n = n;
            obj.m = m;
            
            obj.PartialRadius = 1 / (max(obj.n,obj.m)-1) / 2;
            
            XX = linspace(0,1,n);
            YY = linspace(0,1,m);
            
            [meshXX, meshYY] = meshgrid(XX,YY);
            
            GridPos = [meshXX(:), meshYY(:)];
            
            obj.Graph = graph([]);
            
            for i = 1:length(GridPos)
                if (GridPos(i,1) == 0 && GridPos(i,2) == 0) 
                    State = "Side_1_2";
                elseif GridPos(i,1) == 1 && GridPos(i,2) == 0
                    State = "Side_2_3";
                elseif GridPos(i,1) == 1 && GridPos(i,2) == 1
                    State = "Side_3_4";
                elseif GridPos(i,1) == 0 && GridPos(i,2) == 1
                    State = "Side_4_1";
                elseif GridPos(i,1) == 0 
                    State = "Side_1";
                elseif GridPos(i,2) == 0
                    State = "Side_2";
                elseif GridPos(i,1) == 1
                    State = "Side_3";
                elseif GridPos(i,2) == 1
                    State = "Side_4";
                else
                    State = "Inactive";
                end
                obj = obj.addNode(GridPos(i,1), GridPos(i,2), State,0,0);
            end
            
        end
        
        function obj = PlotGraph(obj,DispGrid,DispSquare, DispSym)
            
            % Load Data
            XY           = table2array([obj.Graph.Nodes(:,'X'),obj.Graph.Nodes(:,'Y')]);
            Offset       = table2array([obj.Graph.Nodes(:,'OffSetX'),obj.Graph.Nodes(:,'OffSetY')]);
            Pos          = XY + Offset;

            Names     = string(obj.Graph.Nodes.Name);
            State     = table2array(obj.Graph.Nodes(:,'State'));
            EndNodes  = obj.Graph.Edges.EndNodes;
            
            % Parse states
            ActiveBool      = strcmp(State, 'Active'); 
            InactiveBool    = strcmp(State, 'Inactive'); 
            OffSetBool      = strcmp(State, 'A-Offset'); 
            SidesBool       = contains(State,'Side');
            
            % Place all the grid, depending on state. 
            if DispGrid
                scatter(Pos(SidesBool,1), Pos(SidesBool,2),'k')
                hold all
                scatter(Pos(ActiveBool,1), Pos(ActiveBool,2),'r')
                scatter(Pos(InactiveBool,1), Pos(InactiveBool,2),'b')
                scatter(Pos(OffSetBool,1), Pos(OffSetBool,2),'g')
                % Label each points with their name.
                labelpoints(Pos(:,1),Pos(:,2),Names);
            end
            
            W = obj.PartialRadius;
            H = obj.PartialRadius;
            
            if DispSquare
                for i = 1:length(XY)
                   rectangle('Position',[XY(i,1)-W/2,XY(i,2)-H/2,W,H])
                end
            end

            % Draw each edges as a line. 
            for i = 1:size(EndNodes,1)
                Point1 = obj.Graph.findnode(EndNodes(i,1));
                Point2 = obj.Graph.findnode(EndNodes(i,2));
                line([Pos(Point1,1) Pos(Point2,1)], [Pos(Point1,2) Pos(Point2,2)])
            end
    
            if sum(DispSym) > 0
               
                if DispSym(1) && DispSym(2)
                    for i = 1:size(EndNodes,1)
                        Point1 = obj.Graph.findnode(EndNodes(i,1));
                        Point2 = obj.Graph.findnode(EndNodes(i,2));
                        line([2-Pos(Point1,1) 2-Pos(Point2,1)], [Pos(Point1,2) Pos(Point2,2)])
                    end
                    for i = 1:size(EndNodes,1)
                        Point1 = obj.Graph.findnode(EndNodes(i,1));
                        Point2 = obj.Graph.findnode(EndNodes(i,2));
                        line([Pos(Point1,1) Pos(Point2,1)], [2-Pos(Point1,2) 2-Pos(Point2,2)])
                    end
                    for i = 1:size(EndNodes,1)
                        Point1 = obj.Graph.findnode(EndNodes(i,1));
                        Point2 = obj.Graph.findnode(EndNodes(i,2));
                        line([2-Pos(Point1,1) 2-Pos(Point2,1)], [2-Pos(Point1,2) 2-Pos(Point2,2)])
                    end
                elseif DispSym(1)
                    for i = 1:size(EndNodes,1)
                        Point1 = obj.Graph.findnode(EndNodes(i,1));
                        Point2 = obj.Graph.findnode(EndNodes(i,2));
                        line([2-Pos(Point1,1) 2-Pos(Point2,1)], [Pos(Point1,2) Pos(Point2,2)])
                    end
                    
                elseif DispSym(2)
                    for i = 1:size(EndNodes,1)
                        Point1 = obj.Graph.findnode(EndNodes(i,1));
                        Point2 = obj.Graph.findnode(EndNodes(i,2));
                        line([Pos(Point1,1) Pos(Point2,1)], [2-Pos(Point1,2) 2-Pos(Point2,2)])
                    end
                end
                axis([-0.5 2.5 -0.5 2.5])
                
            else
                axis([-0.5 1.5 -0.5 1.5])
            end
            
            pbaspect([1 1 1])
            
        end

        function obj = addNode(obj, x, y, State,OffSetX, OffSetY)
            
            newName         = {['N',num2str(obj.NodeIt)]};
            obj.NodeIt      = obj.NodeIt + 1;
            NodeTable       = table(x,y,newName,State,OffSetX, OffSetY,'VariableNames',{'X','Y','Name','State','OffSetX','OffSetY'});
            obj.Graph       = obj.Graph.addnode(NodeTable);
            
        end
        
        function obj = addEdge(obj, N1, N2)
            
            newName         = ['E',num2str(obj.EdgeIt)];
            obj.EdgeIt      = obj.EdgeIt + 1;         
            
            if ~isempty(obj.Graph.Edges)
                
                % Check if edge already exists.
                EndNodes = obj.Graph.Edges.EndNodes;
                NewEndNodes = {N1 N2};
                
                if ~any(all(ismember(EndNodes, NewEndNodes)'))                
                    newName         = string(newName);
                    EdgeTable       = table({N1 N2},1,{newName},'VariableNames',{'EndNodes','Weight','Name'});
                    obj.Graph       = obj.Graph.addedge(EdgeTable);
                end
                
            else
                EdgeTable       = table({N1 N2},1,'VariableNames',{'EndNodes','Weight'});
                obj.Graph       = obj.Graph.addedge(EdgeTable);
                obj.Graph.Edges.Name = {newName};
            end
            
        end

        function [x,y] = getNodePos_bylabel(obj, name)
            
                Node_ID  = obj.Graph.findnode(name);
                
                x = obj.Graph.Nodes.X(Node_ID);
                y = obj.Graph.Nodes.Y(Node_ID);
                
        end
        
        function [x,y] = getNodePosWOffset_bylabel(obj, name)
            
                Node_ID  = obj.Graph.findnode(name);
                
                x       = obj.Graph.Nodes.X(Node_ID) + obj.Graph.Nodes.OffSetX(Node_ID);
                y       = obj.Graph.Nodes.Y(Node_ID) + obj.Graph.Nodes.OffSetY(Node_ID);
                
        end
        
        function [EndNodes] = getEdgeEndNodes_bylabel(obj, name)
            
            EdgeID = find(contains(obj.Graph.Edges.Name,name));
            
            if length(EdgeID) == 1
                EndNodes   = obj.Graph.Edges.EndNodes(EdgeID,:);
            else
                EndNodes = NaN;
            end            
            
        end
        
        function Pos = getEndNodePositions_bylabel(obj, name)
            
            [EndNodes] = obj.getEdgeEndNodes_bylabel(name);
            
            if iscell(EndNodes)
                
                [x1,y1] = obj.getNodePos_bylabel(EndNodes{1});
                [x2,y2] = obj.getNodePos_bylabel(EndNodes{2});
                
                Pos = [x1,y1;x2,y2];
                
            else
                EN_Xs = NaN; 
                EN_Ys = NaN;
            end
        end
        
        function [Nodes,OffSet, NewState] = getCloseNodesFromSegment(obj, N1, N2)
  
            N1_ID  = obj.Graph.findnode(N1);
            N2_ID  = obj.Graph.findnode(N2);
            Names  = obj.Graph.Nodes.Name;
            States = obj.Graph.Nodes.State;
            
            % Get EndNodes Positions
            Pos1 = [obj.Graph.Nodes.X(N1_ID) obj.Graph.Nodes.Y(N1_ID)];
            Pos2 = [obj.Graph.Nodes.X(N2_ID) obj.Graph.Nodes.Y(N2_ID)];

            % Create Vector
            Line = [Pos2(1) - Pos1(1); Pos2(2) - Pos1(2)];
            Vect = Line(:).'/norm(Line);

            % Create Normal Vector           
            Normal=null(Vect).';

            % Create center point
            Center = mean([Pos1;Pos2]);

            % Get distance from edge. 
            allPos = [obj.Graph.Nodes.X,obj.Graph.Nodes.Y];

            newBase = [Vect;Normal];

            NormLineSurDeux = norm(Line) / 2;

            Nodes    = {};
            NewState = {}; 
            OffSet   = [];
            Lambda   = [];
            
            for i = 1:length(allPos)

                if ~strcmp(Names{i},N1) && ~strcmp(Names{i},N2) && ~strcmp(States{i},'Active') && ~contains(States{i},'Side')
                
                    Dist = newBase * (allPos(i,:) - Center)';

                    % Check if normal distance is smaller than radius,
                    % and if the nodes are close to the segment. 
                    if (abs(Dist(2)) < obj.PartialRadius) && abs(Dist(1)) <= NormLineSurDeux
    
                        Lambda(end+1)   = Dist(1);
                        Nodes{end+1}    = Names{i};           
                        
                        if strcmp(States{i},'Inactive')
                            OffSet(end+1,:) = - inv(newBase) * [0;Dist(2)] ;
                            NewState{end+1} = 'A-Offset';
                        elseif strcmp(States{i},'A-Offset')
                            OffSet(end+1,:) = [0,0];
                            NewState{end+1} = 'Active';
                        end
                        
                    end
                
                end
                
            end
            
            % Assure d'avoir les noeuds dans l'ordre N1 vers N2.
            [~,ID2]  = sort(Lambda);
            Nodes    = Nodes(ID2);
            OffSet   = OffSet(ID2,:);
            NewState = NewState(ID2);

        end
        
        function obj = CreateStiffener(obj, N1, N2)
            
            N1_ID = obj.Graph.findnode(N1);
            N2_ID = obj.Graph.findnode(N2);
            
            if N1_ID > 0 && N2_ID > 0
            
                State1 = obj.Graph.Nodes.State(N1_ID);
                State2 = obj.Graph.Nodes.State(N2_ID);

                if ~strcmp(State1,'Inactive') && ~strcmp(State2,'Inactive')
                    
                    [Nodes, OffSet, NewState] = obj.getCloseNodesFromSegment(N1, N2);
                    
                    for i = 1:length(Nodes)
                        
                        N_ID = obj.Graph.findnode(Nodes{i});
                        obj.Graph.Nodes.OffSetX(N_ID)   = OffSet(i,1);
                        obj.Graph.Nodes.OffSetY(N_ID)   = OffSet(i,2);
                        obj.Graph.Nodes.State(N_ID)     = NewState{i};
                        
                    end
                    
                    Edges = [{N1},Nodes,{N2}];
                    
                    if strcmp(State1, 'A-Offset')
                        obj.Graph.Nodes.OffSetX(N1_ID) = 0;
                        obj.Graph.Nodes.OffSetY(N1_ID) = 0;
                        obj.Graph.Nodes.State(N1_ID)   = 'Active';
                    end
                    
                    if strcmp(State2, 'A-Offset')
                        obj.Graph.Nodes.OffSetX(N2_ID) = 0;
                        obj.Graph.Nodes.OffSetY(N2_ID) = 0;
                        obj.Graph.Nodes.State(N2_ID)   = 'Active';
                    end
                    
                    for i = 1:length(Edges)-1
                        obj = obj.addEdge(Edges{i}, Edges{i+1});
                    end
                    
                else
                    
                   obj = NaN;
                   
                end
                
            else

                obj = NaN;
                
            end
            
        end
        
        function Actions = ListOfPossibleActions(obj)
            
            States      = obj.Graph.Nodes.State;
            Names       = obj.Graph.Nodes.Name;
            
            % List possible connections just for the not-inactive nodes.
            NotInactive = find(~strcmp(States,'Inactive')); 
            Actions = {};
             
            for i = 1 : length(NotInactive)
                
                EdgeID = outedges(obj.Graph,NotInactive(i));
                
                if ~isempty(EdgeID)
                    ConnNodes = obj.Graph.Edges.EndNodes(EdgeID,:);
                    ConnNodes = ConnNodes(~strcmp(ConnNodes,Names{NotInactive(i)}));
                    ConnNodes = string(ConnNodes);
                else
                    ConnNodes = "";
                end 
                
                for j = 1:length(NotInactive)
                    
                    Name1 = Names{NotInactive(i)};
                    Name2 = Names{NotInactive(j)};
                    
                    % Added a check to ignore the connections of nodes on
                    % the same side. 

                    
                    if ~strcmp(Name1,Name2)
                    
                        State1 = States{NotInactive(i)};
                        State2 = States{NotInactive(j)};
                        
                        if contains(State1,'Side') && contains(State2,'Side')

                            Side1 = split(State1,'_');
                            Side2 = split(State2,'_');

                            Side1 = Side1(2:end);
                            Side2 = Side2(2:end);

                            if length(Side1) == 2 && length(Side2) == 2
                                if any(~ismember(Side1,Side2))
                                    Actions(end+1,:) = {Name1, Name2};
                                end
                            else
                                if ~any(ismember(Side1,Side2))
                                    Actions(end+1,:) = {Name1, Name2};
                                end
                            end
                            


                        elseif any(~strcmp(Name2,ConnNodes))

                            Actions(end+1,:) = {Name1, Name2};

                        end
                        
                    end
                    
                end
                
            end
            
        end
       
        function code = getCode(obj)
            
             List = string(obj.Graph.Edges.EndNodes);
             
             code = 'Layout';
             for i = 1:size(List,1)
                code = sprintf('%s-%s%s', code, List(i,1), List(i,2)); 
             end
             
        end
        
        function [Response, Mass, Complexity, Sensi, DPs] = EvaluatePerformance(obj, folder, Symmetry, Buckling)
            
            EndNodes = obj.Graph.Edges.EndNodes;
            Pos       = table2array([obj.Graph.Nodes(:,'X'),obj.Graph.Nodes(:,'Y')]);
            OffSet    = table2array([obj.Graph.Nodes(:,'OffSetX'),obj.Graph.Nodes(:,'OffSetY')]);
            
            XBeg = zeros(1,size(EndNodes,1));
            YBeg = zeros(1,size(EndNodes,1));
            XEnd = zeros(1,size(EndNodes,1));
            YEnd = zeros(1,size(EndNodes,1));
            
            RealPos = Pos + OffSet;
                
            for i = 1:size(EndNodes,1)
                
                Point1 = obj.Graph.findnode(EndNodes(i,1));
                Point2 = obj.Graph.findnode(EndNodes(i,2));
                
                XBeg(i) = RealPos(Point1,1);
                YBeg(i) = RealPos(Point1,2);
                XEnd(i) = RealPos(Point2,1);
                YEnd(i) = RealPos(Point2,2);
            
            end
            
            if length(Symmetry) == 2
            
                if Symmetry(1)
                    
                    XB_Old = XBeg/2;
                    XE_Old = XEnd/2;
                    
                    XB_New = 1-XB_Old;
                    XE_New = 1-XE_Old;
                    
                    YB_Old = YBeg;
                    YE_Old = YEnd;
                    
                    YB_New = YB_Old;
                    YE_New = YE_Old;

                    XBeg = [XB_Old,XB_New];
                    XEnd = [XE_Old,XE_New];
                    YBeg = [YB_Old,YB_New];
                    YEnd = [YE_Old,YE_New];
                    
                end

                if Symmetry(2)

                    XB_Old = XBeg;
                    XE_Old = XEnd;
                    
                    XB_New = XB_Old;
                    XE_New = XE_Old;
                    
                    YB_Old = YBeg/2;
                    YE_Old = YEnd/2;
                    
                    YB_New = 1-YB_Old;
                    YE_New = 1-YE_Old;

                    XBeg = [XB_Old,XB_New];
                    XEnd = [XE_Old,XE_New];
                    YBeg = [YB_Old,YB_New];
                    YEnd = [YE_Old,YE_New];
                    
                end

            end
                
            Names  = {  '::Geometry::PanelLength',  ...
                        '::Geometry::PanelHeight',  ...
                        '::Geometry::NumberOfRibs', ...
                        '::Geometry::XBeg',         ...
                        '::Geometry::YBeg',         ...
                        '::Geometry::XEnd',         ...
                        '::Geometry::YEnd',         ...
                        '::Geometry::StiffHeight',  ...
                        '::Material::Matname',      ...
                        '::Material::young ',       ...
                        '::Material::poisson',      ...
                        '::Material::rho',          ...
                        '::Material::Fcy',          ...
                        '::Mesh::meshSize ',        ...
                        '::BCs::Load',              ...
                        '::BCs::LoadType',          ...
                        '::BCs::SideConditions',    ...
                        '::General::Buckling',      ...
                        '::General::Stress',        ...
                        '::General::Sizing', 		...
                        '::General::Complexity',    ...
                        '::Optimization::MassCon'};
            if Buckling
                Values = {  20,                     ...
                            16.667,                 ...
                            0,                      ...
                            XBeg,                   ...
                            YBeg,                   ...
                            XEnd,                   ...
                            YEnd,                   ...
                            1.46,                    ...
                            'Alu7075',              ...
                            10700000,               ...
                            0.33,                   ...
                            0.1,                    ...
                            68000,                  ...
                            0.5,                    ...
                            120000,                 ...% Axial = 120120, Other = 10;
                            "AxialCompression",     ...% AxialCompression, TransverseCompression, PureShear, Pressure.
                            "SimplySupported",      ...% Infinite, SimplySupported, Clamped, None. 
                            1,                      ...
                            0,                      ...
                            1,                      ...
                            0,                      ...
                            5.0                     };
                        
                        [Buckling, Mass, Sensi, DPs, SingleCompliances] = RunHyperMesh_BuckComp(Names, Values, folder,0);
                        Response = Buckling;
            else
                Values = {  20,                     ...
                            16.667,                 ...
                            0,                      ...
                            XBeg,                   ...
                            YBeg,                   ...
                            XEnd,                   ...
                            YEnd,                   ...
                            1.5,                    ...
                            'Alu7075',              ...
                            10700000,               ...
                            0.33,                   ...
                            0.1,                    ...
                            68000,                  ...
                            0.5,                    ...
                            120000,                 ...% Axial = 120000, Other = 10;
                            "AxialCompression",     ...% AxialCompression, TransverseCompression, PureShear, Pressure, Mario5Points.
                            "SimplySupported",      ...% Infinite, SimplySupported, Clamped, None. 
                            0,                      ...
                            0,                      ...
                            1,                      ...
                            0,                      ...
                            5.0                     };           
                        
                        [TotalCompliance, Mass, Sensi, DPs, SingleCompliances] = RunHyperMesh_CompComp(Names, Values, folder,0);
                        Response = TotalCompliance;
            end
 
            S                           = svd(Sensi);
            RecognizedInformation       = sum((1 - (S ./ max(S))).^2) / rank(Sensi); % WeightedEffectiveRank / NumberOfVariables.
            
            AxiomaticInformation  = norm(Sensi) / (norm(SingleCompliances) / norm(DPs)); % Relative Conditionning Number.

            %SuperFluousInformation
            tol = 0.10;
             
            DP_NORM = [];
            for j = 1:size(Sensi,1)
               Vect_DP = Sensi(j,:); 
               DP_NORM(j,1) = norm(Vect_DP);
            end

            SupInfo = find(DP_NORM./max(DP_NORM) > tol); 
            
            SuperFluousInformation = (length(DP_NORM) - length(SupInfo))/length(DP_NORM);
            
            Complexity = norm([RecognizedInformation,AxiomaticInformation,SuperFluousInformation]);
            
%             Complexity = log10(cond(Sensi,2));            
%             Complexity = norm(Sensi) / (norm(SingleCompliances) / norm(DPs)); 
            
            disp('=====')
            disp([RecognizedInformation,AxiomaticInformation,SuperFluousInformation])
            disp(Complexity)
            disp(Mass)
            disp('=====')
            
        end
        
        function NewLayout = CreateNewAction(obj, CodeRegistry)
            
            PossibleActions = obj.ListOfPossibleActions;
            
            OrderOfTries = randperm(length(PossibleActions),length(PossibleActions));
            
            i = 1;
            foundNew = 0;
            while i <= length(OrderOfTries) && ~foundNew
                
                N1      = PossibleActions{OrderOfTries(i),1};
                N2      = PossibleActions{OrderOfTries(i),2};
                
                NewLayout     = obj.CreateStiffener(N1,N2);
                NewCode       = NewLayout.getCode;
                
                isNew = ~any(ismember(CodeRegistry,NewCode));
                
                if isNew
                    foundNew = 1;
                end
                i = i + 1;
                
            end

            if foundNew == 0
               NewLayout = {}; 
            end
            
        end
        
    end
    
end
