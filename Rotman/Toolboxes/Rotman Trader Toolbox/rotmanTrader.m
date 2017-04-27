classdef rotmanTrader < dynamicprops
    %ROTMANTRADER connects MATLAB(R) to Rotman Interactive Trader
    %
    %   RIT = ROTMANTRADER will create a connection to the Rotman
    %   Interactive Trader API using the path specified in the Windows
    %   System registry.
    %
    %   RIT = ROTMANTRADER(DLLPATH) connects to Rotman Interactive Trader
    %   through the DLLPATH specified.  This allows connection to different
    %   dll locations.
    %
    %   A connection is required to trade from MATLAB through Rotman
    %   Interactive Trader.
    %
    %   Example:
    %   rit = rotmanTrader
    %
    %   See also: buy, sell, limitOrder, blotterOrder, addOrder
    
    % Auth/Revision:  Stuart Kozola
    %                 Copyright 2015 The MathWorks, Inc.
    %                 $Id$
    
    properties
        updateFreq = 2;
        lastUpdate = datestr(now);
        updateTimer;
        updateFcns = {};
    end
    properties (SetAccess = private)
        traderName = '';
        traderID = '';
        timeRemaining;
        period;
        yearTime;
        timeSpeed;
        allAssetTickers;
        allAssetTickerInfo;
        allTickers;
        allTickerInfo;
        
        pl;
        cash;
    end
    
    properties (Access = private)
        dllLocation = '';
        api;
        apiAssembly;
        infoRTD = RTDConnector('RIT2.RTD');
        userRTD = RTDConnector('RIT2.RTD');
        infoNames = {'traderName'; 'traderID'; 'timeRemaining'; 'period'; ...
            'yearTime'; 'timeSpeed'; 'allAssetTickers'; ...
            'allAssetTickerInfo'; 'allTickers'; 'allTickerInfo'; 'pl'};
        userNames;
        callbackList = containers.Map('KeyType','char','ValueType','any');
        
        
    end %private propeties
    
    events
        UpdatesAvailable
    end
    
    methods
        function this = rotmanTrader(dllLocation)
            %
            
            % is .NET available
            assert(NET.isNETSupported,'Microsoft .NET Framework not found.  You need to install a supported .NET Framework to connect to the Rotman Interactive Trader Application.  Please see the documentation on how to call .NET libraries for more information.')
            
            % use provided location if specified
            if ~exist('dllLocation','var')
                % find the API location
                % Create the callback class
                switch computer('arch')
                    case {'win64', 'win32'}
                        apiInfo = System.Type.GetTypeFromProgID('RIT2.API');
                    otherwise
                        error('ROTMANTRADER:UnsupportedPlatform','rotmanTrader can only run on Windows 32 or 64 bit systems')
                end
                apiLoc = char(apiInfo.Module.FullyQualifiedName);
                assert(~isempty(apiLoc),'Could not find RTI2.dll.  Please install it or provide the location using rotmanTrader(path).');
                this.dllLocation = apiLoc;
            else
                if ~ischar(dllLocation)
                    error('Path to RIT2.dll must be specified as a string');
                end
                this.dllLocation = dllLocation;
            end
            
            % Add the assembly
            this.apiAssembly = NET.addAssembly(this.dllLocation);
            
            % Instantiate the API
            this.api = TTS.API;
            
            % get general info and put into properties
            info = upper(this.infoNames);
            subscribe(this.infoRTD,info);
            
            % add the user defined names
            this.userNames = containers.Map('KeyType','int32','ValueType','char');
            
            update(this);
            
            % add timer for updates events
            fcn = @(~,~) update(this);
            this.updateTimer = timer('ExecutionMode','FixedRate',...
                'Period',this.updateFreq,'TimerFcn',fcn,'Name','RotmanTrader');
            
            % start the timer
            start(this.updateTimer);
            
        end% constructor
        
        function this = update(this)
            %UPDATE updates subscription data
            %
            %   UPDATE(RIT) will refresh the data that is in
            %   subscription.
            %
            %   Example:
            %   rit = rotmanTrader
            %   update(rit)
            %
            %   See also: stopUpdates, restartTimer
            data = updateTopics(this.infoRTD)';
            index = cell2mat(data(:,1));
            for n = 1:size(data,1)
                this.(this.infoNames{index(n)}) = data{n,2};
            end
            if ~isempty(this.userNames.values)
                data = updateTopics(this.userRTD)';
                index = cell2mat(data(:,1));
                for n = 1:size(data,1);
                    this.(this.userNames(index(n))) = data{n,2};
                end
            end
            this.lastUpdate = datestr(now);
            
            notify(this,'UpdatesAvailable');
            
        end % update
        
        function subscribe(this,newTopics)
            %SUBSCRIBE adds topic to subscription from RIT
            %
            %   SUBSCRIBE(RIT,NEWTOPICS) adds the topics defined in
            %   NEWTOPICS to the topics available from Rotman Interactive
            %   Trader defined in RIT connection object.  NEWTOPICS can be
            %   a cell array or table of topics.  Available topics are
            %   listed below, and can also be found in the RTD link in
            %   Rotman Interactive Trader.
            %
            %   NEWTOPICS can be defined as a string or cell array of
            %   strings as FIELD1|FIELD2|FIELD3 using | separators as
            %   needed fore each field.  See below for field definitions.
            %
            %   If NEWTOPICS is a table, it must contain variable names of
            %   Field1, Field2, and Field3 with the contents defined as
            %   strings.
            %
            %   If NEWTOPICS is a cell array, it must be a cell array of
            %   strings of dimensions R x 1 where each cell along R is
            %   defined as {'FIELD1','FIELD2','FIELD3'}.
            %
            %   TOPICS Available for Subscription in Rotman Interactive
            %   Trader
            %
            %   FIELD1|FIELD2|FIELD3    DESCRIPTION
            %   General
            %   TRADERID                Trader's trader ID
            %   PL                      Overall Trader's P/L
            %   TRADERNAME              Name
            %   TIMEREMAINING           Time remaining in the period
            %   PERIOD                  The period # that is running
            %   YEARTIME                Ticks in a year
            %   TIMESPEED               Speed game is currently running
            %
            %   Asset Information
            %   ALLASSETTICKERS         Comma-delimited list of all asset tickers
            %   ALLASSETTICKERINFO      Table of all asset tickers and detailed info
            %
            %   Security Information
            %   ALLTICKERS              Comma-delimited list of all security tickers
            %   ALLTICKERINFO           Table of all security tickers and detailed info
            %   TICKER|LAST             Last
            %   TICKER|BID              Bid
            %   TICKER|ASK              Ask
            %   TICKER|VOLUME           Volume
            %   TICKER|POSITION         Position
            %   TICKER|MKTSELL|N        The VWAP that would occur if you send an order to market sell N volume
            %   TICKER|MKTBUY|N         The VWAP that would occur if you send an order to market buy N volume
            %   TICKER|COST             VWAP
            %   TICKER|PLUNR            Unrealized P/L
            %   TICKER|PLREL            Realized P/L
            %   TICKER|BIDBOOK          Book view, bid side
            %   TICKER|ASKBOOK          Book view, ask side
            %   TICKER|OPENORDERS       Open personal orders to buy/sell
            %   TICKER|ALLORDERS        All personal orders to buy/sell
            %   TICKER|BID|N            The Nth bid in the book
            %   TICKER|BSZ|N            The size of the Nth bid in the book
            %   TICKER|ASK|N            The Nth ask in the book
            %   TICKER|ASZ|N            The size of the Nth ask in the book
            %   TICKER|AGBID|N          The aggregate (by price) Nth bid in the book
            %   TICKER|AGBSZ|N          The size of the aggregate (by price) Nth bid in the book
            %   TICKER|AGASK|N          The aggregate (by price) Nth ask in the book
            %   TICKER|AGASZ|N          The size of the aggregate (by price) Nth ask in the book
            %   TICKER|INTERESTRATE     The currency interest rate
            %   TICKER|LIMITORDERS      The number of live limit orders
            %
            %   Historical Information
            %   TICKER|LASTHIST|N       (N>0) Historical last value (current period) at Nth tick
            %   TICKER|LASTHIST|N       (N<=0) Historical last value (current period) |N| ticks ago
            %
            %   News Information
            %   NEWS|N                  Nth news item, most recent last
            %   LATESTNEWS|N            Nth news item, most recent first
            %
            %   Example:
            %   % create a connection
            %   rit = rotmanTrader
            %   % subscribe to the last price of CRZY using cell notation
            %   subscribe(rit,{{'CRZY','LAST'}}) % --> note the use of double {{}} for single entry!!!
            %   % subscribe to bid prices for TAME using | separators
            %   subscribe(rit,'TAME|BID|10')
            %   % subscribe using cell definition for TAME and CRZY
            %   subscribe(rit,{{'TAME','BID','20'}; {'CRZY','BID','10'}})
            %   % subscribe using a table
            %   tbl = cell2table({'TAME','ASK','20';'CRZY','ASK','10'},...
            %                'VariableNames',{'Field1','Field2','Field3'});
            %   subscribe(rit,tbl)
            %   % call update to refresh the data
            %   update(rit);
            %   rit
            %
            %   See also: rotmanTrader, unsubscribe, update
            
            this.userRTD.subscribe(newTopics);
            id = cell2mat(keys(this.userRTD.topic));
            names = lower(strrep(values(this.userRTD.topic),'|','_'));
            names = strrep(names,'-','minus');
            for p = 1:length(names)
                try
                    this.addprop(names{p});
                    this.userNames(id(p)) = names{p};
                catch e
                    if ~strcmpi(e.identifier,'MATLAB:class:PropertyInUse')
                        rethrow(e);
                    end
                end
            end
            
            update(this);
        end% subscribe
        
        function topics = getSubscriptions(this)
            %GETSUBSCRIPTIONS returns a table of active subscriptions
            %
            %   T = GETSUBSCRIPTIONS(RIT) returns the active subscriptions
            %   as a table in T for the current connection RIT to Rotman
            %   Interactive Trader.  The table T contains the subcription
            %   ID and TOPIC.
            %
            %   Example:
            %   rit = rotmanTrader;
            %   subscribe(rit,{'CRZY';'ASK'})
            %   topics = getSubscriptions(rit)
            %
            %   See also: subscribe, unsubscribe, rotmanTrader
            
            topics = table(cell2mat(keys(this.userRTD.topic)'),values(this.userRTD.topic)','VariableNames',{'ID','Topic'});
        end% getSubscriptions
        
        function unsubscribe(this,topicID)
            %UNSUBSCRIBE remove the topic from subscription list
            %
            %   UNSUBSCRIBE(RIT,TOPICID) removes the topic defined by
            %   TOPICID from the subscription to RIT.
            %
            %   Example:
            %   rit = rotmanTrader;
            %   subscribe(rit,{'CRZY';'ASK'})
            %   topics = getSubscriptions(rit)
            %   unsubscribe(rit,topics.ID)
            %   topics = getSubscriptions(rit)
            % 
            %   See also: getSubscriptions, subscribe, rotmanTrader
            
            
            for n = 1:length(topicID)
                name = this.userNames(topicID(n));
                p = findprop(this,name);
                delete(p);
                remove(this.userNames,topicID(n));
            end
            this.userRTD.unsubscribe(topicID);
            
        end % unsubscribe
        
        function status = blotterOrder(this,b,skipValidation)
            %BLOTTERORDER submits orders using an order blotter to Rotman
            %Interactive Trader.
            %
            %   ID = BLOTTERORDER(RIT,BLOTTER) submits orders to Rotman
            %   Interactive Trader, through connection RIT.  BLOTTER is the
            %   order table specifying orders to place.
            %
            %   For market orders, BLOTTER must contain the variables names
            %   TICKER, QUANTITY, and ACTION (with Buy/Sell values).
            %
            %   For limit orders, BLOTTER must contain the variable names
            %   TICKER, QUANTITY, ACTION (with Buy/Sell values) and PRICE
            %   of the limit order.  To submit a market order with limit
            %   orders, PRICE must be set to 0 or NaN for the market
            %   orders.  Otherwise the will be submitted as market orders.
            %
            %   Example:
            %   rit = rotmanTrader;
            %   % Create a blotter of buy and sells at market (no need for Price).
            %   ticker  = {'CRZY'; 'TAME'}; % tables need column vectors (use ; instead of ,)
            %   action   = {'Buy'; 'Sell'};
            %   quantity = [110; 120];
            %   blotter = table(ticker,action,quantity)
            %   % submit the blotter order
            %   blotterID = blotterOrder(rit,blotter)
            %   % Add some limit orders into the mix.  Prices must be present to define a
            %   % limit order.  Use 0 or nans for market orders in prices.
            %   ticker  = {'CRZY'; 'TAME'; 'CRZY'; 'CRZY'; 'TAME'; 'TAME'};
            %   action   = {'Buy'; 'Sell'; 'Buy'; 'Sell'; 'Buy';'Sell'};
            %   quantity = [130; 140; 150; 160; 170; 180];
            %   price   = [nan; nan; 9.50; 10.5; 24.5; 26.5];
            %   blotter = table(ticker,action,quantity, price)
            %   % submit the blotter order
            %   blotterID = blotterOrder(rit,blotter)
            %
            %   See also: buy, sell, limitOrder, addOrder
            
            if ~exist('skipValidation','var')
                skipValidation = false;
            end
            
            if ~skipValidation
                % Check for correct variable names
                validNames = {'ticker','quantity','action','price'};
                b.Properties.VariableNames = lower(b.Properties.VariableNames);
                valid = ismember(validNames,b.Properties.VariableNames);
                
                % only price is optional so check the first 3
                assert(sum(valid(1:3)) == 3, 'Blotter table must containg variable names Tickers, Quantity, and Action')
                
                if ~valid(4)
                    price = zeros(size(b.quantity));
                else
                    price = b.price;
                end
            end
            
            % create tradeQty to match buy/sell actions and limit orders
            price(isnan(price)) = 0; % remove nans
            limOrd = price ~= 0;
            buys = strcmpi(b.action,'buy');
            sells = strcmpi(b.action,'sell');
            
            tradeQty = b.quantity;
            tradeQty(~limOrd) = abs(tradeQty(~limOrd)); % make all market orders positive
            tradeQty(buys) = abs(tradeQty(buys)); % all buys are positive
            tradeQty(sells) = - abs(tradeQty(sells)); % all sells are negative
            
            % Execute trade skipping input validation if requested
            status = addOrder(this,b.ticker,tradeQty,price,'skipValidation',skipValidation);
            
        end % blotterOrder
        
        function status = buy(this,ticker,tradeQty,skipValidation)
            %BUY submits a market buy order to Rotman Interactive Trader.
            %
            %   ID = buy(RIT,TICKER,SIZE) returns queued order ID if market
            %   order was successfully submitted.  RIT is the
            %   connection to Rotman interactive Trader.  TICKER is the
            %   symbol(s) as a string or cell array of strings for the
            %   tickers to trade.  SIZE is the quantity to buy at market.
            %
            %   Example:
            %   rit = rotmanTrader;
            %   buyID = buy(rit,'CRZY',100)
            %   sellID = buy(rit,'TAME',-100) % negative is sell
            %
            %   See also sell, limitOrder, addOrder, blotterOrder
            
            if ~exist('skipValidation','var')
                skipValidation = false;
            end
            % Execute trade skipping input validation if requested
            status = addOrder(this,ticker,tradeQty,'skipValidation',...
                skipValidation);
        end % buy
        
        function cancelQueuedOrder(this,queuedID)
            %CANCELQUEUEDORDER cancels an order using the queued order id
            %
            %   CANCELQUEUEDORDER(ID) cancels a queued order that has not
            %   yet been submitted to Rotman Interactive Trader.  ID is the
            %   queued order returned from the order submissions given in
            %   see also section.  This is note the order ID seen in the
            %   Trade Blotter of RIT.  Use cancelOrder to cancel orders in
            %   RTI.
            %
            %   Example:
            %   rit = rotmanTrader;
            %   % submit orders faster than RIT can accept so they are queued.
            %   queuedID = zeros(10,1);
            %   for order = 1:10
            %       queuedID(order) = buy(rit,'CRZY',10*order);
            %   end
            %   cancelQueuedOrder(rit,queuedID)
            %   
           
            %   See also buy, sell, limitOrder, addOrder, clearQueuedOrders
            %
            
            for i = 1:length(queuedID)
                this.api.CancelQueuedOrder(queuedID(i));
            end
            
        end % cancelQueuedOrder
        
        function cancelOrderExpr(this,expr)
            %CANCELORDEREXPR cacnels open orders that satisfy the
            %expression
            %
            %   CANCELORDEREXPR(RIT, EXPR) cancels the orders that
            %   satisfy the expression in EXPR.  RIT is the connection
            %   object to Rotman Interactive Trader.
            %
            %   Example
            %   rit = rotmanTrader;
            %   queuedID(1) = limitOrder(rit,'CRZY',90,20.00);
            %   pause(3) % seconds to submit next order
            %   queuedID(2) = limitOrder(rit,'CRZY',110,20.00);
            %   tf = isOrderQueued(rit,queuedID)
            %   orderID = getOrders(rit)
            %   expr = 'Price < 25.00 AND Volume < 100';
            %   cancelOrderExpr(rit,expr)
            %
            %   See also cancelOrder, cancelQueuedOrder, isOrderQueued,
            %   rotmanTrader, buy, sell, limitOrder, addOrder
            
            if ischar(expr)
                expr = {expr};
            end
            
            for i = 1:length(expr)
                this.api.CancelOrderExpr(expr{i});
            end
            
        end % cancelOrderExp
        
        function cancelOrder(this,orderID)
            %CANCELORDER cancels an open order using the order id
            %
            %   CANCELORDER(ID) cancels an open order in Rotman Interactive
            %   Trader using the order ID in ID.  There is no return value
            %   from this function.
            %
            %   Note that ID is not the id returned from other functions
            %   listed in see also section.  It is the ID seen in the Trade
            %   Blotter window in Rotman Interactive Trader.
            %
            %   Example:
            %   rit = rotmanTrader;
            %   sellID = limitOrder(rit,'CRZY',100,12); % this is queued id, not order id
            %   pause(3) % for order to submit
            %   orderID = getOrders(rit)
            %   cancelOrder(rit,orderID)
            %   
            %   See also buy, sell, limitOrder, addOrder
            %
            
            for i = 1:length(orderID)
                this.api.CancelOrder(orderID(i));
            end
            
        end % cancelOrder
        
        function clearQueuedOrders(this)
            %CLEARQUEUUEDORDERs cancels all queued orders
            %
            %   CLEARQUEUEORDERS cacels all queued orders that have not
            %   yet been submitted to Rotman Interactive Trader.
            %
            %   Note that this does not cancel the order show in RIT.  Only
            %   those in the queue to be submitted.
            %
            %   Example:
            %   rit = rotmanTrader;
            %   % submit orders faster than RIT can accept so they are queued.
            %   queuedID = zeros(10,1);
            %   for order = 1:10
            %       queuedID(order) = buy(rit,'CRZY',10*order);
            %   end
            %   clearQueuedOrders(rit)
            %   See also buy, sell, limitOrder, addOrder, cancelQueuedOrder
            %
            
            this.api.ClearQueuedOrders;
            
        end % clearQueuedOrders
        
        function status = sell(this,ticker,tradeQty,skipValidation)
            %SELL submits a market sell order to Rotman Interactive Trader.
            %
            %   ID = SELL(RIT,TICKER,SIZE) returns queued order id if
            %   market order was successfully submitted.  RIT is the
            %   connection to Rotman interactive Trader.  TICKER is the
            %   symbol(s) as a string or cell array of strings for the
            %   tickers to trade.  SIZE is the quantity to buy at market.
            %
            %   Example:
            %   rit = rotmanTrader;
            %   sellID = sell(rit,'TAME',200)
            %   buyID = sell(rit,'CRZY',-200)
            %
            %   See also buy, limitOrder, addOrder, blotterOrder
            
            if ~exist('skipValidation','var')
                skipValidation = false;
            end
            % Execute trade skipping input validation if requested
            status = addOrder(this,ticker,-tradeQty,'skipValidation',skipValidation);
        end % sell
        
        function set.allTickers(this,value)
            if ~isempty(value) && ischar(value)
                this.allTickers = regexp(value,',','split');
            else
                this.allTickers = value;
            end
        end
        
        function set.updateFreq(this,value)
            this.updateFreq = value;
            restartTimer(this);
        end
        
        
        function set.allAssetTickers(this,value)
            if ~isempty(value) && ischar(value)
                this.allAssetTickers = regexp(value,',','split');
            else
                this.allAssetTickers = value;
            end
        end
        
        function set.allTickerInfo(this,value)
            if ~isempty(value) && ischar(value)
                value = regexp(value,';','split');
                value = regexp(value',',','split');
                tmp = {};
                for i = 1:length(value)
                    tmp = [tmp; value{i}]; %#ok<AGROW>
                end
                this.allTickerInfo = tmp;
            else
                this.allTickerInfo = value;
            end
        end
        
        function set.allAssetTickerInfo(this,value)
            if ~isempty(value) && ischar(value)
                value = regexp(value,';','split');
                value = regexp(value',',','split');
                tmp = {};
                for i = 1:length(value)
                    tmp = [tmp; value{i}]; %#ok<AGROW>
                end
                this.allAssetTickerInfo = tmp;
            else
                this.allAssetTickerInfo = value;
            end
        end
        
        function restartTimer(this)
            %RESTARTTIMER will restart the timer for updates if stopped
            %
            %   RESTARTTIMER(RIT) restarts the timer if stopped.
            stop(this.updateTimer);
            this.updateTimer.Period = this.updateFreq;
            start(this.updateTimer);
        end
        
        function status = limitOrder(this,ticker,tradeQty,price,skipValidation)
            %LIMITORDER submits a limit order to Rotman Interactive Trader.
            %
            %   ID = LIMITORDER(RIT,TICKER,QTY,PRICE) submits a market buy
            %   or sell order depending upon the sign of QTY and returns
            %   queued ID when order is accepted.  False (0) if not
            %   accepted, and -1 if the case is not running.    RIT is the
            %   connection to Rotman interactive Trader.  TICKER is the
            %   symbol(s) as a string or cell array of strings for the
            %   securities to trade.  QTY is the quantity to submit for bid
            %   (buy) or ask (sell).  Price is the bid/ask price to offer.
            %
            %   QTY defines the limit order as a buy limit order if
            %   positive.  If QTY is negative, submits a sell limit order.
            %
            %   Example:
            %   rit = rotmanTrader;
            %   limitBuyID = limitOrder(rit,'CRZY',90,20.00)
            %   limitSellID = limitOrder(rit,'TAME',-100,15.00)
            %   
            %   See also buy, sell, addOrder, blotterOrder
            
            if ~exist('skipValidation','var')
                skipValidation = false;
            end
            % Execute trade skipping input validation if requested
            status = addOrder(this,ticker,tradeQty,price,'skipValidation',skipValidation);
        end
        
        function addUpdateFcn(this,fcn)
            %ADDUPDATEFCN adds the function to the list of callbacks
            %
            %   addUpdateFcn(RIT,FCN) adds the function defined as
            %   a function handle in FCN to the list of functions that will
            %   be called when a data update is available.  RIT is
            %   the connection object the Rotman Interactive Trader.
            %
            %   FCN takes in the RIT object as input.
            %
            %   Example:
            %   % display the ask price for 'CRZY' to the command line
            %   rit = rotmanTrader;
            %   subscribe(rit,'CRZY|ASK')
            %   askfcn = @(input) disp(['CRZY ASK Price is $',num2str(input.crzy_ask,'%4.2f')])
            %   addUpdateFcn(rit,askfcn)
            %   pause(10)
            %   delete(rit) % stops updates
            %   clear rit
            
            if ~isa(fcn,'function_handle')
                error('ROTMANTRADER:invalideFunction','Input must be a function handle');
            end
            fcnName = func2str(fcn);
            lh = addlistener(this,'UpdatesAvailable',@(src,evnt)fcn(this));
            this.callbackList(fcnName) = lh;
            this.updateFcns = keys(this.callbackList);
        end % addCallbackFcn
        
        function removeUpdateFcn(this,fcnName)
            %REMOVEUPDATEFCN removes the specified function from updates
            %
            %   REMOVEUPDATEFCN(RIT,FCNNAME) removes the function
            %   defined in FCNNAME from the list of functions that are
            %   called each time an update to RIT occurs.
            %
            %   Example:
            %   % display the ask price for 'CRZY' to the command line
            %   rit = rotmanTrader;
            %   subscribe(rit,'CRZY|ASK')
            %   askfcn = @(input) disp(['CRZY ASK Price is $',num2str(input.crzy_ask,'%4.2f')])
            %   addUpdateFcn(rit,askfcn)
            %   pause(10)
            %   removeUpdateFcn(rit,rit.updateFcns{1})
            %   pause(10) % will no longer see display updates
            %   delete(rit) % stops updates completely
            %   clear rit
            delete(this.callbackList(fcnName));
            remove(this.callbackList,fcnName);
            this.updateFcns = keys(this.callbackList);
        end
        
        function status = addOrder(this,ticker,tradeQty,varargin)
            %ADDORDER submits an order to Rotman Interactive Trader.
            %
            %   ST = addOrder(RIT,TICKER,QTY) submits a market buy or sell
            %   order depending upon the sign of QTY and returns queued ID
            %   when order is accepted.  False (0) if not accepted, and -1 if
            %   the case is not running.  RIT is the connection object to
            %   Rotman Interactive Trader.  TICKER is a list of securities
            %   to trade as a cell array or scalar string.  QTY is the
            %   order size.  If QTY is positive, the order will be
            %   submitted as BUY order.  If QTY is negative, the order will
            %   be submitted as a SELL order.
            %
            %   ST = addOrder(RIT,TICKER,QTY,PRICE) submits a limit buy or
            %   sell order depending upon the sign of PRICE.  If QTY is
            %   positive, submits a buy limit order with bid of PRICE.  If
            %   QTY is negative, submits a sell limit order with ask of
            %   PRICE.
            %
            %   Example:
            %   rit = rotmanTrader;
            %   status = addOrder(rit,'CRZY',100) % buy
            %   status = addOrder(rit,'TAME',-100) % sell
            %   status = addOrder(rit,{'CRZY','TAME'},[200, -200])
            %   status = addOrder(rit,{'CRZY','TAME'},[300, -300],[15,26])
            %
            %   See also: buy, sell, limitOrder, blotterOrder
            
            %   STATUS = addOrder(...,NAME,VALUE) spefifies additional options
            %   using name-value pair assignment.
            price = zeros(size(tradeQty));
            skipValidation = false;
            
            if ~exist('varargin','var')
                varargin = {}; %#ok<NASGU>
            else
                i = 1;
                while i <= length(varargin);
                    if isnumeric(varargin{i})
                        price = varargin{i};
                    else
                        switch lower(varargin{i})
                            case {'skipvalidation','skip'}
                                skipValidation = varargin{i+1};
                                i = i+1;
                            otherwise
                                error('Did not recognize input.  See help addOrders for proper use')
                        end
                    end
                    i = i+1;
                end
            end
            
            if ~skipValidation
                % parse inputs
                if ischar(ticker) % string case
                    ticker = {ticker};
                elseif ~iscell(ticker)
                    error('Ticker input should be a string or a cell array of strings.')
                end
                
                % check tradeQty and ticker size
                ntick = length(ticker);
                nqty = length(tradeQty);
                if nqty > ntick
                    error('Trader order quantity QTY must be same size as TICKERS.')
                elseif nqty < ntick
                    tradeQty = repmat(tradeQty,size(ticker));
                    if length(price) ~= ntick
                        price = repmat(price,size(ticker));
                    end
                end
            end % validation
            
            % Submit the order(s)
            % API.AddOrder(ticker, sizeTrade, priceTrade, buy_sell, lmt_mkt)
            status = zeros(size(tradeQty));
            for order = 1:length(tradeQty)
                status(order) = this.api.AddQueuedOrder(ticker{order},abs(tradeQty(order)),price(order),sign(tradeQty(order)),price(order) ~= 0);
            end
            
        end %addOrder
        
        function pnl = get.pl(this)
            %GETPNL returns trader profit and loss info
            %
            %   PNL = get.pl(RIT) returns the profit and loss information
            %   for the trader's account.  RIT is the connection object to
            %   Rotman Interactive Trader.
            %
            %   Example:
            %   rit = rotmanTrader;
            %   pnl = getpl(rit);
            %
            %   See also: rotmanTrader, getCash
            
            pnl = this.pl;
        end
        
        function cash = get.cash(this)
            %GETCASH returns current cash balance
            %
            %   CASH = GET.CASH(RIT) returns the current cash blance in the
            %   traders account.  RIT is the connection object to Rotman
            %   Interactive Trader.
            %
            %   Example:
            %   rit = rotmanTrader;
            %   cash = get.cash(rit)
            %
            %   See also: rotmanTrader, getPnL
            
            cash = this.api.GetCash;
        end
        
        function tf = isOrderQueued(this,queuedID)
            %ISORDERQUEUED returns true or false if the order is queued
            %
            %   TF = ISORDERQUEUED(RIT,QUEUEDID) returns true of the order
            %   is in the queue and false if it is not.  RIT is the
            %   connection object to Rotman Interactive Trader.  QUEUEDID
            %   is the order id returned from the functions in the see also
            %   section.  Note that this is not the same ID as the order ID
            %   in the Trade Blotter of Rotman Interactive Trader.
            %
            %   Example:
            %   rit = rotmanTrader;
            %   % submit orders faster than RIT can accept so they are queued.
            %   queuedID = zeros(10,1);
            %   for order = 1:10
            %       queuedID(order) = buy(rit,'CRZY',10*order);
            %   end
            %   TF = isOrderQueued(rit,queuedID)
            %   
            %
            %   See also cancelOrder, cancelQueuedOrder, clearQueuedOrders,
            %   rotmanTrader, buy, sell, limitOrder, addOrder
            %
            tf = false(size(queuedID));
            for i = 1:length(queuedID)
                tf(i) = this.api.IsOrderQueued(queuedID(i));
            end
            
        end %isOrderQueuedID
        
        function id = getOrders(this)
            %GETORDERS returns order id's
            %
            %   ID = GETORDERS(RIT) returns order id's available in the
            %   active session of Rotman Interactive Trader.  RIT is the
            %   connection object for the current session.
            %
            %   Example:
            %   rit = rotmanTrader;
            %   id = getOrders(rit);
            %
            %   See also: getOrderInfo
            
            orders = this.api.GetOrders;
            if orders.Length == 0 % no orders to retrieve
                id = 0;
            else
                id = double(orders);
            end
        end
        
        function blotter = getOrderInfo(this,orderID)
            %GETORDERINFO returns open order information
            %
            %   BLOTTER = GETORDERINFO(RIT) returns order
            %   information for any open or partially filled orders using
            %   the connection RIT.  BLOTTER is a table of
            %   information containing the order id, ticker symbol, type of
            %   order, order type, quantity, price, and status.
            %   
            %   BLOTTER = GETORDERINFO(RIT,ORDERID) returns order
            %   information for orders specified in ORDERID.
            %
            %   BLOTTER will return empty if there is no active orders.
            %
            %   Example:
            %   rit = rotmanTrader;
            %   limitSellID = limitOrder(rit,'CRZY',90,20.00)
            %   limitBuyID = limitOrder(rit,'TAME',-100,15.00)
            %   pause(3)
            %   orderID = getOrders(rit);
            %   blotter = getOrderInfo(rit,orderID)
            %
            %   
            %   See also: limitOrder, getOrders, buy, sell, cancelOrder
            if ~exist('orderID','var') || isempty(orderID)
                orderID = getOrders(this);
            end
            blotter = struct('OrderID',{},'Ticker',{},'Type',{},...
                'OrderType',{},'Quantity',{},'Price',{},'Status',{},...
                'Quantity2',{});
            emptyID = false(size(orderID));
            for id = 1:length(orderID)
                info = this.api.GetOrderInfo(orderID(id));
                if isempty(info) || info.Length == 0;
                    emptyID(id) = true;
                    continue;
                end
                blotter(id).OrderID = double(info(1));
                blotter(id).Ticker = char(info(2));
                blotter(id).Type = char(info(4));
                blotter(id).OrderType = char(info(5));
                blotter(id).Quantity = info(6).ToDouble(info(6));
                blotter(id).Price = info(7).ToDouble(info(7));
                blotter(id).Status = char(info(8));
                blotter(id).Quantity2 = info(9).ToDouble(info(9));
            end
            
            if isempty(blotter)
                blotter = [];
            else
                blotter = blotter(~emptyID);
                blotter = struct2table(blotter);
            end
            
        end
        
        function blotter = getTickerInfo(this,tickers)
            %GETTICKERINFO returns ticker information as a table
            %
            %   BLOTTER = GETTICKERINFO(RIT,TICKERS) returns
            %   information for specified TICKERS (cell array of strings)
            %   for a connection RIT.  BLOTTER is a table of
            %   information about the portfolio of TICKERS
            %
            %   Example:
            %   rit = rotmanTrader;
            %   ticker  = {'CRZY'; 'TAME'; 'CRZY'; 'CRZY'; 'TAME'; 'TAME'};
            %   action   = {'Buy'; 'Sell'; 'Buy'; 'Sell'; 'Buy';'Sell'};
            %   quantity = [130; 140; 150; 160; 170; 180];
            %   price   = [nan; nan; 9.50; 10.5; 24.5; 26.5];
            %   blotter = table(ticker,action,quantity, price)
            %   % submit the blotter order
            %   blotterID = blotterOrder(rit,blotter)
            %   info = getTickerInfo(rit,ticker)
            %
            %   See also: rotmanTrader, blotterOrder, getOrderInfo
            
            
            if ischar(tickers)
                tickers = {tickers};
            end
            
            blotter = struct('Ticker',{},'Position',{},'Last',{},...
                'ID',{},'Bid',{},'Ask',{},'LastVolume',{},'ID3',{},...
                'Volume',{},'Cost',{},'UnrealizedPnL',{},'RealizedPnL',{},'ID7',{});
            for t = 1:length(tickers)
                info = this.api.GetTickerInfo(tickers{t});
                blotter(t).Ticker = char(info(1));
                blotter(t).Position = info(2).ToDouble(info(2));
                blotter(t).Last = info(3).ToDouble(info(3));
                blotter(t).ID = info(4).ToDouble(info(4));
                blotter(t).Bid = info(5).ToDouble(info(5));
                blotter(t).Ask = info(6).ToDouble(info(6));
                blotter(t).LastVolume = info(7).ToDouble(info(7));
                blotter(t).ID3 = double(info(8));
                blotter(t).Volume = info(9).ToDouble(info(9));
                blotter(t).Cost = info(10).ToDouble(info(10));
                blotter(t).UnrealizedPnL = info(11).ToDouble(info(11));
                blotter(t).RealizedPnL = info(12).ToDouble(info(12));
                blotter(t).ID7 = char(info(13));
                %blotter(t).VolumeStr = char(info(14));
            end
            
            blotter = struct2table(blotter);
        end
        
        function stopUpdates(this)
            %STOPUPDATES stops real-time updates by stopping the timer
            %
            %   STOPUPDATES(RIT) stops updates by stopping the
            %   timer.  To restart update, restart the timer.
            %
            %   See also: restartTimer, update
            if ~isempty(this.updateTimer)
                stop(this.updateTimer);
            end
        end
        
        function delete(this)
            %DELETE stops updates and deletes rotmanTrader object
            %
            %   DELETE(RIT) stops the timer and updates and celars
            %   the object prior to destroying it.  You should always run
            %   DELETE prior to using CLEAR so it stops the timer
            %   appropriately.  If you do not, the time and rotmanTrader
            %   may remain in MATLAB's memory.  If CLEAR was run, use
            %   delete(timerfindall) to stop all timer objects runnint.
            %
            %   See also timerfindall, timer.delete
            stopUpdates(this);
            delete(this.updateTimer);
        end
        
        
    end % methods
    
end % rotmanTrader