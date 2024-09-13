function [newt, newx,newy] = trimtrailingzeros(t,x,y)
    inds=find(x~=0);
    ii=inds(end);
    L = length(t);
    newx = x;
    newy = y;
    if(ii<L)
        newx=x(1:ii);
        newy=y(1:ii);
    end
    newt = t(1:ii);
end