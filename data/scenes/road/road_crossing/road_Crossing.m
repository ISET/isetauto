function [allData, scenario, sensor] = dsd()
%dsd - Returns sensor detections
%    allData = dsd returns sensor detections in a structure
%    with time for an internally defined scenario and sensor suite.
%
%    [allData, scenario, sensors] = dsd optionally returns
%    the drivingScenario and detection generator objects.

% Generated by MATLAB(R) 9.14 (R2023a) and Automated Driving Toolbox 3.7 (R2023a).
% Generated on: 19-Jun-2023 06:19:13

% Create the drivingScenario object and ego car
[scenario, egoVehicle] = createDrivingScenario;

% Create all the sensors
sensor = createSensor(scenario);

allData = struct('Time', {}, 'ActorPoses', {}, 'ObjectDetections', {}, 'LaneDetections', {}, 'PointClouds', {}, 'INSMeasurements', {});
running = true;
while running

    % Generate the target poses of all actors relative to the ego vehicle
    poses = targetPoses(egoVehicle);
    time  = scenario.SimulationTime;

    % Generate detections for the sensor
    laneDetections = [];
    ptClouds = [];
    insMeas = [];
    [objectDetections, isValidTime] = sensor(poses, time);
    numObjects = length(objectDetections);
    objectDetections = objectDetections(1:numObjects);

    % Aggregate all detections into a structure for later use
    if isValidTime
        allData(end + 1) = struct( ...
            'Time',       scenario.SimulationTime, ...
            'ActorPoses', actorPoses(scenario), ...
            'ObjectDetections', {objectDetections}, ...
            'LaneDetections', {laneDetections}, ...
            'PointClouds',   {ptClouds}, ... %#ok<AGROW>
            'INSMeasurements',   {insMeas}); %#ok<AGROW>
    end

    % Advance the scenario one time step and exit the loop if the scenario is complete
    running = advance(scenario);
end

% Restart the driving scenario to return the actors to their initial positions.
restart(scenario);

% Release the sensor object so it can be used again.
release(sensor);

%%%%%%%%%%%%%%%%%%%%
% Helper functions %
%%%%%%%%%%%%%%%%%%%%

% Units used in createSensors and createDrivingScenario
% Distance/Position - meters
% Speed             - meters/second
% Angles            - degrees
% RCS Pattern       - dBsm

function sensor = createSensor(scenario)
% createSensors Returns all sensor objects to generate detections

% Assign into each sensor the physical and radar profiles for all actors
profiles = actorProfiles(scenario);
sensor = visionDetectionGenerator('SensorIndex', 1, ...
    'UpdateInterval', 0.3, ...
    'SensorLocation', [1.9 0], ...
    'DetectorOutput', 'Objects only', ...
    'ActorProfiles', profiles);

function [scenario, egoVehicle] = createDrivingScenario
% createDrivingScenario Returns the drivingScenario defined in the Designer

% Construct a drivingScenario object.
scenario = ia_drivingScenario('SampleTime', 0.3);

% Add all road segments
roadCenters = [987.94000244141 6.0899996757507 0;
    737.94139417755 6.9241855858479 0;
    495.24781395568 7.7339963543881 0;
    487.94278591368 7.7583714959451 0;
    237.94417764982 8.5925574060423 0;
    2.5556254699461 9.3779930330255 0];
