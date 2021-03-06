classdef OrderPlacement
    %ORDERPLACEMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        rit
    end
    
    methods
        function obj = OrderPlacement(rotnamObject)
            obj.rit = rotnamObject;
        end
        
        function orderPlacement1(obj, longOrShort, volume, tickerName)
            if longOrShort == true
                buyID = buy(obj.rit, tickerName, volume);
                %disp('bought');
            else
                sellID = sell(obj.rit, obj.tickerName, volume);
                %disp('sold');
            end
        end
         
        function nextVolume = orderPlacementForCostAverage(obj, longOrShort, volume, tickerName)
            if longOrShort == true
                sellID = sell(obj.rit, tickerName, volume);
            else
                buyID = buy(obj.rit, tickerName, volume);
            end
            
            increment = 500;
            nextVolume = volume + increment;           
            if nextVolume >= 10000
                nextVolume = 5000;
            end

        
        end
        
        function orderPlacementAggresUnloadingCostAverage(obj, tickerName)
            clearQueuedOrders(obj.rit); 
            positionString = strcat(lower(tickerName),'_position');
            position = getfield(obj.rit, positionString);
            percentage = 0.5;
            if position > 0 
                if position <= 500
                    sellID = sell(obj.rit, tickerName, position);
                elseif position*percentage > 10000
                    sellID = sell(obj.rit, tickerName, 10000);
                else
                    sellID = sell(obj.rit, tickerName, abs(position)*percentage);
                end
                disp(sellID);
            elseif position < 0
                if position >= -500
                    buyID = buy(obj.rit, tickerName, abs(position));
                elseif abs(position)*percentage > 10000
                    buyID = buy(obj.rit, tickerName, 10000);
                else
                    buyID = buy(obj.rit, tickerName, abs(position)*percentage);
                end
                disp(buyID);
            end
        end
        
        function orderPlacementMarketMaking(obj, bidOrAsk, price, breakEven, tickerName)
           costString = strcat(lower(tickerName),'_cost');
           cost = getfield(obj.rit, costString);
           
           priceIncrease = 0.10
           numberOfOrders = 10
           volume = 150;
           priceIncrement = 0.02;
           %TODO: Test Out Differen Price Level Increments 
           %TODO: Change Lower Volume to 100 if it hits API Limit
           %TODO: an increase in priceINcrease THe likelihood of getting
           %filled is lowered so make volume larger
           %TODO: implement algorithm 3
           if bidOrAsk == 1 %if Ask
               %Place 5 Sell Orders
               for x = 1:numberOfOrders
                    sellID = limitOrder(obj.rit, tickerName, -volume, price + priceIncrease);
                    %buyID = limitOrder(obj.rit, tickerName, 500, breakEven - priceIncrease - 0.01);
                    priceIncrease = priceIncrease + priceIncrement;
               end

           elseif bidOrAsk == 0
               for x = 1:numberOfOrders
                    buyID = limitOrder(obj.rit, tickerName, volume, price - priceIncrease);
                    %sellID = limitOrder(obj.rit, tickerName, -500, price + priceIncrease + 0.01);
                    priceIncrease = priceIncrease + priceIncrement;
               end                            
           end
        end
        
        function orderPlacementTakeProfitBasedOnCost(obj, tickerName)
            positionString = strcat(lower(tickerName),'_position');
            position = getfield(obj.rit, positionString);
            
            costString = strcat(lower(tickerName),'_cost');
            cost = getfield(obj.rit, costString);
                       
            if position < 0
                averageCost = cost - 0.03
           
                askString = strcat(lower(tickerName), '_ask');
                askPrice = getfield(obj.rit, askString);
                if averageCost < askPrice
                    randomVolumeNumber = rand * 0.02 * abs(position) + 100;
                    buyID = limitOrder(obj.rit, tickerName, randomVolumeNumber, askPrice);
                end
            elseif position > 0
                averageCost = cost + 0.03
                
                bidString = strcat(lower(tickerName), '_bid');
                bidPrice = getfield(obj.rit, bidString);                 
                if averageCost > bidPrice
                    randomVolumeNumber = rand * 0.02 * abs(position) + 100;
                    sellID = limitOrder(obj.rit, tickerName, -randomVolumeNumber, bidPrice);
                end 
            end
        end
      
        function orderPlacementTakeProfitBasedOnUnRel(obj, tickerName)
            positionString = strcat(lower(tickerName),'_position');
            position = getfield(obj.rit, positionString);
            
            unRelString = strcat(lower(tickerName), '_plunr');
            unRealizedPL = getfield(obj.rit, unRelString);
            
            bidString = strcat(lower(tickerName), '_bid');
            bidPrice = getfield(obj.rit, bidString);                 

            askString = strcat(lower(tickerName), '_ask');
            askPrice = getfield(obj.rit, askString);
            %if unRealizedPL >= 1000 && unRealizedPL < 5000
            %    if position > 0
            %        sellID = limitOrder(obj.rit, tickerName, -0.02*position, bidPrice);
            %    elseif position < 0
            %        buyID = limitOrder(obj.rit, tickerName, -0.02*position, askPrice);
            %    end
            if unRealizedPL >= 200
                clearQueuedOrders(obj.rit);
                if position > 0
                    %volume = 0.05 * position;
                    %priceIncrease = 0;
                    %for x = 1:5
                    %    sellID = limitOrder(obj.rit, tickerName, -volume/5, bidPrice - priceIncrease);
                    %    priceIncrease = priceIncrease + 0.01;
                    %end
                    
                    % KEEP FROM BEFORE
                    %sellID = limitOrder(obj.rit, tickerName, -0.05*position, bidPrice);
                    %sellID = sell(obj.rit, tickerName, 0.05*position);
                    
                    % RANDOM VOLUME
                    for x = 1:3
                        randomVolume = rand * 40 + 11;
                        sellID = limitOrder(obj.rit, tickerName, -randomVolume, bidPrice);                 
                    end


                elseif position < 0
                    %volume = 0.05 * position;
                    %priceIncrease = 0;
                    %for x = 1:4
                    %    buyID = limitOrder(obj.rit, tickerName, -volume/5, askPrice + priceIncrease);
                    %    priceIncrease = priceIncrease + 0.01;
                    %end
                    
                    %From Before 5% take Profit
                    %buyID = limitOrder(obj.rit, tickerName, -0.05*position, askPrice);
                    %buyID = buy(obj.rit, tickerName, -0.05*position);
                    
                    % RANDOM VOLUME
                    for x=1:3
                        randomVolume = rand * 40 + 11;
                        buyID = limitOrder(obj.rit, tickerName, randomVolume, askPrice);                   
                    end
                   
                end
            end        
        end
        
        function orderPlacementBuyTrend(obj, volume, longOrShort, tickerName)
            disp(tickerName);

            if longOrShort == true
                buyID = buy(obj.rit, tickerName, volume);
            else
                positionString = strcat(lower(tickerName),'_position');
                position = getfield(obj.rit, positionString);
                if position > 0 && position*0.5 > 10000
                    sellID = sell(obj.rit, tickerName, 5000);
                elseif position > 0 
                    sellID = sell(obj.rit, tickerName, position*0.5);
                elseif position < 0
                    
                elseif position == 0
                    disp('Closed Position');
                end
                
            end
        end
        
        function orderPlacementSellTrend(obj, volume, tickerName, longOrShort)
            positionString = strcat(lower(tickerName),'_position');
            position = getfield(obj.rit, positionString);
            if longOrShort == false
                sellID = sell(obj.rit, tickerName, volume);
            else
                if position < 0 && position < -10000
                    buyID = buy(obj.rit, tickerName, 5000);
                elseif position < 0
                    buyID = buy(obj.rit, tickerName, abs(position)  *0.5);
                elseif position > 0
                    
                elseif position == 0
                    disp('Closed Position');
                end
                
            end
        end
        
        
        function takeProfitForTrends(obj, tickerName, maxNumberOfVolume)
            % Max Number Of Volume - is for the random volume size from 0 to
            % MaxNumberOfVolume;
            positionString = strcat(lower(tickerName),'_position');
            position = getfield(obj.rit, positionString);
            volume = rand * maxNumberOfVolume;
            if position > 0
                sellID = sell(obj.rit, tickerName, volume);
            elseif position < 0
                buyID = buy(obj.rit, tickerName, volume);
            end
        end
        
        function orderPlacementManualBuy(obj, tickerName)             
            askString = strcat(lower(tickerName), '_ask');
            askPrice = getfield(obj.rit, askString);
            buyID = limitOrder(obj.rit, tickerName, 1000, askPrice);
        end
        
        function orderPlacementManualSell(obj, tickerName)              
            bidString = strcat(lower(tickerName), '_bid');
            bidPrice = getfield(obj.rit, bidString);  
            sellID = limitOrder(obj.rit, tickerName, -1000, bidPrice);
        end
        
        function orderPlacementForPriceBehaviour(obj, tickerName, longOrShort)
            if longOrShort == true
                askString = strcat(lower(tickerName), '_ask');
                askPrice = getfield(obj.rit, askString);
                volume = 500
                buyID = limitOrder(obj.rit, tickerName, volume, askPrice);
            elseif longOrShort == false
                bidString = strcat(lower(tickerName), '_bid');
                bidPrice = getfield(obj.rit, bidString);  
                volume = 500
                sellID = limitOrder(obj.rit, tickerName, -volume, bidPrice);
            end           
        end
    
        
        function orderPlacementTakeProfitForPriceBehaviour(obj, tickerName)
            positionString = strcat(lower(tickerName),'_position');
            position = getfield(obj.rit, positionString);
            
            unRelString = strcat(lower(tickerName), '_plunr');
            unRealizedPL = getfield(obj.rit, unRelString);
            
            bidString = strcat(lower(tickerName), '_bid');
            bidPrice = getfield(obj.rit, bidString);                 

            askString = strcat(lower(tickerName), '_ask');
            askPrice = getfield(obj.rit, askString);            
            
            if unRealizedPL >= 200                
                if position > 0
                    for x = 1:3
                       randomVolume = rand * 40 + 11
                       sellID = limitOrder(obj.rit, tickerName, -randomVolume, bidPrice);
                    end
                elseif position < 0
                   for x = 1:3
                        randomVolume = rand * 40 + 11;
                        buyID = limitOrder(obj.rit, tickerName, randomVolume, askPrice);
                   end
                end
            end 
        end
    end
    
    
end

