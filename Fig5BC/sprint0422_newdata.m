clear;
LW = 'linewidth';
prefix_arr = {...
    'him-5 male SP new data',...
    % 'him-5 male SP new data 07162024',...
};

mylw=3;
darkpurple = [57, 28, 84]/256;
lightpurple = [145, 99, 193]/256;

darkblue = [0 0.4470 0.7410];
lightblue = [102,170,215]/256;

idprefix = 1;
tmpprefix = prefix_arr{idprefix};
fname = [tmpprefix,'.mat'];
load(fname);
outputpath = ['sprint/',tmpprefix,'/'];
mkdir(outputpath)

v_after = []; v_before = [];
dist_after = [];
t_before = [];

Dq0=0.15;
offstim0 = 225;
for ii = 1:Ndata
    if(~sum(ii==good_inds))
        continue
    end
    trajid = trajids_arr{ii};
    disp(['now extracting from ', trajid])
    
    tmptime = time{ii};
    stim_frame = stimulation_frame_arr{ii};
    tmptime_mid = time_mid{ii};
    tmpdistance = distance{ii};
    tmpDq = straightness{ii};
    tmpstraight = 1./tmpDq;
    tmpv = v{ii};
    dist_mid = (tmpdistance(2:end)+tmpdistance(1:end-1))/2/1000;

    tmpDq_before = tmpDq(1:stim_frame-offstim0);
    tmpv_before = tmpv(1:stim_frame-offstim0);
    tmpDq_after = tmpDq(stim_frame+offstim0:end);
    tmpv_after = tmpv(stim_frame+offstim0:end);
    dist_mid_after = dist_mid(stim_frame+offstim0:end);

    ind_noturn_before = find(tmpDq_before<Dq0);
    ind_noturn_after = find(tmpDq_after<Dq0);
    
    noturn_v_before = tmpv_before(ind_noturn_before);
    mean_v_before = mean(noturn_v_before);
    noturn_v_before = noturn_v_before ./ mean_v_before;
    noturn_t_before = tmptime_mid(ind_noturn_before);

    noturn_v_after = tmpv_after(ind_noturn_after);
    noturn_v_after = noturn_v_after ./ mean_v_before;
    
    t_before = [t_before(:); noturn_t_before(:)];
    v_before = [v_before(:); noturn_v_before(:)];
    v_after = [v_after(:); noturn_v_after(:)];
    dist_after = [dist_after(:); dist_mid_after(ind_noturn_after)];
    
end

% % % before stim
[t_before, idx] = sort(t_before);
v_before = v_before(idx);
num_bins = 1000; 
bin_edges = linspace(min(t_before), max(t_before), num_bins+1);
[~, ~, bin_idx] = histcounts(t_before, bin_edges);

bin_means = accumarray(bin_idx, v_before, [], @mean); 
bin_stds = accumarray(bin_idx, v_before, [], @std); 
bin_centers = (bin_edges(1:end-1) + bin_edges(2:end))/2;
bin_centers = bin_centers(bin_means > 0);
bin_means = bin_means(bin_means > 0);

valid_bins = bin_means > 0;
bin_means = bin_means(valid_bins);
bin_stds = bin_stds(valid_bins);
bin_centers = bin_centers(valid_bins);

v_before_mean_smooth = smooth(bin_centers, bin_means, 0.1,'rloess');
fine_t_before = bin_centers/60;
fine_v_before = v_before_mean_smooth';
smooth_stds = smooth(bin_centers, bin_stds, 0.1, 'rloess');
v_before_smooth_stds = smooth_stds';

figure('position',[300 500 700 500]);
hold on;
% scatter(dist_after, v_after, 'bo');
% Add standard deviation band around the spline
fill([fine_t_before, fliplr(fine_t_before)], ...
    [fine_v_before + v_before_smooth_stds, ...
    fliplr(fine_v_before - v_before_smooth_stds)], ...
    lightblue, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
plot(fine_t_before, fine_v_before, 'k-', 'LineWidth', mylw);
% title('Vmag v.s. time before stim');
xlabel('time [min]');
ylabel('V/V_0');
xlim([0,4.5])
ylim([0.6,2])
box on
axis('square')
set(gca,'fontsize',20)
% exportgraphics(gcf, 'sprint_vbeforestim.png','Resolution',150)


% % % after stim
disp('now after stim...')
[dist_after, idx] = sort(dist_after);
v_after = v_after(idx);

num_bins = 1000; 
bin_edges = linspace(min(dist_after), max(dist_after), num_bins+1);
[~, ~, bin_idx] = histcounts(dist_after, bin_edges);

bin_means = accumarray(bin_idx, v_after, [], @mean); 
bin_stds = accumarray(bin_idx, v_after, [], @std); 
bin_centers = (bin_edges(1:end-1) + bin_edges(2:end))/2;
bin_centers = bin_centers(bin_means > 0);
bin_means = bin_means(bin_means > 0);

valid_bins = bin_means > 0;
bin_means = bin_means(valid_bins);
bin_stds = bin_stds(valid_bins);
bin_centers = bin_centers(valid_bins);

mean_smooth = smooth(bin_centers, bin_means, 0.1,'rloess');
fine_x = bin_centers;
fine_y = mean_smooth';
% % Fit a spline to the binned data for the mean
% pp = spline(bin_centers, bin_means);
% 
% % Evaluate spline at a fine grid for plotting
% fine_x = linspace(min(dist_after), max(dist_after), 10000);
% fine_y = ppval(pp, fine_x);
smooth_stds = smooth(bin_centers, bin_stds, 0.1,'rloess');
smooth_stds = smooth_stds';
% Plotting

xsprint = 3.2;
x0 = 2.5;
fine_x = fine_x - x0;
% fine_x = fine_x*10;
ind_sprint = find(fine_x<xsprint);
ind_nosprint = find(fine_x>xsprint);

figure('position',[300 500 600 500]);
hold on;
% scatter(dist_after, v_after, 'bo');
% Add standard deviation band around the spline
fill([fine_x(ind_nosprint), fliplr(fine_x(ind_nosprint))], ...
    [fine_y(ind_nosprint) + smooth_stds(ind_nosprint), ...
    fliplr(fine_y(ind_nosprint) - smooth_stds(ind_nosprint))], ...
    darkblue, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
fill([fine_x(ind_sprint), fliplr(fine_x(ind_sprint))], ...
    [fine_y(ind_sprint) + smooth_stds(ind_sprint), ...
    fliplr(fine_y(ind_sprint) - smooth_stds(ind_sprint))], ...
    darkblue, 'FaceAlpha', 0.6, 'EdgeColor', 'none');
plot(fine_x, fine_y, 'k-', 'LineWidth', mylw);
% title('Vmag v.s. Dist to target');
xlabel('Distance [mm]');
ylabel('V/V_0');
xlim([0,20])
ylim([0.6,2])
axis('square')
% set(gca, 'YTick', [], 'YTickLabel', []);
box on
set(gca,'fontsize',20)
set(gca, 'XDir', 'reverse');
exportgraphics(gcf, 'sprint_vafterstim.png','Resolution',150)



