% APIエンドポイントURL
url = 'https://www.matsulab.org/dcase//api/login.php';

% ユーザー認証情報
email = 'tier4.jp';  % ここに実際のメールアドレスを入力
password = 'tier4';    % ここに実際のパスワードを入力

% POSTデータの準備（URLエンコード）
postData = sprintf('mail=%s&passwd=%s', urlencode(email), urlencode(password));

% デバッグ情報の表示
fprintf('使用するURL: %s\n', url);
fprintf('POSTデータ: %s\n', postData);

try
    % Java HTTP クライアントを使用してリクエストを送信
    import java.net.*;
    import java.io.*;
    
    % URL オブジェクトの作成
    jUrl = URL(url);
    connection = jUrl.openConnection();
    connection.setRequestMethod('POST');
    connection.setRequestProperty('Content-Type', 'application/x-www-form-urlencoded');
    connection.setDoOutput(true);
    
    % POSTデータの送信
    outputStream = connection.getOutputStream();
    writer = OutputStreamWriter(outputStream);
    writer.write(postData);
    writer.flush();
    writer.close();
    outputStream.close();
    
    % レスポンスの読み取り
    inputStream = connection.getInputStream();
    reader = BufferedReader(InputStreamReader(inputStream));
    response = char(reader.readLine());
    while ~isempty(response)
        fprintf('レスポンス行: %s\n', response);
        response = char(reader.readLine());
    end
    reader.close();
    
    % レスポンスコードの取得
    responseCode = connection.getResponseCode();
    fprintf('レスポンスコード: %d\n', responseCode);
    
    % ヘッダー情報の取得
    headerFields = connection.getHeaderFields();
    headerKeys = headerFields.keySet().toArray();
    for i = 1:length(headerKeys)
        key = headerKeys(i);
        value = headerFields.get(key);
        if ~isempty(key)
            fprintf('ヘッダー: %s: %s\n', char(key), char(value.get(0)));
        end
    end
    
catch ME
    fprintf('エラーが発生しました: %s\n', ME.message);
    fprintf('エラー識別子: %s\n', ME.identifier);
    
    % スタックトレースの表示
    disp(getReport(ME, 'extended'));
end