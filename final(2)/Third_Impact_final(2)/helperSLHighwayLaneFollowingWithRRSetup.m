function helperSLHighwayLaneFollowingWithRRSetup(rrAppObj, scenarioSimulationObj, nvp)
% helperSLHighwayLaneFollowingWithRRSetup creates base workspace variables
% required for Highway Lane Following with RoadRunner Scenario Example.
%
% helperSLHLCPlannerRRSetup takes RoadRunner API object, ScenarioSimulation
% object, scenario name and vehicle detector name as an input.
%
% It initializes the HighwayLaneFollowingRRTestBench.slx model by creating
% data in base workspace. If the RoadRunner API object and ScenarioSimulation
% object are not passed then it initializes with default values, otherwise
% the variables are created based on the associated scenario.
%
% Examples of calling this function:
%    helperSLHighwayLaneFollowingWithRRSetup(rrAppObj, scenarioSimulationObj, scenarioFileName="scenario_HLFRR_CurvedRoad_StopnGo", detectorVariantName= "ACF")
%    helperSLHighwayLaneFollowingWithRRSetup(rrAppObj, scenarioSimulationObj, scenarioFileName="scenario_HLFRR_CurvedRoad_StopnGo", detectorVariantName= "YOLOv2 Code Generation")
%
% This is a helper script for example purposes and may be removed or
% modified in the future.
%
% Copyright 2022-2023 The MathWorks, Inc.
%% Inputs
arguments
    rrAppObj = [];
    scenarioSimulationObj = [];

    % nvp.scenarioFileName {mustBeMember(nvp.scenarioFileName,...
    %                      ["scenario_LFRR_01_Straight_RightLane";...
    %                      "scenario_LFRR_02_Straight_LeftLane";...
    %                      "scenario_LFRR_03_Curve_LeftLane";...
    %                      "scenario_LFRR_04_Curve_RightLane";...
    %                      "scenario_LFACCRR_01_Curve_DecelTarget";...
    %                      "scenario_LFACCRR_02_Curve_AutoRetarget";...
    %                      "scenario_LFACCRR_03_Curve_StopnGo";...
    %                      "scenario_LFACCRR_04_Curve_CutInOut";...
    %                      "scenario_LFACCRR_05_Curve_CutInOut_TooClose";...
    %                      "scenario_LFACCRR_06_Straight_StopandGoLeadCar";])} = "scenario_LFACCRR_03_Curve_StopnGo";
    % nvp.scenarioFileName = "RoadRunner_Prelim";
    nvp.scenarioFileName = "competition";

    nvp.detectorVariantName {mustBeMember(nvp.detectorVariantName, ...
        ["ACF", ...
        "YOLOv2"])}= "YOLOv2";
    nvp.behaviorName (1,1) string = "";
    
end

% Set random seed to ensure reproducibility.
rng(0);

% Load the test bench model
modelName = "Third_Impact_final2";
if ~bdIsLoaded(modelName)
    load_system(modelName);
end

% Create base work space variables based on the vehicle
% detector variant selected.
assignin('base','detectorVariant',nvp.detectorVariantName);

% If the detectorVariantName is "ACF" create a struct "acfDetectorStruct"
% in base workspace that contains the classifier and training options. For
% "YOLOv2" the Deep Learning Object Detector block will use the
% vehicleDetectorYOLOv2() function directly.
if(nvp.detectorVariantName == "ACF")
    detector = vehicleDetectorACF();
    acfDetectorStruct = toStruct(detector);
    % Remove the 'weights' and 'depth' fields from classifier struct. Those
    % two fields are unused for inference, removing them reduces the buffer
    % size used in generated code.
    acfDetectorStruct.Classifier = rmfield(acfDetectorStruct.Classifier, {'weights', 'depth'});
    % Create base work space variables for ACF vehicle detector struct
    assignin('base','acfDetectorStruct',acfDetectorStruct);
end
%%

% Default assessments
assessment.TimeGap = 0.8;
assessment.LongitudinalAccelMin = -3;
assessment.LongitudinalAccelMax =  3;
assessment.LateralDeviationMax = 0.75;
assessment.LaneDeviationMax = 0.25;

