classdef FlappyBirdGym < handle
    properties (Constant)
        BASE = 'http://127.0.0.1:5000';
        GAME = 'FlappyBird-v0';
        OUTDIR = '/tmp/random-matlab-agent-results';
        IS_RENDER = true;
        MAX_STEPS = 2000;
        MAX_EPISODE = 100000;
    end
    
    properties
        client
        instance_id
        TotalReward
        Done
    end
    
    methods
        function [this]= FlappyBirdGym()
            % To Do: Investigate running python script from Matlab
            %             commandStr = 'python gym_http_server.py';
            %             [status, commandOut] = system(commandStr);
            %             if status==0
            %                 fprintf('squared result is %d\n',str2num(commandOut));
            %             end
        end
        
        function [] = initialize(this)
            fprintf('Initialize environment\n');
            this.client = gym_http_client(this.BASE);
            this.instance_id = this.client.env_create(this.GAME);
            this.client.env_monitor_start(this.instance_id, this.OUTDIR, true);
        end
        
        function [] = run_controller(this, Controller)
            for i = 1:10
                fprintf('Run controller \n');
                this.TotalReward = 0;
                obs = this.client.env_reset(this.instance_id);
                ob = nan;
                j = 1;
                while(j < this.MAX_STEPS)
                    if(~isnan(ob))
                        action = Controller.get_action(ob);
                    else
                        action = Controller.get_action(obs);
                    end
                    [ob, reward, done, info] = this.client.env_step(this.instance_id,...
                        action, this.IS_RENDER);

                    % in case the image is needed for Q-learning
                    %tmp_data = load('tmp.mat');
                    %ob_img = tmp_data.obs_img;

                    this.TotalReward = this.TotalReward + reward;
                    if(done)
                        fprintf('Game over, Total Reward: %d \n', this.TotalReward);
                        break;
                    end
                    j = j + 1;
                end

                if(~done)
                    this.client.env_monitor_close(this.instance_id);
                end
            end
        end
        
        function [] = train_controller(this, Controller)
            fprintf('Training controller \n');
            i = 1;
            while(i < this.MAX_EPISODE)
                j = 1;
                obs = this.client.env_reset(this.instance_id);
                this.TotalReward = 0;
                prev_ob = nan;
                while(j < this.MAX_STEPS)
                    if(~isnan(prev_ob))
                        action = Controller.sample_action(prev_ob);
                    else
                        action = Controller.sample_action(obs);
                    end
                    [ob, reward, done, ~] = this.client.env_step(this.instance_id,...
                        action, this.IS_RENDER);
                    train(Controller, action, prev_ob, reward, ob, done);
                    prev_ob = ob;
                    this.TotalReward = this.TotalReward + reward;
                    if(done)
                        fprintf('Game over, Total Reward: %f \n', this.TotalReward);
                        fprintf('Number of steps: %d \n', j);
                        break;
                    end
                    j = j + 1;
                end
                
                if(~done)
                    this.client.env_monitor_close(this.instance_id);
                    fprintf('Not ended, Total Reward: %f \n', this.TotalReward);
                end
                
                fprintf('saving model at iteration: %d \n', Controller.cur_iter);
                Controller.cur_iter = Controller.cur_iter + 1;
                Controller.save_model();
            end
        end
        
        function [] = clean_up(this)
            fprintf('Test ended, Clean up \n');
            this.client.env_monitor_close(this.instance_id);
            this.client.upload(outdir);
        end
    end
    
end