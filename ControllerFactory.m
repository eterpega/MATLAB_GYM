function [controller] = ControllerFactory(type)
% Controller Factory to produce different controllers

model_name = fullfile('model', [type, '.mat']);
switch type
    case 'bang-bang'
        controller = BangBangController();
    case 'rl'
        controller = RlController();
    case 'deep'
        controller = DeepController();
    otherwise
        error('Controller not defined');
end

if(exist(model_name, 'file')==2)
    controller.loadModel(model_name);
end

end