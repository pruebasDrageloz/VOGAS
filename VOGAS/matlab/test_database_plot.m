% script to demo the VOGAS database plotting...

cd C:\Users\Karlc\Desktop\VOGAS\matlab
clear
close all

% https://se.mathworks.com/matlabcentral/answers/161458-how-can-i-change-the-default-text-interpreter-for-a-legend-in-r2014b
set(0, 'DefaultTextInterpreter', 'none')
set(0, 'DefaultLegendInterpreter', 'none')
set(0,'DefaultLegendAutoUpdate','off')

addpath('jsonlab-1.5');

local_path = 'C:\Users\Karlc\Desktop\VOGAS';
db_path = 'test_db\test_01LV\';

clin_table = readtable(fullfile(local_path,db_path,'test_clinic_1.csv'),'Delimiter',';');
link_table = readtable(fullfile(local_path,db_path,'test_link_table.csv'),'Delimiter',';');
%t_names = clin_table.Properties.VariableNames;

% e.g. find patients with cancer == 2
% GCids = clin_table(clin_table.VQ_cancer_group == 2, {'VQ_patientID'})

% 1) plot data for one id, might include more than one .json samples!

curid = '01LV0078'; % this includes four .json files, maybe from different device units?
link_row = find(strcmp(curid,link_table.VQ_patientID)); link_table(link_row,:)

figure(1);clf; set(gcf,'defaultlinelinewidth',2)
figure(2);clf; set(gcf,'defaultlinelinewidth',2)
colors = hsv(length(link_row)+3);
for iidi = 1:length(link_row)
    filepath = cell2mat(link_table.folder(link_row(iidi)));
    filename = cell2mat(link_table.filename(link_row(iidi)));
    cj = jsonLab_readVolgacore(fullfile(local_path,filepath,filename));
    figure(1); plot_sensor(cj,'GNP',colors(iidi,:))
    figure(2); plot_sensor(cj,'MOXanalog',colors(iidi,:))
end
for curfig = 1:2
    figure(curfig); 
    subplot(3,3,1); title(curid);
    legend(link_table.filename(link_row));
    linkaxes(get(gcf,'children'),'x')
end

% 2) plot data for different disease groups with different colours
%controls = find(clin_table.VQ_cancer_group==1);
%gc = find(clin_table.VQ_cancer_group==2);
figure(3);clf; set(gcf,'defaultlinelinewidth',1)
colors = [1 0 0;0 0 1];
for iigroup = 1:2
    currows = find(clin_table.VQ_cancer_group==iigroup);
    currows(6:end) = []; % fasten up the plot by removing most ...
    for ii1 = 1:length(currows)
        curid = cell2mat(table2array(clin_table(currows(ii1),{'VQ_patientID'})));
        link_row = find(strcmp(curid,link_table.VQ_patientID)); %link_table(link_row,:)
        for iidi = 1:length(link_row)
            filepath = cell2mat(link_table.folder(link_row(iidi)));
            filename = cell2mat(link_table.filename(link_row(iidi)));
            cj = jsonLab_readVolgacore(fullfile(local_path,filepath,filename));
            plot_sensor(cj,'GNP',colors(iigroup,:))
        end
    end
end
linkaxes(get(gcf,'children'),'x')


% 3) extract some feature(s) from data
%controls = find(clin_table.VQ_cancer_group==1);
%gc = find(clin_table.VQ_cancer_group==2);
ft = nan(size(clin_table,1),8,1); % collect all features into here
this_sensor = 'GNP';
for ii = 1:size(clin_table,1)
    curid = cell2mat(table2array(clin_table(ii1,{'VQ_patientID'})));
    link_row = find(strcmp(curid,link_table.VQ_patientID)); %link_table(link_row,:)
    for iidi = 1:length(link_row)
        filepath = cell2mat(link_table.folder(link_row(iidi)));
        filename = cell2mat(link_table.filename(link_row(iidi)));
        cj = jsonLab_readVolgacore(fullfile(local_path,filepath,filename));
        tmpx = extract_feature(cj,this_sensor,'mean_last_5');
        if(size(ft,3)<iidi)
            % append cols with nans
            ft = cat(3,ft,nan(size(clin_table,1),8,1));
        end
        ft(ii,:,iidi) = tmpx;
    end
end

% to use matlab histogram: create separate matrices for control and gc 
ft_cn = nan(size(ft));
ind = find(clin_table.VQ_cancer_group==1);
ft_cn(ind,:) = ft(ind,:);

ft_gc = nan(size(ft));
ind = find(clin_table.VQ_cancer_group==2);
ft_gc(ind,:) = ft(ind,:);

figure(4);clf; 
for iic = 1:8
    subplot(2,4,iic)
    % one trick more to have two variables in same hist() call
    cur_cn = squeeze(ft_cn(:,iic,:)); 
    cur_gc = squeeze(ft_gc(:,iic,:)); 
    hist([cur_cn(:) cur_gc(:)]);
    title(sprintf('%s ch%d',this_sensor,iic));
end
legend('control','gc')
% maybe should look for some better features...

%{
for iifig = 1:4
    saveas(iifig,sprintf('test_fig%d.png',iifig))
end
%}