# import requests
# import json

# data = {'mail', 'tier4.jp', 'passwd', 'tier4'}
# response = requests.post('https://www.matsulab.org/dcase//api/login.php', data=data, auth=('username', 'password'))
# print(response.json())

import requests
import json

# APIエンドポイントURL
url = 'https://www.matsulab.org/dcase//api/login.php'

# ユーザー認証情報
email = 'tier4.jp'  # ここに実際のメールアドレスを入力
password = 'tier4'    # ここに実際のパスワードを入力

# POSTデータの準備
post_data = {
    'mail': email,
    'passwd': password
}

try:
    # POSTリクエストの送信
    response = requests.post(url, data=post_data)
    
    # レスポンスのステータスコードチェック
    response.raise_for_status()
    
    # JSONレスポンスのパース
    response_data = response.json()
    
    # 結果の取得と表示
    result = response_data.get('result')
    auth_id = response_data.get('authID')
    
    if result == 'OK':
        print(f"認証成功。認証キー: {auth_id}")
    else:
        print("認証失敗。")
    
    # レスポンスの詳細を表示（デバッグ用）
    print("レスポンスの詳細:")
    print(json.dumps(response_data, indent=2, ensure_ascii=False))

except requests.exceptions.RequestException as e:
    print(f"リクエストエラーが発生しました: {e}")
except json.JSONDecodeError:
    print("JSONデコードエラー。レスポンスの内容:")
    print(response.text)
except KeyError as e:
    print(f"予期しないレスポンス形式です。キーが見つかりません: {e}")
except Exception as e:
    print(f"予期しないエラーが発生しました: {e}")