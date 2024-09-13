LW='linewidth';


prefix_arr={'rab3_male_10_20_100%',...
'rab3_herm_10_20_100%'};


for id_prefix = 1:length(prefix_arr)
% for id_prefix
    prefix = prefix_arr{id_prefix};
    dataname = [prefix,'.mat'];
    load(dataname)
%% fourier analysis of the velocity magnitude
    Dt=t(2)-t(1);
    Fs=1/Dt;
    vel_ft=fft(vel - mean(vel));
    vv=vel_ft(1:end-1,:);L=length(vv);P2 = abs(vv/L);
    P1 = P2(1:L/2+1,:);
    P1(2:end-1,:) = 2*P1(2:end-1,:);
    
    f = Fs*(0:(L/2))/L;
    % plot(f,P1,LW,2)
    % xlim([0,0.4])
    % return
    options.x_axis = f;
    options.handle     = figure('position',[100, 100, 600, 600]);
    options.color_area = [128 193 219]./255;    % Blue theme
    options.color_line = [ 52 148 186]./255;
    options.alpha      = 0.5;
    options.line_width = 2;
    options.error      = 'std';
    
    plot_areaerrorbar(P1',options);
    xlim([0,0.4])
    title("Single-Sided Amplitude Spectrum of V(t)")
    xlabel("f (Hz)")
    ylabel("|P1(f)|")
    set(gca,'fontsize',20);
    set(gca,'linewidth',2);
    figname=[prefix,'-velocity_FT.png']
    saveas(gcf, figname);
    %     pause;
    close;
end


