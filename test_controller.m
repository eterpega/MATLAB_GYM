% test controller

flappy_bird = FlappyBirdGym();
flappy_bird.initialize();

% classical control law
simple_control = ControllerFactory('simple');
flappy_bird.run_controller(simple_control);

% % Q-learning
% q_learner = ControllerFactory('rl');
% %flappy_bird.train_controller(q_learner);
% flappy_bird.run_controller(q_learner);