%OrbitPropagators Example Tutorial


%1. Two-Body-Keplerian orbit propagator:
% based on the relative two-body model that assumes a spherical
% gravity field for the Earth and neglects third body effects and 
% other environmental perturbations

%2. SGP4:
%accounts for secular and periodic orbital perturbations 
% caused by Earth's geometry and atmospheric drag, applicable to 
% near-Earth satellites whose orbital period is less than 225 minutes

%3. SDP4:
% The SDP4 orbit propagator builds upon SGP4 by accounting for 
% solar and lunar gravity, and is applicable to satellites whose 
% orbital period is greater than or equal to 225 minutes

%Setting up Satellites

%Set starting and stopping time
startTime = datetime(2020,5,11,12,35,38);
stopTime = startTime + days(2);
sampleTime = 60;

%Create Satellite Scenario
sc = satelliteScenario(startTime,stopTime,sampleTime);

%add three satellites to the satellite scenario from the two-line element (TLE) file
tleFile = "eccentricOrbitSatellite.tle";

%Assign names to satellites
satTwoBodyKeplerian = satellite(sc,tleFile, ...
    "Name","satTwoBodyKeplerian", ...
    "OrbitPropagator","two-body-keplerian");
satSGP4 = satellite(sc,tleFile, ...
    "Name","satSGP4", ...
    "OrbitPropagator","sgp4");
satSDP4 = satellite(sc,tleFile, ...
    "Name","satSDP4", ...
    "OrbitPropagator","sdp4");
%% Run Simulation

%Visualise the Satellites & their Orbits
v = satelliteScenarioViewer(sc);
satSGP4.MarkerColor = [0 1 0];
satSGP4.Orbit.LineColor = [0 1 0];
satSGP4.LabelFontColor = [0 1 0];
satSDP4.MarkerColor = [1 0 1];
satSDP4.Orbit.LineColor = [1 0 1];
satSDP4.LabelFontColor = [1 0 1];

play(sc) %Add play function

camtarget(v,satTwoBodyKeplerian); %Focus the camera on satTwoBodyKeplerian

%% Obtain & plot position of Satellites in Simulation

%Return the position and velocity history 
%of the satellites in the Geocentric Celestial Reference Frame (GCRF)
[positionTwoBodyKeplerian,velocityTwoBodyKeplerian,time] = states(satTwoBodyKeplerian);
[positionSGP4,velocitySGP4] = states(satSGP4);
[positionSDP4,velocitySDP4] = states(satSDP4);

%Calculate the magnitude of the relative position of satSGP4 and satSDP4 
% with respect to satTwoBodyKeplerian
sgp4RelativePosition = vecnorm(positionSGP4 - positionTwoBodyKeplerian,2,1);
sdp4RelativePosition = vecnorm(positionSDP4 - positionTwoBodyKeplerian,2,1);

%Plot the magnitude of the relative positions in kilometers
% of satSGP4 and satSDP4 with respect to that of satTwoBodyKeplerian
sgp4RelativePositionKm = sgp4RelativePosition/1000;
sdp4RelativePositionKm = sdp4RelativePosition/1000;
plot(time,sgp4RelativePositionKm,time,sdp4RelativePositionKm)
xlabel("Time")
ylabel("Relative position (km)")
legend("SGP4","SDP4")

%% Plot Magnitude of Relative Velocity with Respect to 
% Two-Body-Keplerian Prediction

%Calculate the magnitude of the relative velocity
sgp4RelativeVelocity = vecnorm(velocitySGP4 - velocityTwoBodyKeplerian,2,1);
sdp4RelativeVelocity = vecnorm(velocitySDP4 - velocityTwoBodyKeplerian,2,1);

%Plot the magnitude of the relative velocities in meters per second 
% of satSGP4 and satSDP4
plot(time,sgp4RelativeVelocity,time,sdp4RelativeVelocity)
xlabel("Time")
ylabel("Velocity deviation (m/s)")
legend("SGP4","SDP4")