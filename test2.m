% sltest.testmanager.view
function [result, authID] = userAuthentication(email, password)
    % APIエンドポイントURL
    url = 'https://www.matsulab.org/dcase//api/login.php';
    
    % POSTデータの準備（構造体として）
    postData = struct('mail', email, 'passwd', password);
    
    % リクエストオプションの設定
    options = weboptions('ContentType', 'json', ...  % JSONとして送信
                         'RequestMethod', 'post');
    
    try
        % POSTリクエストの送信
        response = webwrite(url, postData, options);
        
        % レスポンスの確認と処理
        if isempty(response)
            error('空の応答を受信しました。');
        end
        
        % JSONレスポンスのパース
        try
            responseData = jsondecode(response);
        catch jsonException
            fprintf('JSONデコードエラー。応答内容:\n%s\n', response);
            rethrow(jsonException);
        end
        
        % 結果の取得
        if isfield(responseData, 'result') && isfield(responseData, 'authID')
            result = responseData.result;
            authID = responseData.authID;
        else
            error('応答に必要なフィールドが含まれていません。');
        end
    catch exception
        % エラーハンドリング
        fprintf('エラーが発生しました: %s\n', exception.message);
        result = 'NG';
        authID = '';
    end
end


[result, authID] = userAuthentication('tier4.jp', 'tier4');