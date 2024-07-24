
% 作業プロジェクト
rrproj = "/home/matsulab/ROAD/New RoadRunner Project";

% roadrunnerを起動
rrApp=roadrunner(rrproj);

%　シナリオ読み込み
scenarioFile="/home/matsulab/ROAD/New RoadRunner Project/Scenarios/New_shiojiri.rrscenario";
openScenario(rrApp,scenarioFile);
rrSim=rrApp.createSimulation();

% 繰り返しの回数を指定
numIterations = 10;  % 10回繰り返す

% 初期速度を設定
Sedan_initial_speed = 11.1;  % 初期速度 (m/s)
speed_increment = 0.1;  % 反復ごとの増加速度 (m/s)

% シナリオ実行に関する設定
Ts=0.01;
pace=1;
simTime=8;
rrSim.set('StepSize',Ts);
rrSim.set('SimulationPace',pace);
rrSim.set('MaxSimulationTime',simTime);
rrSim.set('Logging','On');

for i = 1:numIterations
    % シナリオを再読み込み
    openScenario(rrApp, scenarioFile);
    rrApp.setScenarioVariable('Sedan_initial_speed',Sedan_initial_speed + speed_increment);

    % シナリオ実行に関する設定
    Ts=0.01;
    pace=1;
    simTime=8;
    rrSim.set('StepSize',Ts);
    rrSim.set('SimulationPace',pace);
    rrSim.set('MaxSimulationTime',simTime);
    rrSim.set('Logging','On');


    % シナリオを実行
    rrSim.set('SimulationCommand','Start')
    while strcmp(get(rrSim ,'SimulationStatus'),'Running')
        pause(1);
    end 
    
    % シミュレーションの終了を待つ（終了条件を指定）
    while isRunning(rrApp)
        pause(1);  % 1秒ごとにチェック
    end
    
    % 3秒待機
    pause(3);
    
    % シミュレーションを停止（必要なら）
    stopScenario(rrApp);
    
    % シナリオのリセット（必要なら）
    rrApp.resetScenario();
    
    % セダンの速度を増加
    speed_increment = speed_increment * i;
end