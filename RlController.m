classdef RlController < handle
    % TO DO: investigate algorithm convergence and tune hyper-parameters
    properties (Constant)
        MODEL_TYPE = 'rl';
        ALPHA = 0.7;                % Learning Rate
        GAMMA = 1;                  % Discount Factor
        EPSILON = 0.07;         	% Exploration Rate
        WIDTH = 288;                % Screen Width
        HEIGHT = 512;               % Screen Height
        SUPERVISE_ITER = 50;        % Every 50 iteration, Run Supervisor Mode
        BATCH_SIZE = 32;            % Training Batch Size
        MAX_VELO = 50;              % Not used at this moment
        MAX_MEMORY = 100000;        % Maximum Replay Memory
        MAX_SUPERVISE_ITER = 1;     % After X iterations, no supervisors
    end
    
    properties
        % random sample previous actions for training
        replay_memory = zeros(100000, 7);
        idx_pt = 1;
    end
    
    properties
        % screen width, screen height, 2 action
        q_table
        cur_iter = 0;
        supervisor
    end
    
    methods
        function [this] = RlController()
            this.supervisor = SimpleController();
            this.q_table = zeros(this.WIDTH, this.HEIGHT*2, 2);
        end
        
        function [action] = get_action(this, obs)
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
            a0 = this.q_table(dx,dy,1);
            a1 = this.q_table(dx,dy,2);
            if(a0==a1)
                action = (rand()>0.5);
            elseif(a0>a1)
                action = 0;
            else
                action = 1;
            end
        end
        
        function [action] = sample_action(this, obs)
            rnum = rand();
            % exponential decaying exploration
            epsilon = this.EPSILON; % * exp(-(this.cur_iter-this.SUPERVISE_ITER)/200);
            if(this.cur_iter<this.MAX_SUPERVISE_ITER)
                if(~mod(this.cur_iter,this.SUPERVISE_ITER)==0)
                    if(rnum>epsilon)
                        action = this.get_action(obs);
                    else
                        action = (rnum>0.5);
                    end
                else
                    action = this.supervisor.get_action(obs);
                end
            else
                % exploration + exploitation
                if(rnum>epsilon)
                    action = this.get_action(obs);
                else
                    action = (rnum>0.5);
                end
            end
        end
        
        function [] = train(this, action, prev_ob, reward, ob, done)
            if(~isnan(prev_ob))
                % exponential decaying learning rate
                alpha = this.ALPHA; %* exp(-this.cur_iter/50);
                [dx_p, dy_p] = this.get_state(prev_ob);
                [dx, dy] = this.get_state(ob);
                
                % add to memory for experience replay
                this.add_to_memory(dx_p, dy_p, dx, dy, action, reward, done);
                
                % experience replay
                if(this.idx_pt > 3*this.BATCH_SIZE)
                    tmp_idx = randi(this.idx_pt-1, this.BATCH_SIZE, 1);
                    parfor s = 1:this.BATCH_SIZE
                        experience_replay(this,tmp_idx(s),alpha);
                    end
                else
                    this.q_table(dx_p, dy_p, action+1) = (1-alpha)*this.q_table(dx_p, dy_p, action+1) + ...
                        alpha * (reward + this.GAMMA*max(this.q_table(dx,dy,:)));
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
            dx = round(obs(5));
            velo = obs(7);
            dy = round(this.HEIGHT/2 - (y-yc1-velo));
            dy = max(dy, 1);
            dx = max(dx, 1);
        end
        
        function [] = add_to_memory(this, dx_p, dy_p, dx, dy, action, reward, done)
            if(this.idx_pt<this.MAX_MEMORY)
                this.replay_memory(this.idx_pt,:) = [dx_p, dy_p, dx, dy, action, reward, done];
                this.idx_pt = this.idx_pt + 1;
            else
                idx = randi(this.MAX_MEMORY,1);
                this.replay_memory(idx,:) = [dx_p, dy_p, dx, dy, action, reward, done];
            end
        end
        
        function [] = experience_replay(this, idx, alpha)
            tmp = this.replay_memory(idx,:);
            dx_p = tmp(1);
            dy_p = tmp(2);
            dx = tmp(3);
            dy = tmp(4);
            action = tmp(5);
            reward = tmp(6);
            %             done = tmp(7);
            %             if(done)
            %                 this.q_table(dx_p, dy_p, action+1) = reward;
            %             else
            this.q_table(dx_p, dy_p, action+1) = (1-alpha)*this.q_table(dx_p, dy_p, action+1) + ...
                alpha * (reward + this.GAMMA*max(this.q_table(dx,dy,:)));
            %             end
        end
    end
end