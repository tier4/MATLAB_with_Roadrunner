try
    
%% D-case側の設定
    
    email = 'tier4.jp'; % ここに実際のメールアドレスを入力
    password = 'tier4'; % ここに実際のパスワードを入力
    
    % その他の必要な情報
    dcaseID = 'no58NkJvu366jusJSMypnstDt1_EOYr0J6Hrf8PSgsI_';
    partsID = 'Parts_fcx90cjb';
    userList = {'uaw_rebPBN_g9oDNrRmD0vs71jRfWeZ2HqZ_lu8idLE_'};

    dcase = dcaseCommunication(email,passwd,dcaseID,partsID,userList);
    
    % JSONファイルのパスを指定
    jsonFilePath = '/home/furuuchi/ドキュメント/GitHub/MATLAB_with_Roadrunner/D_Case.json'; % ここに実際のJSONファイルのパスを入力
    % jsonFilePath = '/home/matsulab/Matlab/MATLAB/codes/output2.json'
    

    % 作業プロジェクト
    rrproj = "/home/furuuchi/ドキュメント/GitHub/Roadrunner";
    % roadrunnerを起動
    rrApp=roadrunner(rrproj,InstallationFolder="/usr/local/RoadRunner_R2024b/bin/glnxa64");
    % シナリオ読み込み、変化に注意。
    scenarioFile="/home/furuuchi/ドキュメント/GitHub/Roadrunner/Scenarios/Testcase_pre.rrscenario";
    openScenario(rrApp,scenarioFile);
    rrSim=createSimulation(rrApp);

    dis = "InitDistance";
    egoInitSpeed = "EgoInitSpeed";
    egoTargetSpeed = "EgoTargetSpeed";
    egoAcc = "EgoAcceleration";
    actInitSpeed = "ActorInitSpeed";
    actDurationTime = "ActorDurationTime";
    actTargetSpeed = "ActorTargetSpeed";
    actAcc = "ActorAcceleration";
    
    value_dis = 110;
    value_egoInitSpeed = 0;
    value_egoTargetSpeed = 10;
    value_egoAcc = 0.98;
    value_actInitSpeed = 13.3;
    value_actDurationTime = 1;
    value_actTargetSpeed = 13.3;
    value_actAcc = 4;

    setScenarioVariable(rrApp,dis,value_dis);
    setScenarioVariable(rrApp,egoInitSpeed,value_egoInitSpeed);
    setScenarioVariable(rrApp,egoTargetSpeed,value_egoTargetSpeed);
    setScenarioVariable(rrApp,egoAcc,value_egoAcc);
    setScenarioVariable(rrApp,actInitSpeed,value_actInitSpeed);
    setScenarioVariable(rrApp,actDurationTime,value_actDurationTime);
    setScenarioVariable(rrApp,actTargetSpeed,value_actTargetSpeed);
    setScenarioVariable(rrApp,actAcc,value_actAcc);
    
    set(rrSim,"Logging","on");
        
    maxSimulationTimeSec = 8;
    maxSimulationTimes = 2;
    StepSize = 0.02;

    set(rrSim,'MaxSimulationTime',maxSimulationTimeSec);
    set(rrSim,'StepSize',StepSize);    

    for SimTimes = 1:maxSimulationTimes
        set(rrSim,"SimulationCommand","Start");
        
        ego = []; 
        act = []; 
        while isempty(ego) || isempty(act)
            try
                ego = Simulink.ScenarioSimulation.find("ActorSimulation", ActorID=uint64(1));
                act = Simulink.ScenarioSimulation.find("ActorSimulation", ActorID=uint64(2));
                pause(0.01);  
            catch
                pause(0.01);
            end
        end       
        previousData = struct('time', [], 'egoSpeed', [], 'actSpeed', []);  
        previousTime = 0;
        previousEgoSpeed = value_egoInitSpeed;
        previousActSpeed = value_actInitSpeed;
        
        while strcmp(get(rrSim,"SimulationStatus"),"Running")
            if ~isempty(ego) && ~isempty(act)
                % dataRealtime.time  = get(rrSim,"SimulationTime");
                % 
                % dataRealtime.egoVelocity = getAttribute(ego,"Velocity");
                % dataRealtime.actVelocity = getAttribute(act,"Velocity");
                % 
                % dataRealtime.egoSpeed = norm(dataRealtime.egoVelocity);
                % dataRealtime.actSpeed = norm(dataRealtime.actVelocity);
                % 
                % dataRealtime.egoAcc = (dataRealtime.egoSpeed - previousEgoSpeed) / (dataRealtime.time - previousTime);
                % dataRealtime.actAcc = (dataRealtime.actSpeed - previousActSpeed) / (dataRealtime.time - previousTime);
                
                % egoPos = getAttribute(ego,"Pose");
                % actPos = getAttribute(act,"Pose");
                % 
                % dataRealtime.dis = norm(egoPos(1:3, 4) - actPos(1:3, 4));
                % 
                % dataRealtime.isCollision = '-';
                % 
                % previousTime = dataRealtime.time;
                % previousEgoSpeed = dataRealtime.egoSpeed;
                % previousActSpeed = dataRealtime.actSpeed;
                % 
                % jsonDataRealtime = jsonencode(dataRealtime);
                % disp(jsonDataRealtime)
                % createJsonFile('realtime.json',jsonDataRealtime)
                previousData = CreateRealtimeStructs(get(rrSim,"SimulationTime"),getAttribute(ego,"Velocity"),getAttribute(act,"Velocity"), ...
                                                                  getAttribute(ego,"Pose"),getAttribute(act,"Pose"), ...
                                                                  '-',previousData);
                sendData = fileread('realtime.json');
                %disp("send")
                %disp(sendData)
                dcase.uploadEvalData(sendData);
            end
            
            pause(1);
        end
        
        simLog = get(rrSim,"SimulationLog");

        egoVelLog = get(simLog, 'Velocity','ActorID',1);
        actVelLog = get(simLog, 'Velocity','ActorID',2);

        egoPosLog = get(simLog,"Pose","ActorID",1);
        actPosLog = get(simLog,"Pose","ActorID",2);
        
        collisionMessages = false;
        diagnostics = get(simLog, "Diagnostics");
        if ~isempty(diagnostics)
            collisionMessages = contains(string(diagnostics.Message), 'Collision');
        end

        if collisionMessages
            isCollision = 'Success';
        else
            isCollision = 'Failed';
        end
        
        lastTime = length(egoVelLog);
        previousData = CreateRealtimeStructs(egoVelLog(lastTime).Time,egoVelLog(lastTime).Velocity,actVelLog(lastTime).Velocity, ...
                                                                  egoPosLog(lastTime).Pose,actPosLog(lastTime).Pose, ...
                                                                  isCollision,previousData);

        dataStruct = CreateLogStructs(egoVelLog,actVelLog,egoPosLog,actPosLog,collisionMessages,value_dis,sprintf('n%s', string(SimTimes)));
        jsonData = jsonencode(dataStruct);
        jsonData = formatJSON(jsonData);
       
        if SimTimes == 1
            createJsonFile('result.json',jsonData)
        else
            appendJsonText('result.json',jsonData);
        end
    end
        

