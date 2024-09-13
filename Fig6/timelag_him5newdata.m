clear;
LW = 'linewidth';
prefix_arr = {...
    'him-5 male SP new data'...
};

sheets = {'sheet1','sheet2'};

id=1; %sheet1

longer15_ids = 0;
longer25_ids = 0;
nkeep = 0;


idprefix = 1; 
tmpprefix = prefix_arr{idprefix};
fname = [tmpprefix,'.mat'];
load(fname);
outputpath = ['timelag/',tmpprefix,'/'];
mkdir(outputpath)
Fs = 1/dt_sec % sampling rate is 8s per frame
filter_frq = 0.1;

dt = 0.13333; % s
windowsize = 1; % between the center of two conseq windows
windowlength = 40;
maxlag = 40;

trivial_inds = [2,3,9,18,19];

for kk = 1:ngroups+1
% for kk=1
    % mkdir([outputpath,'group',num2str(kk)])
    % cur_path = [outputpath,'group',num2str(kk),'/'];
    cur_path = outputpath;
    group_inds = groups{kk};
    group_size = length(group_inds);
    title_str = [tmpprefix,' group ',num2str(kk)];
    figname = [cur_path,tmpprefix,' group ',num2str(kk),'.png'];
    jj=0; mm=0;
    yticks_arr = [];
    ylabels_arr = {};

    timemin = 1000;
    timemax = 0;

    figure('Position',[200 200 1500 1500])
    for ss = 1:group_size
        ii = group_inds(ss);
        if(sum(ii==bad_inds))
            disp(['remove ',num2str(ii)])
            continue
        end
        cur_set = setids(ii);
        % target_pos = target_pos_set{cur_set};
        target_frame = find_target_frame_arr{ii};
        stim_frame = stimulation_frame_arr{ii};

        ii
        mytime = time{ii};
        mytime_mid = time_mid{ii};
        myx = x_mid{ii};
        myy = y_mid{ii};
        dc = direction_correct{ii};
        % tmpdistance = distance{ii};
        Dq = straightness{ii};
        if(target_frame>length(Dq))
            target_frame = length(Dq);
        end
        dc = dc(stim_frame:target_frame);
        Dq = Dq(stim_frame:target_frame);
    
        [xmesh, ymesh, window_xcorr_dc_Dq_lag, window_xcorr_dc_straight] = timelag(mm,dt,dc, Dq, windowsize, windowlength, maxlag);
        jj=jj+1;
        if(sum(jj==trivial_inds))
            continue;
        end
        mm=mm+1;
        % xmesh = xmesh + maxlag;
        % figure('Position',[200 200 1500 500])
        % subplot(1,4,[1,2,3])
        % plot(mytime_mid, Dq, LW,2)
        % hold on
        % yyaxis right
        % plot(mytime_mid, dc,LW,2)
        % subplot(1,4,4)
        surf(ymesh', xmesh', window_xcorr_dc_Dq_lag','edgecolor','none')
        % surf(xmesh, ymesh, window_xcorr_dc_Dq_lag,'edgecolor','none')
        hold on
        ylabel('worm #')
        xlabel('time [min]')
        % yticks([0 1 2 3 4])
        % yticklabels({'8','9','10','11','12'})
        zlabel('xcorr')
        tmptimemin = min(min(ymesh));
        tmptimemax = max(max(ymesh));
        timemin = min(timemin, tmptimemin);
        timemax = max(timemax, tmptimemax);

        lagmin = min(min(xmesh));
        lagmax = max(max(xmesh));
        lagmean = (lagmin+lagmax)/2;
        plot([timemin, timemax], [lagmin, lagmin],'k',LW,1)
        plot([timemin, timemax], [lagmax, lagmax],'k',LW,1)
        
        view(0,90)
        
        
        colormap(bluewhitered)
        clim([-1000, 1000])
        yticks_arr(mm) = lagmean;
        ylabels_arr{mm} = string(mm);
    end
    xlim([timemin, timemax])
    ylim([-maxlag*dt, lagmax])
    yticks(yticks_arr)
    yticklabels(ylabels_arr)
    colorbar()
    
    % colormap(gca,bluewhitered) 
    view(0,90)
    title(title_str,'interpreter','none');
    set(gca,'fontsize',20)
    exportgraphics(gcf, figname, "Resolution",150);
    close all
    disp('finished');
    dataname = [cur_path,tmpprefix,' group ',num2str(kk),'.mat'];
    save(dataname)
end



