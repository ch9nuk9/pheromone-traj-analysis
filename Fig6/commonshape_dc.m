
n = length(dc_all);
all_lengths = cellfun(@length, dc_all); % Get the length of each series
median_length = median(all_lengths); 
aligned_rescaled_dc = zeros(n, median_length);
aligned_rescaled_Dq = zeros(n, median_length);

% Find peak positions and rescale times so peaks align
peak_positions = zeros(n, 1);
for i = 1:n
    [~, peak_positions(i)] = min(dc_all{i});
end
median_peak_position = round(median(peak_positions));
x_new = linspace(0, 1, median_length);
peak_ratio = median_peak_position / median_length;

for i = 1:n
    current_dc = dc_all{i};
    current_Dq = Dq_all{i};
    peak_position = peak_positions(i);
    normalized_dc = current_dc / (-min(current_dc));
    normalized_Dq = current_Dq / max(current_Dq);
    % normalized_Dq = current_Dq;
    
    % Stretch or compress series so peak aligns with median peak position
    % relative to the median length
    x_old = linspace(0, 1, length(current_dc));
    
    adjusted_peak_position = round(length(x_old) * peak_ratio);
    curr_rescale_factor = adjusted_peak_position / peak_position
    x_old = x_old * curr_rescale_factor;
    % Use interpolation to rescale and align peaks
    aligned_rescaled_dc(i, :) = interp1(x_old, normalized_dc, x_new, 'linear', 'extrap');
    aligned_rescaled_Dq(i, :) = interp1(x_old, normalized_Dq, x_new, 'linear', 'extrap');

end

% Compute the median across aligned and rescaled series for each time point
median_dc = median(aligned_rescaled_dc, 1)';
std_dc = std(aligned_rescaled_dc, 1)';
upper_dc = median_dc + std_dc;
lower_dc = median_dc - std_dc;

median_Dq = median(aligned_rescaled_Dq, 1)';
std_Dq = std(aligned_rescaled_Dq, 1)';
upper_Dq = median_Dq + std_Dq;
lower_Dq = median_Dq - std_Dq;

mygrey = [0.4,0.4,0.4];
myshadeDq = [0.2, 0.6, 0.2];
myshadedc = [0.6, 0.2, 0.2];
myalpha = 0.2;

xx = linspace(0, 1, median_length)';

figure('Position',[200 200 900 300])

for i = 1:n
    plot(xx, aligned_rescaled_Dq(i, :), 'Color', mygrey);
end
plot(xx, median_Dq,'k',LW,2);
patch([xx;flipud(xx)],[upper_Dq;flipud(lower_Dq)],myshadeDq,'edgecolor','none','facealpha',myalpha)
ylim([0,0.8])
ylabel('Normalized Dq')
set(gca, 'fontsize',20)
xlabel('Rescaled Time');

yyaxis right

plot(xx, median_dc,'r',LW,2);
patch([xx;flipud(xx)],[upper_dc;flipud(lower_dc)],myshadedc,'edgecolor','none','facealpha',myalpha)
ylim([-1.2,1.2])
ylabel('Normalized correctness');
set(gca, 'fontsize',20)

title('typical taxis turn','FontWeight','normal')
figname = 'taxis-turns-typical.png';
exportgraphics(gcf, figname, 'Resolution',150)


return


figure('Position',[200 200 800 1200])
subplot(2,1,1)
hold on; % Keeps the plot window active to overlay multiple plots
for i = 1:n
    plot(xx, aligned_rescaled_dc(i, :), 'Color', mygrey);
end
plot(xx, median_dc,'g',LW,2);
patch([xx;flipud(xx)],[upper_dc;flipud(lower_dc)],mygrey,'facealpha',0.2)
ylim([-1.2,1.2])
ylabel('Normalized correctness');
set(gca, 'fontsize',20)

subplot(2,1,2)
hold on; % Keeps the plot window active to overlay multiple plots
for i = 1:n
    plot(xx, aligned_rescaled_Dq(i, :), 'Color', mygrey);
end
plot(xx, median_Dq,'g',LW,2);
patch([xx;flipud(xx)],[upper_Dq;flipud(lower_Dq)],mygrey,'facealpha',0.2)
ylim([0,0.8])
ylabel('Normalized Dq')
set(gca, 'fontsize',20)
xlabel('Rescaled Time');

figname = 'rescaled-taxis-turns.png';
exportgraphics(gcf, figname, 'Resolution',150)










