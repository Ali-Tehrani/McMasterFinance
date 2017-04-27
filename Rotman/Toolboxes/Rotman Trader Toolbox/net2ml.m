function mlvar = net2ml(net)
%NET2ML converts .NET types not supported into supported MATLAB types

% Auth/Revision:  Stuart Kozola 
%                 Copyright 2015 The MathWorks, Inc. 
%                 $Id$
switch class(net)
    case 'System.Decimal'
        mlvar = net.ToDouble(net);
    case 'System.String'
        mlvar = char(net);
    case 'System.Object[,]'
        r = net.Rank;
        c = net.Length/r;
        assert(r<=2,'NET2ML only supports up to 2 Dimensional NET objects')
        mlvar = cell(r,c);
        for i = 1:r
            for j = 1:c
                mlvar{i,j} = net2ml(net(i,j));
            end
        end
    otherwise % return it's type
        mlvar = net;
end


