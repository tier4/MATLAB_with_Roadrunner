%%ファイル設定

%パスの追加
addpath('/tmp/Examples/R2024a/driving/AddSensorsToRoadRunnerScenarioUsingMATLABExample');

% 作業プロジェクト
rrproj = "/home/matsulab/ROAD/New RoadRunner Project";

% roadrunnerを起動
rrApp=roadrunner(rrproj,InstallationFolder="/usr/local/RoadRunner_R2024a/bin/glnxa64");

% シナリオ読み込み、変化に注意
scenarioFile="/home/matsulab/ROAD/New RoadRunner Project/Scenarios/New_shiojiri_2.rrscenario";
openScenario(rrApp,scenarioFile);
rrSim=rrApp.createSimulation();

s = settings; 
% s.roadrunner.application.InstallationFolder.PersonalValue = rrInstallationPath; 



% copyfile("straightCurvedFourLaneRoad.rrscene",fullfile(rrProjectPath,"Scenes/"));
% copyfile("SensorDetectionSimulation.rrscenario",fullfile(rrProjectPath,"Scenarios/"))
% copyfile("SensorIntegration.rrbehavior.rrmeta",fullfile(rrProjectPath,"Assets","Behaviors/"))
% 
% openScenario(rrApp,"SensorDetectionSimulation")
% rrSim = createSimulation(rrApp);
% 
% simStepSize = 0.1;
% set(rrSim,"StepSize",simStepSize);
% 
% load("busDefinitionsForRRSim.mat")
% modelName = 'rrScenarioSimWithSensors';
% open_system(modelName)


% scenarioSim = createSimulation(rrApp);

% シミュレーション時間の設定
maxSimulationTimeSec = 8;
stepSize = 0.2;
set(rrSim,'MaxSimulationTime',maxSimulationTimeSec);

% シミュレーション結果のロギングをオン
set(rrSim,"Logging","on");

sensorSim = get(rrSim,"SensorSimulation");


visionSensor = visionDetectionGenerator(SensorIndex=1, ...
            SensorLocation=[2.4 0], MaxRange=120, ...
            DetectorOutput="Lanes and objects", ...
            UpdateInterval=stepSize);

radarSensor = drivingRadarDataGenerator(SensorIndex=2,...
    MountingLocation=[1.8 0 0.2], FieldOfView=[80 5],...
    AzimuthResolution=1,UpdateRate=1/stepSize);

lidarSensor = lidarPointCloudGenerator(SensorIndex=3,UpdateInterval=stepSize);

ShuttleBusID = 1;
addSensors(sensorSim,{visionSensor,radarSensor,lidarSensor},ShuttleBusID);

[visionDetPlotter,radarDetPlotter,pcPlotter,lbGTPlotter,lbDetPlotter,bepAxes] = helperSetupBEP(visionSensor,radarSensor);

simTime = 0.0;
set(rrSim,"SimulationCommand","Step");
pause(0.1)
legend(bepAxes,"show")

while ~isequal(get(rrSim,"SimulationStatus"),"Stopped")

    % Get ground truth target poses and lane boundaries from the sensor
    tgtPoses = targetPoses(sensorSim,1);
    gTruthLbs = laneBoundaries(sensorSim,1,OutputOption="EgoAdjacentLanes",inHostCoordinate=true);
    
    if ~isempty(gTruthLbs)
        
        % Get detections from vision and radar sensors
        [visionDets,numVisionDets,visionDetsValid,lbDets,numLbDets,lbDetsValid] = visionSensor(tgtPoses,gTruthLbs,simTime);
        [radarDets,numRadarDets,radarDetsValid] = radarSensor(tgtPoses,simTime);

        % Get point cloud from lidar sensor
        [ptCloud,ptCloudValid] = lidarSensor();

        % Plot ground-truth and detected lane boundaries
        helperPlotLaneBoundaries(lbGTPlotter,gTruthLbs)
       
        
        % Plot vision and radar detections
        if visionDetsValid
            detPos = cellfun(@(d)d.Measurement(1:2),visionDets,UniformOutput=false);
            detPos = vertcat(zeros(0,2),cell2mat(detPos')');
            plotDetection(visionDetPlotter,detPos)
        end

        if lbDetsValid
            plotLaneBoundary(lbDetPlotter,vertcat(lbDets.LaneBoundaries))
        end

        if radarDetsValid
            detPos = cellfun(@(d)d.Measurement(1:2),radarDets,UniformOutput=false);
            detPos = vertcat(zeros(0,2),cell2mat(detPos')');
            plotDetection(radarDetPlotter,detPos)
        end

        % Plot lidar point cloud
        if ptCloudValid
            plotPointCloud(pcPlotter,ptCloud);
        end
    end     

    if ~isequal(get(rrSim,"SimulationStatus"),"Stopped")
        set(rrSim,"SimulationCommand","Step");
    end

    simTime = simTime + stepSize;
    pause(0.5)
end