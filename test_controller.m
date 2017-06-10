% test controller

flappy_bird = FlappyBirdGym();
flappy_bird.initialize();

% classical control law
% simple_control = SimpleController();
% flappy_bird.run_controller(simple_control);

% % Q-learning
q_learner = RlController();
flappy_bird.train_controller(q_learner);
q_learner.save_model()