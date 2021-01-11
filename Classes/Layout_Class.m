classdef Layout_Class
    
    properties
        H_Stiffs        = 1;
        V_Stiffs        = 0;
        H_Crosses       = [];
        V_Crosses       = [];
        Full_H          = [];
        Full_L          = [];
        Code            = "";
    end
    
    properties(SetAccess=private)
        GeomComplex
        Graph
        InterP
        Inters
    end
    
    methods
        
        function obj = Layout_Class(InputString, Full_H, Full_L)
            
            Inputs = regexp(InputString," ",'split');
            
            HC_Mat = [];
            VC_Mat = [];
            
            for i = 1:length(Inputs{3})/2
                HC_Mat(i,:) = [str2double(Inputs{3}(2*i-1)), str2double(Inputs{3}(2*i))];
            end
            
            for i = 1:length(Inputs{4})/2
                VC_Mat(i,:) = [str2double(Inputs{4}(2*i-1)), str2double(Inputs{4}(2*i))];
            end
            
            obj.H_Stiffs        = str2double(Inputs{1});
            obj.V_Stiffs        = str2double(Inputs{2});
            obj.H_Crosses       = HC_Mat;
            obj.V_Crosses       = VC_Mat;
            
            obj.Full_H          = Full_H;
            obj.Full_L          = Full_L;
            obj.Code            = InputString;
        end
        
        function obj = set_graph(obj)
            
            % Initialize grid placement.
            GridX =  linspace(0,obj.Full_L,obj.V_Stiffs+2);
            GridY =  linspace(0,obj.Full_H,obj.H_Stiffs+2);
            
            [GX, GY] = meshgrid(GridX, GridY);
            
            Points = [GX(:), GY(:)];
            numPoints = length(Points);
            
            Ind_HStiffs = [ 2:obj.H_Stiffs+1;
                numPoints-(obj.H_Stiffs):numPoints-1]';
            Ind_VStiffs = [(obj.H_Stiffs+3):obj.H_Stiffs+2:numPoints-(obj.H_Stiffs+2);
                2*(obj.H_Stiffs+2):obj.H_Stiffs+2:numPoints-1]';
            
            LinkMatrice = zeros(length(Points));
            Point_Table = array2table(Points,'VariableNames',{'X','Y'});
            Graph_Stiffs = graph(LinkMatrice, Point_Table);
            
            for i = 1:size(Ind_HStiffs,1)
                Graph_Stiffs=Graph_Stiffs.addedge(Ind_HStiffs(i,1),Ind_HStiffs(i,2),1);
            end
            
            for i = 1:size(Ind_VStiffs,1)
                Graph_Stiffs=Graph_Stiffs.addedge(Ind_VStiffs(i,1),Ind_VStiffs(i,2),1);
            end
            
            % Manage Crossing.
            H_Cs       = obj.H_Crosses;
            V_Cs       = obj.V_Crosses + obj.H_Stiffs;
            
            for i = 1:min(size(obj.H_Crosses,1),obj.H_Stiffs-1)
                
                T_Cross_1   = table2array(Graph_Stiffs.Edges(H_Cs(i,1),'EndNodes'));
                T_Cross_2   = table2array(Graph_Stiffs.Edges(H_Cs(i,2),'EndNodes'));
                
                CrossNode1  = T_Cross_1(2);
                CrossNode2  = T_Cross_2(2);
                
                T_Y1        = Graph_Stiffs.Nodes(CrossNode1,'Y');
                T_Y2        = Graph_Stiffs.Nodes(CrossNode2,'Y');
                
                Graph_Stiffs.Nodes(CrossNode2,'Y') = T_Y1;
                Graph_Stiffs.Nodes(CrossNode1,'Y') = T_Y2;
                
            end
            
            for i = 1:min(size(obj.V_Crosses,1),obj.V_Stiffs-1)
                
                T_Cross_1   = table2array(Graph_Stiffs.Edges(V_Cs(i,1),'EndNodes'));
                T_Cross_2   = table2array(Graph_Stiffs.Edges(V_Cs(i,2),'EndNodes'));
                
                CrossNode1  = T_Cross_1(2);
                CrossNode2  = T_Cross_2(2);
                
                T_X1        = Graph_Stiffs.Nodes(CrossNode1,'X');
                T_X2        = Graph_Stiffs.Nodes(CrossNode2,'X');
                
                Graph_Stiffs.Nodes(CrossNode2,'X') = T_X1;
                Graph_Stiffs.Nodes(CrossNode1,'X') = T_X2;
                
            end
            
            Points = table2array([Graph_Stiffs.Nodes(:,'X'),Graph_Stiffs.Nodes(:,'Y')]);
            Lines = table2array(Graph_Stiffs.Edges(:,'EndNodes'));
            
            % Build the ALL_LINES matrix.
            ALL_LINES = [Points(Lines(:,1),:),Points(Lines(:,2),:)];
            
            % Find Intersections of each lines.
            InterPoints = [];
            Segi        = [];
            
            for i = 1:size(ALL_LINES,1)
                ToCheck = ALL_LINES(i,:);
                out = lineSegmentIntersect(ToCheck,ALL_LINES);
                
                Adj = out.intAdjacencyMatrix;
                XX  = out.intMatrixX;
                YY  = out.intMatrixY;
                
                Pos = [XX(Adj)',YY(Adj)'];
                Pos = unique(Pos,'rows');
                
                InterPoints = [InterPoints ; Pos] ;
                
                Segi(i) = size(Pos,1) + 1;
                
            end
            
            [UniqueIntersects, ~, b]    = unique(round(InterPoints,3,'significant'),'rows');
            
            Comp = 0;
            for i = 1:max(b)
               Comp = Comp + (sum(b == i)-1).^3;  
            end
            
            % Evaluate Complexity.   
            RealIntersect       = size(UniqueIntersects,1);
            RealSegments        = sum(Segi);
            
            obj.Inters          = UniqueIntersects;
            obj.GeomComplex     = Comp + sum(Segi);
            obj.Graph           = Graph_Stiffs;
            
        end
        
        function plotGraph(obj)
            
            Points  = table2array([obj.Graph.Nodes(:,'X'),obj.Graph.Nodes(:,'Y')]);
            Lines   = table2array(obj.Graph.Edges(:,'EndNodes'));
            
            Point2 = Points(Lines(:),:);
            Point2 = [Point2;obj.Inters];
            scatter(Point2(:,1), Point2(:,2))
            axis([-1 obj.Full_L+1 -1 obj.Full_H+1])
            daspect([1 1 1])
            hold all
            
            Edges = table2array(obj.Graph.Edges(:,'EndNodes'));
            
            for i = 1:size(Edges,1)
                Point1 = Edges(i,1);
                Point2 = Edges(i,2);
                line([Points(Point1,1),Points(Point2,1)], [Points(Point1,2),Points(Point2,2)])
            end
            
        end
        
    end
end

