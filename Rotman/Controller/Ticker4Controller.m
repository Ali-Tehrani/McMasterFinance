classdef Ticker4Controller < ControllerABC
    %TICKER4CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dataHandlerObject;
        orderPlacementObject;
        marketMakingStrategy;

    end
    
    methods
        function obj = Ticker4Controller(gui, dataHandler, rotnamObject, tickerName)
            obj.guiObject = gui;
            obj.dataHandlerObject = dataHandler;
            obj.tickerName = tickerName;
            obj.orderPlacementObject = OrderPlacement(rotnamObject);
            obj.marketMakingStrategy = MarketMakingStrategy(dataHandler, tickerName);
           
        end
        
        function transitionFunction(obj)    
            if obj.guiObject.ticker4OnOff.Value == 1
                if obj.guiObject.ticker4Unloading.Value == 1
                elseif obj.guiObject.ticker4MarketMaking.Value == 1

                end
            end
        end
    end
end

