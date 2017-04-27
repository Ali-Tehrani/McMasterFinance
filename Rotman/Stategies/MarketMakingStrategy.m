classdef MarketMakingStrategy < StrategiesABC
    %MARKETMAKINGSTRATEGY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        breakEven;
        priceForAsk;
        priceForBid;
    end
    
    methods
        function obj = MarketMakingStrategy(dataHandlerObject, tickerName)
            obj.dataHandler = dataHandlerObject;
            obj.tickerName = tickerName;
        end
        
        function tradingRules(obj)
            [probBuy, probSell] = obj.getProbLevels();
            
            if(probBuy > 0.7)
                obj.runOrNot = true;
                obj.longOrShort = true;
                disp('place orders for buy');              
            elseif (probSell > 0.7)
                obj.runOrNot = true;
                obj.longOrShort = false;
                disp('place orders for sell');
            else
                obj.runOrNot = false;
                disp('dont run');
            end
            disp([probBuy probSell]);
        end
        
        function [A B] = getProbLevels(obj)
            bidBook = obj.dataHandler.getBook(obj.tickerName, 'bid');
            totalBidVolume = obj.getUniqueNumbers(4, bidBook{2}, 0);
             
            askBook = obj.dataHandler.getBook(obj.tickerName, 'ask');
            totalAskVolume = obj.getUniqueNumbers(4, askBook{2}, 1);
            
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
            
            if bidOrAsk == 0
                obj.priceForAsk = bidOrAskBook(n);
                obj.breakEven = obj.priceForAsk - 2 * 0.01;
            elseif bidOrAsk == 1
                obj.priceForBid = bidOrAskBook(n);
                obj.breakEven = obj.priceForBid + 2 * 0.01;
            end

            sum = sumOfBid;
        end
    end
end

