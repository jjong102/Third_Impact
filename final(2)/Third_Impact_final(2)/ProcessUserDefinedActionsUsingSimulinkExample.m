%% Process User-Defined Actions Using Simulink
% Create a Simulink model that reads a user-defined action from
% a MAT file and uses it to update actor behavior.
%
% This example shows the Simulink model |hUDA_SL.slx|, which contains the 
% following blocks.
%
% * RoadRunner Scenario &mdash; Associate *Action Name* as entered in RoadRunner
% Scenario with the name of the MAT file (*Bus object name*).
% * RoadRunner Scenario Reader &mdash; Read the user-defined action at runtime.
% Set *Topic Category* to |Action| and *Action Type* to
% |User-Defined|. Enter the name of the action in the *Action Name* box; the
% corresponding MAT file is read during scenario simulation. Use a second 
% RoadRunner Scenario Reader block to input the actor parameters of the
% associated vehicle in RoadRunner Scenario.
% * RoadRunner Scenario Writer &mdash; Convey completion of a user-defined action
% to a scenario simulation by publishing an *Action Complete* event. Set
% *Topic Category* to |Event| and *Event Type* to |Action Complete|.
% Upon receiving an *Action Complete* event, the simulation proceeds to 
% the next action phase with the changed actor behavior. Use a second 
% RoadRunner Scenario Writer block to update the behavior of the
% respective vehicle.

% Copyright 2022 The MathWorks, Inc.
%% 
model_name = 'hUDA_SL.slx';
open_system(model_name);
%%
