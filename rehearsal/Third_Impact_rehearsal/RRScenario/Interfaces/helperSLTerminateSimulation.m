function helperSLTerminateSimulation(stop)
%helperSLTerminateSimulation function sends the "stop simulation" signal to
%RoadRunner when the ego vehicle stops.

% Copyright 2022 The MathWorks, Inc.

if(stop == 1)
    rrSim = Simulink.ScenarioSimulation.find('ScenarioSimulation');
    rrSim.set('SimulationCommand','Stop');
end

end