% Changing the default value of lane deviation threshold due to the complex
% scenario.
if nvp.scenarioFileName == "scenario_LFACCRR_04_Curve_CutInOut" || nvp.scenarioFileName == "scenario_LFACCRR_05_Curve_CutInOut_TooClose"
    assessment.LaneDeviationMax = 0.36;
end

% Assign assessment to base workspace
assignin('base', 'assessment', assessment);

%%
% Initialize variables
% Initialize to default values when the model is opened without opening
% scenario.

% Default number of Target Actors
numTargetActors = 5;

% Default Actor Profiles
initActorProfile = struct(...
    'ActorID',1,...
    'ClassID',1,...
    'Length',4.7,...
    'Width',1.8,...
    'Height',1.4,...
    'OriginOffset',[0 0 0],...
    'FrontOverhang',0,...
    'RearOverhang',0,...
    'Wheelbase',0,...
    'Color',[0 0 0]);

actorProfiles = repmat(initActorProfile, 1, numTargetActors+1);

% Default Actor dimensions
initActorDimensions = struct(...
    'id',1,...
    'length',4.7,...
    'width',1.8,...
    'height',1.4,...
    'rearOverhang',0,...
    'roll',0,...
    'pitch',0,...
    'yaw',0,...
    'frontOverhang',0,...
    'velocity',[0 0 0]);

actorDimensions = repmat(initActorDimensions, 1, numTargetActors+1);

% Default Vehicle Positions and Rotations
initVehiclePosition = struct(...
    'InitialPos',[0 0 0],...
    'InitialRot',[0 0 0]);

vehSim3D = repmat(initVehiclePosition, 1, numTargetActors+1);

%Default Ego Id.
egoId = 1;

%Default Ego Vehicle Dynamics Pramaeters
egoVehDyn.VLong0 = 1;
egoVehDyn.CGToFrontAxle = 1;
egoVehDyn.CGToRearAxle = 1;
egoVehDyn.X0 = 1;
egoVehDyn.Y0 = 1;
egoVehDyn.Yaw0 = 1;

%Default Camera Sensor Parameters
camera.NumColumns      = 1024;
camera.NumRows         = 768;
camera.FieldOfView     = [45,45];
camera.ImageSize       = [camera.NumRows, camera.NumColumns];
camera.PrincipalPoint  = [camera.NumColumns,camera.NumRows]/2;
camera.FocalLength     = [camera.NumColumns / (2*tand(camera.FieldOfView(1))),...
    camera.NumColumns / (2*tand(camera.FieldOfView(2)))];
camera.Position        = [ 1.8750, 0, 1.2];
camera.Rotation = [0, 0, 0];
camera.DetectionRanges  = [6 50];
camera.LaneDetectionRanges  = [6 30];
camera.MeasurementNoise = diag([6,1,1]);
camera.MinObjectImageSize = [10,10];
camera.PositionSim3d = [0 0 1];

% Default Radar sensor parameters
radar.FieldOfView     = [40,5];
radar.DetectionRanges = [1,150];
radar.Rotation = [ 0, 0, 0];
radar.Position = [0 0 1];
radar.PositionSim3d = [0 0 1];


