classdef Ticker2Controller < ControllerABC
    %TICKER2CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dataHandlerObject;
        orderPlacementObject;
        marketMakingStrategy;
    end
    
    methods
        function obj = Ticker2Controller(gui, dataHandler, rotnamObject, tickerName)
            obj.guiObject = gui;
            obj.dataHandlerObject = dataHandler;
            obj.tickerName = tickerName;
            obj.orderPlacementObject = OrderPlacement(rotnamObject);
            obj.marketMakingStrategy = MarketMakingStrategy(dataHandler, tickerName);
        end
        
        function transitionFunction(obj)    
            if obj.guiObject.ticker2OnOff.Value == 1
                if obj.guiObject.ticker2Unloading.Value == 1
                    disp('2:Unloading');
                    obj.orderPlacementObject.orderPlacementAggresUnloadingCostAverage(obj.tickerName);
                    
                elseif obj.guiObject.ticker2MarketMaking.Value == 1
                    disp('2:Market Making');
                    obj.orderPlacementObject.orderPlacementTakeProfitBasedOnUnRel(obj.tickerName);
                    obj.marketMakingStrategy.tradingRules();
                    if obj.marketMakingStrategy.runOrNot == true
                        if obj.marketMakingStrategy.longOrShort == true
                            disp('2:place orders');
                            obj.orderPlacementObject.orderPlacementMarketMaking(1, ...
                                obj.marketMakingStrategy.priceForAsk, obj.marketMakingStrategy.breakEven,...
                                obj.tickerName);
                            
                        else
                            disp('2:place orders');
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

