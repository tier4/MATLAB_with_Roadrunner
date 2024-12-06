try
    % 作業プロジェクト
    rrproj = "/home/furuuchi/ドキュメント/GitHub/Roadrunner";
    % roadrunnerを起動
    rrApp=roadrunner(rrproj,InstallationFolder="/usr/local/RoadRunner_R2024b/bin/glnxa64");
    % シナリオ読み込み、変化に注意。
    scenarioFile="/home/furuuchi/ドキュメント/GitHub/Roadrunner/Scenarios/Testcase_pre.rrscenario";
    openScenario(rrApp,scenarioFile);
    rrSim=createSimulation(rrApp);

    dis = "InitDistance";
    EgoInitSpeed = "EgoInitSpeed";
    EgoTargetSpeed = "EgoTargetSpeed";
    EgoAcc = "EgoAcceleration";
    ActInitSpeed = "ActorInitSpeed";
    ActDurationTime = "ActorDurationTime";
    ActTargetSpeed = "ActorTargetSpeed";
    ActAcc = "ActorAcceleration";

    value_dis = 110;
    value_EgoInitSpeed = 0;
    value_EgoTargetSpeed = 10;
    value_EgoAcc = 0.98;
    value_ActInitSpeed = 13.3;
    value_ActDurationTime = 1;
    value_ActTargetSpeed = 13.3;
    value_ActAcc = 4;

    setScenarioVariable(rrApp,dis,value_dis);
    setScenarioVariable(rrApp,EgoInitSpeed,value_EgoInitSpeed);
    setScenarioVariable(rrApp,EgoTargetSpeed,value_EgoTargetSpeed);
    setScenarioVariable(rrApp,EgoAcc,value_EgoAcc);
    setScenarioVariable(rrApp,ActInitSpeed,value_ActInitSpeed);
    setScenarioVariable(rrApp,ActDurationTime,value_ActDurationTime);
    setScenarioVariable(rrApp,ActTargetSpeed,value_ActTargetSpeed);
    setScenarioVariable(rrApp,ActAcc,value_ActAcc);
    
    set(rrSim,"Logging","on");
        
    maxSimulationTimeSec = 8;
    set(rrSim,'MaxSimulationTime',maxSimulationTimeSec);
    

    for SimTimes = 1:2
        set(rrSim,"SimulationCommand","Start");
        pause(0.5);
        Ego = Simulink.ScenarioSimulation.find("ActorSimulation",ActorID=uint64(1));
        Onc = Simulink.ScenarioSimulation.find("ActorSimulation",ActorID=uint64(2));
          
        while strcmp(get(rrSim,"SimulationStatus"),"Running")
            %EgoVelocity = getAttribute(Ego,"Velocity");
            %OncVelocity = getAttribute(Onc,"Velocity");

            pause(0.01);
            pause(1);
        end
        simLog = get(rrSim,"SimulationLog");

        EgoVel = get(simLog, 'Velocity','ActorID',1);
        ActVel = get(simLog, 'Velocity','ActorID',2);

        EgoPos = get(simLog,"Pose","ActorID",1);
        ActPos = get(simLog,"Pose","ActorID",2);
        
        collisionMessages = false;
        diagnostics = get(simLog, "Diagnostics");
        if ~isempty(diagnostics)
            collisionMessages = contains(string(diagnostics.Message), 'Collision');
        end

        if collisionMessages
            disp('衝突が検出されました。');
            %field = sprintf('回数%d_距離%.4f_衝突%s', SimTimes, value_dis, 'False');

% 例えば SimTimes = 1, value_dis = 1.2345 の場合：
% "回数1_距離1.2345_衝突False" となります
        else
           %field = sprintf('回数%d_距離%.4f_衝突%s', SimTimes, value_dis, 'False');

        end


        %json = convertToJson(velocity2,field);
        e = CreateStructs(EgoVel,ActVel,EgoPos,ActPos,collisionMessages,value_dis,sprintf('n%s', string(SimTimes)));
        % if SimTimes == 1
        %     createJsonFile(JsonFileName,"data",json);
        % else
        %     appendJsonText(JsonFileName,json);
        % end
    end
        

catch ME
    disp(getReport(ME, 'extended'));
    %close(rrApp);
