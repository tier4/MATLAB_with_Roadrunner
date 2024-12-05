try
    % 作業プロジェクト
    rrproj = "/home/furuuchi/ドキュメント/GitHub/Roadrunner";
    % roadrunnerを起動
    rrApp=roadrunner(rrproj,InstallationFolder="/usr/local/RoadRunner_R2024b/bin/glnxa64");
    % シナリオ読み込み、変化に注意
    scenarioFile="/home/furuuchi/ドキュメント/GitHub/Roadrunner/Scenarios/Testcase_pre.rrscenario";
    openScenario(rrApp,scenarioFile);

    JsonFileName = "result.json";
    
    OncomingInitSpeed = "Oncoming_init_Speed";
    value_oc_s = 10;
    setScenarioVariable(rrApp,OncomingInitSpeed,value_oc_s);

    distance = "distance";
    value_dis = 0.0;
        
    scenario=createSimulation(rrApp);
    
    set(scenario,"Logging","on");
        
    maxSimulationTimeSec = 6;
    set(scenario,'MaxSimulationTime',maxSimulationTimeSec);

    

   a = uint64(2);
   disp(a)
        
    value_oc_s = value_oc_s + 1;
    setScenarioVariable(rrApp,OncomingInitSpeed,value_oc_s);
    
   
    value_dis = 110;
    setScenarioVariable(rrApp,distance,value_dis);

    set(scenario,"SimulationCommand","Start");
    pause(0.5);
    actor = Simulink.ScenarioSimulation.find("ActorSimulation",ActorID=a);
    while strcmp(get(scenario,"SimulationStatus"),"Running")
        
        velocity = getAttribute(actor,"Velocity");
        disp(ConverToFlaotVelocity(velocity))
        pause(0.01);
    end
        

catch ME
    disp('エラーが発生しました：');
    disp(ME.message);
    disp(ME.stack(1).line)
end
close(rrApp);


function FloatVelocity = ConverToFlaotVelocity(velocity)
    FloatVelocity = sqrt(velocity(1)^2 + velocity(2)^2 + velocity(3)^2);
end
