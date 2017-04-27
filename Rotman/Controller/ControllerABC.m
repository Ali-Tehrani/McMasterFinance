classdef ControllerABC
    %CONTROLLERABC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tickerName;
        guiObject;
    end
    
    methods (Abstract)
        transitionFunction(obj);
    end
    
end