headings = [179.808818317323;179.808818317323;179.808818317323;179.808818317323;179.808818317323;179.808818317323];
marking = [laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')];
lanetypes = [laneType('Border')
    laneType('Border')
    laneType('Shoulder')
    laneType('Driving')
    laneType('Driving')
    laneType('Shoulder')
    laneType('Border')
    laneType('Border')];
laneSpecification = lanespec([4 4], 'Width', [2 0.635 0.5 3.5 3.5 0.5 0.635 2], 'Marking', marking, 'Type', lanetypes);
road(scenario, roadCenters, 'Heading', headings, 'Lanes', laneSpecification, 'Name', 'road_Crossing');

roadCenters = [-15.466419910264 9.4381283131045 0;
    -60.948632728799 9.5898916423355 0;
    -106.43084554733 9.7416549715666 0];
headings = [179.808818317323;179.808818317323;179.808818317323];
marking = [laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')];
lanetypes = [laneType('Border')
    laneType('Border')
    laneType('Shoulder')
    laneType('Driving')
    laneType('Driving')
    laneType('Shoulder')
    laneType('Border')
    laneType('Border')];
laneSpecification = lanespec([4 4], 'Width', [2 0.635 0.5 3.5 3.5 0.5 0.635 2], 'Marking', marking, 'Type', lanetypes);
road(scenario, roadCenters, 'Heading', headings, 'Lanes', laneSpecification, 'Name', 'road_Crossing');

roadCenters = [-124.44010456665 9.8017475865997 0;
    -374.43871283051 10.635933496697 0;
    -564.72502664856 11.270873678859 0;
    -624.43732109438 11.470119406794 0;
    -874.43592935824 12.304305316891 0;
    -1005.0099487305 12.739999771119 0];
headings = [179.808818317323;179.808818317323;179.808818317323;179.808818317323;179.808818317323;179.808818317323];
marking = [laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')];
lanetypes = [laneType('Border')
    laneType('Border')
    laneType('Shoulder')
    laneType('Driving')
    laneType('Driving')
    laneType('Shoulder')
    laneType('Border')
    laneType('Border')];
laneSpecification = lanespec([4 4], 'Width', [2 0.635 0.5 3.5 3.5 0.5 0.635 2], 'Marking', marking, 'Type', lanetypes);
road(scenario, roadCenters, 'Heading', headings, 'Lanes', laneSpecification, 'Name', 'road_Crossing');

roadCenters = [-1.8899999856949 1009.2099609375 0;
    -3.0315635229039 759.21256728571 0;
    -4.152125146163 513.81450041518 0;
    -4.173127060113 509.21517363391 0;
    -5.3146905973221 259.21777998212 0;
    -6.4142503066311 18.419039892856 0];
headings = [-90.2616280001046;-90.2616280001046;-90.2616280001046;-90.2616280001046;-90.2616280001046;-90.2616280001046];
marking = [laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')];
lanetypes = [laneType('Border')
    laneType('Border')
    laneType('Shoulder')
    laneType('Driving')
    laneType('Driving')
    laneType('Shoulder')
    laneType('Border')
    laneType('Border')];
laneSpecification = lanespec([4 4], 'Width', [2 0.635 0.5 3.5 3.5 0.5 0.635 2], 'Marking', marking, 'Type', lanetypes);
road(scenario, roadCenters, 'Heading', headings, 'Lanes', laneSpecification, 'Name', 'road_Crossing');

roadCenters = [-6.4965440037028 0.39708219071133 0;
    -7.6381075409118 -249.60031146108 0;
    -8.7382717729695 -490.53143937339 0;
    -8.7796710781209 -499.59770511288 0;
    -9.9212346153299 -749.59509876467 0;
    -10.979999542236 -981.4599609375 0];
headings = [-90.2616280001046;-90.2616280001046;-90.2616280001046;-90.2616280001046;-90.2616280001046;-90.2616280001046];
marking = [laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')];
lanetypes = [laneType('Border')
    laneType('Border')
    laneType('Shoulder')
    laneType('Driving')
    laneType('Driving')
    laneType('Shoulder')
    laneType('Border')
    laneType('Border')];
laneSpecification = lanespec([4 4], 'Width', [2 0.635 0.5 3.5 3.5 0.5 0.635 2], 'Marking', marking, 'Type', lanetypes);
road(scenario, roadCenters, 'Heading', headings, 'Lanes', laneSpecification, 'Name', 'road_Crossing');

roadCenters = [-117.39999389648 87.75 0;
    -116.4069148232 53.405914686006 0;
    -115.41383574992 19.061829372012 0];
headings = [-88.34372093382;-88.34372093382;-88.34372093382];
marking = [laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('Unmarked')];
lanetypes = [laneType('Border')
    laneType('Border')
    laneType('Shoulder')
    laneType('Driving')
    laneType('Driving')
    laneType('Shoulder')
    laneType('Border')
    laneType('Border')];
laneSpecification = lanespec([4 4], 'Width', [2 0.635 0.5 3.5 3.5 0.5 0.635 2], 'Marking', marking, 'Type', lanetypes);
road(scenario, roadCenters, 'Heading', headings, 'Lanes', laneSpecification, 'Name', 'road_Crossing');

roadCenters = [-1025.0320880245 50 0;
    -1025.0320880245 0 0;
    -1025.0320880245 -50 0];
headings = [-90;-90;-90];
laneSpecification = lanespec([1 1]);
road(scenario, roadCenters, 'Heading', headings, 'Lanes', laneSpecification, 'Name', 'road_Crossing');

rg = driving.scenario.RoadGroup('Name', 'Roadgroup');
Centers = [-117.163104611556 19.0112482520267 0;
    -117.159858620049 18.8989907166016 0;
    -124.321961434996 11.551363113269 0;
    -124.43389268505 11.5517366012349 0];
marking = laneMarking('Unmarked');
laneSpecification = lanespec(1, 'Width', 3.5, 'Marking', marking);
headings = [-88.3437209338199;-88.3437209338199;179.808818317323;179.808818317323];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-110.098557366049 19.2155237180232 0;
    -110.081772095673 18.6350315021669 0;
    -108.971231520206 16.1046055724636 0;
    -106.413103239302 15.0591253720959 0];
marking = laneMarking('Unmarked');
lanetypes = [laneType('Border')
    laneType('Border')];
laneSpecification = lanespec(2, 'Width', [2 0.635], 'Marking', marking, 'Type', lanetypes);
headings = [-88.34372093382;271.65839227913;315.732542346854;359.808818317323];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-106.425006245964 11.4916452294135 0;
    -106.619386590608 11.492293830403 0;
    -113.642167266945 18.3377546496635 0;
    -113.647785569957 18.5320548651511 0;
    -113.664566888277 19.1124104919967 0];
marking = laneMarking('Unmarked');
laneSpecification = lanespec(1, 'Width', 3.5, 'Marking', marking);
headings = [539.808818317322;179.808818317323;451.65627906618;91.65627906618;91.65627906618];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-117.163104611556 19.0112482520267 0;
    -117.067704661991 15.7119903228846 0;
    -109.156706086103 8.00074077781098 0;
    -109.019947560354 8.00028444712975 0;
    -106.436684848705 7.99166471371962 0];
marking = [laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)
    laneMarking('Unmarked')];
laneSpecification = lanespec(1, 'Width', 3.5, 'Marking', marking);
headings = [-88.34372093382;-88.34372093382;-0.191181682677464;359.808818317323;359.808818317323];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-113.414671336614 19.1196363662802 0;
    -113.205715561306 11.8932279491797 0;
    -112.996759785999 4.66681953207918 0];
