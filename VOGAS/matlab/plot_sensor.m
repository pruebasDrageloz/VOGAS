function plot_sensor(cj,this_sensor,this_color);

if(~exist('this_sensor','var') | isempty(this_sensor))
    this_sensor = 'GNP';
end

if(~exist('this_color','var') | isempty(this_color))
    this_color = [1 0 0];
end


tmp = cj.Flow;
subplot(3,3,1);
iic = 1;
line(tmp.t-cj.t0,(tmp.x(:,iic)),'color',this_color); 
ylabel('Flow')
%title(tmp.names{iic})
if(isfield(cj,this_sensor))
    tmp = cj.(this_sensor);
    % baseline compensation
    tmp.x = tmp.x./(ones(size(tmp.x,1),1)*tmp.baseline);
    for iic = 1:8
        subplot(3,3,iic+1);
        line(tmp.t(tmp.inds)-cj.t0,tmp.x(tmp.inds,iic),'color',this_color); 
        ylabel('baseline compensated');
        title([char(tmp.names{iic})])
        %set(gca,'ylim',[0.995 1.014])
        set(gca,'xlim',[-15 20]);
    end
end