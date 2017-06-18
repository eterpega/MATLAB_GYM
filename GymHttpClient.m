classdef GymHttpClient < AbstractClient
    % Matlab Http client for OpenAI gym

    properties
        remote_base
    end
    properties (SetAccess = private)
        webopt
    end

    methods (Access = private)
        % Parse a JSON response, and return a (struct) on resp_data
        % For more information about using JSON in matlab refer to:
        % http://mathworks.com/help/matlab/ref/webread.html
        % http://mathworks.com/help/matlab/ref/webwrite.html
        function [resp_data] = get_request(this, route)
            url = [this.remote_base, route];
            resp_data = webread(url, this.webopt);
        end

        % Encode a JSON message with data described on "req_data", and
        % return a response (struct) on resp_data
        function [resp_data] = post_request(this, route, req_data)
            url = [this.remote_base, route];
            resp_data = webwrite(url, req_data, this.webopt);
        end
    end

    methods (Access = public)
        % Constructor
        function [this] = GymHttpClient(remote_base)
            this.remote_base = remote_base;
            this.webopt = weboptions( ...
                'MediaType', 'application/json', ...
                'Timeout', 10);
        end

        function [resp_data] = env_create(this, env_id)
            route = '/v1/envs/';
            req_data = struct('env_id',env_id);
            resp_data = this.post_request(route, req_data);
            resp_data = resp_data.instance_id;
        end

        function [resp_data] = env_list_all(this)
            route = '/v1/envs/';
            resp_data = this.get_request(route);
            resp_data = resp_data.all_envs;
        end

        function [resp_data] = env_reset(this, instance_id)
            route = ['/v1/envs/', instance_id, '/reset/'];
            resp_data = this.post_request(route, []);
            resp_data = resp_data.observation;
        end

        function [obs, reward, done, info] = env_step(this, ...
                instance_id, action, render)
            if ~exist('render', 'var')
                render = false;
            end
            route = ['/v1/envs/', instance_id, '/step/'];
            req_data = struct('action', action, 'render', render);
            resp_data = this.post_request(route, req_data);
            obs = resp_data.observation;
            reward = resp_data.reward;
            done = resp_data.done;
            info = resp_data.info;
        end

        function [resp_data] = env_action_space_info(this, instance_id)
            route = ['/v1/envs/', instance_id, '/action_space/'];
            resp_data = this.get_request(route);
            resp_data = resp_data.info;
        end

        function [resp_data] = env_action_space_sample(this, instance_id)
            route = ['/v1/envs/', instance_id, '/action_space/sample'];
            resp_data = this.get_request(route);
            resp_data = resp_data.action;
        end

        function [resp_data] = env_action_space_contains(this, instance_id, x)
            route = ['/v1/envs/', instance_id, ...
                     '/action_space/contains/', num2str(x)];
            resp_data = this.get_request(route);
            resp_data = resp_data.member;
        end

        function [resp_data] = env_observation_space_info(this, instance_id)
            route = ['/v1/envs/', instance_id, '/observation_space/'];
            resp_data = this.get_request(route);
            resp_data = resp_data.info;
        end

        function env_monitor_start(this, ...
                instance_id, directory, varargin)
            if nargin > 3
                if nargin == 4
                    force = varargin{1};
                    resume = false;
                else
                    force = varargin{1};
                    resume = varargin{2};
                end
            else
                force = false;
                resume = false;
            end
            req_data = struct( ...
                'directory', directory, ...
                'force', force, ...
                'resume', resume);
            route = ['/v1/envs/', instance_id, '/monitor/start/'];
            this.post_request(route, req_data);
        end

        function env_monitor_close(this, instance_id)
            route = ['/v1/envs/', instance_id, '/monitor/close/'];
            this.post_request(route, []);
        end

        function upload(this, ...
                training_dir, varargin)
            if nargin > 3
                if nargin == 4
                    api_key = varargin{1};
                    algorithm_id = '';
                end
                if nargin == 5
                    api_key = varargin{1};
                    algorithm_id = varargin{2};
                end
            else
                api_key = getenv('OPENAI_GYM_API_KEY');
                algorithm_id = '';
            end
            req_data = struct('training_dir',training_dir,...
                'algorithm_id',algorithm_id,'api_key',api_key);
            route = '/v1/upload/';
            this.post_request(route, req_data);
        end

        function shutdown_server(this)
            route = '/v1/shutdown/';
            this.post_request(route, []);
        end
    end
end

