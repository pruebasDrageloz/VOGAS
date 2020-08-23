%% A routine to read and plot sensor data from cj files

function cj = readSensorOutput(filepath)
% filepath = path of the cj file to read

% addpath('C:\data\matlab\jsonlab-1.5\');
% filepath = 'C:\data\projects\Vogas\data\Riga\Volgacore\volgacore001\10000410_19_12_09_11_02.json';

%% Read cj file
cj = loadjson(filepath);
cj.parameters = cj.measurements{1}.devices{1}.parameters;
cj.t0 = nan;

for iis = 1:length(cj.measurements{1}.devices{1}.devices); 
    devname0 = cj.measurements{1}.devices{1}.devices{iis}.name;
    tmp = cj.measurements{1}.devices{1}.devices{iis}.sensors; 
    if iscell(tmp.data)
        celldata = tmp.data;
        tmp.data = zeros(0,length(celldata{1}));
        for iic = 1:length(celldata)
            if(length(celldata{iic})==size(tmp.data,2))
                tmp.data(iic,:) = celldata{iic};
            end
        end
    end
    switch devname0
        case 'Flow'
            devname = devname0;
            cj.(devname).t = tmp.data(:,1)*24*3600;
            cj.(devname).x = tmp.data(:,2:end);
            cj.(devname).names = tmp.names;
        case 'GNP'
            devname = devname0;
            cj.(devname).t = tmp.data(:,1)*24*3600;
            cj.t0 = cj.(devname).t(cj.parameters.BaselineAcqs+1);
            cj.(devname).x = tmp.data(:,2:end);
            cj.(devname).names = tmp.names;

            cj.(devname).inds = logical(zeros(size(cj.(devname).t)));
            cj.(devname).inds(cj.parameters.BaselineAcqs+1:end) = 1;
            cj.(devname).baseline = mean(cj.(devname).x(~cj.(devname).inds,:));
        case 'MOX analog'
            devname = 'MOXanalog';
            cj.(devname).t = tmp.data(:,1)*24*3600;
            cj.(devname).x = tmp.data(:,2:end);
            cj.(devname).names = tmp.names;

            cj.(devname).inds = logical(zeros(size(cj.(devname).t)));
            cj.(devname).inds(cj.parameters.BaselineAcqs+1:end) = 1;
            cj.(devname).baseline = mean(cj.(devname).x(~cj.(devname).inds,:));
        case 'MOX digital'
            devname = 'MOXdigital';
            cj.(devname).info = 'todo';
    end
    %plot(tmp.data); legend(tmp.names); pause; end
end

%{


%% Convert units
datafield =     {'baseline', 'breath',   'nv',      'environment'};
subdatafield =  {'gnpvalues','gnpvalues','nvvalues','bmevalues'};
newsubdatafield =  {'gnpvaluesConverted','gnpvaluesConverted',...
    'nvvaluesConverted','bmevaluesConverted'};

cj.measurement.baseStartSeconds = cj.measurement.device.device.baseline.gnpvalues(1,1)*24*3600;

for i = 1:length(datafield)
    cj.measurement.device.device.(datafield{i}).(newsubdatafield{i}) = ...
        cj.measurement.device.device.(datafield{i}).(subdatafield{i});
    
    % Time to seconds
    cj.measurement.device.device.(datafield{i}).(newsubdatafield{i})(:,1) = ...
        (cj.measurement.device.device.(datafield{i}).(subdatafield{i})(:,1)*24*3600 ...
        -cj.measurement.baseStartSeconds);
    
	%if ~contains(subdatafield{i},'bme')
	if isempty(strfind(subdatafield{i},'bme'))
		% ADC to voltage
		cj.measurement.device.device.(datafield{i}).(newsubdatafield{i})(:,2:end) = ...
			(cj.measurement.device.device.(datafield{i}).(subdatafield{i})(:,2:end)/(2^32-1))*2.5;
		
		% Voltage to resistance
		%if contains(subdatafield{i},'gnp')
		if ~isempty(strfind(subdatafield{i},'gnp'))
			cj.measurement.device.device.(datafield{i}).(newsubdatafield{i})(:,2:end) = ...
				200*10^3./(1.2*(cj.measurement.device.device.(datafield{i}).(newsubdatafield{i})(:,2:end)).^(-1)-1);
		%elseif contains(subdatafield{i},'nv')
		elseif ~isempty(strfind(subdatafield{i},'nv'))
			cj.measurement.device.device.(datafield{i}).(newsubdatafield{i})(:,2:end) = ...
				10^6*(1.2*(cj.measurement.device.device.(datafield{i}).(newsubdatafield{i})(:,2:end)).^(-1))-10^6;
		end
	end
end

%% include some common measurements
tmpt = cj.measurement.device.device.environment.bmevalues(:,1)*24*3600-cj.measurement.baseStartSeconds;
tmpind = find(tmpt>40); % select environment after breath sample, i.e. after one minute
tmpind(tmpt(tmpind)>tmpt(tmpind(1))+15) = []; % take in maximum 15 seconds
tmp = cj.measurement.device.device.environment.bmevalues(tmpind,:);
cj.measurement.env.N = size(tmp,1);
cj.measurement.env.Min = min(tmp);
cj.measurement.env.Max = max(tmp);
cj.measurement.env.Mean = mean(tmp);
cj.measurement.env.Median = median(tmp);

% features
tmpx = cj.measurement.device.device.baseline.gnpvaluesConverted;
% select tmpind as 80-100% end period from the total measurement recording:
tmpt = tmpx(:,1); tmptNorm = (tmpt-tmpt(1))/(tmpt(end)-tmpt(1)); tmpind = find(tmptNorm>=.8);
cj.measurement.feat.baseline.mean80_100 = mean(tmpx(tmpind,:));

tmpx = cj.measurement.device.device.breath.gnpvaluesConverted;
% select tmpind as 80-100% end period from the total measurement recording:
tmpt = tmpx(:,1); tmptNorm = (tmpt-tmpt(1))/(tmpt(end)-tmpt(1)); tmpind = find(tmptNorm>=.8);
cj.measurement.feat.breath.mean80_100 = mean(tmpx(tmpind,:));
%}