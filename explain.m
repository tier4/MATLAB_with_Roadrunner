%% 作業プロジェクト
rrproj = "/home/matsulab/ROAD/New RoadRunner Project";

% roadrunnerを起動
rrApp=roadrunner(rrproj,InstallationFolder="/usr/local/RoadRunner_R2024a/bin/glnxa64");
% シナリオ読み込み
scenarioFile="/home/matsulab/ROAD/Roadrunner_Scenario/Scenarios/explain.rrscenario";
openScenario(rrApp,scenarioFile);
rrSim=rrApp.createSimulation();

maxSimulationTimeSec = 10;
set(rrSim,'MaxSimulationTime',maxSimulationTimeSec);

set(rrSim,"Logging","on");

set(rrSim,"SimulationCommand","Start");
while strcmp(get(rrSim,"SimulationStatus"),"Running")
    pause(1);
end

rrLog = get(rrSim,"SimulationLog");

velocityAgent1 = get(rrLog,'Velocity','ActorID',1);
velocityAgent2 = get(rrLog,'Velocity','ActorID',2);
time = [velocityAgent1.Time];

velMagAgent1 = arrayfun(@(x) norm(x.Velocity,2),velocityAgent1);
velMagAgent2 = arrayfun(@(x) norm(x.Velocity,2),velocityAgent2);

figure
hold on
plot(time,velMagAgent1,"r")
plot(time,velMagAgent2,"b")
grid on
title("Agent Velocities from RoadRunner Scenario")
ylabel("Velocity (m/sec)")
xlabel("Time (sec)")
legend("Actor ID = 1","Actor ID = 2")