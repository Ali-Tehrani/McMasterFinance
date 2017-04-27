classdef CostAverageStrategy < StrategiesABC
    %COSTAVERAGESTRATEGY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nextPriceChange;
        percentChangePrevious = 0;
        percentChangeCurrent;
        openingPrice;
        volumeToTrade = 500;
    end
    
    methods
        function obj = CostAverageStrategy(dataHandlerObject, openingPrice, tickerName)
            obj.dataHandler = dataHandlerObject;
            obj.openingPrice = openingPrice;
            obj.tickerName = tickerName;
        end
            
        function tradingRules(obj)
            obj.percentChangeCurrent = obj.dataHandler.getPercentChange(obj.openingPrice, obj.tickerName);
            if (obj.percentChangeCurrent - obj.percentChangePrevious) > 0
                % Send Orders
                obj.runOrNot = true;
                obj.longOrShort = false;
                obj.percentChangePrevious = obj.percentChangeCurrent;
                
            elseif (obj.percentChangeCurrent - obj.percentChangePrevious) < 0
                % Send Orders
                obj.runOrNot = true;
                obj.longOrShort = true;
                obj.percentChangePrevious = obj.percentChangeCurrent;
            end
            
        end
    end
    
end

