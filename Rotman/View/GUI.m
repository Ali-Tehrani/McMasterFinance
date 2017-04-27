classdef GUI < handle
    %GUI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        order;
        ticker1Name;
        ticker1OnOff;
        ticker1Un;
        ticker1MarketMake;
        ticker1TakeProfit;
        ticker1TrendBuyPriceBeha;
        ticker1TrendSellPriceBeha;
            
        ticker2OnOff;
        ticker2Unloading;
        ticker2MarketMaking;
        ticker2TakeProfit;
        ticker2TrendPriceBeha;
        ticker2TrendBuyPriceBeha;
        ticker2TrendSellPriceBeha;
        
        ticker3OnOff; 
        ticker3Unloading;
        ticker3MarketMaking;
        ticker3TakeProfit;
        ticker3TrendPriceBeha
        ticker3TrendBuyPriceBeha;
        ticker3TrendSellPriceBeha;        
        
        ticker4OnOff;
        ticker4Unloading;
        ticker4MarketMaking;
        ticker4TakeProfit;
        ticker4TrendPriceBeha
        ticker4TrendBuyPriceBeha;
        ticker4TrendSellPriceBeha;
    end
    
    methods
        function obj = GUI(rotmanObject)
            f = figure('Position', [0 0 750 510]);
            obj.ticker1GUI();
            obj.ticker2GUI();
            obj.ticker3GUI();
            obj.ticker4GUI();
            obj.order = OrderPlacement(rotmanObject);
        end
        
        function ticker1GUI(obj) 
            text_ticker1 = uicontrol('Style','text', 'Position', [10, 380, 100, 30],...
                            'String', 'First Ticker');     
            volume = uicontrol('Style','text', 'Position', [10, 360, 100, 30],...
                            'String', 'Volume');                           
            obj.ticker1Name = uicontrol('Style', 'edit', 'Position', [10, 350, 80, 20]);
            obj.ticker1OnOff = uicontrol('Style', 'radiobutton', 'String', 'ON/OFF',...
                            'Position', [20 310 100 30]);
            obj.ticker1Un = uicontrol('Style', 'radiobutton', 'String', 'Unloading',...
                            'Position', [20 285 100 30]);
            obj.ticker1MarketMake = uicontrol('Style', 'radiobutton', 'String', 'MarketMaking',...
                            'Position', [20 250 100 30]);
            obj.ticker1TakeProfit = uicontrol('Style', 'radiobutton', 'String', 'Tr: Take Profit',...
                'Position', [20 220 100 30]);
            uicontrol('Style', 'pushbutton', 'String', 'B', 'Position', [20 190 30 30], 'Callback',...
                {@(hObject,callbackdata)obj.order.orderPlacementManualBuy('POOH')});
            uicontrol('Style', 'pushbutton', 'String', 'S', 'Position', [60 190 30 30], 'Callback',...
                {@(hObject,callbackdata)obj.order.orderPlacementManualSell('POOH')});   
            
            
            obj.ticker1TrendBuyPriceBeha = uicontrol('Style', 'radiobutton', 'String', 'B:Tr $ Behavi',...
                'Position', [20 160 100 30]);
            obj.ticker1TrendSellPriceBeha = uicontrol('Style', 'radiobutton', 'String', 'S:Tr $ Behavi',...
                'Position', [20 130 100 30]);
        end
        
        function ticker2GUI(obj)
            textTicker2 = uicontrol('Style','text',...
                'Position', [150, 380, 100, 30],...
                'String', 'Second Ticker');       
            obj.ticker2OnOff = uicontrol('Style', 'radiobutton', 'String', 'ON/OFF',...
                'Position', [150 310 100 30]);
            obj.ticker2Unloading = uicontrol('Style', 'radiobutton', 'String', 'Unloading',...
                'Position', [150 285 100 30]);  
            obj.ticker2MarketMaking = uicontrol('Style', 'radiobutton', 'String', 'Market Making',...
                'Position', [150 255 100 30]);  
            obj.ticker2TakeProfit = uicontrol('Style', 'radiobutton', 'String', 'T: Take Profit',...
                'Position', [150 225 100 30]);  
            uicontrol('Style', 'pushbutton', 'String', 'B', 'Position', [150 195 30 30], 'Callback',...
                {@(hObject,callbackdata)obj.order.orderPlacementManualBuy('TIGR')});
            uicontrol('Style', 'pushbutton', 'String', 'S', 'Position', [180 195 30 30], 'Callback',...
                {@(hObject,callbackdata)obj.order.orderPlacementManualSell('TIGR')});
            obj.ticker2TrendBuyPriceBeha = uicontrol('Style', 'radiobutton', 'String', 'B:Tr $ Behavi',...
                'Position', [150 165 100 30]);
            obj.ticker2TrendSellPriceBeha = uicontrol('Style', 'radiobutton', 'String', 'S:Tr $ Behavi',...
                'Position', [150 135 100 30]);
        end
        
        function ticker3GUI(obj)
            textTicker3 = uicontrol('Style','text',...
                'Position', [270, 380, 100, 30],...
                'String', 'Third Ticker');
            
            obj.ticker3OnOff = uicontrol('Style', 'radiobutton', 'String', 'ON/OFF',...
                'Position', [290 310 100 30]);
            obj.ticker3Unloading = uicontrol('Style', 'radiobutton', 'String', 'Unloading',...
                'Position', [290 285 100 30]);  
            obj.ticker3MarketMaking = uicontrol('Style', 'radiobutton', 'String', 'Market Making',...
                'Position', [290 255 100 30]); 
            obj.ticker3TakeProfit = uicontrol('Style', 'radiobutton', 'String', 'T: Take Profit',...
                'Position', [290 225 100 30]); 
            uicontrol('Style', 'pushbutton', 'String', 'B', 'Position', [290 195 30 30], 'Callback',...
                {@(hObject,callbackdata)obj.order.orderPlacementManualBuy('EYOR')});
            uicontrol('Style', 'pushbutton', 'String', 'S', 'Position', [320 195 30 30], 'Callback',...
                {@(hObject,callbackdata)obj.order.orderPlacementManualSell('EYOR')});
            obj.ticker3TrendBuyPriceBeha = uicontrol('Style', 'radiobutton', 'String', 'B: Tr $ Behavi',...
                'Position', [290 165 100 30]);  
            obj.ticker3TrendSellPriceBeha = uicontrol('Style', 'radiobutton', 'String', 'S: Tr $ Behavi',...
                'Position', [290 135 100 30]);                 
        end
        
        function ticker4GUI(obj)
            textTicker4 = uicontrol('Style','text',...
            'Position', [405, 380, 100, 30],...
            'String', 'Fourth Ticker ETF');

            obj.ticker4OnOff = uicontrol('Style', 'radiobutton', 'String', 'ON/OFF',...
                'Position', [405 310 100 30]);
            obj.ticker4Unloading = uicontrol('Style', 'radiobutton', 'String', 'Unloading',...
                'Position', [405 285 100 30]);  
            obj.ticker4MarketMaking = uicontrol('Style', 'radiobutton', 'String', 'Market Making',...
                'Position', [405 255 100 30]); 
            obj.ticker4TakeProfit = uicontrol('Style', 'radiobutton', 'String', 'T: Take Profit',...
                'Position', [405 225 100 30]); 
            uicontrol('Style', 'pushbutton', 'String', 'B', 'Position', [405 195 30 30], 'Callback',...
                {@(hObject,callbackdata)obj.order.orderPlacementManualBuy('HUNY')});
            uicontrol('Style', 'pushbutton', 'String', 'S', 'Position', [445 195 30 30], 'Callback',...
                {@(hObject,callbackdata)obj.order.orderPlacementManualSell('HUNY')});
            
            obj.ticker4TrendBuyPriceBeha = uicontrol('Style', 'radiobutton', 'String', 'B: Tr $ Behavi',...
                'Position', [405 165 100 30]);  
            obj.ticker4TrendSellPriceBeha = uicontrol('Style', 'radiobutton', 'String', 'S: Tr $ Behavi',...
                'Position', [405 135 100 30]); 
        end

        
    end  
end

