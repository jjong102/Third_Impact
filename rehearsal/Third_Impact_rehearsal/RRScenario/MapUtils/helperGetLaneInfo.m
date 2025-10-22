function [lanes,laneBoundaries] = helperGetLaneInfo(varargin)
%helperGetLaneInfo gets map data from RoadRunner Scenario and pack it into
%lanes and lane boundaries
%   
% This is a helper script for example purposes and may be removed or
% modified in the future.

% Copyright 2021-2023 The MathWorks, Inc.

%% Read map data from SSE
if nargin ~= 1
    % Get Scenario Simulation variable
    rrSim = Simulink.ScenarioSimulation.find('ScenarioSimulation');
else
    rrSim = varargin{1};
end
% Read Map information
map = rrSim.getMap;
% Pack lane and lane boundaries
lanes = packLaneStruct(map.map.lanes);
laneBoundaries = packLaneBoundaryStruct(map.map.lane_boundaries);
end

function laneStruct = packLaneStruct(laneData)
% packLaneStruct packs lane data from map into 
% HelperRRDefaultData.lane format

% Initialize laneStruct
laneStruct = repmat(HelperRRDefaultData.lane, length(laneData), 1);
% Add lane information to laneStruct
for i = 1:length(laneData)
    lane = laneData(i);
    laneStruct(i,1).ID = char(lane.id(2:end-1));
    laneStruct(i,1).TravelDir = lane.travel_dir;
    laneStruct(i,1).LaneType = lane.lane_type;
    laneStruct(i,1).RightLaneBoundary.ID        = char(lane.right_lane_boundary.reference.id(2:end-1));
    laneStruct(i,1).RightLaneBoundary.Alignment = lane.right_lane_boundary.alignment;
    laneStruct(i,1).LeftLaneBoundary.ID        = char(lane.left_lane_boundary.reference.id(2:end-1));
    laneStruct(i,1).LeftLaneBoundary.Alignment = lane.left_lane_boundary.alignment;
    % update geometry values
    control_points = lane.geometry.values;
    num_control_points = length(control_points);
    for j = 1 : num_control_points
        control_point = control_points(j);
        laneStruct(i).Geometry.ControlPoints.x(j,1) = control_point.x;
        laneStruct(i).Geometry.ControlPoints.y(j,1) = control_point.y;
        laneStruct(i).Geometry.ControlPoints.z(j,1) = control_point.z;
    end
    % update PredecessorLanes and SuccessorLanes
    laneStruct(i).PredecessorLanes = repmat(HelperRRDefaultData.alignmentSingle,length(lane.predecessors),1);
    for j = 1:length(lane.predecessors)
        laneStruct(i).PredecessorLanes(j,1).ID = char(lane.predecessors(j).reference.id(2:end-1));
        laneStruct(i).PredecessorLanes(j,1).Alignment = lane.predecessors(j).alignment;
    end
    laneStruct(i).SuccessorLanes = repmat(HelperRRDefaultData.alignmentSingle,length(lane.successors),1);
    for j = 1:length(lane.successors)
        laneStruct(i).SuccessorLanes(j,1).ID = char(lane.successors(j).reference.id(2:end-1));
        laneStruct(i).SuccessorLanes(j,1).Alignment = lane.successors(j).alignment;
    end
end
end

function laneBoundaryStruct = packLaneBoundaryStruct(laneBoundaryData)
% packLaneBoundaryStruct packs lane data from map into 
% HelperRRDefaultData.laneBoundary format

% Initialize laneBoundaryStruct
laneBoundaryStruct = repmat(HelperRRDefaultData.laneBoundary, length(laneBoundaryData), 1);
% Add lane boundary information to laneBoundaryStruct
for i = 1:length(laneBoundaryData)
    laneBoundary = laneBoundaryData(i);
    control_points = laneBoundary.geometry.values;
    num_control_points = length(control_points);
    for j = 1 : num_control_points
        control_point = control_points(j);
        laneBoundaryStruct(i,1).Geometry.ControlPoints.x(j,1) = control_point.x;
        laneBoundaryStruct(i,1).Geometry.ControlPoints.y(j,1) = control_point.y;
        laneBoundaryStruct(i,1).Geometry.ControlPoints.z(j,1) = control_point.z;
    end
    laneBoundaryStruct(i,1).ID = char(laneBoundary.id(2:end-1));
end
end