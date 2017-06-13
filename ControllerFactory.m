function [controller] = ControllerFactory(type)
model_name = fullfile('model', [type, '.mat']);
switch type
    case 'simple'
        controller = SimpleController();
    case 'rl'
        controller = RlController();
    otherwise
        error('Controller not defined');
end

if(exist(model_name, 'file')==2)
    controller.load_model(model_name);
end

end