classdef BuyTrendStrategy < StrategiesABC 
    %BUYTRENDSTRATEGY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        timeRemaining;
        volume;
    end
    
    methods
        function obj = BuyTrendStrategy(dataHandlerObject, tickerName)
            obj.dataHandler = dataHandlerObject;
            obj.tickerName = tickerName;
        end
        
        function updateTimeRemaining(obj)
            obj.timeRemaining = obj.dataHandler.getTimeRemaining();
        end
        
        function tradingRules(obj)
            obj.updateTimeRemaining();
            timeStarted = 300 - obj.timeRemaining;
            if timeStarted >= 10 && timeStarted < 100
                obj.runOrNot = true;
                obj.longOrShort = true;
                obj.volume = 5000;
            elseif timeStarted >= 100 && timeStarted < 200
                obj.runOrNot = true;
                obj.longOrShort = true;
                obj.volume = 3000;
            elseif timeStarted >= 200 && timeStarted < 270
                obj.runOrNot = true;
                obj.longOrShort = true;
                obj.volume = 1000;
            elseif timeStarted >= 270
                obj.runOrNot = true;
                obj.longOrShort = false;
                
            end
        end
    end
    
end

