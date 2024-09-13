clear;
LW = 'linewidth';


fname = ['quicksteering.xlsx'];
data=readmatrix(fname,'numheaderlines',1);
header_ids=readcell(fname,'range','A2:A33');
sample_ids = data(:,2);
time_ranges = data(:,3:8);

Ndata =length(header_ids)
nn=1;
dc_all = {};
Dq_all = {};
for ii=1:Ndata
    prefix = header_ids{ii};
    fname = [prefix,'.mat'];
    load(fname,'trajids_arr', 'time_mid','straightness','direction_correct');
    prefix = header_ids{ii}

    dt = 0.8;
    sample_id = sample_ids(ii)
    flag = 0;
    for kk=1:sample_id
        if(trajids_arr{kk}==sample_id)
            sample_id = kk
            flag = 1;
            break
        end
    end
    if (~flag)
        disp('not found this traj!!!')
        continue
    end
    tt=time_mid{sample_id};
    time_range = time_ranges(ii,:);
    for jj=1:3
        disp([prefix, ' ', num2str(sample_id), ', jj=',num2str(jj)])
        tstart = time_range(jj*2-1);
        tend = time_range(jj*2);
        if(isnan(tstart))
            continue
        end

        tstart = floor(tstart * 60/dt);
        tend = floor(tend * 60/dt);
        lentt = length(tt);
        if(tend>lentt)
            tend = lentt;
        end
        Dq = straightness{sample_id};
        dc = direction_correct{sample_id};
        tmid = floor((tstart + tend)/2);
        a=find(dc(tstart-10:tmid)>0);
        b=find(dc(tstart-10:tmid)<0);
        ind1 = min(find(a(2:end)-a(1:end-1)>1));
        if(ind1)
            frame_start = tstart + a(ind1) -10 -1
        else
            frame_start = tstart + max(a) -10 -1
        end
        if(length(frame_start)>1 || isempty(frame_start))
            disp(['remove ',prefix,' ',num2str(sample_id)])
            continue
        end
        % if(frame_start==1039)
        %     disp(['remove ',prefix,' ',num2str(sample_id)])
        % end
        myrange = frame_start:tend;
        % myrange = frame_start:frame_start+90;
        dc_all{nn} = dc(myrange);
        Dq_all{nn} = Dq(myrange);
        data_len(nn) = tend-frame_start;
        nn = nn+1;
        % myrange0 = myrange - myrange(1)+1;
        % yyaxis left
        % plot(myrange0*dt,dc(myrange),LW,2)
        % hold on
        % yyaxis right
        % plot(myrange0*dt,Dq(myrange),LW,2)
        % hold on
        % close all

    end
end




