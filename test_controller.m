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
% q_learner.save_model()

for p in self.pipe_group:
    hit = pygame.sprite.spritecollide(
        self.player, self.pipe_group, False)
    for h in hit:
        is_in_pipe = ((p.x - p.width / 2) <= self.player.pos_x < (p.x - p.width / 2))
        # do check to see if its within the gap.
        top_pipe_check = (
            (self.player.pos_y - self.player.height / 2) <= h.gap_start) and is_in_pipe
        bot_pipe_check = (
            (self.player.pos_y +
             self.player.height) > h.gap_start +
            self.pipe_gap) and is_in_pipe