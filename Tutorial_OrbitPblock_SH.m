%%Orbit_Propagator Block Tutorial to model Satellite Constellation
%Shuhao Lim
% Look at openExample('aeroblks/OrbitPropagatorBlockConstellationExample')
% for background theory and tutorial page
%Run by each section
close all;clear all;


%Define mission parameters and initial conditions
% For a Walker-Delta  constellation (24 satellites in 3 planes 
% inclined at 56 degrees) in a 29599.8 km orbit.
mission.StartDate = datetime(2020, 11, 30, 22, 23, 24);
mission.Duration  = hours(24);

mission.Satellites.SemiMajorAxis  = 29599.8e3 * ones(24,1); % meters
mission.Satellites.Eccentricity   = 0.0005    * ones(24,1);
mission.Satellites.Inclination    = 56        * ones(24,1); % deg
mission.Satellites.ArgOfPeriapsis = 350       * ones(24,1); % deg

mission.Satellites.RAAN               = sort(repmat([0 120 240], 1,8))'; % deg
mission.Satellites.TrueAnomaly        = repmat(0:45:315, 1,3)'; % deg

% Account for the relative angular shift between adjacent orbital planes.
% The phase difference is given as , or 15 degrees in this case.
mission.Satellites.TrueAnomaly(9:16)  = mission.Satellites.TrueAnomaly(9:16)  + 15;
mission.Satellites.TrueAnomaly(17:24) = mission.Satellites.TrueAnomaly(17:24) + 30;

%Show the constellation nodes in a table.
ConstellationDefinition = table(mission.Satellites.SemiMajorAxis, ...
    mission.Satellites.Eccentricity, ...
    mission.Satellites.Inclination, ...
    mission.Satellites.RAAN, ...
    mission.Satellites.ArgOfPeriapsis, ...
    mission.Satellites.TrueAnomaly, ...
    'VariableNames', ["a (m)", "e", "i (deg)", "Ω (deg)", "ω (deg)", "ν (deg)"]);

%% Open and Configure the Orbit Propagation Model

