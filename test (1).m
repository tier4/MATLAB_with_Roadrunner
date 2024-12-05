try
    % 作業プロジェクト
    rrproj = "/home/furuuchi/ドキュメント/GitHub/Roadrunner";
    % roadrunnerを起動
    rrApp=roadrunner(rrproj,InstallationFolder="/usr/local/RoadRunner_R2024b/bin/glnxa64");
    % シナリオ読み込み、変化に注意
    scenarioFile="/home/furuuchi/ドキュメント/GitHub/Roadrunner/Scenarios/Testcase_pre.rrscenario";
    openScenario(rrApp,scenarioFile);

    JsonFileName = "result.json";
    
    OncomingInitSpeed = "Oncoming_init_Speed";
    value_oc_s = 10;
    setScenarioVariable(rrApp,OncomingInitSpeed,value_oc_s);

    distance = "distance";
    value_dis = 0.0;
        
    scenario=createSimulation(rrApp);
    
    set(scenario,"Logging","on");
        
    maxSimulationTimeSec = 3;
    set(scenario,'MaxSimulationTime',maxSimulationTimeSec);
    

    for SimTimes = 1:10
        
        value_oc_s = value_oc_s + 1;
        setScenarioVariable(rrApp,OncomingInitSpeed,value_oc_s);
        
       
        value_dis = randi([0, 1100]) / 10;
        setScenarioVariable(rrApp,distance,value_dis);

        set(scenario,"SimulationCommand","Start");
        %SimTimes = SimTimes + 1;
          
        while strcmp(get(scenario,"SimulationStatus"),"Running")
            pause(1);
        end
        simLog = get(scenario,"SimulationLog");
        %velocity1 = get(simLog, 'Velocity','ActorID',1);
        velocity2 = get(simLog, 'Velocity','ActorID',2);
        
        collisionMessages = false;
        diagnostics = get(simLog, "Diagnostics");
        disp(diagnostics)
        if ~isempty(diagnostics)
            collisionMessages = contains(string(diagnostics.Message), 'Collision');
        end
        if collisionMessages
            disp('衝突が検出されました。');
            field = sprintf('%d回目:距離-%.4f：衝突あり,%.1fms', SimTimes,value_dis,velocity2(length(velocity2)).Time*1000);
        else
            field = sprintf('%d回目：距離-%.4f：衝突なし', SimTimes,value_dis);
        end
        json = convertToJson(velocity2,field);
        if SimTimes == 1
            createJsonFile(JsonFileName,"data",json);
        else
            appendJsonText(JsonFileName,json);
        end
    end
        

catch ME
    disp('エラーが発生しました：');
    disp(ME.message);
end
close(rrApp);

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