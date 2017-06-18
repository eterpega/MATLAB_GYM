classdef AbstractController < handle
    properties (Abstract)
        
    end
    
    methods (Abstract)
        % return optimal action given observation
        [action] = getAction(this, ob)
        
        % sample action given observation, for training purpose
        [action] = sampleAction(this, ob)
        
        [] = updateOneIter(this, action, prev_ob, reward, ob, done, info);
        % Update controller parameters for one iteration
        % prev_ob:      previous state
        % reward:       reward acquired by performing action at prev_ob
        % ob:           new state
        % done:         is simulation ended
        % info:         for debugging purpose
    end
end