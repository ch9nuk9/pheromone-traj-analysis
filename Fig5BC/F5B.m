%Filename and sheetname need changing——Olivia WX
alpha = 0.5;

colors_head = {[0.1725,0.635,0.3725,alpha],...
    [0.6,0.847,0.788,alpha],[0.898,0.96,0.976,alpha]};
colors_tail = {[0.89,0.29,0.2,alpha],...
    [0.992,0.733,0.5176,alpha],[0.996,0.9098,0.784,alpha]};
myblue = [31,119,180]/256;

mylw = 3;
myfs = 30;

progid = 1;
names = {'DA','M9','SP_1_10_100','SP_500_1000_2000'};

for progid = 1:3
    prefix = ['prog',num2str(progid)]
    
    for ii = 1:4
        tmpname = names{ii};
    
        filename = [prefix,tmpname,'.xlsx'];
        genotype = '';
        num_rep = ''; 
        rawdata  = xlsread(filename);
    
        % Create sample data as column vectors.
        time = rawdata(: , 1);
        Fdata = rawdata(:, 2:end);
        % stimulation onset and offset ——Olivia WX
        % stim = [0,time(end)];
        stim = {[0,2],[4,6],[8,10]};
    
        %
        data = Fdata;
    
        data_average = mean(data,2);
        data_sem = std(data,[],2)/sqrt(size(data,2)); 
    
        data_upper = data_average  + data_sem;
        data_lower = data_average  - data_sem;
    
        smooth_data_average = smooth(data_average);
    
        % Plot 
        figure('Position',[200 200 600 300]);
    
        %Set parameters for plotting ——Olivia WX
        %UP_BOUND =  max(data_upper)*1.2;
        LOW_BOUND  = min(data_lower)*1.2; 
        UP_BOUND =  max(data_upper)*1.2;
        % LOW_BOUND  = -0.72; 
        edg = min(data_average)*0.01;
    
    
    
        plot(time, data_average, 'g', 'LineWidth', 1.5);
    
        hold on
        xlim([min(time),max(time)]);
        ylim([LOW_BOUND, UP_BOUND]);
    
    
        for jj=1:3
            for i = 1:size(stim,1)
                if (progid==1 || progid==2)
                    rectangle('Position',[stim{jj}(i,1),LOW_BOUND+10*edg, stim{jj}(i,2)-stim{jj}(i,1),UP_BOUND - LOW_BOUND-edg*10],...
                        'FaceColor',colors_head{4-jj}, 'Edgecolor', [1,0.8,0.4,0.],'LineWidth', 0.01);
                end
                if (progid==1 || progid==3)
                    rectangle('Position',[stim{jj}(i,1), LOW_BOUND+10*edg, stim{jj}(i,2)-stim{jj}(i,1),UP_BOUND - LOW_BOUND-edg*10],...
                    'FaceColor',colors_tail{4-jj}, 'Edgecolor', [1,0.8,0.4,0.],'LineWidth', 0.01);
                end
            end
        end
        % plot(time,data_upper, 'color',[1,0.4,0.4], 'LineWidth', 1);
        % hold on
        % plot(time, data_lower, 'color',[1,0.4,0.4],'LineWidth', 1);
    
        plot(time, data_average, 'g', 'LineWidth', mylw);
        hold on
        patch([time;flipud(time)],[data_upper; flipud(data_lower)],'k','FaceA',.3,'EdgeA',0);
    
        %'color', [.15,.15,.15]
        %title ([genotype '  GCaMP6s Region ' sheetname]);
        xlabel('time[m]')
        ylabel('\DeltaR/R_0')
        title(regexprep([prefix,tmpname], '_', '-'),'interpreter','none')
        set(gca,'fontsize',myfs);
        set(gca,'linewidth',mylw);
        % axis square
        box on
        figname_signal=[prefix,'/',prefix,tmpname,'.png'];
        exportgraphics(gcf, figname_signal, 'Resolution',150);
    
        close()
    
    end
end