end
close(rrApp);
function data = CreateStructs(EgoV,ActV,EgoP,ActP,isCollision,InitDis,FieldName)
    data = struct(FieldName, []);
    data.isCollision = isCollision;
    data.InitDis = InitDis;
    data.SimulationTime = EgoV(length(EgoV)).Time;

    for i = 1:length(EgoV)
        data.(FieldName)(i).time = EgoV(i).Time*1000;

        data.(FieldName)(i).EgoVelocity =EgoV(i).Velocity;
        data.(FieldName)(i).EgoSpeed = norm(EgoV(i).Velocity);
        if i == 1
            data.(FieldName)(i).EgoAcc = 0;
        else
            data.(FieldName)(i).EgoAcc = (data.(FieldName)(i).EgoSpeed - data.(FieldName)(i - 1).EgoSpeed) ...
               / (data.(FieldName)(i).time - data.(FieldName)(i - 1).time) * 1000;
        end

        data.(FieldName)(i).ActVelocity =ActV(i).Velocity;
        data.(FieldName)(i).ActSpeed = norm(ActV(i).Velocity);
        if i == 1
            data.(FieldName)(i).ActAcc = 0;
        else
            data.(FieldName)(i).ActAcc = (data.(FieldName)(i).ActSpeed - data.(FieldName)(i - 1).ActSpeed) ...
               / (data.(FieldName)(i).time - data.(FieldName)(i - 1).time);
        end
        
        data.(FieldName)(i).dis = norm(EgoP(i).Pose(1:3, 4) - ActP(i).Pose(1:3, 4));

    end

end

function Acc =  VelocityToAcceleration(velocity)
    acc = zeros(size(velocity)-1);
    
    % n-1番目とn番目の差を計算してn番目の値とする
    for i = 2:length(velocity)
        acc(i-1) = velocity(i) - velocity(i-1);
    end
end

function createJsonFile(filename, fieldName, jsonData)
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
            initialJson = sprintf('{\n"%s":%s\n}', fieldName, jsonData);
            fprintf(fid, '%s', initialJson);
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
  
function appendJsonText(filename, newJsonText)
    try
        % 既存のJSONファイルを読み込む
        fid = fopen(filename, 'r');
        if fid == -1
            error('ファイルを開けませんでした: %s', filename);
        end
        
        % ファイルを1行ずつ読み込む
        lines = {};
        while ~feof(fid)
            lines{end+1} = fgets(fid);
        end
        fclose(fid);
        
        % 最後の閉じ括弧を見つける
        found = false;
        for i = length(lines):-1:1
            if contains(lines{i}, ']')
                % 閉じ括弧の前にカンマを追加
                lines{i} = strrep(lines{i}, ']', sprintf(',\n    %s\n]', newJsonText));
                found = true;
                break;
            end
        end
        
        if ~found
            error('JSONファイルの形式が正しくありません');
        end
        
        % 更新したJSONを書き込む
        fid = fopen(filename, 'w');
        if fid == -1
            error('ファイルを書き込めませんでした: %s', filename);
        end
        
        % 各行を書き込む
        for i = 1:length(lines)
            fprintf(fid, '%s', lines{i});
        end
        
        fclose(fid);
        fprintf('JSONファイルが更新されました: %s\n', filename);
        
    catch ME
        if exist('fid', 'var') && fid ~= -1
            fclose(fid);
        end
        rethrow(ME);
    end
end

function FloatVelocity = ConverToFlaotVelocity(velocity)
    FloatVelocity = sqrt(velocity(1)^2 + velocity(2)^2 + velocity(3)^2);
end 

function jsonText = convertToJson(structArray,fieldName)
    % 構造体配列をJSONに変換する関数
    % 入力: Time と Velocity フィールドを持つ 1×50 の構造体配列
    % 出力: 整形されたJSON文字列
    
    % 新しい構造体を作成して配列データを格納
    data = struct('data', []);
    
    % 各要素のTimeとVelocityを配列に変換
    for i = 1:length(structArray)
        data.data(i).time = structArray(i).Time*1000;
        data.data(i).velocity = ConverToFlaotVelocity(structArray(i).Velocity);
    end
    
    % JSONにエンコード
    jsonText = jsonencode(data);
  
    jsonText = strrep(jsonText, '"data":', ['"' fieldName '":']);
    % JSON文字列を整形（可読性向上のため）
    jsonText = strrep(jsonText, ',"', sprintf(',\n\t"'));
    jsonText = strrep(jsonText, '{', sprintf('{\n\t'));
    jsonText = strrep(jsonText, '}', sprintf('\n}'));
    jsonText = strrep(jsonText, '[{', sprintf('[\n    {'));
    jsonText = strrep(jsonText, '}]', sprintf('    }\n]'));
    
    
    % 配列要素間に改行を追加
    jsonText = regexprep(jsonText, '(\}\,)(\{)', '    $1\n    $2');
    %disp(jsonText)
end


%テーブルをJSON形式で保存                  
function saveTableAsJSON(table, filename)      
	% テーブルを構造体配列に変換
	structArray = table2struct(table);    
	% 構造体配列をJSONテキストに変換
	jsonText = jsonencode(structArray, 'PrettyPrint', true);

	% JSONテキストをファイルに書き込む
	fid = fopen(filename, 'w');
	if fid == -1
		error('ファイルを開けませんでした');
	end
	fwrite(fid, jsonText, 'char');
	fclose(fid);
	
	fprintf('テーブルが %s に保存されました。\n', filename);
end