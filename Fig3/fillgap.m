function [newx,newy] = fillgap(t,myx,myy)
    inds=find(myx==0);
    ninds=length(inds);
    ii=0;
    newx=myx; newy=myy;
    while(ii<ninds)
        ii=ii+1;
        jlow=inds(ii)
        %%% start search for jhigh
        while(ii<ninds && inds(ii+1)==inds(ii)+1)
            ii = ii+1;
        end
        jhigh=inds(ii)
        newx(jlow:jhigh) = (myx(jhigh+1)-myx(jlow-1))/(t(jhigh+1)-t(jlow-1))...
            *(t(jlow:jhigh) - t(jlow-1)) + myx(jlow-1);
        newy(jlow:jhigh) = (myy(jhigh+1)-myy(jlow-1))/(t(jhigh+1)-t(jlow-1))...
            *(t(jlow:jhigh) - t(jlow-1)) + myy(jlow-1);
    end
end