marking = [laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)];
lanetypes = [laneType('Shoulder')
    laneType('Driving')];
laneSpecification = lanespec(2, 'Width', [0.5 3.5], 'Marking', marking, 'Type', lanetypes);
headings = [-88.34372093382;-88.34372093382;-88.34372093382];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-117.413000163219 19.0040223777431 0;
    -117.204044387911 11.7776139606426 0;
    -116.995088612603 4.5512055435421 0];
marking = [laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)
    laneMarking('Unmarked')
    laneMarking('Unmarked')];
lanetypes = [laneType('Driving')
    laneType('Shoulder')];
laneSpecification = lanespec(2, 'Width', [3.5 0.5], 'Marking', marking, 'Type', lanetypes);
headings = [-88.34372093382;-88.34372093382;-88.34372093382];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-106.424172060053 11.7416438376775 0;
    -109.007434771702 11.7502635710877 0;
    -109.974654904324 11.7534909546807 0;
    -119.979799233938 11.786875742245 0;
    -121.269575916858 11.7911794203476 0;
    -124.433431079372 11.8017364527106 0];
marking = [laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)
    laneMarking('Unmarked')
    laneMarking('Unmarked')];
lanetypes = [laneType('Driving')
    laneType('Shoulder')];
laneSpecification = lanespec(2, 'Width', [3.5 0.5], 'Marking', marking, 'Type', lanetypes);
headings = [539.808818317322;539.808818317322;539.808818317322;539.808818317322;539.808818317322;539.808818317322];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-106.437519034615 7.74166610545576 0;
    -109.020781746264 7.75028583886589 0;
    -109.988001878886 7.75351322245893 0;
    -119.993146208499 7.7868980100232 0;
    -121.28292289142 7.7912016881258 0;
    -124.446778053934 7.80175872048885 0];
