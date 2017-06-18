classdef DeepController < AbstractController
    % only for behavior cloning, not working very well
    properties (Constant)
        MODEL_TYPE = 'deep';
        WIDTH = 288;                % Screen Width
        HEIGHT = 512;               % Screen Height
        BATCH_SIZE = 32;            % Training Batch Size
        MAX_MEMORY = 50000;        % Maximum Replay Memory
        DATA_FILE = fullfile('record','deep.mat');
    end
    
    properties
        game
        img_no
    end
    
    properties
        % neural network options and structure
        q_layer
        q_network
        supervisor
        rl_supervisor
        supervisor_type
    end
    
    methods
        function [this] = DeepController()
            this.q_layer = [ ...
                imageInputLayer([512, 288, 1])
                convolution2dLayer(8, 128, 'Stride', 4)
                reluLayer()
                maxPooling2dLayer(2)
                convolution2dLayer(4, 256, 'Stride', 2)
                reluLayer()
                maxPooling2dLayer(2)
                convolution2dLayer(3, 256, 'Stride', 1)
                reluLayer()
                maxPooling2dLayer(2)
                dropoutLayer(0.4)
                fullyConnectedLayer(2)
                softmaxLayer
                classificationLayer()];
            this.supervisor = SimpleController();
            this.rl_supervisor = RlController();
            this.rl_supervisor.load_model('model/rl.mat');
            this.supervisor_type = 'simple';
        end
        
        function [action] = getAction(this, obs, type)
            switch this.supervisor_type
                case 'rl'
                    action = this.supervisor.get_action(obs);
                case 'simple'
                    action = this.supervisor.get_action(obs);
            end
        end
        
        function [action] = sampleAction(this, ob_img)
            %this.q_network
            q = this.q_network.predict(rgb2gray(ob_img));
            a0 = q(1);
            a1 = q(2);
            if(a0>a1)
                action = 0;
            else
                action = 1;
            end
        end
        
        function [] = run_deep(this)
            fprintf('running deep \n');
            this.game = FlappyBirdGym();
            this.game.initialize();
            for i = 1:10
                fprintf('Run deep controller at iteration %d \n', i);
                obs = this.game.client.env_reset(this.game.instance_id);
                
                action = this.get_action(obs);
                j = 1;
                while(j < this.game.MAX_STEPS)
                    [ob, ~, done, ~] = this.game.client.env_step(this.game.instance_id,...
                        action, this.game.IS_RENDER);
                    
                    % in case the image is needed for Q-learning
                    tmp_data = load('tmp.mat');
                    ob_img = tmp_data.obs_img;
                    
                    action = this.sample_action(ob_img);
                    
                    if(done)
                        fprintf('Game over \n');
                        break;
                    end
                    j = j + 1;
                end
                
                if(~done)
                    this.game.client.env_monitor_close(this.game.instance_id);
                end
                
            end
        end
        
        function [] = collect_data(this)
            fprintf('Collect some data \n');
            if(exist(this.DATA_FILE, 'file')==0)
                this.game = FlappyBirdGym();
                this.game.initialize();
                Xtrain = uint8(zeros(512, 288, 1, this.MAX_MEMORY));
                ytrain = uint8(zeros(this.MAX_MEMORY,1));
                this.img_no = 1;
                for i = 1:1000
                    fprintf('Run %s controller at iteration %d \n', this.supervisor_type, i);
                    obs = this.game.client.env_reset(this.game.instance_id);
                    if(i==20)
                        this.supervisor_type = 'rl';
                        disp('using RlController');
                    end
                    action = this.get_action(obs);
                    j = 1;
                    while(j < this.game.MAX_STEPS)
                        [ob, ~, done, ~] = this.game.client.env_step(this.game.instance_id,...
                            action, this.game.IS_RENDER);
                        
                        % in case the image is needed for Q-learning
                        tmp_data = load('tmp.mat');
                        ob_img = tmp_data.obs_img;
                        if(~done)
                            action = this.get_action(ob);
                            Xtrain(:,:,:,this.img_no) = rgb2gray(ob_img);
                            ytrain(this.img_no) = action;
                            this.img_no = this.img_no + 1;
                        end
                        
                        if(this.img_no>this.MAX_MEMORY)
                            break;
                        end
                        
                        if(done)
                            fprintf('Game over \n');
                            break;
                        end
                        j = j + 1;
                    end
                    
                    if(~done)
                        this.game.client.env_monitor_close(this.game.instance_id);
                    end
                    
                    if(this.img_no>this.MAX_MEMORY)
                        break;
                    end
                    
                end
                % save data
                save(this.DATA_FILE,'Xtrain','ytrain','-v7.3');
            end
        end
        
        function [] = train(this)
            load(this.DATA_FILE);
            options = trainingOptions('sgdm',...
                'MaxEpochs', 100, ...
                'InitialLearnRate',0.0005,...
                'MiniBatchSize',64,...
                'ExecutionEnvironment','gpu');
            ytrain = categorical(ytrain);
            this.q_network = trainNetwork(Xtrain,ytrain,this.q_layer,options);
        end
        
        function [] = saveModel(this)
            qNetwork = this.q_network;
            save(fullfile('model',[this.MODEL_TYPE, '.mat']), 'qNetwork');
        end
        
        function [] = loadModel(this, data_file)
            load(data_file, 'qNetwork');
            this.q_network = qNetwork;
        end
        
    end
    
end