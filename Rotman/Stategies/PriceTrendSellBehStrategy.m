classdef PriceTrendSellBehStrategy < StrategiesABC
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        whichTicker
    end
    
    methods
        function obj = PriceTrendSellBehStrategy(dataHandlerObject, tickerName)
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
            if priceHistory(currentTick) > priceHistory(currentTick - 1) && priceHistory(currentTick - 1) ...
                    > priceHistory(currentTick - 2) && probSell >= 0.7
                obj.runOrNot = true;
                obj.longOrShort = false;           
            end
         
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