%%
if ~isempty(scenarioSimulationObj)

    % Open scenario
    scenarioFcnName = nvp.scenarioFileName;
    openScenario(rrAppObj, strjoin([scenarioFcnName, '.rrscenario'],""));

    % Set Simulation 3D Scene Configuration block' SceneDesc parameter
    blkSim3DConfig = "HighwayLaneFollowingRRTestBench/Sensors and Vehicles/Simulation 3D Scene Configuration";

    % setSim3DSceneDesc(blkSim3DConfig,scenarioFcnName)

    % Get Initial Actor Poses and Profiles from RoadRunner Scenario
    % egoSetSpeed = str2double(rrAppObj.getScenarioVariable('egoInitialSpeed'));
    egoSetSpeed = double(14);

    worldActor = scenarioSimulationObj.getScenario;
    world = worldActor.actor_spec.world_spec;
    
    
    behavior = string(nvp.behaviorName);
    if ~endsWith(behavior, ".rrbehavior", "IgnoreCase", true)
        behavior = behavior + ".rrbehavior";
    end

    %Get actor profiles from the scenario.
    actorProfiles = helperGetActorProfiles(world.actors,OriginOffset="RearAxleCenter");

    numActors = length(world.actors);

    for i=1:numActors
        actorDimensions(i).id = actorProfiles(i).ActorID;
        actorDimensions(i).length = actorProfiles(i).Length;
        actorDimensions(i).width = actorProfiles(i).Width;
        actorDimensions(i).height = actorProfiles(i).Height;
        actorDimensions(i).rearOverhang = actorProfiles(i).RearOverhang;
        actorDimensions(i).frontOverhang = actorProfiles(i).FrontOverhang;
    end

    % Get ego ActorID
    for i = 1:length(world.behaviors)
        if contains(upper(world.behaviors(i).asset_reference),upper(behavior))
            egoBehavior = world.behaviors(i).id;
            break;
        end
    end

    for i = 1:length(world.actors)
        id = str2double(world.actors(i).actor_spec.id);
        if isequal(world.actors(i).actor_spec.behavior_id,egoBehavior)
            egoId = id;
        end
    end


    numActors = length(world.actors);
    numTargetActors = numActors - 1;

    %Default actor poses.
    object = struct(...
        'ActorID', 0, ...
        'Position',[0,0,0], ...
        'Velocity', [0,0,0], ...
        'Roll', 0, ...
        'Pitch', 0, ...
        'Yaw', 0, ...
        'AngularVelocity', [0 0 0]);

    actorInitialPoses = repmat(object, 1, numActors);
    actors = world.actors;

    %Get actor initial poses from the scenario.
    for i = 1:numActors

        id = str2double(actors(i).actor_spec.id);

        vehicleInitialPose = helperGetActorPose(world.actors,id,egoSetSpeed);

        actorInitialPoses(id).ActorID = vehicleInitialPose.ActorID;
        actorInitialPoses(id).Position  = vehicleInitialPose.Position;
        actorInitialPoses(id).Velocity  = vehicleInitialPose.Velocity;
        actorInitialPoses(id).Roll  =  vehicleInitialPose.Roll;
        actorInitialPoses(id).Pitch   =  vehicleInitialPose.Pitch;
        actorInitialPoses(id).Yaw = vehicleInitialPose.Yaw;
        actorInitialPoses(id).AngularVelocity = vehicleInitialPose.AngularVelocity;

    end

    %Set actors initial positions based on the scenario.
    vehSim3D = vehicleSim3DParams(actorInitialPoses,actorProfiles);
    egoVehDyn = egoVehicleDynamicsParams(actorInitialPoses,actorProfiles,egoId);

    %Set sensor parameters based on the scenario.
    camera = updateCameraParams(egoId,actorProfiles,camera);
    radar = updateRadarParams(egoId,actorProfiles,radar);
end


%%
assignin('base', 'egoActorID',egoId);
assignin('base', 'numTargetActors',numTargetActors);

% Vehicle Parameters
assignin('base','actorProfiles',actorProfiles);
assignin('base','actorDimensions',actorDimensions);
assignin('base','egoVehDyn', egoVehDyn);
assignin('base','vehSim3D', vehSim3D);

%% Sensor parameters
assignin('base','camera',camera);
assignin('base','radar', radar);

%% Vehicle Detection Range for Ground Truth Filtering

% Specify the range till which ground truth is considered. ACF can
% detect vehicles in close range. YOLOv2 can detect vehicles at a large
% range.

if(nvp.detectorVariantName == "ACF")
    vehicleDetectionRange = 35; % For ACF.
elseif(nvp.detectorVariantName == "YOLOv2")
    vehicleDetectionRange = camera.DetectionRanges(2); % For YOLOv2.
end

assignin('base','vehicleDetectionRange', vehicleDetectionRange);
%% General model parameters
assignin('base','Ts',0.01);                   % Algorithm sample time  (s)
assignin('base','v_set', egoVehDyn.VLong0);  % Set velocity (m/s)
assignin('base','TimeDataType', 'double');

