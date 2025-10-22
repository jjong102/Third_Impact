classdef HelperPackRRActorPoses < matlab.System
    % HelperPackRRActorPoses Adapts a set of BusActorPose messages to
    % signals carrying the same data.
    %
    % Output carries a vector of bus objects containing
    % the data in these messages.
    
    % Copyright 2022 The MathWorks, Inc.

    properties(Nontunable)
        %EgoActorID Ego Actor ID
        EgoActorID = 1;
        %ActorProfiles Actor Profiles
        ActorProfiles = struct(...
        'ActorID', 0, ...
        'Position',[0,0,0], ...
        'Velocity', [0,0,0], ...
        'Roll', 0, ...
        'Pitch', 0, ...
        'Yaw', 0, ...
        'AngularVelocity', [0 0 0]);
        %ActorPosesDefault Actor Poses Structure
        ActorPosesDefault = Simulink.Bus.createMATLABStruct("BusActors");
    end

    methods(Access = protected)

        function TargetPoses = stepImpl(obj, time, msgs)

            % Initialize outputs
            TargetPoses = obj.ActorPosesDefault;
            TargetPoses.Time = time;

            % Extract actor poses
            actors = msgs';
            numActors = length(actors);

            TargetPoses.NumActors = numActors-1;
            iTarget = 1;
            for i = 1:numActors
                if actors(i).ActorID ~= obj.EgoActorID
                    rotationMatrix = actors(i).Pose(1:3,1:3);
                    rotation = rotm2eul(rotationMatrix); % The default order for Euler angle rotations is "ZYX"
                    rotation = rad2deg(rotation);
                    vehPos = actors(i).Pose(1:3,4)';
                    yaw = rotation(1) + 90;
                    id = double(actors(i).ActorID);

                    TargetPoses.Actors(iTarget).ActorID  = id;
                    TargetPoses.Actors(iTarget).Velocity = actors(i).Velocity;
                    TargetPoses.Actors(iTarget).Roll     = rotation(3);
                    TargetPoses.Actors(iTarget).Pitch    = rotation(2);
                    TargetPoses.Actors(iTarget).Yaw      = yaw;
                    TargetPoses.Actors(iTarget).AngularVelocity = rad2deg(actors(i).AngularVelocity);

                    if obj.ActorProfiles(id).ClassID == 1 || ... % car or truck
                            obj.ActorProfiles(id).ClassID == 2

                        % Translate position from center of the vehicle to one
                        % located under the rear axle.
                        % yaw must be in degrees.

                        % Compute the offset from vehPos to reach the new position.
                        offset = obj.ActorProfiles(id).RearOverhang - obj.ActorProfiles(id).Length/2;
                        % Add this offset to the position along the orientation of the
                        % vehicle.

                        forwardVector = [cosd(yaw) sind(yaw) 0];

                        % Determine the new position along the forward vector
                        newPos = vehPos + offset*forwardVector;

                        TargetPoses.Actors(iTarget).Position = newPos;
                    else
                        TargetPoses.Actors(iTarget).Position = vehPos;
                    end

                    iTarget = iTarget + 1;
                end
            end
        end

        function num = getNumInputsImpl(~)
            num = 2;
        end

        function num = getNumOutputsImpl(~)
            num = 1;
        end

        function interface = getInterfaceImpl(~)
            import matlab.system.interface.*;
            interface = [Input("Time", Data), ...
                Input("Msg", Message),...
                Output("TargetPoses", Data)];
        end

        function out1 = getOutputSizeImpl(obj)
            out1 = [1 1];
        end

        function out1 = getOutputDataTypeImpl(~)
            out1 = "BusActors";
        end

        function out1 = isOutputComplexImpl(~)
            out1 = false;
        end

        function out1 = isOutputFixedSizeImpl(~)
            out1 = true;
        end
    end

    methods(Access = protected, Static)
        function simMode = getSimulateUsingImpl
            % Return only allowed simulation mode in System block dialog
            simMode = "Interpreted execution";
        end

        function flag = showSimulateUsingImpl
            % Return false if simulation mode hidden in System block dialog
            flag = false;
        end
    end
end
