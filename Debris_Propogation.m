%Time range
startTime = datetime(2023,14,12,20,35,38);
stopTime = startTime + days(2);
sampleTime = 60;

%Scenario + Satellite init
sc = satelliteScenario(startTime,stopTime,sampleTime);
tleFile = "Test_1.txt";

%Satellites init
% satTwoBodyKeplerian = satellite(sc,tleFile, ...
%     "Name","satTwoBodyKeplerian", ...
%     "OrbitPropagator","two-body-keplerian");

satellites = satellite(sc,tleFile);


v = satelliteScenarioViewer(sc);
satellites.MarkerColor = [0 1 0];
satellites.LabelFontColor = [0 1 0];
v.PlaybackSpeedMultiplier = 150;

%Obtaining Position and Velocity of Satellites
[position,velocity] = states(satellites);


