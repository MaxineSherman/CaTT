%CATT_IMPORT import data into an intero structure from the
%catt_data_importer spreadsheet
%   usage: dat = catt_import
%
%   This function will guide you through loading your ECG and behavioural
%   data into a format that the toolbox can use. 
%
%   The format of the output, dat, is as follows:
%   dat is an nparticipant x 1 structure with the following fields:
%      - dat(i).ECG is an ntrials x 1 cell array containing continuous ECG
%        data for each trial.
%      - dat(i).times is an ntrials x 1 cell array containing continuous
%      timestamps for the ECG data
%      - dat(i).Response is an ntrials x 1 vector containing a response per
%      trial
%     - dat(i).Onsets is an ntrials x 1 vector containing the onset
%     (response time or stimulus onset time) for each trial
%
%  For example, the 7th participant's data on their 10th trial would be
%     ECG - dat(7).ECG{10}
%     Times - dat(7).times{10}
%     Response - dat(7).Response(10)
%     Onsets - dat(7).Onsets(10)
%    
%
% ========================================================================
%  CaTT TOOLBOX v1.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================

function dat = catt_import

clc;
disp('===========================================');
disp('   Welcome to the CaTT Toolbox (v 1.0)');
disp('   Data import');
disp('===========================================');
disp('This function will import your data from');
disp('the intero_data_importer xls spreadsheet.');
disp('You can import participant data file-by-file by');
disp('running this script several times.');
disp('Alternatively, put all your participant data');
disp('importer spreadsheets into one folder and this script');
disp('will process them all at once.');
disp('Please note that if you have spaces in your');
disp('filenames then the script will probably crash.');

%%  ==============================================
%   Get files to import
%   ==============================================

runBatch = input('<strong>Run on one file (1) or run on a folder (2)? </strong>');

if runBatch == 1 % run on a single file
    disp(sprintf('\n'));
    disp('Importing from one data importer sheet...');
    disp('Enter the full path for the file.');
    disp('For example, enter /Users/Jane/Desktop/intero_data_importer_subj01.csv');
    fname = input('<strong>Full path: </strong>','s');
    fname = {fname};
    
elseif runBatch == 2 % run on a folder
    disp(sprintf('\n'));
    disp('Importing multiple importer sheets from a folder...');
    disp('Please ensure the folder only contains the data you want');
    disp('to import.');disp('Enter the full path for the folder.');
    disp('For example, enter /Users/Jane/Desktop/data');
    fname = input('<strong>Full path: </strong>','s');

    % get all file names
    fname = arrayfun( @(x) [x.folder '/' x.name], dir([fname '/*.csv']), 'UniformOutput', false);
    
else; error('Invalid response. Please enter (1) for a single file or (2) for a whole folder.');
end
    
%%  ==============================================
%   Import data from the files
%   ==============================================

% update the researcher
disp(sprintf('\n'));
disp('Starting import.');