%% Path following controller parameters
assignin('base','tau',             0.5);     % Time constant for longitudinal dynamics 1/s/(tau*s+1)
assignin('base','time_gap',        1.5);     % Time gap               (s)
assignin('base','default_spacing', 10);      % Default spacing        (m)
assignin('base','max_ac',          1000);       % Maximum acceleration   (m/s^2)
assignin('base','min_ac',          -2000);      % Minimum acceleration   (m/s^2)
assignin('base','max_steer',       0.26);    % Maximum steering       (rad)
assignin('base','min_steer',       -0.26);   % Minimum steering       (rad)
assignin('base','PredictionHorizon', 30);    % Prediction horizon
assignin('base','ControlHorizon', 2);
assignin('base','v0_ego', egoVehDyn.VLong0); % Initial longitudinal velocity (m/s)
assignin('base','tau2', 0.07);    % Longitudinal time constant (brake)             (N/A)
assignin('base','max_dc', -10);        % Maximum deceleration   (m/s^2)
assignin('base','LaneWidth', single(3.85)); % Width of the lane (m)

%% Watchdog Braking controller parameters
assignin('base', 'PB1_decel',       3.8);      %1st stage Partial Braking deceleration (m/s^2)
assignin('base', 'PB2_decel',       5.3);      % 2nd stage Partial Braking deceleration (m/s^2)
assignin('base', 'FB_decel',        9.8);      % Full Braking deceleration              (m/s^2)
assignin('base', 'headwayOffset',   3.7);      % headway offset                         (m)
assignin('base', 'timeMargin',      0);
assignin('base', 'timeToReact',     1.2);      % driver reaction time                   (sec)
assignin('base', 'driver_decel',    4.0);      % driver braking deceleration            (m/s^2)
assignin('base','Default_decel', 0);           % Default deceleration (m/s^2)
assignin('base','TimeFactor', 1.2);            % Time factor (sec)
assignin('base','stopVelThreshold', 0.1);      % Velocity threshold for stopping ego vehicle (m/s)

%% Tracking and sensor fusion parameters
assignin('base','assigThresh',  650);    % Tracker assignment threshold          (N/A)
assignin('base','numTracks',    100);   % Maximum number of tracks              (N/A)
assignin('base','numSensors',   2);     % Maximum number of sensors used for detection (N/A)
assignin('base','Epsilon',      3);     % Distance for clustering
assignin('base','MinNumPoints', 2);     % Minimum number of points required for clustering
assignin('base', 'M',           3);     % Tracker M value for M-out-of-N logic
assignin('base', 'N',           4);     % Tracker N value for M-out-of-N logic
assignin('base', 'P',           4);     % Tracker P value for P-out-of-R logic
assignin('base', 'R',           5);     % Tracker R value for P-out-of-R logic


% Position selector from track state.
% The filter initialization function used in this example is initcvekf that
% defines a state that is: [x;vx;y;vy;z;vz].
assignin('base','posSelector', [1,0,0,0,0,0; 0,0,1,0,0,0]); % Position selector   (N/A)

%% Dynamics modeling parameters
assignin('base','m',  436);                    % Total mass of vehicle                          (kg)
assignin('base','Iz', 736);                    % Yaw moment of inertia of vehicle               (m*N*s^2)
assignin('base','Cf', 1900000);                   % Cornering stiffness of front tires             (N/rad)
assignin('base','Cr', 3300000);                   % Cornering stiffness of rear tires              (N/rad)
assignin('base','lf', egoVehDyn.CGToFrontAxle); % Longitudinal distance from c.g. to front tires (m)
assignin('base','lr', egoVehDyn.CGToRearAxle);  % Longitudinal distance from c.g. to rear tires  (m)
assignin('base','des_vel', 50);  % Longitudinal distance from c.g. to rear tires  (m)
%%
global x_ref y_ref x_ref2 y_ref2 

dist1 = min((x_ref-egoVehDyn.X0).^2 + (y_ref-egoVehDyn.Y0).^2);
dist2 = min((x_ref-egoVehDyn.X0).^2 + (y_ref-egoVehDyn.Y0).^2);

if dist1 <= dist2
    assignin('base','startLane', 1);
else
    assignin('base','startLane', 2);
end


%% GOSPA metric parameters
assignin('base', 'alpha',               2);        % Alpha parameter of GOSPA metric
assignin('base', 'order',               2);        % Order of GOSPA metric
assignin('base', 'switchingPenalty',    0);        % Penalty for assignment switching
assignin('base', 'cutOffDistance',     30);        % Threshold for cutoff distance between track and truth

%% Bus creation
evalin('base','helperCreateLFBusObjects');
helperCreateLCBusActorsEgo(numTargetActors);

