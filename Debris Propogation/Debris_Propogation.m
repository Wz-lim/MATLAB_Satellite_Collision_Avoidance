
close;clear
% Load Data
addpath('..\Satellites\')

%Time range
startTime = datetime(2023,14,12,20,35,38);
stopTime = startTime + days(7);
sampleTime = 20;

%Scenario
sc = satelliteScenario(startTime,stopTime,sampleTime);
tleFile = "Test_1.txt";

%Satellites init
satellites = satellite(sc,tleFile,"OrbitPropagator","sgp4");

%Minimum conjunction distance
dMinTarget = 200e3;


% v = satelliteScenarioViewer(sc);
% satellites.MarkerColor = [0 1 0];
% satellites.LabelFontColor = [0 1 0];
% v.PlaybackSpeedMultiplier = 150;

% Find possible conjunction
k = 0;
for i = 1:length(satellites)-1
    for j = i+1:length(satellites)
        fprintf('    Windows for %s and %s \n',satellites(i).Name,satellites(j).Name);
        k = k + Conjunction(dMinTarget,satellites(i),satellites(j));
    end
end
    fprintf("    %d windows found for dMin = %g km\n",k,dMinTarget*1e-3);
%% Determine access

% Groundstation Sentosa (User input)
mission.GroundStation.Latitude  =1.2475;  % deg
mission.GroundStation.Longitude =103.8371; % deg
gs = groundStation(sc, mission.GroundStation.Latitude, mission.GroundStation.Longitude, ...
    "MinElevationAngle", 10, "Name", "Singapore_Sentosa");

% Preview latitude (deg), longitude (deg), and altitude (m) for each satellite
for idx = numel(satellites):-1:1
    % Retrieve states in geographic coordinates
    [llaData, ~, llaTimeStamps] = states(satellites(idx), "CoordinateFrame","geographic");
    % Organize state data for each satellite in a seperate timetable
    mission.Satellite.LLATable{idx} = timetable(llaTimeStamps', llaData(1,:)', llaData(2,:)', llaData(3,:)',...
        'VariableNames', {'Lat_deg','Lon_deg', 'Alt_m'});
    mission.Satellite.LLATable{idx}
end

% Compute Ground Station to Satellite Access (Line-of-Sight Visibility)
accessSG = access(gs,satellites);
accessSG.LineColor = "green";

%View the full access table between each ground station and all 
%satellites as tables
intervalsSG = accessIntervals(accessSG);
intervalsSG = sortrows(intervalsSG, "StartTime", "ascend")

% Visualise Scenario with Satellites and Groundstation
satellites.MarkerColor = [0 1 0]; 
satellites.LabelFontColor = [0 1 0];
viewer3D = satelliteScenarioViewer(sc, ShowDetails=false);
show(satellites.Orbit);
gs.ShowLabel = true;
gs.LabelFontSize = 11;

%% Plot access status of groundstation
[statusSG, timeSteps] = accessStatus(accessSG);

% Sum cumulative access at each timestep
statusSG = sum(statusSG, 1);

figure()
stairs(timeSteps, statusSG);
title("Sentosa(Singapore) to Satellites")
ylabel("# of satellites")

%Collect access interval metrics for each ground station in a
% table for comparison.
statusTable = [table(height(intervalsSG)); ...
    table(sum(intervalsSG.Duration)/3600); ...
    table(mean(intervalsSG.Duration/60)); ...
    table(mean(statusSG, 2)); ...
    table(min(statusSG)); ...
    table(max(statusSG))];
statusTable.Properties.VariableNames = ["Singapore"];
statusTable.Properties.RowNames = ["Total # of intervals", "Total interval time (hrs)",...
    "Mean interval length (min)", "Mean # of satellites in view", ...
    "Min # of satellites in view", "Max # of satellites in view"];
statusTable

