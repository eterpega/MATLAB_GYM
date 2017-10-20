classdef HumanNMS < CommonGymGame
    methods
        function [this]= HumanNMS()
            this = this@CommonGymGame('osim');
        end
        
        function [] = runController(this, Controller)
            fprintf('Run controller once\n');
            % initialize variables
            done = false;
            total_reward = 0;
            prev_ob = this.Client.env_reset(this.InstanceId);
            action = Controller.getAction(prev_ob);
            while(~done)
                [ob, reward, done, info] = this.Client.env_step(this.InstanceId,action, this.IsRender);
                action = Controller.getAction(ob);
                total_reward = total_reward + reward;
                if(done)
                    fprintf('Game over, Total Reward: %d \n', total_reward);
                    break;
                end
            end
            this.cleanUp();
        end
        
        function [] = collectDataForSysID(this, Controller, input_idx)
            MaxExperiment = 1;
            MaxStep = 1000;
            sbuffer = zeros(Controller.NUM_STATES, MaxExperiment*MaxStep);
            abuffer = zeros(Controller.NUM_INPUT, MaxExperiment*MaxStep);
            curPointer = 1;
            
            for i = 1:MaxExperiment    
                % initialize variable for current episode
                prev_ob = this.Client.env_reset(this.InstanceId);
                action = Controller.sampleActionByIndex(input_idx);
                
                % save initial condition
                sbuffer(:,curPointer) = prev_ob;
                abuffer(:,curPointer) = action; %(input_idx);
                curPointer = curPointer + 1;
                
                % initialize parameters
                total_reward = 0;
                for j = 1:MaxStep
                    % go one step forward
                    [ob, reward, done, info] = this.Client.env_step(this.InstanceId,...
                        action, this.IsRender);
                    
                    % get next action
                    prev_ob = ob;
                    action = Controller.sampleActionByIndex(input_idx);
                    
                    % save actions and states
                    sbuffer(:,curPointer) = prev_ob;
                    abuffer(:,curPointer) = action; %(input_idx);
                    curPointer = curPointer + 1;
                    
                    % update total reward
                    total_reward = total_reward + reward;
                    if(done)
                        fprintf('Episode %d Game over, Total Reward: %f \n', i, total_reward);
                        fprintf('Number of steps: %d \n', j);
                        break;
                    end
                end
                
                if(~done)
                    this.Client.env_monitor_close(this.instance_id);
                    fprintf('Not ended, Total Reward: %f \n', this.TotalReward);
                end
            end
            
            keepIdx = find(all(sbuffer==0,1),1);
            sbuffer = sbuffer(:,1:(keepIdx-1));
            abuffer = abuffer(:,1:(keepIdx-1));
            save(sprintf('muscle_%d_%d.mat',numel(input_idx),sum(input_idx)), 'sbuffer', 'abuffer');
        end
    end
    
end