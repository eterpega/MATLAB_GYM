classdef RlController < handle
    % TO DO: investigate algorithm convergence and tune hyper-parameters
    properties (Constant)
        MODEL_TYPE = 'rl';
        ALPHA = 0.1;    % Learning Rate
        GAMMA = 0.1;    % Discount Factor
        EPSILON = 0.1; % Exploration Rate
        WIDTH = 288;
        HEIGHT = 512;
        SUPERVISE_ITER = 100;
    end
    
    properties
        % screen width, screen height, 2 action
        q_table = zeros(288, 512, 2);
        cur_iter = 0;
        supervisor
    end
    
    methods
        function [this] = RlController()
            this.supervisor = SimpleController()
        end
        
        function [action] = get_action(this, obs)
            % TO DO: Based on state space, design bang-bang controller
            % action=1, going up; action=0, going down
            %  observation ordering
            %   [next_next_pipe_bottom_y, \
            %    next_next_pipe_dist_to_player, \
            %    next_next_pipe_top_y, \
            %    next_pipe_bottom_y, \
            %    next_pipe_dist_to_player, \
            %    next_pipe_top_y,
            %    player_vel,
            %    player_y]
            
            % use Q-learning to define control action
            [dx, dy] = this.get_state(obs);
            [~,idx] = max(this.q_table(dx,dy,:));
            action = idx-1;
        end
        
        function [action] = sample_action(this, obs)
            rnum = rand();
            
            if(this.cur_iter>this.SUPERVISE_ITER)
                % exponential decaying exploration
                epsilon = this.EPSILON * exp(-(this.cur_iter-this.SUPERVISE_ITER)/200);
                if(rnum>epsilon)
                    action = this.get_action(obs);
                else

                    if(rnum>epsilon/2)
                        action = (rnum>0.5);
                    else
                        % use supervisor to guide training
                        action = this.supervisor.get_action(obs);
                    end
                end
            else
                action = this.supervisor.get_action(obs);
            end
        end
        
        function [] = train(this, action, prev_ob, reward, ob, done)
            if(~isnan(prev_ob))
                % exponential decaying learning rate
                alpha = this.ALPHA * exp(-this.cur_iter/50);
                [dx_p, dy_p] = this.get_state(prev_ob);
                [dx, dy] = this.get_state(ob);
                this.q_table(dx_p, dy_p, action+1) = (1-alpha)*this.q_table(dx_p, dy_p, action+1) + ...
                    alpha * (reward + this.GAMMA*max(this.q_table(dx,dy,:)));
                if(done==1)
                    this.cur_iter =  this.cur_iter + 1;
                end
                if(reward>0)
                    disp(reward);
                end
            end
        end
        
        function [] = save_model(this)
            qTable = this.q_table;
            save(fullfile('model',[this.MODEL_TYPE, '.mat']), 'qTable');
        end
        
        function [] = load_model(this)
            load(fullfile('model',[this.MODEL_TYPE, '.mat']), 'qTable');
            this.q_table = qTable;
        end
        
    end
    
    methods (Access = private)
        function [dx, dy] = get_state(this, obs)
            yc1 = (obs(4) + obs(6))/2;
            y = obs(8);
            dx = obs(5);
            dy = max((y-yc1) + this.HEIGHT/2, 1);
        end
    end
end