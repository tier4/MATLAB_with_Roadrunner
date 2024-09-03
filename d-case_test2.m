% APIエンドポイントURL
url = 'http://example.com/api/login.php';

% ユーザー認証情報
email = 'user@example.com';  % ここに実際のメールアドレスを入力
password = 'password123';    % ここに実際のパスワードを入力

% POSTデータの準備
postData = struct('mail', email, 'passwd', password);

% リクエストオプションの設定
options = weboptions('ContentType', 'json', 'RequestMethod', 'post');

try
    % POSTリクエストの送信
    response = webwrite(url, postData, options);
    
    % JSONレスポンスのパース
    responseData = jsondecode(response);
    
    % 結果の取得と表示
    if isfield(responseData, 'result') && isfield(responseData, 'authID')
        result = responseData.result;
        authID = responseData.authID;
        
        if strcmp(result, 'OK')
            fprintf('認証成功。認証キー: %s\n', authID);
        else
            fprintf('認証失敗。\n');
        end
        
        % レスポンスの詳細を表示（デバッグ用）
        fprintf('レスポンスの詳細:\n');
        disp(responseData);
    else
        error('予期しないレスポンス形式です。必要なフィールドが見つかりません。');
    end
    
catch ME
    if strcmp(ME.identifier, 'MATLAB:webservices:HTTP404StatusCodeError')
        fprintf('URLが見つかりません。URLを確認してください。\n');
    elseif strcmp(ME.identifier, 'MATLAB:webservices:JSONDecodingError')
        fprintf('JSONデコードエラー。レスポンスの内容:\n%s\n', ME.message);
    else
        fprintf('エラーが発生しました: %s\n', ME.message);
    end
end