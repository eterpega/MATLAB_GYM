% test controller

flappy_bird = FlappyBirdGym();
flappy_bird.initialize();

% classical control law
simple_control = SimpleController();
flappy_bird.run_controller(simple_control);