marking = [laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)];
lanetypes = [laneType('Shoulder')
    laneType('Driving')];
laneSpecification = lanespec(2, 'Width', [0.5 3.5], 'Marking', marking, 'Type', lanetypes);
headings = [539.808818317322;539.808818317322;539.808818317322;539.808818317322;539.808818317322;539.808818317322];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-124.457847700961 4.48427718882741 0;
    -121.293992538447 4.47372015646436 0;
    -120.004215403997 4.46941647685493 0;
    -120.224776461771 4.55955763972766 0;
    -120.320525535899 4.77773791907698 0;
    -120.311202583168 4.45531819179916 0];
marking = laneMarking('Unmarked');
lanetypes = [laneType('Border')
    laneType('Border')];
laneSpecification = lanespec(2, 'Width', [0.635 2], 'Marking', marking, 'Type', lanetypes);
headings = [359.808818317323;359.808818317323;-0.191181682677566;-44.2675340767394;-88.34372093382;-88.34372093382];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-116.74519306094 4.55843141782567 0;
    -116.754522326611 4.8810694682526 0;
    -116.757521030267 4.98477494041928 0;
    -117.935679306974 7.07756779507302 0;
    -121.178122052156 8.04085338438883 0;
    -121.282088705509 8.04120029638966 0;
    -124.445943868024 8.05175732875271 0];
marking = [laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)];
laneSpecification = lanespec(1, 'Width', 3.5, 'Marking', marking);
headings = [91.65627906618;91.65627906618;91.65627906618;147.099246424331;179.808818317323;539.808818317322;539.808818317322];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-124.434265265283 11.5517378444468 0;
    -121.270187154803 11.5411800681592 0;
    -121.193247921908 11.5409233402339 0;
    -116.237738175549 10.3255820802206 0;
    -113.27411343994 5.60918914580803 0;
    -113.246655337661 4.65959365779562 0];
marking = [laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)];
laneSpecification = lanespec(1, 'Width', 3.5, 'Marking', marking);
headings = [359.808818317323;359.808818317323;359.808818317323;332.63150178494;271.65627906618;271.65627906618];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-106.448588681642 4.42418457379432 0;
    -109.999019563535 4.43603152182064 0;
    -109.770655547856 4.53191170266851 0;
    -109.680645842952 4.76270783551624 0];
marking = laneMarking('Unmarked');
lanetypes = [laneType('Border')
    laneType('Border')];
laneSpecification = lanespec(2, 'Width', [2 0.635], 'Marking', marking, 'Type', lanetypes);
headings = [179.808818317323;179.818367294071;225.732492821592;271.656279066181];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-106.436684848705 7.99166471371962 0;
    -109.020181626972 8.0002852281542 0;
    -109.077489922234 8.00047645230849 0;
    -112.167286864595 6.97005408890664 0;
    -113.248318522412 4.71711229906226 0;
    -113.246655337661 4.65959365779561 0];
marking = [laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)];
laneSpecification = lanespec(1, 'Width', 3.5, 'Marking', marking);
headings = [179.808818317323;179.808818317323;179.808818317322;217.077435599183;271.65627906618;271.65627906618];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-106.425006245964 11.4916452294137 0;
    -109.029873048474 11.5003370505377 0;
    -113.980852027183 10.2673675447521 0;
    -116.771045331184 5.45249171847876 0;
    -116.77042089393 5.43089653344343 0;
    -116.74519306094 4.55843141782567 0];
marking = [laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)
    laneMarking('Unmarked')];