catch ME
    disp(getReport(ME, 'extended'));
    %close(rrApp);
end
close(rrApp);

function previousData = CreateRealtimeStructs(time,egoV,actV,egoP,actP,isCollision,previousData)
                dataRealtime = struct('time', [], 'egoVelocity', [], 'egoSpeed', [] ,'egoAcc',[], 'actVelocity', [], 'actSpeed', [] ,'actAcc',[],'dis', [],'isCollision',[]);
                dataRealtime.time  = time;

                dataRealtime.egoVelocity = egoV;
                dataRealtime.actVelocity = actV;

                dataRealtime.egoSpeed = norm(dataRealtime.egoVelocity);
                dataRealtime.actSpeed = norm(dataRealtime.actVelocity);

                dataRealtime.egoAcc = (dataRealtime.egoSpeed - previousData.egoSpeed) / (dataRealtime.time - previousData.time);
                dataRealtime.actAcc = (dataRealtime.actSpeed - previousData.actSpeed) / (dataRealtime.time - previousData.time);
                
                egoPos = egoP;
                actPos = actP;
                
                dataRealtime.dis = norm(egoPos(1:3, 4) - actPos(1:3, 4));

                dataRealtime.isCollision = isCollision;
                
                previousData.time = dataRealtime.time;
                previousData.egoSpeed = dataRealtime.egoSpeed;
                previousData.atSpeed = dataRealtime.actSpeed;
    
                jsonDataRealtime = jsonencode(dataRealtime);
                %disp(jsonDataRealtime)
                createJsonFile('realtime.json',jsonDataRealtime)
end
function data = CreateLogStructs(egoV,actV,egoP,actP,isCollision,InitDis,fieldName)

    data = struct(   'isCollision', isCollision, ...
                     'InitDis', InitDis, ...
                     'SimulationTime', egoV(length(egoV)).Time ,...
                      fieldName, []);
  

    for i = 1:length(egoV)
        data.(fieldName)(i).time = egoV(i).Time*1000;

        data.(fieldName)(i).egoVelocity =egoV(i).Velocity;
        data.(fieldName)(i).egoSpeed = norm(egoV(i).Velocity);

        if i == 1
            data.(fieldName)(i).egoAcc = 0; 
        else
            data.(fieldName)(i).egoAcc = (data.(fieldName)(i).egoSpeed - data.(fieldName)(i - 1).egoSpeed) ...
               / (data.(fieldName)(i).time - data.(fieldName)(i - 1).time) * 1000;
        end

        data.(fieldName)(i).actVelocity =actV(i).Velocity;
        data.(fieldName)(i).actSpeed = norm(actV(i).Velocity);
        if i == 1
            data.(fieldName)(i).actAcc = 0; 
        else
            data.(fieldName)(i).actAcc = (data.(fieldName)(i).actSpeed - data.(fieldName)(i - 1).actSpeed) ...
               / (data.(fieldName)(i).time - data.(fieldName)(i - 1).time);
        end
        
        data.(fieldName)(i).dis = norm(egoP(i).Pose(1:3, 4) - actP(i).Pose(1:3, 4));

    end

end

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
