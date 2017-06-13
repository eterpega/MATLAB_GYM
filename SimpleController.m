classdef SimpleController < handle
    properties (Constant)
        HALF_HEIGHT = 512/2;
    end
    
    methods
        function [this] = SimpleController()
        end
        
        function [action] = get_action(this, obs)
            % TO DO: Based on state space, design bang-bang controller
            % action=1, going down; action=0, going up
            %  observation ordering
            %   [next_next_pipe_bottom_y, \
            %    next_next_pipe_dist_to_player, \
            %    next_next_pipe_top_y, \
            %    next_pipe_bottom_y, \
            %    next_pipe_dist_to_player, \
            %    next_pipe_top_y,
            %    player_vel,
            %    player_y]
            
            % define a bang-bang controller
            yc1 = (obs(4) + obs(6))/2;
            yc2 = (obs(1) + obs(3))/2;
            dx2 = obs(2);
            dx = obs(5);
            y = obs(8);
            velo = obs(7);
%             if(dx<=1)
%                 action = (y-yc2-velo)<0;
%             else
                action = (y-yc1-velo)<0;
%             end
        end
        
        function [action] = sample_action(this, obs)
        end
        
    end
end
