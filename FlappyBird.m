classdef FlappyBird < CommonGymGame
    methods
        function [this]= FlappyBird()
            this = this@CommonGymGame('FlappyBird-v0');
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
                
                % in case the image is needed for Q-learning
%                 tmp_data = load('tmp.mat');
%                 ob_img = tmp_data.obs_img;
                
                action = Controller.getAction(ob);
                total_reward = total_reward + reward;
                if(done)
                    fprintf('Game over, Total Reward: %d \n', total_reward);
                    break;
                end
            end
            this.cleanUp();
        end
    end
    
end