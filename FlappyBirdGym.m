classdef FlappyBirdGym < handle
    properties (Constant)
        BASE = 'http://127.0.0.1:5000';
        GAME = 'FlappyBird-v0';
        OUTDIR = '/tmp/random-matlab-agent-results';
        IS_RENDER = true;
        MAX_STEPS = 500;
        MAX_EPISODE = 50000;
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
            fprintf('Run controller \n');
            this.TotalReward = 0;
            obs = this.client.env_reset(this.instance_id);
            ob = nan;
            j = 1;
            while(j < this.MAX_STEPS)
                if(~isnan(ob))
                    action = Controller.get_action(ob);
                else
                    action = 1;
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
            end
        end
        
        function [] = train_controller(this, Controller)
            fprintf('Training controller \n');
            i = 1;
            while(i < this.MAX_EPISODE)
                j = 1;
                obs = this.client.env_reset(this.instance_id);
                prev_ob = nan;
                while(j < this.MAX_STEPS)
                    if(~isnan(prev_ob))
                        action = Controller.sample_action(prev_ob);
                    else
                        action = 1;
                    end
                    [ob, reward, done, ~] = this.client.env_step(this.instance_id,...
                        action, this.IS_RENDER);
                    train(Controller, action, prev_ob, reward, ob, done);
                    prev_ob = ob;
                    if(done)
                        break;
                    end
                end
            end
        end
        
        function [] = clean_up(this)
            fprintf('Test ended, Clean up \n');
            this.client.env_monitor_close(this.instance_id);
            this.client.upload(outdir);
        end
    end
    
end