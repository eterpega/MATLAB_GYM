% test controller

flappy_bird = FlappyBirdGym();
flappy_bird.initialize();

% % classical control law
% simple_control = ControllerFactory('simple');
% flappy_bird.run_controller(simple_control);

% % Q-learning
q_learner = ControllerFactory('rl');
% %flappy_bird.train_controller(q_learner);
flappy_bird.run_controller(q_learner);

%% deep network for behavior cloning
deep_learner = DeepController();
deep_learner.collect_data();
train(deep_learner);
deep_learner.save_model();

%%
deep_learner = DeepController();
deep_learner.load_model('model/deep.mat');
deep_learner.run_deep()