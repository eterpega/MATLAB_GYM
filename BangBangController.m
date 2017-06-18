classdef BangBangController < AbstractController
    properties (Constant)
        TYPE = 'classic';
    end
    
    methods
        function [this] = BangBangController()
            
        end
        
        function [action] = getAction(this, obs)
            % bang-bang controller for flappy bird
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
            y = obs(8);
            velo = obs(7);
            action = (y-yc1-velo)<0;
        end
        
        %---- not used since the controller does not need training ------
        function [action] = sampleAction(this, obs)

        end
        
        function [] = updateOneIter(varargin)
        end
        %-----------------------------------------------------------------
    end
end
