% APIエンドポイントURL
url = 'https://www.matsulab.org/dcase//api/login.php';

% ユーザー認証情報
email = 'tier4.jp';  % ここに実際のメールアドレスを入力
password = 'tier4';  % ここに実際のパスワードを入力

% POSTデータの準備
post_data = struct('mail', email, 'passwd', password);

try
    % Webオプションの設定
    options = weboptions('MediaType', 'application/x-www-form-urlencoded', 'RequestMethod', 'post');
    
    % POSTリクエストの送信
    response = webwrite(url, post_data, options);
    
    % JSONレスポンスのパース
    response_data = jsondecode(response);
    
    % 結果の取得と表示
    if isfield(response_data, 'result') && strcmp(response_data.result, 'OK')
        auth_id = response_data.authID;
        fprintf('認証成功。認証キー: %s\n', auth_id);
    else
        fprintf('認証失敗。\n');
    end
    
    % レスポンスの詳細を表示（デバッグ用）
    disp('レスポンスの詳細:');
    disp(response_data);
    
catch ME
    if strcmp(ME.identifier, 'MATLAB:webservices:HTTP404StatusCodeError')
        fprintf('リクエストエラーが発生しました: %s\n', ME.message);
    elseif strcmp(ME.identifier, 'MATLAB:webservices:JSONParseError')
        fprintf('JSONデコードエラー。レスポンスの内容:\n');
        disp(ME.message);
    else
        fprintf('予期しないエラーが発生しました: %s\n', ME.message);
    end
end
