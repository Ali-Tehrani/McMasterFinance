classdef StrategiesABC < handle
    %STATEGIESABC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        longOrShort;
        runOrNot;
        dataHandler;
        tickerName;
    end
    
    methods (Abstract)
        tradingRules(obj);    
    end
        
end


