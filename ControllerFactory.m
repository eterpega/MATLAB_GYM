function [controller] = ControllerFactory(type)
if(strcmp(type,'simple'))
    controller = SimpleController();
end

end