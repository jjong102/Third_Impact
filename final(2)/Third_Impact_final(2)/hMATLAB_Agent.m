classdef hMATLAB_Agent < matlab.System

    % Copyright 2023 The MathWorks, Inc.
    properties (Access = private)
        mActorSimulationHdl;
        mScenarioSimulationHdl;
        mActor;
        mAmbulanceHdl;
    end

    properties (Access = public)
        mSimStepCount = 0;
        SpeedFactor = 1;
        HasChangedLane = false;
        HasSentEvent = false;
    end

    methods (Access = protected)
      function interface = getInterfaceImpl(~)
          import matlab.system.interface.*;
          interface = ActorInterface();

          eventType = 'UserDefinedEvent';
          eventName = 'ChangeLane';
          eventElements = struct('ActorID',1);
          newEvent = matlab.system.interface.UserDefinedEvent(eventName, eventElements);
          interface.addEvent(eventType, newEvent);
      end

      function sz = getOutputSizeImpl(~)
          sz = [1 1];
      end

      function st = getSampleTimeImpl(obj)
         st = createSampleTime( ...
             obj, 'Type', 'Discrete', 'SampleTime', 0.02);
      end

      function t = getOutputDataTypeImpl(~)
            t = "double";
      end

      function resetImpl(~)
      end

      function setupImpl(obj)
            obj.mScenarioSimulationHdl = ...
                Simulink.ScenarioSimulation.find( ...
                    'ScenarioSimulation', 'SystemObject', obj);
            obj.mActorSimulationHdl = Simulink.ScenarioSimulation.find( ...
                'ActorSimulation', 'SystemObject', obj);

            obj.mActor.actorModel = ...
                obj.mActorSimulationHdl.get('ActorModel');
            obj.mActor.pose = ...
                obj.mActorSimulationHdl.getAttribute('Pose');
            obj.mActor.velocity = ...
                obj.mActorSimulationHdl.getAttribute('Velocity');
            obj.mActor.angularVelocity = ...
                obj.mActorSimulationHdl.getAttribute('AngularVelocity');
            obj.mActor.wheelPoses = ...
                obj.mActorSimulationHdl.getAttribute('WheelPoses');
            obj.mActor.actorID = ...
                double(obj.mActorSimulationHdl.getAttribute('ID'));
      end

      function stepImpl(obj, ~)

            obj.mSimStepCount = obj.mSimStepCount + 1;

            velocity = obj.mActor.velocity;
            dTimeUnit = obj.getSampleTimeImpl.SampleTime;
            pose = obj.mActor.pose;

            assert(isequal(pose, obj.mActorSimulationHdl.getAttribute('Pose')), ...
                'Pose not updated properly.');

            dTimeUnit = dTimeUnit * obj.SpeedFactor;

            pose(1,4) = pose(1,4) + velocity(1) * dTimeUnit;
            pose(2,4) = pose(2,4) + velocity(2) * dTimeUnit;
            pose(3,4) = pose(3,4) + velocity(3) * dTimeUnit;

            actorsim = get(obj.mScenarioSimulationHdl, 'ActorSimulation');

           for i = 1 : length(actorsim)
                otherActor = actorsim(i);
                id = double(getAttribute(otherActor,'ID'));
                if(obj.HasSentEvent)
                      attribute = struct('ActorID', 10);
                      obj.mActorSimulationHdl.sendEvent('UserDefinedEvent', 'ChangeLane', attribute);
                end
                if (id ~= 0 && id ~= 2 && id ~= obj.mActor.actorID && ~obj.HasSentEvent)
                    otherPose = getAttribute(otherActor, 'Pose');
                    distance = sqrt(abs(sum(pose(1:3,4) - otherPose(1:3,4))));
                    if (distance < 3)
                        attribute = struct('ActorID', id);
                        obj.mActorSimulationHdl.sendEvent('UserDefinedEvent', 'ChangeLane', attribute);
                        obj.HasSentEvent = true;
                    end
                end

           end

            obj.mActor.pose = pose;
            obj.mActorSimulationHdl.setAttribute('Pose', obj.mActor.pose);
      end

      function releaseImpl(~)
      end
    end
end