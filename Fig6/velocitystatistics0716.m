clear;
LW = 'linewidth';
prefix_arr = {...
    'him-5 male SP new data',...
    % 'him_5 SP on LID SD calm down',...
};
tmpprefix = prefix_arr{1};
fname = ['analysis/',tmpprefix,'.mat'];
load(fname);
yellow = [255, 195, 11]/256;

mylw = 3;
myfs = 30;

% mode = "vmag";
mode = "dot";

Dq_threshold = 0.2;

if mode=="vmag"

    drdt = []; vv = [];
    % compare before and after stim
    % vmag distribution only

    vbefore_found = [];
    vbefore_not_found = [];
    vafter_found = [];
    vafter_not_found = [];
    for ii=1:Ndata
        ii
        if(sum(ii==bad_inds))
            continue
        end
        % drdts = drdts_arr{ii};
        vtmp = v_raw{ii};
        stim_frame = stimulation_frame_arr{ii};
        Dq = straightness{ii};
        maxDq = quantile(Dq,0.99);
        ind_noturn = find(Dq<Dq_threshold*maxDq);
        frac_noturn = length(ind_noturn)/length(Dq)
        
        vbefore = vtmp(1:stim_frame-50);
        vafter = vtmp(stim_frame+20:end);
        ind_noturn_before = find(Dq(1:stim_frame-50)<Dq_threshold);
        ind_noturn_after = find(Dq(stim_frame+20:end)<Dq_threshold);
        vbefore = vbefore(ind_noturn_before);
        vafter = vafter(ind_noturn_after);
        if(sum(ii==inds_not_find))
            disp('not found')
            vbefore_not_found = [vbefore_not_found; vbefore(:)];
            vafter_not_found = [vafter_not_found; vafter(:)];
        else
            disp('found')
            vbefore_found = [vbefore_found; vbefore(:)];
            vafter_found = [vafter_found; vafter(:)];
        end
    end
    vbefore_found_mean = mean(vbefore_found)
    vafter_found_mean = mean(vafter_found)
    vbefore_not_found_mean = mean(vbefore_not_found)
    vafter_not_found_mean = mean(vafter_not_found)

    xoffset = 30;
    yoffset = 0.04;
    figure('Position',[400 400 1000 600])
    subplot(2,2,1)
    histogram(vbefore_found,100,'Normalization','probability')
    hold on
    plot([vbefore_found_mean,vbefore_found_mean],[0,0.05],'k',LW,2);
    text(vbefore_found_mean+xoffset,yoffset,['mean=',num2str(vbefore_found_mean,'%.2f')],'FontSize',20)
    title('before stim. succ','FontWeight','normal')
    % xlim([0,1])
    xticks([])
    ylim([0,0.05])
    xlabel('vmag [um/s]')
    ylabel('PDF')
    set(gca,'fontsize',20)
    subplot(2,2,3)
    histogram(vafter_found, 100,'Normalization','probability','facecolor','r')
    hold on
    plot([vafter_found_mean,vafter_found_mean],[0,0.06],'k',LW,2);
    text(vafter_found_mean+xoffset, yoffset,['mean=',num2str(vafter_found_mean,'%.2f')],'FontSize',20)
    title('after stim. succ','FontWeight','normal')
    % xlim([0,1])
    ylim([0,0.06])
    xlabel('vmag [um/s]')
    ylabel('PDF')
    set(gca,'fontsize',20)
    subplot(2,2,2)
    histogram(vbefore_not_found,100,'Normalization','probability')
    hold on
    plot([vbefore_not_found_mean,vbefore_not_found_mean],[0,0.05],'k',LW,2);
    text(vbefore_not_found_mean+xoffset, yoffset,['mean=',num2str(vbefore_not_found_mean,'%.2f')],'FontSize',20)
    title('before stim. fail','FontWeight','normal')
    % xlim([0,1])
    xticks([])
    ylim([0,0.05])
    xlabel('vmag [um/s]')
    ylabel('PDF')
    set(gca,'fontsize',20)
    subplot(2,2,4)
    histogram(vafter_not_found, 100,'Normalization','probability','facecolor',yellow)
    hold on
    plot([vafter_not_found_mean,vafter_not_found_mean],[0,0.06],'k',LW,2);
    text(vafter_not_found_mean+xoffset, yoffset,['mean=',num2str(vafter_not_found_mean,'%.2f')],'FontSize',20)
    title('after stim. fail','FontWeight','normal')
    % xlim([0,1])
    ylim([0,0.05])
    xlabel('vmag [um/s]')
    ylabel('PDF')
    set(gca,'fontsize',20)
    
    figname=[tmpprefix,'/vmag-pdf.png'];
    exportgraphics(gcf, figname, 'Resolution',150)
    % print(gcf, figname, '-dpng', '-r300');
    
    % close all;