laneSpecification = lanespec(1, 'Width', 3.5, 'Marking', marking);
headings = [179.808818317323;179.808818317323;-151.840377566631;-88.3437209338198;-88.34372093382;-88.34372093382];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-120.729114133783 18.9081350260002 0;
    -121.773076375849 16.2312806926248 0;
    -124.422207120546 15.1192174727033 0];
marking = laneMarking('Unmarked');
lanetypes = [laneType('Border')
    laneType('Border')];
laneSpecification = lanespec(2, 'Width', [0.635 2], 'Marking', marking, 'Type', lanetypes);
headings = [-88.34372093382;-134.26743059337;-180.188780739838];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-113.664566888277 19.1124104919967 0;
    -113.57311265703 15.9496090547635 0;
    -113.570978656998 15.8758080039224 0;
    -115.729722230915 10.3405149194707 0;
    -121.208011459851 8.04095311823509 0;
    -124.445943868024 8.05175732875251 0];
marking = [laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)];
laneSpecification = lanespec(1, 'Width', 3.5, 'Marking', marking);
headings = [-88.34372093382;271.65627906618;271.65627906618;225.732526176586;179.808818317323;179.808818317323];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

roadGroup(scenario, rg);

rg = driving.scenario.RoadGroup('Name', 'Roadgroup1');
Centers = [-4.41427115741671 18.4099073845579 0;
    -4.45541800595255 9.39892853348578 0;
    -4.49656485448839 0.387949682413622 0];
marking = [laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)];
lanetypes = [laneType('Shoulder')
    laneType('Driving')];
laneSpecification = lanespec(2, 'Width', [0.5 3.5], 'Marking', marking, 'Type', lanetypes);
headings = [-90.2616280001046;-90.2616280001046;-90.2616280001046];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-8.41422945584543 18.4281724011533 0;
    -8.45537630438127 9.41719355008112 0;
    -8.49652315291711 0.406214699008967 0];
marking = [laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)
    laneMarking('Unmarked')
    laneMarking('Unmarked')];
lanetypes = [laneType('Driving')
    laneType('Shoulder')];
laneSpecification = lanespec(2, 'Width', [3.5 0.5], 'Marking', marking, 'Type', lanetypes);
headings = [-90.2616280001046;-90.2616280001046;-90.2616280001046];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-15.4605806088932 11.1881185709515 0;
    -15.4384484631012 11.1880447212436 0;
    -12.4542133106432 11.1780870381432 0;
    -12.3525892009293 11.1777479426537 0;
    -6.95037576183174 8.91697931570484 0;
    -4.73237028844953 3.49706799700045 0;
    -4.74656224814026 0.389091245951295 0];
marking = [laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)];
laneSpecification = lanespec(1, 'Width', 3.5, 'Marking', marking);
headings = [359.808818317323;359.808818317323;359.808818317323;359.808818317323;314.773602909301;269.738371999895;269.738371999895];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-8.2465241627345 0.405422768714126 0;
    -8.24582781139454 0.557920649367686 0;
    -15.3194109551296 7.68762803697017 0;
    -15.4722592116347 7.68813805525725 0];
marking = laneMarking('Unmarked');
laneSpecification = lanespec(1, 'Width', 3.5, 'Marking', marking);
headings = [89.7383719998954;89.7383719998954;179.808818317323;179.808818317323];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-15.484162931416 4.12065791495438 0;
    -12.8823116995638 3.03184108867335 0;
    -11.8139875579036 0.421508649647735 0];
marking = laneMarking('Unmarked');
lanetypes = [laneType('Border')
    laneType('Border')];
laneSpecification = lanespec(2, 'Width', [0.635 2], 'Marking', marking, 'Type', lanetypes);
headings = [-0.191181682677464;-45.2252680188994;-90.2593543551213];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [2.57336847577027 14.6954634312263 0;
    -0.0284826533546567 15.7842804674204 0;
    -1.09680614207025 18.39461315884 0];
marking = laneMarking('Unmarked');
lanetypes = [laneType('Border')
    laneType('Border')];
