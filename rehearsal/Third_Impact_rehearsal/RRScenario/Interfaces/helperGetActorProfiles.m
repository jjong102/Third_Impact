function actorProfiles = helperGetActorProfiles(worldActors, nvp)
% helperGetActorProfiles calculates driving scenario actor profiles
% for all the actors using actor spec information from RoadRunner
% Scenario.
%
% helperGetActorProfiles take worldActors and OriginOffset as input.
% By default, the origin offset is set to 'VehicleCenter' and returns the
% origin offset of the actor with respect to the vehicle center.
% If OriginOffset is set to  'RearAxleCenter' then the vehicle's
% origin offset will be calculated as the offset from the real axle
% center to the geometric center of the vehicle.
%
% Examples of calling this function:
%   actorProfiles = helperGetActorProfiles(worldActors,"OriginOffset","RearAxleCenter")
%
%
% NOTE: The name of this helper function and it's functionality may
% change without notice in a future release, or the helper function
% itself may be removed.
%

% Copyright 2022 The MathWorks, Inc.

%% Inputs
arguments
    worldActors = [];
    nvp.OriginOffset {mustBeMember(nvp.OriginOffset,...
        ["RearAxleCenter";...
        "VehicleCenter";])} = "VehicleCenter";
end

numActors = length(worldActors);

% Initialize actorProfiles struct.
actorProfile = struct(...
    'ActorID',0,...
    'ClassID',1,...
    'Length',0,...
    'Width',0,...
    'Height',0,...
    'OriginOffset',[0 0 0],...
    'FrontOverhang',0,...
    'RearOverhang',0,...
    'Color',[0 0 0],...
    'bbx',zeros(2,3));

actorProfiles = repmat(actorProfile, 1, numActors);

for i = 1:numActors
    id = str2double(worldActors(i).actor_spec.id);
    
    % Get actor bounding box
    min = worldActors(i).actor_spec.bounding_box.min;
    max = worldActors(i).actor_spec.bounding_box.max;
    bbx = [min.x min.y min.z; ...
        max.x max.y max.z];
    actorProfiles(i).ActorID = id;

    % Calculate length and width from bounding boxes
    actorProfiles(i).Length  = max.y - min.y;
    actorProfiles(i).Width   = max.x - min.x;
    actorProfiles(i).Height  = max.z;
    actorProfiles(i).bbx     = bbx;


    % Update the Color, FrontOverhang, RearOverhang and OriginOffset values
    % in the actor profiles if it is a vehicle. For character, these values
    % are not valid.
    if ~isempty(worldActors(i).actor_spec.vehicle_spec) && isempty(worldActors(i).actor_spec.character_spec)
        % Get actor color
        color = worldActors(i).actor_spec.vehicle_spec.paint_color;
        r = double(color.r)/255;
        g = double(color.g)/255;
        b = double(color.b)/255;
        actorProfiles(i).Color   = [r g b];
        % Calculate FrontOverhang and RearOverhang
        actorProfiles(i).FrontOverhang = actorProfiles(i).Length/2 - worldActors(i).actor_spec.vehicle_spec.wheels(1).wheel_offset.y;
        actorProfiles(i).RearOverhang = actorProfiles(i).Length/2 + worldActors(i).actor_spec.vehicle_spec.wheels(3).wheel_offset.y;
        %Calculate OriginOffset
        if(nvp.OriginOffset == "RearAxleCenter")
            actorProfiles(i).OriginOffset(1) = actorProfiles(i).RearOverhang - actorProfiles(i).Length/2 ;
        end
    end

    if(~isempty(worldActors(i).actor_spec.character_spec))
        actorProfiles(i).ClassID = 4; % Update Class ID for pedestrian actor.
    end
end
end

