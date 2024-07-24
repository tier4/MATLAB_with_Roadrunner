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

% 初期変数定義
bus="Bus_ChangeSpeed_TargetSpeed";
sedan="Sedan_initial_speed";

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

% シナリオを実行
rrSim.set('SimulationCommand','Start')
while strcmp(get(rrSim ,'SimulationStatus'),'Running')
    % とりあえず表示
    %　パラメータの取得
    Sedan_speed = getScenarioVariable(rrApp,sedan);
    Bus_speed = getScenarioVariable(rrApp,bus);
    % values = getAllScenarioVariables(rrApp);
    disp(Sedan_speed);
    disp(Bus_speed);
    pause(1);
end 


