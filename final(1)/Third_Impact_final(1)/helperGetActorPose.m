function actorPose = helperGetActorPose(worldActors, actorID, varargin)
% helperGetActorPose calculates actor pose of the actor correspoding to
% provided actorID using scenario information from RoadRunner Scenario. It
% takes actor speed as an optional input which is used to update velocity
% in the actor pose.
%
% NOTE: The name of this helper function and it's functionality may
% change without notice in a future release, or the helper function
% itself may be removed.
%

% Copyright 2022-2023 The MathWorks, Inc.

% Find actor with ActorID = actorID 
actorIDs = arrayfun(@(actors) str2double(actors.actor_runtime.id),worldActors,'UniformOutput',true);
idx = actorIDs == actorID;
if nnz(idx) == 1
    % Get pose matrix.
    m = worldActors(idx).actor_runtime.pose.matrix;
    c1 = m.col0;
    c2 = m.col1;
    c3 = m.col2;
    c4 = m.col3;
    
    pose = [c1.x c2.x c3.x c4.x; ...
        c1.y c2.y c3.y c4.y; ...
        c1.z c2.z c3.z c4.z; ...
        c1.w c2.w c3.w c4.w];
    
    position = pose(1:3,4)';
    heading = rotm2eul(pose(1:3, 1:3)); % The default order for Euler angle rotations is "ZYX"
    
    % Adjust yaw due to difference in the actor's starting orientation
    yaw = rad2deg(heading(1))+90;
    if yaw > 180
        yaw = yaw-360;
    end
    
    if nargin == 3
        % Actor speed is available
        actorSpeed = varargin{1};
        velocity = [actorSpeed*cosd(yaw) actorSpeed*sind(yaw) 0];
    else
        % Actor speed is not available
        velocity = [0 0 0];
    end
    
    actorPose = struct(...
        'ActorID', double(actorID), ...
        'Position', position, ...         % m
        'Velocity', velocity, ...         % m/s
        'Roll', rad2deg(heading(3)), ...  % deg
        'Pitch', rad2deg(heading(2)), ... % deg
        'Yaw', yaw, ...                   % deg
        'AngularVelocity', [0 0 0]);      % deg/s
else
    error("Actor with ActorID:%d does not exist",actorID);
end
end
