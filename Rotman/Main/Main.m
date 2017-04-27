function Main()
%MAIN Summary of this function goes here
%   Detailed explanation goes here

    %Enter Ticker Names Here
    ticker1Name = lower('pooh');
    ticker2Name = lower('tigr');
    ticker3Name = lower('eyor');
    ticker4Name = lower('huny');
    
    %Tickers Opening Price
    ticker1OpeningPrice = 20;
    ticker2OpeningPrice = 20;
    ticker3OpeningPrice = 20;
    ticker4OpeningPrice = 80;

    
    %SUbscrive INformation to RIT
    rit = rotmanTrader;
    rit.updateFreq = 0.3;
    ticker1BidBook = strcat(upper(ticker1Name) , '|BIDBOOK');
    ticker1AskBook = strcat(upper(ticker1Name), '|ASKBOOK');
    ticker1Position = strcat(upper(ticker1Name), '|POSITION');
    ticker1BidPrice = strcat(lower(ticker1Name), '|BID');
    ticker1AskPrice = strcat(lower(ticker1Name), '|ASK');
    ticker1Cost = strcat(lower(ticker1Name), '|COST');
    ticker1PLUNR = strcat(lower(ticker1Name), '|PLUNR');
    ticker1PLREL = strcat(lower(ticker1Name), '|PLREL');
    

    ticker2BidBook = strcat(upper(ticker2Name) , '|BIDBOOK');
    ticker2AskBook = strcat(upper(ticker2Name), '|ASKBOOK');
    ticker2Position = strcat(upper(ticker2Name), '|POSITION');
    ticker2BidPrice = strcat(lower(ticker2Name), '|BID');
    ticker2AskPrice = strcat(lower(ticker2Name), '|ASK');
    ticker2Cost = strcat(lower(ticker2Name), '|COST');
    ticker2PLUNR = strcat(lower(ticker2Name), '|PLUNR');
    ticker2PLREL = strcat(lower(ticker2Name), '|PLREL');
    
    ticker3BidBook = strcat(upper(ticker3Name) , '|BIDBOOK');
    ticker3AskBook = strcat(upper(ticker3Name), '|ASKBOOK');
    ticker3Position = strcat(upper(ticker3Name), '|POSITION');
    ticker3BidPrice = strcat(lower(ticker3Name), '|BID');
    ticker3AskPrice = strcat(lower(ticker3Name), '|ASK');
    ticker3Cost = strcat(lower(ticker3Name), '|COST');
    ticker3PLUNR = strcat(lower(ticker3Name), '|PLUNR');
    ticker3PLREL = strcat(lower(ticker3Name), '|PLREL');
    
    ticker4BidBook = strcat(upper(ticker4Name) , '|BIDBOOK');
    ticker4AskBook = strcat(upper(ticker4Name), '|ASKBOOK');
    ticker4Position = strcat(upper(ticker4Name), '|POSITION');
    ticker4BidPrice = strcat(lower(ticker4Name), '|BID');
    ticker4AskPrice = strcat(lower(ticker4Name), '|ASK');
    ticker4Cost = strcat(lower(ticker4Name), '|COST');
    ticker4PLUNR = strcat(lower(ticker4Name), '|PLUNR');
    ticker4PLREL = strcat(lower(ticker4Name), '|PLREL');

    subscribe(rit, {ticker1BidBook; ticker1AskBook; ticker1BidPrice; ticker1AskPrice; ticker1Position;...
        ticker2BidBook; ticker2AskBook; ticker2BidPrice; ticker2AskPrice; ticker2Position;...
        ticker3BidBook; ticker3AskBook; ticker3BidPrice; ticker3AskPrice; ticker3Position;...
        ticker4BidBook; ticker4AskBook; ticker4BidPrice; ticker4AskPrice; ticker4Position;...
        ticker1Cost; ticker2Cost; ticker3Cost; ticker4Cost; ticker1PLUNR; ticker1PLREL;...
        ticker2PLUNR; ticker2PLREL; ticker3PLUNR; ticker3PLREL; ticker4PLUNR; ticker4PLREL;});
    
    disp(rit);

    dataHandler = DataHandler(rit);
    timeRemaining = 300;
        
    keepLooping = true;
    guiObject = GUI(rit);
    Ticker1Control = Ticker1Controller(guiObject, dataHandler, rit, ticker1Name);
    Ticker2Control = Ticker2Controller(guiObject, dataHandler, rit, ticker2Name);
    Ticker3Control = Ticker3Controller(guiObject, dataHandler, rit, ticker3Name);
    Ticker4Control = Ticker4Controller(guiObject, dataHandler, rit, ticker4Name);
    
    previousTick = 0;
    while keepLooping        
        if rit.timeRemaining < timeRemaining
            currentTick = (timeRemaining - rit.timeRemaining);
            %disp([currentTick 1]);
            if  currentTick - previousTick >= 1
                previousTick = currentTick;
                askPrice = getfield(rit, strcat(ticker1Name, '_ask'));
                bidPrice = getfield(rit, strcat(ticker1Name, '_bid'));
                dataHandler.Ticker1PriceArray = [dataHandler.Ticker1PriceArray, (askPrice + bidPrice)/2];
                ask2Price = getfield(rit, strcat(ticker2Name, '_ask'));
                bid2Price = getfield(rit, strcat(ticker2Name, '_bid'));
                dataHandler.Ticker2PriceArray = [dataHandler.Ticker2PriceArray, (ask2Price + bid2Price)/2];
                ask3Price = getfield(rit, strcat(ticker3Name, '_ask'));
                bid3Price = getfield(rit, strcat(ticker3Name, '_bid'));
                dataHandler.Ticker3PriceArray = [dataHandler.Ticker2PriceArray, (ask3Price + bid3Price)/2];
                ask4Price = getfield(rit, strcat(ticker4Name, '_ask'));
                bid4Price = getfield(rit, strcat(ticker4Name, '_bid'));
                dataHandler.Ticker4PriceArray = [dataHandler.Ticker2PriceArray, (ask4Price + bid4Price)/2];             
            end
            %disp([currentTick 2]);
            Ticker1Control.transitionFunction();
            Ticker2Control.transitionFunction();
            Ticker3Control.transitionFunction();
            Ticker4Control.transitionFunction();
            %disp([currentTick 3]);
        end
        %TODO: Debate Whether To Remove This Or Not
        pause(0.5)
    end 
end


