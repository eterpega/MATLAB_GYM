
%% deep network for behavior cloning
deep_learner = DeepController();
deep_learner.collect_data();
train(deep_learner);
deep_learner.save_model();

%%
deep_learner = DeepController();
deep_learner.load_model('model/deep.mat');
deep_learner.run_deep()