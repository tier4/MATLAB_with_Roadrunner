%% D-case側の設定
% ユーザー認証情報
email = 'tier4.jp'; % ここに実際のメールアドレスを入力
password = 'tier4'; % ここに実際のパスワードを入力

% その他の必要な情報
dcaseID = 'jxlSYMp53SIn2BSJHo_5mnXt6Fb0iKKL_KRqfBJ3qao_';
partsID = 'Parts_qypn1wir';
userList = {'uaw_rebPBN_g9oDNrRmD0vs71jRfWeZ2HqZ_lu8idLE_'};

% JSONファイルのパスを指定
jsonFilePath = '/home/matsulab/Matlab/MATLAB/codes/D_Case.json'; % ここに実際のJSONファイルのパスを入力
% jsonFilePath = '/home/matsulab/Matlab/MATLAB/codes/output2.json'

%% D-Case送信処理
function uploadEvaluationData(email, password, jsonFilePath, dcaseID, partsID, userList)
% uploadEvaluationData - JSONファイルから評価データを読み込み、APIを通じてアップロードする関数
%
% 入力:
%   email - ユーザーの認証用メールアドレス
%   password - ユーザーの認証用パスワード
%   jsonFilePath - 評価データを含むJSONファイルのパス
%   dcaseID - D-Case ID
%   partsID - Parts ID
%   userList - ユーザーリスト（セル配列）

    % APIエンドポイントURL
    baseURL = 'https://www.matsulab.org/dcase/';
    loginUrl = [baseURL 'api/login.php'];
    uploadUrl = [baseURL 'api/uploadEvalData.php'];

    try
        % 認証リクエストの送信
        postData = sprintf('mail=%s&passwd=%s', urlencode(email), urlencode(password));
        options = weboptions('RequestMethod', 'post', 'ContentType', 'text');
        response = webwrite(loginUrl, postData, options);

        % レスポンスからauthIDを抽出
        authData = jsondecode(response);
        if isfield(authData, 'authID')
            authID = authData.authID;
            fprintf('認証成功。authID: %s\n', authID);
        else
            error('認証レスポンスにauthIDが含まれていません。');
        end

        % JSONファイルの読み込み
        if exist(jsonFilePath, 'file')
            fid = fopen(jsonFilePath, 'r');
            raw = fread(fid, inf);
            str = char(raw');
            fclose(fid);
            
            % JSONデータのデコード
            paramList = jsondecode(str);
        else
            error('指定されたJSONファイルが見つかりません: %s', jsonFilePath);
        end

        % デバッグ: paramListの内容を表示
        fprintf('送信するparamList:\n%s\n', jsonencode(paramList));

        % 評価データのアップロード
        uploadData = sprintf('authID=%s&dcaseID=%s&partsID=%s&userList=%s&paramList=%s', ...
            urlencode(authID), ...
            urlencode(dcaseID), ...
            urlencode(partsID), ...
            urlencode(jsonencode(userList)), ...
            urlencode(jsonencode(paramList)));

        % デバッグ: 送信するデータを表示
        fprintf('送信するデータ:\n%s\n', uploadData);

        options = weboptions('RequestMethod', 'post', 'ContentType', 'text');
        response = webwrite(uploadUrl, uploadData, options);

        % レスポンスの表示
        fprintf('アップロード結果: %s\n', response);

    catch ME
        fprintf('エラーが発生しました: %s\n', ME.message);
        fprintf('エラー識別子: %s\n', ME.identifier);
        disp(getReport(ME, 'extended'));
    end
end

%% 作業プロジェクト
rrproj = "/home/matsulab/ROAD/New RoadRunner Project";

% roadrunnerを起動
rrApp=roadrunner(rrproj,InstallationFolder="/usr/local/RoadRunner_R2024a/bin/glnxa64");

% シナリオ読み込み
scenarioFile="/home/matsulab/ROAD/New RoadRunner Project/Scenarios/New_shiojiri_2.rrscenario";
openScenario(rrApp,scenarioFile);
rrSim=rrApp.createSimulation();

%% 変数設定
% セダンの速度設定
Sedan = "Sedan_initial_speed";
sedan_speed = 11.1;
setScenarioVariable(rrApp,Sedan,sedan_speed)

% バスの速度設定
Bus_T = "Bus_ChangeSpeed_TargetSpeed";
bus_speed = 1.94;
setScenarioVariable(rrApp,Bus_T,bus_speed)

% バスの加速度設定
Bus_D = "Bus_ChangeSpeed_DynamicsValue";
bus_acceleration = 4;
setScenarioVariable(rrApp,Bus_D,bus_acceleration)

%% シミュレーション設定
% シミュレーション時間の設定 
maxSimulationTimeSec = 8;
set(rrSim,'MaxSimulationTime',maxSimulationTimeSec);

% シミュレーション結果のロギングをオン
set(rrSim,"Logging","on");

%% シミュレーション回数、バスの速度、バスの加速度、セダンの速度、セダンとバスの距離（シミュレーション開始時）、衝突判定
% テーブルとして保存
% simResults = table("回数", "バスの速度", "バスの加速度", "セダンの速度", "衝突判定");

% simResults = table('Size', [0, 5], 'VariableTypes', {'double', 'double', 'double', 'double', 'string'}, ...
%                    'VariableNames', {'n', 'bus_speed', 'bus_acceleration', 'sedan_speed', 'status'});
% simResults2 = table('Size', [0, 5], 'VariableTypes', {'double', 'double', 'double', 'double', 'string'}, ...
%                    'VariableNames', {'n', 'bus_speed', 'bus_acceleration', 'sedan_speed', 'status'});

simResults = table('Size', [0, 6], 'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'string'}, ...
    'VariableNames', {'n', 'sim_runtime',  'bus_speed', 'bus_acceleration', 'sedan_speed', 'status'});
simResults2 = table('Size', [0, 6], 'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'string'}, ...
    'VariableNames', {'n', 'sim_runtime',  'bus_speed', 'bus_acceleration', 'sedan_speed', 'status'});

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

%% 最新の結果のみを保存
function saveLatestTableRowAsJSONArray(table, filename)
    % テーブルの最後の行（最新のデータ）を取得
    latestRow = table(end, :);
    
    % 最新の行を構造体に変換
    latestStruct = table2struct(latestRow);
    
    % 空のオブジェクトと最新データを含む配列を作成
    dataArray = {struct(), latestStruct};
    
    % 配列をJSONテキストに変換
    jsonText = jsonencode(dataArray);
    
    % JSONテキストをファイルに書き込む
    fid = fopen(filename, 'w');
    if fid == -1
        error('ファイルを開けませんでした');
    end
    fwrite(fid, jsonText, 'char');
    fclose(fid);
end

%% シミュレーション実行、結果をプロット
%シミュレーションスタート
for n=1:10
    status = "-";
    sim_start_time = tic; % シミュレーション開始時間を記録
    set(rrSim,"SimulationCommand","Start");
    while strcmp(get(rrSim,"SimulationStatus"),"Running")

        sim_runtime = toc(sim_start_time); % 現在のシミュレーション実行時間を計算
   
        newRow = table(n, sim_runtime, bus_speed, bus_acceleration, sedan_speed, status, ...
            'VariableNames', {'n', 'sim_runtime', 'bus_speed', 'bus_acceleration', 'sedan_speed', 'status'});
        simResults2 = [simResults2; newRow];
        saveTableAsJSON(simResults2, '/home/matsulab/Matlab/MATLAB/codes/output2.json');
        saveLatestTableRowAsJSONArray(simResults2, '/home/matsulab/Matlab/MATLAB/codes/D_Case.json');
        uploadEvaluationData(email, password, jsonFilePath, dcaseID, partsID, userList);
        % pause(1);
    end
    %% シミュレーション回数、バスの速度、バスの加速度、セダンの速度、セダンとバスの距離（シミュレーション開始時）、衝突判定
    % テーブルとして保存
    log = get(rrSim,'SimulationLog');
    mission = get(log,"Diagnostics");
    if isnumeric(mission)
        status = "Success";
    else
        status = "Collision";
        % fprintf('衝突発生: n = %d, bus_speed = %.2f, bus_acceleration = %.2f, sedan_speed = %.2f\n', n, bus_speed, bus_acceleration, sedan_speed);
    end
    % disp(mission);

    newRow = table(n, sim_runtime, bus_speed, bus_acceleration, sedan_speed, status, ...
        'VariableNames', {'n', 'sim_runtime', 'bus_speed', 'bus_acceleration', 'sedan_speed', 'status'});
    simResults = [simResults; newRow];

    % テーブルを表示
    %disp(simResults2);

    % テーブルをjson形式で保存
    saveTableAsJSON(simResults, '/home/matsulab/Matlab/MATLAB/codes/output.json');
    

    % 速度を増加
    sedan_speed = sedan_speed + 1;
    setScenarioVariable(rrApp,Sedan,sedan_speed)
end