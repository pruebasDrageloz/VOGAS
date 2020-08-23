% generate table which link_s each .json file to patient id and device id and gives information 

cd C:\large\vogas\WP6\test_db\matlab

clear
close all

addpath('jsonlab-1.5');

local_path = 'C:\large\vogas\WP6\';
db_path = 'test_db\test_01LV\';

clinics = {};
clinics{1}.filename = 'test_clinic_1.csv';
clinics{2}.filename = 'test_clinic_2.csv';
for iic = 1:length(clinics)
    clinics{iic}.ta = readtable(fullfile(local_path,db_path,clinics{iic}.filename),'Delimiter',';');
end

files = dir(fullfile(local_path,db_path,'**\*.json')); % matlab notation: '**\' looks for all subfolders
link_names = {
'filename','string'
'device_serial','string',
'folder','string'
'date','string'
'VQ_patientID','string'
'clinical','string'
'GNP','uint32'
'MOXanalog','uint32'
'MOXdigital','uint32'};

%link_table = cell2table(cell(length(files),length(link_names)),'VariableNames',link_names);
link_table = table('Size',[length(files),length(link_names)],'VariableNames',link_names(:,1),'VariableTypes',link_names(:,2));

for ii1 = 1:length(files)
    cj = jsonLab_readVolgacore(fullfile(files(ii1).folder,files(ii1).name));
    link_table(ii1,{'filename'}) = {files(ii1).name};
    link_table(ii1,{'device_serial'}) = {cj.measurements{1}.devices{1}.serial};
    link_table(ii1,{'folder'}) = {files(ii1).folder(length(local_path)+1:end)};
    link_table(ii1,{'date'}) = {cj.measurements{1}.date};
    curid = cj.measurements{1}.sample.code;
    link_table(ii1,{'VQ_patientID'}) = {curid};
    cur_clinic = '';
    for iic = 1:length(clinics)
        if any(strcmp(curid,clinics{iic}.ta.VQ_patientID))
            if isempty(cur_clinic)
                cur_clinic = clinics{iic}.filename;
            else
                % add more
                cur_clinic = sprintf('%s, %s',cur_clinic,clinics{iic}.filename);
                %cur_clinic = cat(2,cur_clinic,clinics{iic}.filename);
            end
        end
    end
    link_table(ii1,{'clinical'}) = {cur_clinic}; 
    link_table(ii1,{'GNP'}) = {isfield(cj,'GNP')}; 
    link_table(ii1,{'MOXanalog'}) = {isfield(cj,'MOXanalog')}; 
    link_table(ii1,{'MOXdigital'}) = {isfield(cj,'MOXdigital')}; 
end

% write the table
% writetable(link_table,'test_link_table.csv','Delimiter',';');

% if you would test not same information is duplicated in different folders
columns_to_check = setdiff(1:size(link_table,2),3);% just skip the subfolder which is column 3
[C,IA,IC] = unique(link_table(:,columns_to_check),'stable','rows'); 
assert(size(C,1)==size(link_table,1),'same filename and content was found in different folders?');

columns_to_check = 1;% or just by filename, but this might find duplicate filenames, as having same id and date but from under different device folders
[C,IA,IC] = unique(link_table(:,columns_to_check),'stable','rows'); 
assert(size(C,1)==size(link_table,1),'same filename.json was found in different folders?');

