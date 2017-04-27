%% Trading with Rotman Intractive Trader
% This example shows how to use the rotmanTrader functions to connect to
% and trade through Rotman Interactive Trader (RIT).  RIT must be installed
% on your computer along with the Excel(R) RTD Links.  For more information
% visit http://rit.rotman.utoronto.ca/software.asp.  This example also
% assumes that RIT is running Liability Trading 3 Case.

% Copyright 2015 The MathWorks, Inc.

%% Create a Connection
% First create a connection to Rotman Interactive Trader and list the
% functions (methods) available.
rit = rotmanTrader;
methods(rit)

%%
% To get more information on the functions, type help or doc and the name
% of the function.  For example:
help rotmanTrader
help rotmanTrader/buy
help sell % same as help rotmanTrader/sell

%% Submitting Market Orders
% Buy and sell market order for a single security.  For both |buy| and
% |sell| functions, the returned value is the orderID.
buyID = buy(rit,'CRZY',10)
sellID = sell(rit,'TAME',15)

%%
% Buy and sell market order for multiple securities at same quantity
tickers = {'CRZY','TAME'};
qty = 20;
buyID = buy(rit,tickers,qty)
sellID = sell(rit,tickers,qty)

%%
% Buy and sell market orders for multiple securities at diferent quantities
buyID = buy(rit,tickers,[30 40])
buyID = sell(rit,tickers, [50 60])

%%
% Type of order can also be changed based upon the qty sign.  If submitting
% a buy order with quantity of -70 it becomes a sell order.
buyID = buy(rit,'CRZY',-70)  % becomes sell order
sellID = sell(rit,'TAME',-80) % becomes buy order

%% Submitting Limit Orders
% Limit orders can be submitted using the limitOrder function.
help limitOrder

%%
% Submit a buy limit order, a bit for CRZY at price of 20.00 and quantity
% 90
buyID = limitOrder(rit,'CRZY',90,20.00)
%%
% Submit a sell limit order, an ask for TAME at price of 15.00 and quantity
% 100. Note the quantity is (-) negative, to denote a sell limit order.
limitID = limitOrder(rit,'TAME',-100,15.00)

%% Submit Orders Using a Blotter
% Create an order blotter, a table with order information
help blotterOrder
%%
% Create a blotter of buy and sells at market (no need for Price).
ticker  = {'CRZY'; 'TAME'}; % tables need column vectors (use ; instead of ,)
action   = {'Buy'; 'Sell'};
quantity = [110; 120];
blotter = table(ticker,action,quantity)

%%
% submit the blotter order
blotterID = blotterOrder(rit,blotter)

%%
% Add some limit orders into the mix.  Prices must be present to define a
% limit order.  Use 0 or nans for market orders in prices.
ticker  = {'CRZY'; 'TAME'; 'CRZY'; 'CRZY'; 'TAME'; 'TAME'};
action   = {'Buy'; 'Sell'; 'Buy'; 'Sell'; 'Buy';'Sell'};
quantity = [130; 140; 150; 160; 170; 180];
price   = [nan; nan; 9.50; 10.5; 24.5; 26.5];
blotter = table(ticker,action,quantity, price)

%%
% submit the blotter order
tf = blotterOrder(rit,blotter)
pause(10)
%%
id = getOrders(rit)

%%
orderBlotter = getOrderInfo(rit,id)

%% Canceling Orders
% Cancel an order by order ID
cancelID = id(1);
cancelOrder(rit,cancelID)
pause(3)
orderBlotter = getOrderInfo(rit,id)

%%
% Cancel orders by expression
expr = 'Price <= 15.00 AND ticker = ''CRZY''';
cancelOrderExpr(rit,expr)
pause(3)
orderBlotter = getOrderInfo(rit,id)

%% Cancel Queued Orders
% Orders are submitted to Rotaman Interactive Trader and may be queued if
% the orders are submitted faster than the case allows.  The queued orders
% can be queried and even deleted.  Resubmite the blotter order from above,
% query which ones are still queued, and then cancel them.
blotter
queuedID = blotterOrder(rit,blotter)
inQueue = isOrderQueued(rit,queuedID)
cancelQueuedOrder(rit,queuedID(inQueue))
isOrderQueued(rit,queuedID)
id = getOrders(rit)
orderBlotter = getOrderInfo(rit,id)

%%
% Alternatively, you can submit orders faster than RIT can accept them.
% This allows canceling queued orders that have not been accepted yet (9 of
% 10 orders will be canceled).
queuedID = zeros(10,1);
for order = 1:10
    queuedID(order) = buy(rit,'CRZY',10*order);
end
cancelQueuedOrder(rit,queuedID)

%%
% Can also clear all queued orders using clearQueuedOrders
blotter
queuedID = blotterOrder(rit,blotter)
inQueue = isOrderQueued(rit,queuedID)
clearQueuedOrders(rit)
isOrderQueued(rit,queuedID)
id = getOrders(rit)
orderBlotter = getOrderInfo(rit,id)

%% Cleaning Up
% To properly clean up, you first need to delete the |rotmanTrader|
% connection before clearing it from the workspace.  This stops the updates
% and disconnect from Rotman Interactive Trader.
delete(rit)
clear rit

%%
% We now no longer have a connection.
%
% If you cleared the rit variable before issuing delete, the update timer is
% still running in the background, and you may see errors/warnings.  To
% stop it, issue the following command:
delete(timerfind('Name','RotmanTrader'))
