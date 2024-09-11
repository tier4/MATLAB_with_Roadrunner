%% D-case側の設定
% ユーザー認証情報
email = 'tier4.jp'; % ここに実際のメールアドレスを入力
password = 'tier4'; % ここに実際のパスワードを入力
global authID;
global velocityData;
if isempty(velocityData)
    velocityData = table('Size', [0, 3], 'VariableTypes', {'double', 'double', 'double'}, ...
        'VariableNames', {'Time', 'Suv', 'Bus'});
end

% その他の必要な情報
dcaseID = 'jxlSYMp53SIn2BSJHo_5mnXt6Fb0iKKL_KRqfBJ3qao_';
partsID = 'Parts_f5r1y6mu';
userList = {'uaw_rebPBN_g9oDNrRmD0vs71jRfWeZ2HqZ_lu8idLE_'};

% JSONファイルのパスを指定
jsonFilePath = '/home/matsulab/Matlab/MATLAB/codes/D_Case.json'; % ここに実際のJSONファイルのパスを入力
% jsonFilePath = '/home/matsulab/Matlab/MATLAB/codes/output2.json'

% 認証処理を行う関数
function authID = authenticateUser(email, password)
    baseURL = 'https://www.matsulab.org/dcase/';
    loginUrl = [baseURL 'api/login.php'];
    
    postData = sprintf('mail=%s&passwd=%s', urlencode(email), urlencode(password));
    options = weboptions('RequestMethod', 'post', 'ContentType', 'text');
    response = webwrite(loginUrl, postData, options);
    
    authData = jsondecode(response);
    if isfield(authData, 'authID')
        authID = authData.authID;
        fprintf('認証成功。authID: %s\n', authID);
    else
        error('認証に失敗しました。');
    end
end

% 更新されたパラメータをアップロードする関数（簡略化版）
function uploadUpdatedParams(authID, dcaseID, partsID, userList, updatedParamsTable)
    baseURL = 'https://www.matsulab.org/dcase/';
    uploadUrl = [baseURL 'api/uploadEvalData.php'];
    
    % テーブルを指定された形式のJSONに変換
    jsonStruct = convertTableToCustomJSON(updatedParamsTable);
    
    uploadData = sprintf('authID=%s&dcaseID=%s&partsID=%s&userList=%s&paramList=%s', ...
        urlencode(authID), ...
        urlencode(dcaseID), ...
        urlencode(partsID), ...
        urlencode(jsonencode(userList)), ...
        urlencode(jsonencode(jsonStruct)));
    
    options = weboptions('RequestMethod', 'post', 'ContentType', 'text');
    response = webwrite(uploadUrl, uploadData, options);
    
    % fprintf('アップロード結果: %s\n', response);
end


%% 作業プロジェクト
rrproj = "/home/matsulab/ROAD/New RoadRunner Project";

% roadrunnerを起動
rrApp=roadrunner(rrproj,InstallationFolder="/usr/local/RoadRunner_R2024a/bin/glnxa64");

% シナリオ読み込み
scenarioFile="/home/matsulab/ROAD/New RoadRunner Project/Scenarios/New_shiojiri_5.rrscenario";
openScenario(rrApp,scenarioFile);
rrSim=rrApp.createSimulation();

%% 変数設定


%Suvの速度設定
%Suv=getScenarioVariable(rrApp,"Suv_speed");
Suv = "Suv_speed";
suv_speed = 13.1;%48km/h
% suv_speed = 16.6;%59.7km/h
setScenarioVariable(rrApp,Suv,suv_speed)

%Suvの減速設定
Suv_acc = "Suv_ChangeSpeed_TargetSpeed";
acc_speed = 8.3;
% acc_speed = 13.3;%時速48km/h
setScenarioVariable(rrApp,Suv_acc,acc_speed);


%バスの速度設定
%Bus=getScenarioVariable(rrApp,"Bus_speed");
Bus = "Bus_speed";
bus_speed = 0;
setScenarioVariable(rrApp,Bus,bus_speed)

%% シミュレーション設定
% シミュレーション時間の設定 
maxSimulationTimeSec = 14.5;
set(rrSim,'MaxSimulationTime',maxSimulationTimeSec);

Ts = 0.02;
rrSim.set('StepSize',Ts);

set(rrSim,'MaxSimulationTime',maxSimulationTimeSec);


% シミュレーション結果のロギングをオン
%set(rrSim,"Logging","on");

%% シミュレーション回数、バスの速度、バスの加速度、セダンの速度、セダンとバスの距離（シミュレーション開始時）、衝突判定
% テーブルとして保存
% simResults = table("回数", "シミュレーション実行時間","セダンの速度", "Suvの加速度", "バスの速度", "衝突判定");
simResults = table('Size', [0, 5], 'VariableTypes', {'double', 'double', 'double', 'double', 'string'}, ...
    'VariableNames', {'n', 'sim_runtime', 'suv_speed', 'bus_speed', 'status'});
simResults2 = table('Size', [0, 5], 'VariableTypes', {'double', 'double', 'double',  'double', 'string'}, ...
    'VariableNames', {'n', 'sim_runtime',  'suv_speed', 'bus_speed', 'status'});

