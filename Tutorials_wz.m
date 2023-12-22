%Time range
startTime = datetime(2020,5,11,12,35,38);
stopTime = startTime + days(2);
sampleTime = 60;

%Scenario init
sc = satelliteScenario(startTime,stopTime,sampleTime);
tleFile = "eccentricOrbitSatellite.tle";

%Satellites init
satTwoBodyKeplerian = satellite(sc,tleFile, ...
    "Name","satTwoBodyKeplerian", ...
    "OrbitPropagator","two-body-keplerian");

satSGP4 = satellite(sc,tleFile, ...
    "Name","satSGP4", ...
    "OrbitPropagator","sgp4");

satSDP4 = satellite(sc,tleFile, ...
    "Name","satSDP4", ...
    "OrbitPropagator","sdp4");


% v = satelliteScenarioViewer(sc);
% satSGP4.MarkerColor = [0 1 0];
% satSGP4.Orbit.LineColor = [0 1 0];
% satSGP4.LabelFontColor = [0 1 0];
% satSDP4.MarkerColor = [1 0 1];
% satSDP4.Orbit.LineColor = [1 0 1];
% satSDP4.LabelFontColor = [1 0 1];
% camtarget(v,satTwoBodyKeplerian);

%Obtaining Position and Velocity of Satellites
[positionTwoBodyKeplerian,velocityTwoBodyKeplerian,time] = states(satTwoBodyKeplerian);
[positionSGP4,velocitySGP4] = states(satSGP4);
[positionSDP4,velocitySDP4] = states(satSDP4);

%Relative Position of Satellites
sgp4RelativePosition = vecnorm(positionSGP4 - positionTwoBodyKeplerian,2,1);
sdp4RelativePosition = vecnorm(positionSDP4 - positionTwoBodyKeplerian,2,1);

sgp4RelativePositionKm = sgp4RelativePosition/1000;
sdp4RelativePositionKm = sdp4RelativePosition/1000;
plot(time,sgp4RelativePositionKm,time,sdp4RelativePositionKm)
xlabel("Time")
ylabel("Relative position (km)")
legend("SGP4","SDP4")

%Relative Velocity of Satellites
sgp4RelativeVelocity = vecnorm(velocitySGP4 - velocityTwoBodyKeplerian,2,1);
sdp4RelativeVelocity = vecnorm(velocitySDP4 - velocityTwoBodyKeplerian,2,1);

plot(time,sgp4RelativeVelocity,time,sdp4RelativeVelocity)
xlabel("Time")
ylabel("Velocity deviation (m/s)")
legend("SGP4","SDP4")