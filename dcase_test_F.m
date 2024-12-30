email = 'tier4.jp';
passwd = 'tier4';
dcaseID = "no58NkJvu366jusJSMypnstDt1_EOYr0J6Hrf8PSgsI_" ;
partsID = "Parts_fcx90cjb" ;
userList = [] ;
% JSON形式に対応する構造体配列
paramList = struct(...
    "n_1", struct(...
        "n", 1, ...
        "Time", 13, ...
        "Sedan", 0, ...
        "SUV", 13.315045357942582, ...
        "Bus", 1.9314290691777336 ...
    )...
);

% 構造体配列をJSON形式に変換
jsonString = jsonencode(paramList);

% 表示
createJsonFile('dc.json',jsonString)

% JSONファイルの内容を一気に読み込む
rawData = fileread('realtime.json');

% JSON文字列を構造体に変換



d = dcaseCommunication(email,passwd,dcaseID,partsID,userList);
d.uploadEvalData(rawData);

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