laneSpecification = lanespec(2, 'Width', [0.635 2], 'Marking', marking, 'Type', lanetypes);
headings = [179.808818317322;134.774722502612;89.7406266879024];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [2.56146477131667 11.1279832908723 0;
    2.40861650962753 11.1284933091767 0;
    -4.66496649896309 18.2582014290158 0;
    -4.66427014759951 18.4106993148416 0];
marking = laneMarking('Unmarked');
laneSpecification = lanespec(1, 'Width', 3.5, 'Marking', marking);
headings = [179.808818317323;179.808818317323;89.7383719998954;89.7383719998954];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-8.16423206219363 18.4270308376161 0;
    -8.1643331260807 18.4048982908625 0;
    -8.17795891928274 15.420909510651 0;
    -8.17842881607893 15.3180041790553 0;
    -5.55993113297874 9.70732862242837 0;
    0.147568728858031 7.63601840356563 0;
    0.250474560419308 7.63567503127525 0;
    0.255943664838689 7.63565678217427 0;
    2.52765453428453 7.62807662317952 0;
    2.54978616857543 7.62800277517844 0];
marking = [laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)
    laneMarking('Unmarked')];
laneSpecification = lanespec(1, 'Width', 3.5, 'Marking', marking);
headings = [269.738371999895;269.738371999895;269.738371999895;269.738371999895;320.298474413783;359.808818317323;359.808818317323;359.808818317323;359.808818317323;359.808818317323];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [2.54895198266533 7.37800416691458 0;
    -6.46207070743967 7.40807180695407 0;
    -15.4730933975447 7.43813944699357 0];
marking = [laneMarking('Unmarked')
    laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)];
lanetypes = [laneType('Shoulder')
    laneType('Driving')];
laneSpecification = lanespec(2, 'Width', [0.5 3.5], 'Marking', marking, 'Type', lanetypes);
headings = [179.808818317323;179.808818317323;179.808818317323];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [2.56229895722689 11.3779818991364 0;
    -6.44872373287811 11.4080495391758 0;
    -15.4597464229831 11.4381171792153 0];
marking = [laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)
    laneMarking('Unmarked')
    laneMarking('Unmarked')];
lanetypes = [laneType('Driving')
    laneType('Shoulder')];
laneSpecification = lanespec(2, 'Width', [3.5 0.5], 'Marking', marking, 'Type', lanetypes);
headings = [179.808818317323;179.808818317323;179.808818317323];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [2.56146477131679 11.1279832908725 0;
    0.162253024837393 11.1359888899761 0;
    -5.56311632570211 9.10707048398687 0;
    -8.23231776216824 3.51656200798963 0;
    -8.23279890758852 3.41119327718063 0;
    -8.24652575926532 0.405073135471769 0];
marking = [laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)
    laneMarking('Unmarked')];
laneSpecification = lanespec(1, 'Width', 3.5, 'Marking', marking);
headings = [179.808818317323;179.808818317323;-140.782876613433;-90.2616280001046;-90.2616280001046;-90.2616280001046];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [2.54978616857543 7.62800277517844 0;
    2.52730667556605 7.62807778390118 0;
    2.37167644965687 7.62859708495865 0;
    -2.6482282150717 5.57068399055749 0;
    -4.74574895252726 0.567199408038554 0;
    -4.74656224814025 0.389091245951329 0];
marking = [laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)];
laneSpecification = lanespec(1, 'Width', 3.5, 'Marking', marking);
headings = [179.808818317323;179.808818317323;179.808818317323;224.773596965493;269.738371999895;269.738371999895];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [2.53788233563834 4.06052263525315 0;
    2.51560584260937 4.06059696376597 0;
    -0.0901477963352613 2.99230672855924 0;
    -1.1789983844296 0.394932019393636 0;
    -1.17909944072914 0.372801134275354 0];
marking = laneMarking('Unmarked');
lanetypes = [laneType('Border')
    laneType('Border')];
laneSpecification = lanespec(2, 'Width', [2 0.635], 'Marking', marking, 'Type', lanetypes);
headings = [179.808818317323;179.811071402176;224.773598354563;269.738371999895;269.738371999895];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-4.6642685510685 18.4110489480951 0;
    -4.67799646927678 15.404695240698 0;
    -4.67847120861254 15.3007294142367 0;
    -6.9428024779283 9.89933207912795 0;
    -12.361926194741 7.67775961356743 0;
    -15.4722592116347 7.68813805525725 0];
