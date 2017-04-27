classdef RsiTypeStrategy < StrategiesABC 
    %RSITYPESTRATEGY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        rit;
    end
    
    methods
        function obj = RsiTypeStrategy(dataHandlerObject, tickerName)
            obj.dataHandler = dataHandlerObject;
            obj.tickerName = tickerName;
            obj.rit = rotmanTrader;
        end
        
        function tradingRules(obj)
            [probBuy, probSell] = obj.getProbBuySell();
            
            if 60 <= probBuy  && probBuy < 75
                obj.runOrNot = true;
                obj.longOrShort = false;
                disp(2);
            elseif probBuy >= 75
                obj.runOrNot = true;
                obj.longOrShort = false;
                disp(3);
            elseif 60 <= probSell && probSell < 75
                obj.runOrNot = true;
                obj.longOrShort = false;
                disp(4);
            elseif probSell >= 75
                obj.runOrNot = true;
                obj.longOrShort = false;
                disp(5)
            elseif probBuy < 60 || probSell < 60
                obj.runOrNot = true;
                obj.longOrShort = true;
                disp(6);
            else
                obj.runOrNot = false;
            end
        end
        
        function [A B] = getProbBuySell(obj)
            bidBook = obj.dataHandler.getBook(obj.tickerName, 'bid');
            bidVolume = bidBook{3};
            totalBidVolume = sum(bidVolume);
            disp(totalBidVolume);
            
            askBook = obj.dataHandler.getBook(obj.tickerName, 'ask');
            askVolume = askBook{3};
            totalAskVolume = sum(askVolume);
            disp(totalAskVolume);
            
            totalVolume = totalBidVolume + totalAskVolume;
            
            probBuy = totalBidVolume / totalVolume;
            probSell = totalAskVolume / totalVolume;
            A = probBuy; B = probSell;
            disp([probBuy probSell ]);
            disp([totalBidVolume totalAskVolume]);          
        end
        
    end
    
end

