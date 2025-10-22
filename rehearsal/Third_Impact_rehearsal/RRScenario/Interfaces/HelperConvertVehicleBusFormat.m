classdef HelperConvertVehicleBusFormat < matlab.System
    % HelperConvertVehicleBusFormat converts RRScenario vehicle runtime to 
    % BusActorEgo
    %
    % NOTE: The name of this System Object and it's functionality may
    % change without notice in a future release, or the System Object
    % itself may be removed.
    %
    
    % Copyright 2021-2022 The MathWorks, Inc.

    properties(Nontunable)
        %egoActorID Ego Actor ID
        egoActorID = 1;

        % Number of target actors
        NumVehicles = 1;
    end

    properties(Access = private)
        % Time
        Time = 0;
    end

    methods(Access = protected)
        function TargetActors = stepImpl(obj, timeStep, VehicleRuntime)
            % Converts RRScenario vehicle runtime to BusActorEgo format
            actorStruct = struct('ActorID', 0, ...
                'Position', zeros([1,3]), ...
                'Velocity', zeros([1,3]), ...
                'Roll', 0, ...  % deg
                'Pitch', 0, ... % deg
                'Yaw', 0, ...   % deg
                'AngularVelocity', zeros([1,3]));  % deg/sec
            TargetActors = struct('NumActors', 0, ...
                'Time', 0, ...
                'Actors', repmat(actorStruct, obj.NumVehicles, 1));

            numActors = 1;
            numWorldActors = sum([VehicleRuntime.ActorID]==0);
            for i=1:length(VehicleRuntime)-numWorldActors
                if double(VehicleRuntime(i).ActorID) ~= obj.egoActorID
                    % In world coordinates
                    rotationMatrix = VehicleRuntime(i).Pose(1:3,1:3);
                    rotation = rotm2eul(rotationMatrix); % The default order for Euler angle rotations is "ZYX"
                    rotation = rad2deg(rotation);
                    location = VehicleRuntime(i).Pose(1:3,4)';

                    TargetActors.Actors(numActors).ActorID  = double(VehicleRuntime(i).ActorID);
                    TargetActors.Actors(numActors).Position = location;
                    TargetActors.Actors(numActors).Velocity = VehicleRuntime(i).Velocity;
                    TargetActors.Actors(numActors).Roll     = rotation(3);
                    TargetActors.Actors(numActors).Pitch    = rotation(2);
                    TargetActors.Actors(numActors).Yaw      = rotation(1) + 90;
                    TargetActors.Actors(numActors).AngularVelocity = rad2deg(VehicleRuntime(i).AngularVelocity);

                    numActors = numActors + 1;
                end
            end

            TargetActors.NumActors = numActors - 1;
            TargetActors.Time = obj.Time;

            obj.Time = obj.Time + timeStep;
        end

        function icon = getIconImpl(obj)
            % Use class name slightly raised above center
            icon = [mfilename("class"), newline, newline];
        end

        function out1 = getOutputSizeImpl(~)
            out1 = [1 1];
        end

        function interface = getInterfaceImpl(~)
            import matlab.system.interface.*;
            interface = [Input("in1", Data),...
                         Input("in2", Message), ...
                         Output("out1", Data)];
        end

        function out1 = getOutputDataTypeImpl(~)
            out1 = "Bus: BusActorsEgo";
        end

        function out1 = isOutputComplexImpl(~)
            out1 = false;
        end

        function out1 = isOutputFixedSizeImpl(~)
            out1 = true;
        end
    end
end