marking = [laneMarking('Unmarked')
    laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)];
laneSpecification = lanespec(1, 'Width', 3.5, 'Marking', marking);
headings = [-90.2616280001046;269.738371999895;269.738371999895;224.773583715515;179.808818317323;179.808818317323];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-8.16423206219363 18.4270308376161 0;
    -8.165045365568 18.2489209758377 0;
    -15.2824703902604 11.1875242595035 0;
    -15.4384484631011 11.1880447212436 0;
    -15.4605806088932 11.1881185709515 0];
marking = [laneMarking('DoubleSolid', 'Color', [0.98 0.86 0.36], 'Width', 0.125)
    laneMarking('Unmarked')];
laneSpecification = lanespec(1, 'Width', 3.5, 'Marking', marking);
headings = [-90.2616280001046;-90.2616280001046;179.808818317323;179.808818317323;179.808818317323];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

Centers = [-11.7316948696047 18.443320949292 0;
    -11.7317959334919 18.4211884025389 0;
    -12.8206465424505 15.8238143153978 0;
    -15.4265446301641 14.7555248611689 0;
    -15.4486767759561 14.7555987108768 0];
marking = laneMarking('Unmarked');
lanetypes = [laneType('Border')
    laneType('Border')];
laneSpecification = lanespec(2, 'Width', [0.635 2], 'Marking', marking, 'Type', lanetypes);
headings = [-90.2616280001046;-90.2616280001046;-135.226407405361;179.808818317323;179.808818317323];
road(rg, Centers, 'Lanes', laneSpecification, 'Heading', headings);

roadGroup(scenario, rg);

% Add the ego vehicle
egoVehicle = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [-136.2 8.6 0], ...
    'Mesh', driving.scenario.carMesh, ...
    'Name', 'car_058');
waypoints = [-136.2 8.6 0;
    -97.4 7.9 0;
    -49.2 7.8 0;
    -20 7.8 0;
    -10.9 5.4 0;
    -7.6 -0.2 0;
    -7.2 -11.1 0;
    -7.5 -24.7 0;
    -7.3 -45.6 0;
    -6.7 -63 0];
speed = [30;30;30;30;30;30;30;30;30;30];
trajectory(egoVehicle, waypoints, speed);

% Add the non-ego actors
pedestrian_001 = actor(scenario, ...
    'ClassID', 4, ...
    'Length', 0.24, ...
    'Width', 0.45, ...
    'Height', 1.7, ...
    'Position', [-19.1 -10.7 0], ...
    'RCSPattern', [-8 -8;-8 -8], ...
    'Mesh', driving.scenario.pedestrianMesh, ...
    'Name', 'pedestrian_001');
waypoints = [-19.1 -10.7 0;
    7.8 -4.1 0;
    10.5 6.3 0;
    9.4 21.4 0;
    8.1 32.7 0;
    7.5 38.6 0;
    7.5 44.3 0];
speed = [1.5;1.5;1.5;1.5;1.5;1.5;1.5];
trajectory(pedestrian_001, waypoints, speed);

truck_001 = vehicle(scenario, ...
    'ClassID', 2, ...
    'Length', 8.2, ...
    'Width', 2.5, ...
    'Height', 3.5, ...
    'Position', [123.9 11.2 0], ...
    'Mesh', driving.scenario.truckMesh, ...
    'Name', 'truck_001');
waypoints = [123.9 11.2 0;
    114.4 11.2 0;
    105 11.2 0;
    84.1 11.1 0;
    55.3 10.4 0;
    31.5 11.2 0;
    1.5 11.5 0;
    -1.6 15 0;
    -6.4 21.2 0;
    -6.8 34.3 0;
    -6.3 45.3 0;
    -6.5 61.4 0];
speed = [30;30;30;30;30;30;30;30;30;30;30;30];
trajectory(truck_001, waypoints, speed);