for ifile = 1:numel(fname)
    
    % update researcher
    disp(sprintf('Importing file %d of %d...',[ifile, numel(fname)]));
    
    % load csv
    T = readtable(fname{ifile}); % load the xls
    
    % Check to see whether the readme stuff has been kept in or not.
    % If it has, remove it.
    opts = detectImportOptions(fname{ifile},'NumHeaderLines',0);
    
    if ismember({'InThisColumn'},opts.VariableNames)
        opts.VariableNamesRange = 'A6';
        opts.DataRange = 'A7';
        T = readtable(fname{ifile},opts,'ReadVariableNames',true);
    end
    
    % get the number of data rows
    nRows = numel(T.Behaviour);
    
    %%  ==============================================
    %   Check all columns
    %   ==============================================
    
     % check Timestamp is continuous & numeric
    if ~isnumeric(T.Timestamp)
        if iscell(T.Timestamp)
            try; T.Timestamp = cell2mat(T.Timestamp);
            catch; error('The column Timestamp has strings inside. Please ensure that all timestamps are numeric');
            end
        end
    end
    
    % check Trial is numeric. If it's not continuous, pad
    if iscell(T.Trial)
        empty_cell = find( cellfun('isempty',T.Trial) == 1);
        full_cell  = find( cellfun('isempty',T.Trial) == 0 );
        
        T.Trial(empty_cell) = cellfun(@(x) NaN,T.Trial(empty_cell),'UniformOutput',false);
        T.Trial(full_cell) = cellfun(@(x) str2double(x),T.Trial(full_cell),'UniformOutput',false);
        
        try
            T.Trial = cell2mat(T.Trial);
        catch; error('The column Trial has strings inside. Please ensure that all onsets are numeric');
        end
    end
    
    % check ECG is continuous & numeric
    if ~isnumeric(T.ECG)
        if iscell(T.ECG)
            try; T.ECG = cell2mat(T.ECG);
            catch; error('The column ECG has strings inside. Please ensure that all ECG voltage values are numeric');
            end
        end
    end
    
    % check Onset is numeric. If it's not continuous, pad
    if iscell(T.Onset)
        empty_cell = find( cellfun('isempty',T.Onset) == 1);
        full_cell  = find( cellfun('isempty',T.Onset) == 0 );
        
        T.Onset(empty_cell) = cellfun(@(x) NaN,T.Onset(empty_cell),'UniformOutput',false);
        T.Onset(full_cell) = cellfun(@(x) str2double(x),T.Onset(full_cell),'UniformOutput',false);
        
        try
            T.Onset = cell2mat(T.Onset);
        catch; error('The column Onset has strings inside. Please ensure that all onsets are numeric');
        end
    end
    
    % check Behaviour is numeric. If it's not continuous, pad
    if iscell(T.Behaviour)
        
        empty_cell = find( cellfun('isempty',T.Behaviour) == 1);
        full_cell  = find( cellfun('isempty',T.Behaviour) == 0 );
        
        T.Behaviour(empty_cell) = cellfun(@(x) NaN,T.Behaviour(empty_cell),'UniformOutput',false);
        T.Behaviour(full_cell) = cellfun(@(x) str2double(x),T.Behaviour(full_cell),'UniformOutput',false);
        
        try
            T.Behaviour = cell2mat(T.Behaviour);
        catch; error('The column Behaviour has strings inside. Please ensure that all onsets are numeric');
        end
    end
    
    % check Condition is numeric. If it's not continuous, pad
    if iscell(T.Condition)
        empty_cell = find( cellfun('isempty',T.Condition) == 1);
        full_cell  = find( cellfun('isempty',T.Condition) == 0 );
        
        T.Condition(empty_cell) = cellfun(@(x) NaN,T.Condition(empty_cell),'UniformOutput',false);
        T.Condition(full_cell) = cellfun(@(x) str2double(x),T.Condition(full_cell),'UniformOutput',false);
        
        try
            T.Condition = cell2mat(T.Condition);
        catch; error('The column Condition has strings inside. Please ensure that all onsets are numeric');
        end
    end
    
    %%  ==============================================
    %   Interpret trial information
    %   ==============================================
    
    nUnique  = numel(unique(T.Trial(~isnan(T.Trial))));
    nEntries = numel(T.Trial(~isnan(T.Trial)));
    
    if nUnique == 1 % trials indicated by a trigger
        dat(ifile).info.ntrials      = nEntries;
        dat(ifile).info.trial_marker = 'trigger';
    else
        dat(ifile).info.ntrials      = nUnique;
        if nEntries == nUnique; dat(ifile).info.trial_marker = 'trigger';
        else; dat(ifile).info.trial_marker = 'continuous';
        end
    end
    
    % loop trials & get start and end
    switch dat(ifile).info.trial_marker
        case 'trigger'
            dat(ifile).info.row_trialStart = find(~isnan(T.Trial));
            dat(ifile).info.row_trialEnd   = [dat(ifile).info.row_trialStart(2:end)-1; nRows];
        case 'continuous'
            
            % check nothing is missing
            nans = find(isnan(T.Trial));
            assert(isempty(nans),['Empty data on data rows ' num2str(nans)]);
            
            % load in trial info assuming all is ok
            dat(ifile).info.row_trialStart = [1; find(diff(T.Trial))];
            dat(ifile).info.row_trialEnd   = [find(diff(T.Trial))+1; numel(T.Trial)];
    end
            
                
    %%  ==============================================
    %   Loop trials and gather information
    %   ==============================================
    for itrial = 1:dat(ifile).info.ntrials
        
        trial_dat                     = T(dat(ifile).info.row_trialStart(itrial):dat(ifile).info.row_trialEnd(itrial),:);
        dat(ifile).ECG{itrial,1}      = trial_dat.ECG;
        dat(ifile).times{itrial,1}    = trial_dat.Timestamp - trial_dat.Timestamp(1) + 1;
        dat(ifile).Response(itrial,1) = unique(trial_dat.Behaviour(~isnan(trial_dat.Behaviour)));
        dat(ifile).Onsets(itrial,1)   = dat(ifile).times{itrial}(find(~isnan(trial_dat.Onset)));
        
    end 
    
    %%  ==============================================
    %   Finally, report the output to the researcher
    %   ==============================================
    
    disp('===========================================');
    disp(sprintf('   Participant %d summary:',[ifile]));
    disp('===========================================');
    disp(sprintf('Number of behavioural responses: %d',numel(dat(ifile).Response)));
    disp(sprintf('Number of unique behavioural responses: %d', numel(unique(dat(ifile).Response))));
    disp(sprintf('Number of ECG trials: %d',numel(dat(ifile).ECG)));
    
    nsamples = cellfun(@(x) numel(x),dat(1).ECG);
    disp(sprintf('Length of ECG trials: %d to %d samples',[min(nsamples), max(nsamples)]));
    
    disp(sprintf('Number of onsets: %d',numel(dat(ifile).Onsets)));
    disp(sprintf('Range of onsets: sample %d to %d',[min(dat(ifile).Onsets), max(dat(ifile).Onsets)]));
  
end

% save the data and tell the researcher where it is
sname = 'catt_data_imported.mat';
save(sname,'dat');
disp(sprintf('\n'));
disp(['<strong>Data has been saved in ' cd '/' sname '</strong>']);

end
    
    