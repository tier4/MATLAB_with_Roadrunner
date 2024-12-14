classdef controlSimDatas < handle
    properties
		maxSimulationTimes
        dataRealtime = struct('time', [], 'dis', [], 'egoSpeed', [] , 'actSpeed', []);
        previousData = struct('time', [], 'egoSpeed', [], 'actSpeed', []);

        egoVel
        actVel
        
        egoPos
        actPos
        
        time
        dis
        
        egoSpeed
        actSpeed
        
        dataLog
        
        egoVelLog
        actVelLog
        
        egoPosLog
        actPosLog
        
        timeLog
        disLog
        
		isCollision       
    end
    methods

        function obj = controlSimDatas()
                % コンストラクタ
        end
        
        function setRealtimeData(time,egoVel,actVel,egoPos,actPos,isCollision)

        end

    end
end