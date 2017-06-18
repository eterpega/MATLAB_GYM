%% Flappy bird example
flappy_bird = FlappyBird();

% Bang-bang control
controller = ControllerFactory('bang-bang');

for i = 1:10
flappy_bird.runController(controller);
end

% Q-learning
q_learner = ControllerFactory('rl');

for i = 1:10
flappy_bird.runController(q_learner);
end

%% Cart Pole
game = CommonGymGame('CartPole-v0');
game.testEnvironment();