classdef testUDA_ML < matlab.System

    % Copyright 2022 The MathWorks, Inc.
    properties
    end

    properties (Access = private)
        mActorHdl;
        mThrottleLevel = 35;
        mSteeringAngle = 0;
        mLastTime = 0;
    end

    methods (Access=protected)

        function interface = getInterfaceImpl(~)
            import matlab.system.interface.*;
            interface = ActorInterface();
            actionType = 'UserDefinedAction';
            actionName = 'CustomDrive';
            actionElements = struct('ThrottleLevel',"", 'SteeringAngle',"");
            newAction = matlab.system.interface.UserDefinedAction( ...
                actionName, actionElements);
            interface.addAction(actionType, newAction);
        end
% 사용자 정의 액션을 사용하는 MATLAB System object의 인터페이스를 정의
% 01 참조

        function st = getSampleTimeImpl(obj)
            st = createSampleTime( ...
                obj, 'Type', 'Discrete', 'SampleTime', 0.02);
        end
% 샘플 타임을 정의

        function setupImpl(obj)
            sim = Simulink.ScenarioSimulation.find('ScenarioSimulation');
            % 시나리오 시뮬레이션 객체(액터 그룹이 포함된 객체)를 찾음
            actor = sim.get('ActorSimulation','SystemObject',obj);
            % 현재 behavior가 연결된 액터 객체를 반환
            obj.mActorHdl = actor;
        end
% 여기까지는 CustomDrive(Throttle + Steering) 명령을 받을 수 있게 만들고, "시뮬레이션 시작 시, 내가 제어할 액터를 찾아 연결"하는 단계

        function resetImpl(~)
        end

        function releaseImpl(~)
        end

        function stepImpl(obj)
            uda = obj.mActorHdl.getAction("UserDefinedAction", "CustomDrive");
            for i = 1:length(uda)
                obj.mThrottleLevel = eval(uda(i).Parameters.ThrottleLevel);
                obj.mSteeringAngle = eval(uda(i).Parameters.SteeringAngle);
                obj.mActorHdl.sendEvent('ActionComplete', uda(i).ActorAction.ActionID);
            end
% 02 참조
% 시뮬레이션에서 액터가 "외부에서 받은 운전 명령(엑셀, 핸들)"을 받아오는 단계

            currentTime = obj.getCurrentTime;
            elapsedTime = currentTime - obj.mLastTime;
            obj.mLastTime = currentTime;

            pose = obj.mActorHdl.getAttribute('Pose');

            maxSpeed = 50;
            distance = elapsedTime*obj.mThrottleLevel*maxSpeed/100;
            angle = deg2rad(obj.mSteeringAngle);

            pose(1,4) = pose(1,4) + distance*cos(angle);
            pose(2,4) = pose(2,4) + distance*sin(angle);

            obj.mActorHdl.setAttribute('Pose', pose);
% 시간 및 pose 갱신
% 액션으로 받은 ThrottleLevel(가속) 과 SteeringAngle(조향각) 을 이용해, 차량을 2D 평면 위에서 앞으로 움직이는 로직
% 사용자 정의 매개변수 값에 따라 차량의 현재 pose와 속도를 업데이트
% 03 참조

        end
    end
end