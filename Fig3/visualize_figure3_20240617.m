LW='linewidth';
pos=[200 200 500 800];

% prefix_arr={'rab3_male_10_20_100%',...
% 'rab3_herm_10_20_100%'};
path='Revised_data/';
figpath = [path,'fig3-traj-vel-srd1/'];
prefix_arr = {['PS8023_C_him-5_herm_10_20_100%_Revised'],...
['PS8023_C_him-5_male_10_20_100%_revised'],...
['PS9478_C_Him-5_herm_10_20_100%_Revised'],...
['PS9478_C_Him-5_male_10_20_100%_Revised'],...
};


offset_arr = {[0.1,0.1],[0.2, 0.05],[0.1,0.1],[0.1,0.1]};
xlim_arr = {[0,5],[0,2],[0,1],[0,1]};
ylim_arr = {[0,5],[0,1],[0,1],[0,1]};
xticks_arr = {[0,2.5,5],[0,1,2],[0,0.5,1],[0,0.5,1]};
yticks_arr = {[0,2.5,5],[0,0.5,1],[0,0.5,1],[0,0.5,1]};

% for id = 1:length(prefix_arr)
% for id_prefix
for myid = 1:4
    prefix = prefix_arr{myid};
    dataname = [path,prefix,'.mat'];
    load(dataname)
    prefix_arr = {['PS8023_C_him-5_herm_10_20_100%_Revised'],...
['PS8023_C_him-5_male_10_20_100%_revised'],...
['PS9478_C_Him-5_herm_10_20_100%_Revised'],...
['PS9478_C_Him-5_male_10_20_100%_Revised'],...
};
    prefix = prefix_arr{myid};
    pos0 = [200 200 500 500];
    % % for figure 3: id = 2,10,9,14
    ids = {2,10,9,14};
    ii=ids{myid}
    % for ii=1:Ndata
    offset = offset_arr{myid};
        figure()
        str_sgtitle=['trajectory ',num2str(ii)];
        set(gcf,'position',pos0)
        sgtitle(str_sgtitle,'fontsize',20)
        x0 = min(x{ii}./1000);
        y0 = min(y{ii}./1000);
        scatter(x{ii}./1000-x0+offset(1),...
            y{ii}./1000-y0+offset(2),50,time{ii},'filled')
        xlabel('x [mm]')
        ylabel('y [mm]')
        % xticks(xticks_arr{id})
        % yticks(yticks_arr{id})
        % xlim(xlim_arr{id})
        % ylim(ylim_arr{id})
        axis square
        box on
        colorbar()
        set(gca,'fontsize',30)
        figname=[figpath,prefix,num2str(ii),'_trajonly.png'];
        saveas(gcf, figname);
            
        pos=[200 200 500 200];
        figure('Position',pos)
        tt=time{ii};
        plot(tt(Nframe/2:end-Nframe/2), v{ii}./1000, LW,2)
        xlabel('time [s]')
        ylabel('v [mm/s]')
        box on
        set(gca,'fontsize',20)
        xlim([0,180])
        xticks(0:60:180)
        figname=[figpath,prefix,num2str(ii),'_vonly.png'];
        saveas(gcf, figname);

        close all
    % end
    
end




