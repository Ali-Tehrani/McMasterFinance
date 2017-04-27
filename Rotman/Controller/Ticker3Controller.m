classdef Ticker3Controller < ControllerABC
    %TICKER3CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dataHandlerObject;
        orderPlacementObject;
        marketMakingStrategy;
    end
    
    methods
        function obj = Ticker3Controller(gui, dataHandler, rotnamObject, tickerName)
            obj.guiObject = gui;
            obj.dataHandlerObject = dataHandler;
            obj.tickerName = tickerName;
            obj.orderPlacementObject = OrderPlacement(rotnamObject);
            obj.marketMakingStrategy = MarketMakingStrategy(dataHandler, tickerName);
           
        end
        
        function transitionFunction(obj)  
            if obj.guiObject.ticker3OnOff.Value == 1
                if obj.guiObject.ticker3Unloading.Value == 1
                    disp('3:Unloading');
                    obj.orderPlacementObject.orderPlacementAggresUnloadingCostAverage(obj.tickerName);
                elseif obj.guiObject.ticker3MarketMaking.Value == 1
                    disp('3:Market Making');
                    obj.orderPlacementObject.orderPlacementTakeProfitBasedOnUnRel(obj.tickerName);
                    obj.marketMakingStrategy.tradingRules();
                    if obj.marketMakingStrategy.runOrNot == true
                        if obj.marketMakingStrategy.longOrShort == true
                            disp('place orders');
                            obj.orderPlacementObject.orderPlacementMarketMaking(1, ...
                                obj.marketMakingStrategy.priceForAsk, obj.marketMakingStrategy.breakEven,...
                                obj.tickerName);
                            
                        else
                            disp('place orders');
                            obj.orderPlacementObject.orderPlacementMarketMaking(0, ...
                                obj.marketMakingStrategy.priceForBid, obj.marketMakingStrategy.breakEven,...
                                obj.tickerName);  
                            
                        end
                    end
                        

                end
            end
        end
        
    end
    
end

