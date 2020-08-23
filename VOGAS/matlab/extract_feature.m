function x = exact_feature(cj,this_sensor,this_feature);

if(~exist('this_sensor','var') | isempty(this_sensor))
    this_sensor = 'GNP';
end

if(~exist('this_feature','var') | isempty(this_feature))
    this_sensor = 'mean_last_5';
end

x = nan(1,8);
tmp = cj.Flow;
iic = 1;

ylabel('Flow')
%title(tmp.names{iic})
if(isfield(cj,this_sensor))
    tmp = cj.(this_sensor);
    % baseline compensation
    tmp.x = tmp.x./(ones(size(tmp.x,1),1)*tmp.baseline);
    switch this_feature
    case 'mean_last_5'
        inds = find(tmp.t>=max(tmp.t)-5);
        x = mean(tmp.x(inds,:)); 
    otherwise
        error('no such feature')
    end
end