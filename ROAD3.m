% 作業プロジェクト
rrproj = "/home/matsulab/ROAD/New RoadRunner Project";

% roadrunnerを起動
rrApp=roadrunner(rrproj,InstallationFolder="/usr/local/RoadRunner_R2024a/bin/glnxa64");

%　シナリオ読み込み
scenarioFile="/home/matsulab/ROAD/New RoadRunner Project/Scenarios/New_shiojiri.rrscenario";
openScenario(rrApp,scenarioFile);
rrSim=rrApp.createSimulation();

%シミュレーション時間の設定
maxSimulationTimeSec = 10;
set(rrSim,'MaxSimulationTime',maxSimulationTimeSec);

%シミュレーション結果のロギングをオン
set(rrSim,"Logging","on");

%シミュレーションスタート
set(rrSim,"SimulationCommand","Start");
while strcmp(get(rrSim,"SimulationStatus"),"Running")
    pause(1);
end

%シナリオからログ結果を取得
rrLog = get(rrSim,"SimulationLog");


%アクターIDから速度を取得
velocity_Bus = get(rrLog,'Velocity','ActorID',1);
velocity_sedan = get(rrLog,'Velocity','ActorID',2);
time = [velocity_Bus.Time];
disp(velocity_sedan);

%ベクトル表現をしているらしい
velMagAgent1 = arrayfun(@(x) norm(x.Velocity,2),velocity_Bus);
velMagAgent2 = arrayfun(@(x) norm(x.Velocity,2),velocity_sedan);

%プロット化
figure
hold on
plot(time,velMagAgent1,"r")
plot(time,velMagAgent2,"b")
grid on
title("Agent Velocities from RoadRunner Scenario")
ylabel("Velocity (m/sec)")
xlabel("Time (sec)")
legend("Actor ID = 1","Actor ID = 2")