% Open the Orbit Propagation Model (I still don't understand)
mission.mdl = "OrbitPropagatorBlockExampleModel";
open_system(mission.mdl);

%Define the path to the Orbit Propagator block in the model.
mission.Satellites.blk = mission.mdl + "/Orbit Propagator";

% Set satellite initial conditions.  Use set_param to assign the Keplerian
% orbital element set defined in the previous section.
set_param(mission.Satellites.blk, ...
    startDate = num2str(juliandate(mission.StartDate)), ...
    stateFormatNum = "Orbital elements", ...
    orbitType      = "Keplerian", ...
    semiMajorAxis  = "mission.Satellites.SemiMajorAxis", ...
    eccentricity   = "mission.Satellites.Eccentricity", ...
    inclination    = "mission.Satellites.Inclination", ...
    raan           = "mission.Satellites.RAAN", ...
    argPeriapsis   = "mission.Satellites.ArgOfPeriapsis", ...
    trueAnomaly    = "mission.Satellites.TrueAnomaly");

% Set the position and velocity output ports of the block to use the
% Earth-centered Earth-fixed frame, which is the International Terrestrial
% Reference Frame (ITRF).
set_param(mission.Satellites.blk, ...
    centralBody  = "Earth", ...
    outportFrame = "Fixed-frame");

% Configure the propagator. This example uses the Oblate ellipsoid 
% (J2) propagator which includes second order zonal harmonic 
% perturbations in the satellite trajectory calculations, 
% accounting for the oblateness of Earth.
set_param(mission.Satellites.blk, ...
    propagator   = "Numerical (high precision)", ...
    gravityModel = "Oblate ellipsoid (J2)", ...
    useEOPs      = "off");

% Apply model-level solver setting using set_param. For best performance
% and accuracy when using a numerical propagator, use
% a variable-step solver.
set_param(mission.mdl, ...
    SolverType = "Variable-step", ...
    SolverName = "VariableStepAuto", ...
    RelTol     = "1e-6", ...
    AbsTol     = "1e-7", ...
    StopTime   = string(seconds(mission.Duration)));

%Save model output port data as a dataset of time series objects.
set_param(mission.mdl, ...
    SaveOutput = "on", ...
    OutputSaveName = "yout", ...
    SaveFormat = "Dataset");

%% Run Model & collect Satellite Ephemerides

%Run model
mission.SimOutput = sim(mission.mdl);

%Extract position and velocity data from the model output data structure.
mission.Satellites.TimeseriesPosECEF = mission.SimOutput.yout{1}.Values;
mission.Satellites.TimeseriesVelECEF = mission.SimOutput.yout{2}.Values;

%Set the start data from the mission in the timeseries object.
mission.Satellites.TimeseriesPosECEF.TimeInfo.StartDate = mission.StartDate;
mission.Satellites.TimeseriesVelECEF.TimeInfo.StartDate = mission.StartDate;

%The timeseries objects contain position and velocity data for 
% all 24 satellites
mission.Satellites.TimeseriesPosECEF;

%% Load the Satellite Ephemerides into a satelliteScenario Object

%Create a satellite scenario object for the analysis.
scenario = satelliteScenario(mission.StartDate, mission.StartDate + hours(24), 60);

% Add all 24 satellites to the satellite scenario from the ECEF position
% and velocity timeseries objects using the satellite method.
sat = satellite(scenario, mission.Satellites.TimeseriesPosECEF, mission.Satellites.TimeseriesVelECEF, ...
    CoordinateFrame="ecef", Name="GALILEO " + (1:24));
disp(scenario)

%% Set Graphical Properties on the Satellites
%Set satellites in each orbital plane to have the same orbit color.
set(sat(1:8), MarkerColor="#FF6929");
set(sat(9:16), MarkerColor="#139FFF");
set(sat(17:24), MarkerColor="#64D413");
orbit = [sat(:).Orbit];
set(orbit(1:8), LineColor="#FF6929");
set(orbit(9:16), LineColor="#139FFF");
set(orbit(17:24), LineColor="#64D413");

%% Add Ground Stations to Scenario
%a location on Earth must have access to at least 4 satellites in the 
% constellation at any given time
% In this example, use three MathWorks® locations to compare total 
% constellation access over the 1 day analysis window to different regions
% of Earth:

gsUS = groundStation(scenario, 42.30048, -71.34908, ... %Coordinates
    MinElevationAngle=10, Name="Natick");
gsUS.MarkerColor = "red";
gsDE = groundStation(scenario, 48.23206, 11.68445, ...
    MinElevationAngle=10, Name="Munchen");
gsDE.MarkerColor = "red";
gsIN = groundStation(scenario, 12.94448, 77.69256, ...
    MinElevationAngle=10, Name="Bangalore");
gsIN.MarkerColor = "red";


% figure
% geoscatter([gsUS.Latitude gsDE.Latitude gsIN.Latitude], ...
%     [gsUS.Longitude gsDE.Longitude gsIN.Longitude], "red", "filled")
% geolimits([-75 75], [-180 180])
% title("Ground Stations")

%% Compute Ground Station to Satellite Access (Line-of-Sight Visibility)
accessUS = access(gsUS, sat);
accessDE = access(gsDE, sat);
accessIN = access(gsIN, sat);

%Set access colors to match orbital plane colors assigned earlier in the example.
set(accessUS, LineWidth="1");
set(accessUS(1:8), LineColor="#FF6929");
set(accessUS(9:16), LineColor="#139FFF");
set(accessUS(17:24), LineColor="#64D413");

set(accessDE, LineWidth="1");
set(accessDE(1:8), LineColor="#FF6929");
set(accessDE(9:16), LineColor="#139FFF");
set(accessDE(17:24), LineColor="#64D413");

set(accessIN, LineWidth="1");
set(accessIN(1:8), LineColor="#FF6929");
set(accessIN(9:16), LineColor="#139FFF");
set(accessIN(17:24), LineColor="#64D413");

%View the full access table between each ground station and all 
%satellites in the constellation as tables
intervalsUS = accessIntervals(accessUS); %US
intervalsUS = sortrows(intervalsUS, "StartTime", "ascend")

intervalsDE = accessIntervals(accessDE); %Munchen
intervalsDE = sortrows(intervalsDE, "StartTime", "ascend")

intervalsIN = accessIntervals(accessIN); %Bangalore
intervalsIN = sortrows(intervalsIN, "StartTime", "ascend")

%% View the Satellite Scenario
%Open a 3-D viewer window of the scenario.
viewer3D = satelliteScenarioViewer(scenario, ShowDetails=false);
show(sat.Orbit);
gsUS.ShowLabel = true;
gsUS.LabelFontSize = 11;
gsDE.ShowLabel = true;
gsDE.LabelFontSize = 11;
gsIN.ShowLabel = true;
gsIN.LabelFontSize = 11;

%% Compare Access Between Ground Stations

% Calculates access status between each satellite and ground station 
[statusUS, timeSteps] = accessStatus(accessUS);
statusDE = accessStatus(accessDE);
statusIN = accessStatus(accessIN);

% Sum cumulative access at each timestep
statusUS = sum(statusUS, 1);
statusDE = sum(statusDE, 1);
statusIN = sum(statusIN, 1);

subplot(3,1,1);
stairs(timeSteps, statusUS);
title("Natick to GALILEO")
ylabel("# of satellites")
subplot(3,1,2);
stairs(timeSteps, statusDE);
title("München to GALILEO")
ylabel("# of satellites")
subplot(3,1,3);
stairs(timeSteps, statusIN);
title("Bangalore to GALILEO")
ylabel("# of satellites")

%Collect access interval metrics for each ground station in a
% table for comparison.
statusTable = [table(height(intervalsUS), height(intervalsDE), height(intervalsIN)); ...
    table(sum(intervalsUS.Duration)/3600, sum(intervalsDE.Duration)/3600, sum(intervalsIN.Duration)/3600); ...
    table(mean(intervalsUS.Duration/60), mean(intervalsDE.Duration/60), mean(intervalsIN.Duration/60)); ...
    table(mean(statusUS, 2), mean(statusDE, 2), mean(statusIN, 2)); ...
    table(min(statusUS), min(statusDE), min(statusIN)); ...
    table(max(statusUS), max(statusDE), max(statusIN))];
statusTable.Properties.VariableNames = ["Natick", "München", "Bangalore"];
statusTable.Properties.RowNames = ["Total # of intervals", "Total interval time (hrs)",...
    "Mean interval length (min)", "Mean # of satellites in view", ...
    "Min # of satellites in view", "Max # of satellites in view"];
statusTable