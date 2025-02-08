% CSVファイルを読み込む

%Names = string(T.Properties.VariableNames);

inputTable = readtable('inputTable.csv');

for j = 1:height(inputTable)
    simtimes = inputTable.times(j);
    value_dis = inputTable.InitDistance(j);%初期のegoとactの距離
    value_egoInitSpeed = inputTable.EgoInitSpeed(j);%egoの初期速度
    value_egoTargetSpeed = inputTable.EgoTargetSpeed(j);%egoの変更後速度
    value_egoAcc = inputTable.EgoAcceleration(j);%egoの加速度
    value_actInitSpeed = inputTable.ActorInitSpeed(j);%actorの初期速度
    value_actReactionTime = inputTable.ActorReactionTime(j);%actorの速度変更までの時間
    value_actTargetSpeed = inputTable.ActorTargetSpeed(j);%acotrの変更後速度
    value_actAcc = inputTable.ActorAcceleration(j);%actorの加速度
end
% 保存
% for j = 1:height(inputTable)
%     for i = 1:width(Names)
%             disp(inputTable.(Names(i))(j))       
%     end
% end
%writetable(T, 'simpleResult.csv');
% 
% dis = "InitDistance";%初期のegoとactの距離
% egoInitSpeed = "EgoInitSpeed";%egoの初期速度
% egoTargetSpeed = "EgoTargetSpeed";%egoの変更後速度
% egoAcc = "EgoAcceleration";%egoの加速度
% actInitSpeed = "ActorInitSpeed";%actorの初期速度
% actReactionTime = "ActorReactionTime";%actorの速度変更までの時間
% actTargetSpeed = "ActorTargetSpeed";%acotrの変更後速度
% actAcc = "ActorAcceleration";%actorの加速度
% 
% value_dis = 82.8;%初期のegoとactの距離
% value_egoInitSpeed = 0;%egoの初期速度
% value_egoTargetSpeed = 10;%egoの変更後速度
% value_egoAcc = 1.6;%egoの加速度
% value_actInitSpeed = 40;%actorの初期速度
% value_actReactionTime = 1000;%actorの速度変更までの時間
% value_actTargetSpeed = 40;%acotrの変更後速度
% value_actAcc = 0;%actorの加速度