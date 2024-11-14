%%　バスをワークスペースへ追加
Simulink.ActorSimulation.load( "BusActorPose" );
load(fullfile(matlabroot,'toolbox','driving','drivingdata','rrScenarioSimTypes.mat'));

%% 作業プロジェクト
rrproj = "/home/matsulab/ROAD/New RoadRunner Project";

% roadrunnerを起動
rrApp=roadrunner(rrproj,InstallationFolder="/usr/local/RoadRunner_R2024a/bin/glnxa64");

% シナリオ読み込み
scenarioFile="/home/matsulab/ROAD/New RoadRunner Project/Scenarios/CoSimu2.rrscenario";
openScenario(rrApp,scenarioFile);
rrSim=rrApp.createSimulation();

observer = addObserver(rrSim,"velThreshold","mySysObserver");

%% 変数設定

Suv = "Suv_speed";
suv_speed = 13.1;%48km/h
setScenarioVariable(rrApp,Suv,suv_speed)

%% シミュレーション設定
% シミュレーション時間の設定 
maxSimulationTimeSec = 15;
set(rrSim,'MaxSimulationTime',maxSimulationTimeSec);

Ts = 0.1;
rrSim.set('StepSize',Ts);

% シミュレーション結果のロギングをオン
set(rrSim,"Logging","on");

%シミュレーションスタート
for n=1:1
    % アクターのハンドルを取得
    set(rrSim,"SimulationCommand","Start");
            Simulink.ActorSimulation.load( "BusActorPose" );


    while strcmp(get(rrSim,"SimulationStatus"),"Running")

        % pause(1);
    end

end

close(rrApp);