%% テーブルをJSON形式で保存
function saveTableAsJSON(table, filename)
    % テーブルを構造体配列に変換
    structArray = table2struct(table);
    
    % 構造体配列をJSONテキストに変換
    jsonText = jsonencode(structArray);
    
    % JSONテキストをファイルに書き込む
    fid = fopen(filename, 'w');
    if fid == -1
        error('ファイルを開けませんでした');
    end
    fwrite(fid, jsonText, 'char');
    fclose(fid);
    
    % fprintf('テーブルが %s に保存されました。\n', filename);
end

%% テーブルを指定された形式のJSONに変換する関数
function jsonStruct = convertTableToCustomJSON(dataTable)
    jsonStruct = struct();
    for i = 1:height(dataTable)
        row = dataTable(i, :);
        key = sprintf('n_%d', row.n);
        jsonStruct.(key) = table2struct(row);
    end
end


%% 最新の行を指定された形式のJSONとして保存する関数
function saveLatestRowAsCustomJSON(dataTable, filename)
    % テーブルの最後の行（最新のデータ）を取得
    latestRow = dataTable(end, :);
    
    % 指定された形式のJSON構造を作成
    jsonStruct = struct();
    key = sprintf('n_%d', latestRow.n);
    jsonStruct.(key) = table2struct(latestRow);
    
    % JSONテキストに変換
    jsonText = jsonencode(jsonStruct);
    
    % JSONテキストをファイルに書き込む
    fid = fopen(filename, 'w');
    if fid == -1
        error('ファイルを開けませんでした');
    end
    fwrite(fid, jsonText, 'char');
    fclose(fid);
end

%% シミュレーション実行、結果をプロット
authID = authenticateUser(email, password);
allVelocityData = table('Size', [0, 4], 'VariableTypes', {'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'n', 'Time', 'SUV', 'Bus'});
%シミュレーションスタート
for n=1:1
    % アクターのハンドルを取得

    status = "-";
    sim_start_time = tic; % シミュレーション開始時間を記録
    pause(1);
    set(rrSim,"SimulationCommand","Start");

    m=1;

    while strcmp(get(rrSim,"SimulationStatus"),"Running")

        sim_runtime = toc(sim_start_time); % 現在のシミュレーション実行時間を計算
        %disp(sim_runtime)

        velocityAgent_Suv = get(log,'Velocity','ActorID',3);
        velocityAgent_Bus = get(log,'Velocity','ActorID',4);

        currentTime = velocityAgent_Suv(m);
        Time=currentTime.Time;
        currentSuv = velocityAgent_Suv(m);
        currentBus = velocityAgent_Bus(m);

        velocityTable = table(n,Time, currentSuv.Velocity, currentBus.Velocity, ...
            'VariableNames', {'n','Time', 'SUV', 'Bus'});

        % saveTableAsJSON(velocityTable, '/home/matsulab/Matlab/MATLAB/codes/output3.json');
        % allVelocityData{end+1} = table2struct(velocityTable);

        % Time=currentTime.Time;
        Suv_speed=currentSuv.Velocity;
        Bus_speed=currentBus.Velocity;

        Suv_km=abs(Suv_speed(2)*3.6);
        Bus_km=abs(Bus_speed(1)*3.6);

        velocityTable2 = table(n,round(Time,1), round(Suv_km,3), round(Bus_km,3), ...
            'VariableNames', {'n','Time', 'SUV', 'Bus'});
         % ダッシュボードを表示/更新
        
        saveLatestRowAsCustomJSON(velocityTable2, '/home/matsulab/Matlab/MATLAB/codes/D_Case.json');
        saveTableAsJSON(velocityTable2, '/home/matsulab/Matlab/MATLAB/codes/output3.json');

        uploadUpdatedParams(authID, dcaseID, partsID, userList, velocityTable2);
        pause(0.046);
                % 全データを蓄積
        allVelocityData = [allVelocityData; velocityTable2];
        m=m+1;
    end
    %% シミュレーション回数、バスの速度、バスの加速度、セダンの速度、セダンとバスの距離（シミュレーション開始時）、衝突判定
    % テーブルとして保存
    % log = get(rrSim,'SimulationLog');
    % mission = get(log,"Diagnostics");
    % if isnumeric(mission)
    %     status = "Success";
    % else
    %     status = "Collision";
    %     % fprintf('衝突発生: n = %d, bus_speed = %.2f, bus_acceleration = %.2f, sedan_speed = %.2f\n', n, bus_speed, bus_acceleration, sedan_speed);
    % end
    % disp(mission);

    jsonStr = jsonencode(allVelocityData);
    fid = fopen('/home/matsulab/Matlab/MATLAB/codes/all_velocity_data.json', 'w');
    if fid == -1
        error('ファイルを開けませんでした');
    end
    fwrite(fid, jsonStr, 'char');
    fclose(fid);

    % 全データをJSONとして保存
    saveTableAsJSON(allVelocityData, '/home/matsulab/Matlab/MATLAB/codes/all_velocity_data.json');

end