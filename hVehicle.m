classdef hVehicle < matlab.System
    % Copyright 2022 The MathWorks, Inc.
    properties (Access = private)
        mActorSimulationHdl;
        mScenarioSimulationHdl;
        mActor;
        mLastTime = 0;
        mJsonFilename = '/home/matsulab/Matlab/MATLAB/codes/test3.json'; % JSONファイル名
        mFileId; % ファイルハンドル
        mIsFirstEntry = true; % 最初のエントリかどうかを追跡
    end
    methods (Access=protected)
        function sz = getOutputSizeImpl(~)
            sz = [1 1];
        end
        function st = getSampleTimeImpl(obj)
            st = createSampleTime( ...
                obj, 'Type', 'Discrete', 'SampleTime', 0.02);
        end
        function t = getOutputDataTypeImpl(~)
            t = "double";
        end
        function setupImpl(obj)
            obj.mScenarioSimulationHdl = ...
                Simulink.ScenarioSimulation.find( ...
                'ScenarioSimulation', 'SystemObject', obj);
            obj.mActorSimulationHdl = Simulink.ScenarioSimulation.find( ...
                'ActorSimulation', 'SystemObject', obj);
            obj.mActor.pose = ...
                obj.mActorSimulationHdl.getAttribute('Pose');
            obj.mActor.velocity = ...
                obj.mActorSimulationHdl.getAttribute('Velocity');
            % JSONファイルを初期化
            obj.mFileId = fopen(obj.mJsonFilename, 'w');
            fprintf(obj.mFileId, '[\n');
            obj.mIsFirstEntry = true;
        end
        function stepImpl(obj, ~)
            currentTime = obj.getCurrentTime;
            elapsedTime = currentTime - obj.mLastTime;
            obj.mLastTime = currentTime;
            velocity = obj.mActor.velocity;
            pose = obj.mActor.pose;
            pose(1,4) = pose(1,4) + velocity(1) * elapsedTime; % x
            pose(2,4) = pose(2,4) + velocity(2) * elapsedTime; % y
            pose(3,4) = pose(3,4) + velocity(3) * elapsedTime; % z
            disp(pose(1,4));
            disp(pose(2,4));
            disp(pose(3,4));
            obj.mActor.pose = pose;
            obj.mActorSimulationHdl.setAttribute('Pose', pose);
            % JSONにposeデータとvelocityデータを書き込む
            obj.writePoseAndVelocityToJSON(pose, velocity, currentTime);
        end
        function releaseImpl(obj)
            % JSONファイルを閉じる
            if ~isempty(obj.mFileId) && obj.mFileId ~= -1
                fprintf(obj.mFileId, '\n]');
                fclose(obj.mFileId);
            end
        end
        function writePoseAndVelocityToJSON(obj, pose, velocity, currentTime)
            % poseデータ、velocityデータ、タイムスタンプを構造体に格納
            data = struct('timestamp', currentTime, ...
                          'pose', struct('x', pose(1,4), 'y', pose(2,4), 'z', pose(3,4)), ...
                          'velocity', struct('x', velocity(1), 'y', velocity(2), 'z', velocity(3)));
            % データをJSONに変換
            jsonStr = jsonencode(data);
            % ファイルに書き込む
            if ~obj.mIsFirstEntry
                fprintf(obj.mFileId, ',\n');
            else
                obj.mIsFirstEntry = false;
            end
            fprintf(obj.mFileId, '%s', jsonStr);
            % ファイルを閉じて再度開くことで、確実にディスクに書き込む
            fclose(obj.mFileId);
            obj.mFileId = fopen(obj.mJsonFilename, 'a');
        end
    end
end