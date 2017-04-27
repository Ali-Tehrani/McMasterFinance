classdef PriceTrendBuyBehStrategy < StrategiesABC
    %PRICETRENDBEHSTRATEGY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        whichTicker;
        initialTrade = true;
    end
    
    methods
        function obj = PriceTrendBuyBehStrategy(dataHandlerObject, tickerName)
            obj.dataHandler = dataHandlerObject;
            obj.tickerName = tickerName;
            if strcmpi(tickerName,'pooh')
                obj.whichTicker = 0;
            elseif strcmpi(tickerName,'tigr')
                obj.whichTicker = 1;
            elseif strcmpi(tickerName,'eyor')
                obj.whichTicker = 2;
            elseif strcmpi(tickerName,'huny')
                obj.whichTicker = 3;
            end
        end
        
        function tradingRules(obj, numberOfPrices)
            %4 is the depth of the book i.e. get prob levels of first 4s
            [probBuy, probSell] = obj.getProbLevels(numberOfPrices);
            currentTick = 300 - obj.dataHandler.getTimeRemaining();
            priceHistory = obj.dataHandler.getPrices(obj.whichTicker)
            disp(currentTick);
            if priceHistory(currentTick) < priceHistory(currentTick - 1) && priceHistory(currentTick - 1) ...
                    < priceHistory(currentTick - 2) && probBuy > 0.7
                obj.runOrNot = true;
                obj.longOrShort = true;           
            end
         
        end
        
        function [A B C] = isTrend(obj, numberOfPreviousPrices)
            currentTick = 300 - obj.dataHandler.getTimeRemaining();
            priceHistory = obj.dataHandler.getPrices(obj.whichTicker)
            isItATrend = false;
            isUp = false;
            isDown = false;
            previousPrice = priceHistory(currentTick);
            
            increments = 2;
            if priceHistory(currentTick) > priceHistory(currentTick - increments)
                if priceHistory(currentTick - increments) > priceHistory(currentTick - increments*2)
                    if priceHistory(currentTick - increments*2) > priceHistory(currentTick - increments*3)
                        isItATrend = true;
                        isUp = true;
                    end
                end
            elseif priceHistory(currentTick) < priceHistory(currentTick - 2)
                if priceHistory(currentTick - 2) < priceHistory(currentTick - 4)
                    if priceHistory(currentTick - 4) < priceHistory(currentTick - 6)
                        isItATrend = true;
                        isDown = true;
                    end
                end
            end
            A = isItATrend;
            B = isUp;
            C = isDown;
        end
        
        function [A B] = getProbLevels(obj, depthLevelOfBook)
            bidBook = obj.dataHandler.getBook(obj.tickerName, 'bid');
            totalBidVolume = obj.getUniqueNumbers(depthLevelOfBook, bidBook{2}, 0);
             
            askBook = obj.dataHandler.getBook(obj.tickerName, 'ask');
            totalAskVolume = obj.getUniqueNumbers(depthLevelOfBook, askBook{2}, 1);
            
            totalVolume = totalBidVolume + totalAskVolume;
            
            probBuy = totalBidVolume / totalVolume;
            probSell = totalAskVolume / totalVolume;
            A = probBuy; B = probSell;
                      
        end
        
        function sum = getUniqueNumbers(obj, numOfUniqueOrders, bidOrAskBook, bidOrAsk)
            counter = 0;
            previousPrice = 0;
            sumOfBid = 0;
            n = 1;
            while counter ~= numOfUniqueOrders - 1
                price = bidOrAskBook(n);
                if n == 1
                    previousPrice = price;
                end
                if price ~= previousPrice
                    previousPrice = price;
                    counter = counter + 1;
                else
                    sumOfBid = sumOfBid + price;
                end
                    n = n + 1;
            end
            sum = sumOfBid;
        end
        
        
    end
    
end

