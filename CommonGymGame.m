classdef CommonGymGame
    properties (Constant)
        BASE = 'http://127.0.0.1:5000';
        OUTDIR = '/tmp/gym_client_result';
    end
    
    properties
        IsRender = true;
        MaxStep = 1000;
        MaxEpisode = 10000;
    end
    
    properties
        GameName
        Client
        InstanceId
        Done
    end
    
    methods
        function [this]= CommonGymGame(game_name)
            % initialize game environment
            % game_name: game name for gym platform
            fprintf('Initialize environment\n');
            this.GameName = game_name;
            this.Client = GymHttpClient(this.BASE);
            this.InstanceId = this.Client.env_create(this.GameName);
            this.Client.env_monitor_start(this.InstanceId, this.OUTDIR, true);
        end
        
        function [] = testEnvironment(this)
            % test environment by randomly sampling the environment
            fprintf('Test game environment\n');
            % initialize variables
            done = false;
            prev_ob = this.Client.env_reset(this.InstanceId);
            total_reward = 0;
            action = this.Client.env_action_space_sample(this.InstanceId);
            while(~done)
                [ob, reward, done, info] = this.Client.env_step(this.InstanceId,action, this.IsRender);
                action = this.Client.env_action_space_sample(this.InstanceId);
                total_reward = total_reward + reward;
                if(done)
                    fprintf('Game over, Total Reward: %d \n', total_reward);
                    break;
                end
            end
            this.cleanUp();
        end
        
        function [] = runControllerOnce(this, Controller)
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
        
        function [] = trainController(this, Controller)
            fprintf('Training controller \n');
            for i = 1:this.MaxEpisode
                % initialize variable for current episode
                prev_ob = this.Client.env_reset(this.instance_id);
                action = Controller.sampleAction(prev_ob);
                
                total_reward = 0;
                for j = 1:this.MaxSteps
                    % go one step forward
                    [ob, reward, done, info] = this.Client.env_step(this.instance_id,...
                        action, this.IsRender);
                    
                    % update controller given action, previous states,
                    % reward, etc
                    updateOneIter(Controller, action, prev_ob, reward, ob, done, info);
                    
                    % get next action
                    prev_ob = ob;
                    action = Controller.sample_action(prev_ob);
                    
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
        end
        
        function [] = cleanUp(this)
            fprintf('Test ended, Clean up \n');
            this.Client.env_monitor_close(this.InstanceId);
        end
        
        function [] = delete(this)
            this.Client.shutdown_server();
        end
    end
end