% The Sim 3D VDG block outputs a lane boundry at every 0.5 m between
% 0 to 70 m of the parent. The following function helps in creating the
% required bus of size 141 X 3.
evalin('base',"helperCreateSim3DVDGBusObjects('laneDimensions',141)");

BusActorPose = evalin('base', 'BusVehiclePose');
assignin('base','BusActorPose', BusActorPose);
evalin('base',"assignin('base','BusActors', BusActorsEgo)");

end

function egoVehDyn = egoVehicleDynamicsParams(actorPoses,actorProfiles,egoId)
egoPose = actorPoses(egoId);
egoProfile = actorProfiles(egoId);

% Translate to SAE J670E (North-East-Down)
% Adjust sign of y position to
egoVehDyn.X0  =  egoPose.Position(1); % (m)
egoVehDyn.Y0  = -egoPose.Position(2); % (m)
egoVehDyn.VX0 =  egoPose.Velocity(1); % (m/s)
egoVehDyn.VY0 = -egoPose.Velocity(2); % (m/s)

% Adjust sign and unit of yaw
egoVehDyn.Yaw0 = -deg2rad(egoPose.Yaw); % (rad)

% Longitudinal velocity
egoVehDyn.VLong0 = hypot(egoVehDyn.VX0,egoVehDyn.VY0); % (m/sec)

% Distance from center of gravity to axles
egoVehDyn.CGToFrontAxle = egoProfile.Length/2 - egoProfile.FrontOverhang;
egoVehDyn.CGToRearAxle  = egoProfile.Length/2 - egoProfile.RearOverhang;

end


function vehSim3D = vehicleSim3DParams(actorPoses,actorProfiles)
%vehicleSim3DParams vehicle parameters used by Sim 3D

% Number of vehicles in scenario
numVehicles = numel(actorPoses);

% Preallocate struct
vehSim3D = repmat(...
    struct(...
    'Length', 0,...
    'RearOverhang', 0,...
    'InitialPos',[0 0 0],...
    'InitialRot',[0 0 0]),...
    numVehicles,1);

for n = 1:numVehicles
    % Vehicle information from driving scenario
    veh = actorPoses(n);

    % Update struct elements
    vehSim3D(n).Length = actorProfiles(n).Length;
    vehSim3D(n).RearOverhang = actorProfiles(n).RearOverhang;
    vehSim3D(n).InitialPos = veh.Position;
    vehSim3D(n).InitialRot = [veh.Roll veh.Pitch veh.Yaw];
end
end


function camera = updateCameraParams(egoId,actorProfiles,camera)

camera.PositionSim3d   = ...      % Position with respect to vehicle center (m)
    camera.Position - ...         %  - Reduce position X by distance from vehicle center to rear axle
    [ actorProfiles(egoId).Length/2 - actorProfiles(egoId).RearOverhang,...
    0, 0];

end


function radar = updateRadarParams(egoId,actorProfiles,radar)

radar.Position        = ...        % Position with respect to rear axle (m)
    [ actorProfiles(egoId).Length - actorProfiles(egoId).RearOverhang, ...
    0,...
    0.8];
radar.PositionSim3d   = ...       % Position with respect to vehicle center (m)
    radar.Position - ...
    [actorProfiles(egoId).Length/2 - actorProfiles(egoId).RearOverhang, 0, 0];

end

function setSim3DSceneDesc(blkSim3DConfig,scenarioFcnName)
if contains(scenarioFcnName,"Straight")
    sceneDesc = "Straight road";
    set_param(blkSim3DConfig, 'ProjectFormat', "Default Scenes");
    set_param(blkSim3DConfig, 'SceneDesc', sceneDesc);

elseif contains(scenarioFcnName,"Curve")
    sceneDesc = "Curved road";
    set_param(blkSim3DConfig, 'ProjectFormat', "Default Scenes");
    set_param(blkSim3DConfig, 'SceneDesc', sceneDesc);
else
    % error("Scenario name should contain 'Straight' or 'Curve' substring to set Sim 3D scene description.");
    sceneDesc = "Straight road";
    set_param(blkSim3DConfig, 'ProjectFormat', "Default Scenes");
    set_param(blkSim3DConfig, 'SceneDesc', sceneDesc);
end

end