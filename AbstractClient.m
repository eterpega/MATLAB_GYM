classdef (Abstract) AbstractClient < handle
    properties (Abstract)
        
    end
    
    methods (Abstract)
        [varargout] = env_create(this, env_id)
        % create simulation environment named "env_id" in the server
        
        [varargout] = env_reset(this, instance_id)
        % reset simulation environment given the instance name
        
        [obs, reward, done, info] = env_step(this, instance_id, action, render)
        % obs:          new state
        % reward:       return reward after performing action
        % done:         is simulation ended
        % info:         for debugging purpose
        % instance_id:  instance to perform action on
        % action:       current action
        % render:       whether to perform rendering
        
        [info] = env_action_space_info(this, instance_id)
        % get action space given the instance name
        
        [info] = env_observation_space_info(this, instance_id)
        % get observation space info
        
        [action] = env_action_space_sample(this, instance_id)
        % random sample action space and return action
                
        [] = env_monitor_start(this, instance_id, output_dir, varargin)
        % start monitor the instance and output to 'output_dir'
        
        [action] = env_monitor_close(this, instance_id)
        % close monitor
        
        [] = shutdown_server(this, varargin)
        % remove all the temporary file and shutdown server
    end
end