% Clean up function for the Highway Lane Following with RoadRunner Scenario Example
%
% This script cleans up the  Highway Lane Following with RoadRunner Scenario test bench model. It is
% triggered by the CloseFcn callback.

% This is a helper script for example purposes and may be removed or
% modified in the future.

% Copyright 2022-2023 The MathWorks, Inc.

clearBuses({...
    'BusActors1',...
    'BusActors',...
    'BusDetectionConcatenation1',...
    'BusDetectionConcatenation1Detections',...
    'BusDetectionConcatenation1DetectionsMeasurementParameters',...
    'BusLaneBoundaries',...
    'BusLaneBoundariesLaneBoundaries',...
    'BusRadar',...
    'BusRadarDetections',...
    'BusRadarDetectionsMeasurementParameters',...
    'BusRadarDetectionsObjectAttributes',...
    'BusVehiclePose',...
    'BusVision',...
    'BusVisionDetections',...
    'BusVisionDetectionsMeasurementParameters',...
    'BusVisionDetectionsObjectAttributes',...
    'BusActorPose',...
    'BusActorsEgo',...
    'BusLaneCenter',...
    'BusTrackerJPDA',...
    'BusTrackerJPDATracks',...
    'BusVisionInfo',...
    'BusVisionDetectionsInfo'});

clear actorDimensions
clear alpha
clear cutOffDistance
clear vehicleDetectionRange
clear order
clear switchingPenalty
clear LaneSensorBoundaries
clear LaneSensor
clear actorProfiles
clear Cf
clear Cr
clear Ir
clear PredictionHorizon
clear Ts
clear assessment
clear assigThresh
clear camera
clear default_spacing
clear egoVehDyn
clear lf
clear lr
clear m
clear max_ac
clear max_steer
clear min_ac
clear min_steer
clear numSensors
clear posSelector
clear radar
clear scenario
clear tau
clear TimeDataType
clear time_gap
clear v0_ego
clear v_set
clear ControlHorizon
clear vehSim3D
clear max_dc
clear tau2
clear driver_decel
clear FB_decel
clear headwayOffset
clear PB1_decel
clear PB2_decel
clear timeMargin
clear timeToReact
clear Default_decel
clear detectorVariant
clear Epsilon
clear LaneWidth
clear M
clear MinNumPoints
clear N
clear numTargetActors
clear P
clear R
clear stopVelThreshold
clear TimeFactor
clear egoActorID
clear Iz
clear numTracks
clear acfDetectorStruct

function clearBuses(buses)
matlabshared.tracking.internal.DynamicBusUtilities.removeDefinition(buses);
end