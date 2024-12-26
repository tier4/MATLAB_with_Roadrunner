% CSVファイルを読み込む
T = readtable('simpleResult.csv');

% 削除前の行数を表示
disp(['削除前の行数: ' num2str(height(T))]);

% 82~91行目を削除
T(81,:) = [];

% 削除後の行数を表示
disp(['削除後の行数: ' num2str(height(T))]);

% 保存
writetable(T, 'simpleResult.csv');