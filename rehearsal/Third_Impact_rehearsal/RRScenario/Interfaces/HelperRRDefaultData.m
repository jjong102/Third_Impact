classdef HelperRRDefaultData
    % HelperRRDefaultData specifies values for common agent data 
    % types.
    %
    % NOTE: The name of this class and it's functionality may change 
    % without notice in a future release, or the class itself may be 
    % removed.
    %
    
    % Copyright 2021-2023 The MathWorks, Inc.
    properties(Constant)
        % 36 length char used for lane ID and lane boundary ID
        ID = repmat('0', 1, 36);
    end

    methods(Static)
        % /////////////////////////////////////////////////////////////////
        function out = actorRuntime()
            %ACTORRUNTIME Creates the default actor runtime struct
            out = struct(...
                'ActorID', uint64(0), ...
                'Pose', zeros(4,4), ...
                'Velocity', zeros(1,3), ...
                'AngularVelocity', zeros(1,3));
        end

        % /////////////////////////////////////////////////////////////////
        function out = actorRuntimes()
            %ACTORRUNTIME Creates the default actor runtimes struct
            out = repmat(HelperRRDefaultData.actorRuntime, 0, 1);
            coder.varsize('out', [Inf 1], [1 0]);
        end

        % /////////////////////////////////////////////////////////////////
        function out = alignmentSingle()
            %ALIGNMENTSINGLE Creates the default alignment struct
            out = struct(...
                'ID', HelperRRDefaultData.ID, ...
                'Alignment', roadrunner.hdmap.Alignment(0));
        end

        % /////////////////////////////////////////////////////////////////
        function out = alignmentMultiple()
            %ALIGNMENTMULTIPLE Creates the default alignment struct
            out = repmat(HelperRRDefaultData.alignmentSingle, 2, 1);
            coder.varsize('out', [Inf 1], [1 0]);
        end

        % /////////////////////////////////////////////////////////////////
        function out = controlPoints()
            %CONTROLPOINTS Returns the default controlPoints struct
            out = struct(...
                'x', 0, ...
                'y', 0, ...
                'z', 0);
            coder.varsize('out.x', [Inf 1], [1 0]);
            coder.varsize('out.y', [Inf 1], [1 0]);
            coder.varsize('out.z', [Inf 1], [1 0]);
        end

        % /////////////////////////////////////////////////////////////////
        function out = geometry()
            %GEOMETRY Returns the default geometry struct
            out = struct('ControlPoints',HelperRRDefaultData.controlPoints);
        end

        % /////////////////////////////////////////////////////////////////
        function out = lane()
            %LANE Returns the default lane struct
            out = struct(...
                'ID', HelperRRDefaultData.ID, ...
                'TravelDir', roadrunner.hdmap.TravelDirection(0),...
                'LaneType', roadrunner.hdmap.LaneType(0),...
                'LeftLaneBoundary', HelperRRDefaultData.alignmentSingle,...
                'RightLaneBoundary', HelperRRDefaultData.alignmentSingle,...
                'SuccessorLanes', HelperRRDefaultData.alignmentMultiple,...
                'PredecessorLanes', HelperRRDefaultData.alignmentMultiple,...
                'Geometry', HelperRRDefaultData.geometry);
            coder.varsize('out.SuccessorLanes', [Inf 1], [1 0]);
            coder.varsize('out.PredecessorLanes', [Inf 1], [1 0]);
        end

        % /////////////////////////////////////////////////////////////////
        function out = lanes()
            %LANES Returns the default lanes struct
            out = repmat(HelperRRDefaultData.lane,0,1);
            coder.varsize('out', [Inf 1], [1 0]);
        end
        
        % /////////////////////////////////////////////////////////////////
        function out = laneBoundary()
            %LANEBOUNDARY Returns the default lane Boundary struct
            out = struct(...
                'ID', HelperRRDefaultData.ID,...
                'Geometry', HelperRRDefaultData.geometry);
        end

        % /////////////////////////////////////////////////////////////////
        function out = laneBoundaries()
            %LANEBOUNDARIES Returns the default lanes struct
            out = repmat(HelperRRDefaultData.laneBoundary,0,1);
            coder.varsize('out', [Inf 1], [1 0]);
        end       

        % /////////////////////////////////////////////////////////////////
        function out = pathLikely(numPoints)
            %PATHLIKELY Returns the default reference path obtained in most
            %likely path algoritm.
            out = struct('ArcLength', zeros(numPoints, 1), ...
                            'X', zeros(numPoints, 1), ...
                            'Y', zeros(numPoints, 1), ...
                            'Heading', zeros(numPoints, 1), ...
                            'Curvature', zeros(numPoints, 1), ...
                            'Elevation', zeros(numPoints, 1), ...
                            'Grade', zeros(numPoints, 1), ...
                            'Banking', zeros(numPoints, 1));
            coder.varsize("out.X", [inf 1], [1 0]);
            coder.varsize("out.Y", [inf 1], [1 0]);
            coder.varsize("out.ArcLength", [inf 1], [1 0]);
            coder.varsize("out.Heading", [inf 1], [1 0]);
            coder.varsize("out.Curvature", [inf 1], [1 0]);
            coder.varsize("out.Elevation", [inf 1], [1 0]);
            coder.varsize("out.Grade", [inf 1], [1 0]);
            coder.varsize("out.Banking", [inf 1], [1 0]);
        end

    end

end