end

% return

% % % % for vmag of after found:
% x=0:0.02:20;
% a1=0.2862;a2=0.1173;b1=9.5509;b2=3.4443;
% c1=2.2343;c2=2.1355;
% % a1=0.28;a2=0.13; % my own trial
% y=a1/c1*exp(-(x-b1).^2./2./c1^2)+a2/c2*exp(-(x-b2).^2./2./c2^2);
% [Nafter_found, edges]=histcounts(vafter_found);
% bincenters=(edges(1:end-1)+edges(2:end))/2;
% Nafter_found_pdf = Nafter_found ./ trapz(bincenters, Nafter_found);
% plot(bincenters,Nafter_found_pdf,LW,2)
% hold on
% plot(x,y,LW,2)

if mode=="dot"

    vfound = [];
    vnotfound = [];
    drdt_found = [];
    drdt_notfound = [];
    for ii=1:Ndata
        ii
        if(sum(ii==bad_inds))
            continue
        end
        drdts = drdts_arr_raw{ii};
        vtmp = v_raw{ii};
        stim_frame = stimulation_frame_arr{ii};
        Dq = straightness{ii};
        Dq = Dq(stim_frame+20:end);
        vafter = vtmp(stim_frame+20:end);
        drdt = drdts(stim_frame+20:end);
        ind_noturn = find(Dq<Dq_threshold);
        frac_noturn = length(ind_noturn) / length(drdt)

        vafter = vafter(ind_noturn);
        drdt = drdt(ind_noturn);

        % plot(drdt, vafter, LW,2)
        
        if(~sum(ii==inds_not_find))
            disp('found')
            vfound = [vfound; vafter(:)];
            drdt_found = [drdt_found; drdt(:)];
            subplot(1,2,1)
        else
            disp('not found')
            vnotfound = [vnotfound; vafter(:)];
            drdt_notfound = [drdt_notfound; drdt(:)];
            subplot(1,2,2)
        end
        dr
        max(drdt)
        scatter(drdt, vafter, 3, 'filled'); hold on;
        % pause
    end
    % return
    vall = {vfound, vnotfound};
    drdtall = {drdt_found, drdt_notfound};
    suff = {"succ", "fail"};

    set(gcf,'position',[200 200 1200 500])

    for jj=1:2
        
        vv = vall{jj};
        drdt = drdtall{jj};
        suffix = suff{jj};

        vmean=mean(vv);
        vmax = quantile(vv,0.9995);
        % vmax = 1;
        drdtmin=min(drdt);
        drdtmax = max(drdt);
        xmax = max(abs(drdtmin),drdtmax)
        % xmax = 1;
        drdtmin = -xmax;
        drdtmax = xmax;
        
        indv1=find(vv>vmean);
        indv2=find(vv<vmean);
        indr1=find(drdt>0);
        indr2=find(drdt<0);
        ind1=intersect(indv1,indr1);
        ind2=intersect(indv1,indr2);
        ind3=intersect(indv2,indr2);
        ind4=intersect(indv2,indr1);
        n1 = length(ind1)
        n2 = length(ind2)
        n3 = length(ind3)
        n4 = length(ind4)
        nn = n1+n2+n3+n4;

        subplot(1,2,jj)
        % plot([0,30],[0,30],'k--',LW,2)
        % plot([-30,0],[30,0],'k--',LW,2)
        xlim([drdtmin drdtmax])
        ylim([0,vmax]);
        plot([0 0],[0 vmax],'k--',LW,mylw);
        plot([drdtmin drdtmax],[vmean vmean],'k--',LW,mylw);
        text(drdtmax*0.2, vmax*0.95, sprintf('n1=%0.1f%%',n1/nn*100),'fontsize',myfs)
        text(drdtmin*0.9, vmax*0.95, sprintf('n2=%0.1f%%',n2/nn*100),'fontsize',myfs)
        text(drdtmin*0.9, vmax*0.2, sprintf('n3=%0.1f%%',n3/nn*100),'fontsize',myfs)
        text(drdtmax*0.2, vmax*0.2, sprintf('n4=%0.1f%%',n4/nn*100),'fontsize',myfs)
        title(sprintf('%s: vmean=%0.1f',suffix, vmean));
        
        box on
        set(gca,'fontsize',myfs)
        xlabel('V_R [mm/s]')
        ylabel('V_T [mm/s]')
    end
    figname=[tmpprefix,'/vdots.png'];
    exportgraphics(gcf, figname, 'Resolution',150)
    % saveas(gcf, figname);
    % close()
    

end



