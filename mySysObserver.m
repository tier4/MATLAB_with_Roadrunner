classdef mySysObserver < matlab.System

    properties(Access=private)
         mScenarioSimObj;
         mScenarioSimActorList = [];
         velThreshold = 15;  % Set threshold velocity
         y = [];
    end

    methods(Access = protected)             
       
       function setupImpl(obj)
           obj.mScenarioSimObj = Simulink.ScenarioSimulation.find("ScenarioSimulation", ...
           "SystemObject", obj);
           obj.mScenarioSimActorList = obj.mScenarioSimObj.get("ActorSimulation");
           % Get list of all actors
       end

       function stepImpl(obj)
           count = 0;
           for i = 1:length(obj.mScenarioSimActorList)
               vel = norm(getAttribute(obj.mScenarioSimActorList{i},"Velocity"));
               if(vel > obj.velThreshold)
                 count = count + 1;  
                 % Number of vehicles driving above threshold velocity
                   in every time step 
               end 
           end
           obj.y = [obj.y,count]; 
           % Array with count value across all time steps                              
       end

       function releaseImpl(obj)
           assignin('base','NumberofVehiclesOverThreshold', obj.y);
           % Final array assigned to workspace variable
       end
    end
end