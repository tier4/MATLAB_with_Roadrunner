% 作業プロジェクト
rrproj = "/home/matsulab/ROAD/New RoadRunner Project";

% roadrunnerを起動
rrApp=roadrunner(rrproj,InstallationFolder="/usr/local/RoadRunner_R2024a/bin/glnxa64");

% シナリオ読み込み
scenarioFile="/home/matsulab/ROAD/New RoadRunner Project/Scenarios/New_shiojiri.rrscenario";
openScenario(rrApp,scenarioFile);
rrSim=rrApp.createSimulation();

% シミュレーション時間の設定
maxSimulationTimeSec = 10;
set(rrSim,'MaxSimulationTime',maxSimulationTimeSec);

% シミュレーション結果のロギングをオン
set(rrSim,"Logging","on");

% シミュレーションスタート
set(rrSim,"SimulationCommand","Start");
while strcmp(get(rrSim,"SimulationStatus"),"Running")
    pause(1);
end

log = get(rrSim,'SimulationLog');

mission = get(log,"Diagnostics");
disp(mission);
% disp(mission2);



% シミュレーション再実行
set(rrSim,"SimulationCommand","Start");
while strcmp(get(rrSim,"SimulationStatus"),"Running")
    pause(1);
end
openScenario(rrApp,scenarioFile);

