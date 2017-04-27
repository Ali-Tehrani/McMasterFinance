classdef DataHandler < handle
    %DATAHANDLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        rotnamObject;
        Ticker1PriceArray = {};
        Ticker2PriceArray = {};
        Ticker3PriceArray = {};
        Ticker4PriceArray = {};
    end
    
    methods
        function obj = DataHandler(rotnamAPI)
            obj.rotnamObject = rotnamAPI;
        end
        
        function f = getBook(obj, tickerName, bidOrAsk)
            fieldForTickerAskBook = strcat(tickerName , '_', bidOrAsk, 'book');
            bookString = getfield(obj.rotnamObject, fieldForTickerAskBook);
            disp(bookString);
            bookArray = textscan(bookString, '%s %f %f', 'delimiter', ',;'); 
            f = bookArray;           
        end
        
        function f = getPercentChange(obj, openingPrice, tickerName)
            currentBidPrice = getfield(obj.rotnamObject, strcat(tickerName,'_ask'));
            currentAskPrice = getfield(obj.rotnamObject, strcat(tickerName, '_bid'));
            currentPrice = (currentAskPrice + currentBidPrice)/2;
            disp('currentMarketPrice:');
            disp(currentPrice);
            f = ((currentPrice - openingPrice) / openingPrice)*100;
            
        end
        
        function f = getTimeRemaining(obj)
            f = getfield(obj.rotnamObject, 'timeRemaining');
        end
        
        function out = getPrices(obj, whichTicker)
            if whichTicker == 0
                out = obj.Ticker1PriceArray;
            elseif whichTicker == 1
                out = obj.Ticker2PriceArray;
            elseif whichTicker == 2
                out = obj.Ticker3PriceArray;
            elseif whichTicker == 3
                out = obj.Ticker4PriceArray;
            end
        end
        

    end
end

