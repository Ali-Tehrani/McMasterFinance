classdef Ticker1Controller < ControllerABC
    %C Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dataHandlerObject;
        orderPlacementObject;
        marketMakingStrategy;
        priceTrendBuyBehStrategy;
        priceTrendSellBehStrategy;
    end
    
    methods      
        function obj = Ticker1Controller(gui, dataHandler, rotnamObject, tickerName)
            obj.guiObject = gui;
            obj.dataHandlerObject = dataHandler;
            obj.tickerName = tickerName;
            obj.orderPlacementObject = OrderPlacement(rotnamObject);
            obj.marketMakingStrategy = MarketMakingStrategy(dataHandler, tickerName);
            obj.priceTrendBuyBehStrategy = PriceTrendBuyBehStrategy(dataHandler, tickerName);
            obj.priceTrendSellBehStrategy = PriceTrendSellBehStrategy(dataHandler, tickerName);           
        end
        
        function transitionFunction(obj)    
            if (obj.guiObject.ticker1OnOff.Value == 1)
                    
                if obj.guiObject.ticker1Un.Value==1
                    disp('1: Unloading');
                    obj.orderPlacementObject.orderPlacementAggresUnloadingCostAverage(obj.tickerName);
                    
                elseif obj.guiObject.ticker1MarketMake.Value==1
                    disp('1:Market Making');
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
                    
                    
                elseif obj.guiObject.ticker1TrendBuyPriceBeha.Value == 1
                    disp('1: Price Behaviour');
                    obj.orderPlacementObject.orderPlacementTakeProfitForPriceBehaviour(obj.tickerName);
                    obj.priceTrendBuyBehStrategy.tradingRules(4);
                    if obj.priceTrendBuyBehStrategy.runOrNot == true
                        if obj.priceTrendBuyBehStrategy.longOrShort == true
                           obj.orderPlacementObject.orderPlacementForPriceBehaviour(obj.tickerName,...
                               true) 
                        elseif obj.priceTrendBuyBehStrategy.longOrShort == false
                            obj.orderPlacementObject.orderPlacementForPriceBehaviour(obj.tickerName,...
                               false)     
                        end
                    end
                    obj.orderPlacementObject.orderPlacementTakeProfitForPriceBehaviour(obj.tickerName);
                
                elseif obj.guiObject.ticker1TrendSellPriceBeha.Value == 1
                     obj.orderPlacementObject.orderPlacementTakeProfitForPriceBehaviour(obj.tickerName);
                     obj.priceTrendSellBehStrategy.tradingRules();
                     if obj.priceTrendSellBehStrategy.runOrNot == true
                        if obj.priceTrendSellBehStrategy.longOrShort == true
                              obj.orderPlacementObject.orderPlacementForPriceBehaviour(obj.tickerName,...
                               true) 
                        elseif obj.priceTrendSellBehStrategy.longOrShort == false
                              obj.orderPlacementObject.orderPlacementForPriceBehaviour(obj.tickerName,...
                               false) 
                        end
                     end

                    
                end   
                if obj.guiObject.ticker1TakeProfit.Value == 1
                    obj.orderPlacementObject.takeProfitForTrends(...
                        obj.tickerName, 50);
                end 
            end

        end
    end
    
end

