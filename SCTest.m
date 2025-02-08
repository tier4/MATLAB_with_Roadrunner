try  
    email = 'tier4.jp'; % ログイン用メールアドレス
    password = 'tier4'; % ログイン用のパスワードを入力
    
    % その他の必要な情報
    dcaseID = 'no58NkJvu366jusJSMypnstDt1_EOYr0J6Hrf8PSgsI_';
    partsID = 'Parts_fcx90cjb';
    userList = {'uaw_rebPBN_g9oDNrRmD0vs71jRfWeZ2HqZ_lu8idLE_'};
		%　dcaseとの通信を確率
    dcase = dcaseCommunication(email,password,dcaseID,partsID,userList);
    
    csvName = 'reultsimple.csv';

    % 作業プロジェクト
    rrproj = "/home/furuuchi/ドキュメント/GitHub/Roadrunner";
    % roadrunnerを起動
    rrApp=roadrunner(rrproj,InstallationFolder="/usr/local/RoadRunner_R2024b/bin/glnxa64");
    % シナリオ読み込み、変化に注意。
    scenarioFile="/home/furuuchi/ドキュメント/GitHub/Roadrunner/Scenarios/Testcase_pre.rrscenario";
    %シナリオを指定してひらkう
    openScenario(rrApp,scenarioFile);
    rrSim=createSimulation(rrApp);

    dis = "InitDistance";%初期のegoとactの距離
    egoInitSpeed = "EgoInitSpeed";%egoの初期速度
    egoTargetSpeed = "EgoTargetSpeed";%egoの変更後速度
    egoAcc = "EgoAcceleration";%egoの加速度
    actInitSpeed = "ActorInitSpeed";%actorの初期速度
    actReactionTime = "ActorReactionTime";%actorの速度変更までの時間
    actTargetSpeed = "ActorTargetSpeed";%acotrの変更後速度
    actAcc = "ActorAcceleration";%actorの加速度
    % 
    % value_dis = 82.8;%初期のegoとactの距離
    % value_egoInitSpeed = 0;%egoの初期速度
    % value_egoTargetSpeed = 10;%egoの変更後速度
    % value_egoAcc = 1.6;%egoの加速度
    % value_actInitSpeed = 40;%actorの初期速度
    % value_actReactionTime = 1000;%actorの速度変更までの時間
    % value_actTargetSpeed = 40;%acotrの変更後速度
    % value_actAcc = 0;%actorの加速度

    %シミュレーションのログを取れるようにする
    set(rrSim,"Logging","on");
        
    maxSimulationTimeSec = 35;%シミュレーションの最大時間
    StepSize = 0.02;%何秒ごとにシミュレーションを行うか
    
		%上記2つのパラメータをシミュレーションに設定
    set(rrSim,'MaxSimulationTime',maxSimulationTimeSec);
    set(rrSim,'StepSize',StepSize);

		%シミュレーション回数を決定
    %maxSimulationTimes = 10;
    %シミュレーションで得るデータを格納するクラスを定義
    SimDatas = controlSimDatas(value_egoInitSpeed,value_actInitSpeed, 1);

    inputTable = readtable('inputTable.csv');

    for j = 1:height(inputTable)

        maxSimulationTimes = inputTable.times(j);
        value_dis = inputTable.InitDistance(j);%初期のegoとactの距離
        value_egoInitSpeed = inputTable.EgoInitSpeed(j);%egoの初期速度
        value_egoTargetSpeed = inputTable.EgoTargetSpeed(j);%egoの変更後速度
        value_egoAcc = inputTable.EgoAcceleration(j);%egoの加速度
        value_actInitSpeed = inputTable.ActorInitSpeed(j);%actorの初期速度
        value_actReactionTime = inputTable.ActorReactionTime(j);%actorの速度変更までの時間
        value_actTargetSpeed = inputTable.ActorTargetSpeed(j);%acotrの変更後速度
        value_actAcc = inputTable.ActorAcceleration(j);%actorの加速度   
        %上記の8つの値をシミュレーションに設定する
        setScenarioVariable(rrApp,dis,value_dis);
        setScenarioVariable(rrApp,egoInitSpeed,value_egoInitSpeed / 3.6);
        setScenarioVariable(rrApp,egoTargetSpeed,value_egoTargetSpeed / 3.6);
        setScenarioVariable(rrApp,egoAcc,value_egoAcc);
        setScenarioVariable(rrApp,actInitSpeed,value_actInitSpeed / 3.6);
        setScenarioVariable(rrApp,actReactionTime,value_actReactionTime);
        setScenarioVariable(rrApp,actTargetSpeed,value_actTargetSpeed / 3.6);
        setScenarioVariable(rrApp,actAcc,value_actAcc);

        for SimTimes = 1:maxSimulationTimes
		        %シミュレーション開始
            set(rrSim,"SimulationCommand","Start");
            
            SimDatas.isEgoCompleted = false;
            SimDatas.isActCompleted = false;
            %リアルタイムでegoとactorの情報を得るための変数
            ego = []; 
            act = []; 
            
            %egoとactorが取得するできるまで待機
            while isempty(ego) || isempty(act)
                try
                    ego = Simulink.ScenarioSimulation.find("ActorSimulation", ActorID=uint64(1));
                    act = Simulink.ScenarioSimulation.find("ActorSimulation", ActorID=uint64(2));
                    pause(0.01);  
                catch
                    pause(0.01);
                end
            end       
            
				    %シミュレーション実行中の処理
            while strcmp(get(rrSim,"SimulationStatus"),"Running")
                if ~isempty(ego) && ~isempty(act)%egoとacotorがシミュレーション中で削除されてないらなら
		                %リアルタイムでデータを取得し、構造体にする
                    SimDatas.CreateRealtimeStructs( get(rrSim,"SimulationTime"), ...
                                                    getAttribute(ego,"Velocity"),getAttribute(act,"Velocity"), ...
                                                    getAttribute(ego,"Pose"),getAttribute(act,"Pose"), ...
                                                    '-');
                    %構造体にしたデータをjsonにする
                    sendData = SimDatas.jsonDataRealtime;

                    %jsonにしたデータを保存する
                    createJsonFile('realtime.json',sendData)
                    %jsonデータをD-caseにアップロードする
                    dcase.uploadEvalData(sendData);
                end
                
                pause(1);
            end
            %以下はシミュレーション終了後の処理
            
            %ログデータの取得
            simLog = get(rrSim,"SimulationLog");
				    %ログからego、actorの速度取得
            egoVelLog = get(simLog, 'Velocity','ActorID',1);
            actVelLog = get(simLog, 'Velocity','ActorID',2);
				    %ログからego、actorの場所取得
            egoPosLog = get(simLog,"Pose","ActorID",1);
            actPosLog = get(simLog,"Pose","ActorID",2);
            %衝突判定の確認
            collisionMessages = false;%衝突判定
            diagnostics = get(simLog, "Diagnostics");%エラーメッセージがあれば取得
    
            if ~isempty(diagnostics)%エラーメッセージがあるなら
                collisionMessages = contains(string(diagnostics.Message), 'Collision');%メッセージ中にCollisionがあれば衝突がtrueになる
            end
    
            if collisionMessages
                isCollision = 'Failed';%衝突あり(失敗
            else
                isCollision = 'Success';%衝突なし(成功
            end
            
            lastTime = length(egoVelLog);%シミュレーションの最終時間
            %最終時間でのデータを取得し、D-caseに送信
		    SimDatas.CreateRealtimeStructs(  egoVelLog(lastTime).Time, ...
                                            egoVelLog(lastTime).Velocity,actVelLog(lastTime).Velocity, ...
                                            egoPosLog(lastTime).Pose,actPosLog(lastTime).Pose, ...
                                            isCollision);
    
		    %構造体にしたデータをjsonにする
		    sendData = SimDatas.jsonDataRealtime;
		    %jsonにしたデータを保存する
		    createJsonFile('realtime.json',sendData)
		    %jsonデータをD-caseにアップロードする
		    dcase.uploadEvalData(sendData);
    
		    %Logからシミュレーション結果をまとめたデータを作成
		    SimDatas.CreateLogStructs( egoVelLog,actVelLog, ...
                                            egoPosLog,actPosLog, ...
                                            isCollision,value_dis, ...
                                            sprintf('n%s', string(SimTimes)));
		    %保存するためのjsonデータを作る
            jsonData = jsonencode(SimDatas.dataLog);%データをjson形式にする
            jsonData = formatJSON(jsonData);%jsonデータを見やすく清書する
            
            SimDatas.createSimpleResultStruct(value_egoAcc,value_actInitSpeed,value_actAcc)
    
	          %結果を保存するresult.jsonを作成
            if SimTimes == 1 && j == 1%最初のシミュレーションなら
                createJsonFile('result.json',jsonData);%新しくjsonファイルを作る
                createJsonFile('resultSimple2.json',jsonencode(SimDatas.simpleResults));
    
            else%2回目以降のシミュレーションなら
                appendJsonText('result.json',jsonData);%1回目で作ったjsonファイルに追記する
                appendJsonText('resultSimple2.json',jsonencode(SimDatas.simpleResults));
    
            end
            T = struct2table(SimDatas.simpleResults);
            if isfile(csvName)
                
                writetable(T, csvName, 'WriteMode', 'append');
            else
                writetable(T, csvName);
            end
    
        end

    end

    % value_egoInitSpeed = value_egoInitSpeed / 3.6;%egoの初期速度
    % value_egoTargetSpeed = value_egoTargetSpeed / 3.6;%egoの変更後速度
    % value_actInitSpeed = value_actInitSpeed / 3.6;%actorの初期速度
    % value_actTargetSpeed = value_actTargetSpeed / 3.6;%acotrの変更後速度
    

    

		
		%1~maxSimulationTimesまでループさせる
    
        

catch ME%エラーが起きたら
    disp(getReport(ME, 'extended'));%エラーを表示
    %close(rrApp);
end
close(rrApp);%シミュレーションを閉じる

function formatedJson = formatJSON(jsonData)
    jsonText = strrep(jsonData, '{"time"',sprintf('\n\t\t{"time"'));
    
   % 文字列の最初と最後を見つける
    firstBracePos = find(jsonText == '{', 1, 'first');
    lastBracePos = find(jsonText == '}', 1, 'last');
    
    % 文字列を3つの部分に分割して改行を追加
    beforeFirst = jsonText(1:firstBracePos);
    middle = jsonText(firstBracePos+1:lastBracePos-1);
    afterLast = jsonText(lastBracePos:end);
    
    % 改行を追加して結合
    formatedJson = [beforeFirst sprintf('\n\t') middle newline afterLast];
end

function createJsonFile(filename,  jsonData)
    try
        % ファイルが存在するかチェック
        if exist(filename, 'file')
            disp("ファイルを上書きします")
        end
        
        % 新規ファイルの作成
        fid = fopen(filename, 'w');
        if fid == -1
            error('ファイルを作成できませんでした: %s', filename);
        end
        
        % 初期JSONの構造を作成
        try
            % JSON形式で書き込み
            fprintf(fid, '%s', jsonData);
            fprintf('新しいJSONファイルを作成しました: %s\n', filename);
            
        catch ME
            error('JSON形式が正しくありません: %s', ME.message);
        end
        
        % ファイルを閉じる
        fclose(fid);
        
    catch ME
        % エラーハンドリング
        if exist('fid', 'var') && fid ~= -1
            fclose(fid);
        end
        fprintf('エラーが発生しました: %s\n', ME.message);
        rethrow(ME);
    end
end
  
function appendJsonText(filename, jsonData)
    try
        % 既存のJSONファイルを読み込む
        fid = fopen(filename, 'r');
        if fid == -1
            error('ファイルを開けませんでした: %s', filename);
        end
        
        content = fscanf(fid, '%c', inf);
        fclose(fid);
        
        content = content(1:end-1);
        if length(content) > 2  % '{\n' より長い場合
            content = [content, ','];
        end
          
        % 新しいデータを整形
        newData = formatJSON(jsonData);
        % 最初の { と最後の } を除去
        newData = newData(2:end-1);
        
        % ファイルを書き込みモードで開く
        fid = fopen(filename, 'w');
        if fid == -1
            error('ファイルを開けませんでした: %s', filename);
        end
        
        % 結合したデータを書き込み
        fprintf(fid, '%s%s}', content, newData);
        fprintf('JSONファイルに追記しました: %s\n', filename);
        
        % ファイルを閉じる
        fclose(fid);
            
    catch ME
        if exist('fid', 'var') && fid ~= -1
            fclose(fid);
        end
        rethrow(ME);
    end
end
