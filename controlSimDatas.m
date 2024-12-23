classdef controlSimDatas < handle
    properties
		dataRealtime = struct('time', [], 'egoVelocity', [], 'egoSpeed', [] ,'egoAcc',[], 'actVelocity', [], 'actSpeed', [] ,'actAcc',[],'dis', [],'isCollision',[]);
        previousData = struct('time', [], 'egoSpeed', [], 'actSpeed', []);
        jsonDataRealtime
             
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

        function obj = controlSimDatas(initEgoSpeed,initActSpeed)
           obj.previousData.time = 0;
            obj.previousData.egoSpeed = initEgoSpeed;
            obj.previousData.atSpeed = initActSpeed;
        end
        
        function CreateRealtimeStructs(obj,time,egoVel,actVel,egoPos,actPos,isCollision)
                obj.dataRealtime.time  = time;

                obj.dataRealtime.egoVelocity = egoVel;
                obj.dataRealtime.actVelocity = actVel;

                obj.dataRealtime.egoSpeed = norm(obj.dataRealtime.egoVelocity);
                obj.dataRealtime.actSpeed = norm(obj.dataRealtime.actVelocity);

                obj.dataRealtime.egoAcc = (obj.dataRealtime.egoSpeed - obj.previousData.egoSpeed) / (obj.dataRealtime.time - obj.previousData.time);
                obj.dataRealtime.actAcc = (obj.dataRealtime.actSpeed - obj.previousData.actSpeed) / (obj.dataRealtime.time - obj.previousData.time);
                              
                obj.dataRealtime.dis = norm(egoPos(1:3, 4) - actPos(1:3, 4));

                obj.dataRealtime.isCollision = isCollision;
                
                obj.previousData.time = obj.dataRealtime.time;
                obj.previousData.egoSpeed = obj.dataRealtime.egoSpeed;
                obj.previousData.atSpeed = obj.dataRealtime.actSpeed;
    
                obj.jsonDataRealtime = jsonencode(obj.dataRealtime);
                %disp(jsonDataRealtime)
%                createJsonFile('realtime.json',obj.jsonDataRealtime)
        end
        
        function CreateLogStructs(obj,egoVel,actVel,egoPos,actPos,isCollision,InitDis,fieldName)

            obj.dataLog = struct(   'isCollision', isCollision, ...
                             'InitDis', InitDis, ...
                             'SimulationTime', egoVel(length(egoVel)).Time ,...
                              fieldName, []);
          
        
            for i = 1:length(egoVel)
                obj.dataLog.(fieldName)(i).time = egoVel(i).Time*1000;
        
                obj.dataLog.(fieldName)(i).egoVelocity =egoVel(i).Velocity;
                obj.dataLog.(fieldName)(i).egoSpeed = norm(egoVel(i).Velocity);
        
                if i == 1
                    obj.dataLog.(fieldName)(i).egoAcc = 0; 
                else
                    obj.dataLog.(fieldName)(i).egoAcc = (obj.dataLog.(fieldName)(i).egoSpeed - obj.dataLog.(fieldName)(i - 1).egoSpeed) ...
                       / (obj.dataLog.(fieldName)(i).time - obj.dataLog.(fieldName)(i - 1).time) * 1000;
                end
        
                obj.dataLog.(fieldName)(i).actVelocity =actVel(i).Velocity;
                obj.dataLog.(fieldName)(i).actSpeed = norm(actVel(i).Velocity);
                if i == 1
                    obj.dataLog.(fieldName)(i).actAcc = 0; 
                else
                    obj.dataLog.(fieldName)(i).actAcc = (obj.dataLog.(fieldName)(i).actSpeed - obj.dataLog.(fieldName)(i - 1).actSpeed) ...
                       / (obj.dataLog.(fieldName)(i).time - obj.dataLog.(fieldName)(i - 1).time);
                end
                
                obj.dataLog.(fieldName)(i).dis = norm(egoPos(i).Pose(1:3, 4) - actPos(i).Pose(1:3, 4));

            end
        
        end


    end
end