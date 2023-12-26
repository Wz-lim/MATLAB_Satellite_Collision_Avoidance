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

k = 0;
for i = 1:length(satellites)-1
    for j = i+1:length(satellites)
        fprintf('    Windows for %s and %s \n',satellites(i).Name,satellites(j).Name);
        k = k + Conjunction(dMinTarget,satellites(i),satellites(j));
    end
end
    fprintf("    %d windows found for dMin = %g km\n",k,dMinTarget*1e-3);