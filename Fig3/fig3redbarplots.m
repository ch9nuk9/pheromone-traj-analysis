%% load the data excel, already texttocolumned by macros.
%  then process it.
% prefix_arr={'rab3_male_10_20_100%',...
% 'rab3_herm_10_20_100%'};
path='Revised_data/';
prefix_arr = {[path,'PS9478_C_Him-5_male_10_20_100%_Revised'],...
[path,'PS9478_C_Him-5_herm_10_20_100%_Revised']}
correction_factor = 25/4.4;

duration = {12.5, 11};
tstim_arr = {-20, -25};

for id_prefix=1:length(prefix_arr)
    prefix = prefix_arr{id_prefix}
    fname = [prefix,'.xlsx'];
    data=readmatrix(fname,'numheaderlines',1);
    
    Nframe=40;
    
    data(isnan(data))=0;
    Ndata = ((size(data,2)-1)/2);
    
    data = data(1:1300,:);
    
    x = cell(1,Ndata); y = cell(1,Ndata);
    
    t = data(:,1); t=t-min(t);
    dt0 = t(2)-t(1);
    lent = length(t);
    t = 0:dt0:dt0*lent;
    
    NN=zeros(1,Ndata);
    v=cell(1,Ndata);
    time=cell(1,Ndata);
    msdback=cell(1,Ndata);
    drdts_arr=cell(1,Ndata);
    
    vel = zeros(lent-Nframe+1,Ndata);
    
    for ii=1:Ndata
    % for ii=40
        ii
        indx = 2*ii;
        indy = 2*ii+1;
        xx = data(:,indx).*correction_factor;
        yy = data(:,indy).*correction_factor;
        [tt,xx,yy]=trimtrailingzeros(t,xx,yy);
        NN(ii)=length(tt);
        [xx,yy] = fillgap(tt,xx,yy);
        x{ii} = xx;
        y{ii} = yy;
        
        time{ii}=t(1:NN(ii));
        dt=t(Nframe:NN(ii))-t(1:NN(ii)-Nframe+1);
        dx=xx(Nframe:end)-xx(1:end-Nframe+1);
        dy=yy(Nframe:end)-yy(1:end-Nframe+1);
        ds=sqrt(dx.^2+dy.^2);
        v{ii}=ds(:)./dt(:);
        lenii = length(ds);
    %     v{ii}=v{ii}-mean(v{ii});
        vel(1:lenii,ii) = v{ii}./max(v{ii});
        msd=(xx - xx(end)).^2 + (yy - yy(end)).^2;
        msdback{ii}=msd;
        
    %     msdma=movmean(msd,Nframe);
        dr = (sqrt(msd(Nframe:end))-sqrt(msd(1:end-Nframe+1)));
        drdts=dr(:)./dt(:);
        
        drdts_arr{ii} = drdts;
        
    end
    
    dataname = [prefix,'.mat']
    save(dataname)
    
    % tstim1 = floor(5/dt0);
    tstim1 = tstim_arr{id_prefix};
    dur = duration{id_prefix};
    tendstim1 = tstim1+floor(dur/dt0);
    tperiod = 2*floor(10/dt0);
    Nstim = floor(length(t)/tperiod)
    
    f = figure('position',[100, 100, 600, 600]);
    for nstim = 1:Nstim+1
        frame_stimstart = tstim1 + (nstim-1)*tperiod
        frame_stimend = tendstim1 + (nstim-1)*tperiod
        tt1 = dt0*frame_stimstart; tt2 = dt0*frame_stimend;
        yy1 = 0; yy2 = 1;
        xvec=[tt1,tt2,tt2,tt1];
        yvec=[yy1,yy1,yy2,yy2];
        patch = fill(xvec, yvec, [255, 100, 103]./255);
        set(patch, 'edgecolor', 'none');
        set(patch, 'FaceAlpha', 0.5);
        hold on;
    end
    plotOptions.x_axis = (t(Nframe:end-1)+t(1:end-Nframe))/2;
    plotOptions.handle     = f;
    plotOptions.color_area = [128 193 219]./255;    % Blue theme
    plotOptions.color_line = [ 52 148 186]./255;
    plotOptions.alpha      = 0.5;
    plotOptions.line_width = 2;
    plotOptions.error      = 'std';
    plot_areaerrorbar(vel',plotOptions)
    xlim([0,170])
    ylim([0,1])
    xlabel('time [s]')
    ylabel('velocity [mm/s]')
    set(gca,'fontsize',40);
    set(gca,'linewidth',4);
    
    figname_vel=[prefix,num2str(ii),'-velocity.png'];
    exportgraphics(gcf, figname_vel, 'Resolution',150);
    
    close all

    fourier_analysis
    % % 
    % xticks(0:0.01:0.05);
    xlim([0,0.25])
    ylim([0,0.25])
    set(gca,'fontsize',30)
    figname_freq=[prefix,'-freq.png'];
    exportgraphics(gcf, figname_freq,'Resolution',150);

    close()
end

