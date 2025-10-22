clear all
clc
close all

if ~ispc
    error(['This example is supported only on Microsoft.',char(174),' Windows',char(174),'.'])
end

pathToCurvedRRScene = fullfile(matlabshared.supportpkg.getSupportPackageRoot,"toolbox","shared","sim3dprojects","spkg","roadrunner","RoadRunnerProject","Scenes","CurvedRoad.rrscene");
pathToStrightRRScene = fullfile(matlabshared.supportpkg.getSupportPackageRoot,"toolbox","shared","sim3dprojects","spkg","roadrunner","RoadRunnerProject","Scenes","StraightRoad.rrscene");
pathToAssets = fullfile(matlabshared.supportpkg.getSupportPackageRoot,"toolbox","shared","sim3dprojects","spkg","roadrunner","RoadRunnerProject","Assets","Markings","*.rrmeta");

if (~exist(pathToCurvedRRScene, 'file') && ~exist(pathToStrightRRScene, 'file'))
    error('This example requires you to download and install Automated Driving Toolbox Interface for Unreal Engine 4 Projects support package');
end

rrAppPath = "C:\Program Files\RoadRunner R2025a\bin\win64";
rrProjectPath = "C:\Users\leskb\OneDrive\문서\New RoadRunner Project";

s = settings;
s.roadrunner.application.InstallationFolder.TemporaryValue = rrAppPath;

rrApp = roadrunner(rrProjectPath);

openProject("HLFWithRRScenario");


HLFWithRRScenarioProject = currentProject;
projectPath = convertStringsToChars(HLFWithRRScenarioProject.RootFolder);
projectRootFolder = projectPath(1:find(projectPath=='\',1,'last')-1);

copyfile(pathToCurvedRRScene,fullfile(rrProjectPath,"Scenes"),'f')
copyfile(pathToStrightRRScene,fullfile(rrProjectPath,"Scenes"),'f')
copyfile(fullfile(projectRootFolder,"HLFTestScenarios/RoadRunner/Scenarios"),fullfile(rrProjectPath,"Scenarios"),'f')
copyfile(fullfile(projectRootFolder,"HLFWithRRScenario/TestBench/HLF.rrbehavior.rrmeta"),fullfile(rrProjectPath,"Assets","Behaviors"),'f')
copyfile(pathToAssets, fullfile(rrProjectPath,"Assets/Markings"),'f')


%%
openScene(rrApp,"RoadRunner_Prelim.rrscene")
openScenario(rrApp,"RoadRunner_Prelim.rrscenario")

rrSim = createSimulation(rrApp);
set(rrSim,Logging="on");

Ts = 0.01;

set(rrSim,StepSize=Ts)

open_system("HighwayLaneFollowingRRTestBench")

mpcverbosity("off");

helperSLHighwayLaneFollowingWithRRSetup(rrApp,rrSim,scenarioFileName="RoadRunner_Prelim")

set_param("HighwayLaneFollowingRRTestBench",SimulationCommand="update")

v_set = 20;

%%
set(rrSim,SimulationCommand="Start")

% while strcmp(rrSim.get("SimulationStatus"),"Running")
%     pause(1)
% end