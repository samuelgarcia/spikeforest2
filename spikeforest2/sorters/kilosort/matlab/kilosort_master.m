function kilosort_master(dat_file, output_folder, params)

if isstr(params)
    params = jsondecode(fileread(params));
end;

% set file path
fpath = output_folder;

kilosort_channelmap( ...
    'chanMap.mat', ...
    struct( ...
        'nchan', params.nchan, ...
        'xcoords', params.xcoords, ...
        'ycoords', params.ycoords, ...
        'kcoords', params.kcoords, ...
        'sample_rate', params.sample_rate ...
    ) ...
);

ops = kilosort_config(struct( ...
    'nchan', params.nchan, ...
    'sample_rate', params.sample_rate, ...
    'dat_file', dat_file, ...
    'freq_min', params.freq_min, ...
    'freq_max', params.freq_max, ...
    'kilo_thresh', params.kilo_thresh, ...
    'use_car', params.use_car, ...
    'Nfilt', params.Nfilt, ...
    'Nt', params.Nt, ...
    'chanmap_file', 'chanMap.mat' ...
))

[rez, DATA, uproj] = preprocessData(ops); % preprocess data and extract spikes for initialization
rez                = fitTemplates(rez, DATA, uproj);  % fit templates iteratively
rez                = fullMPMU(rez, DATA);% extract final spike times (overlapping extraction)

rez = merge_posthoc2(rez);

% save python results file for Phy
rezToPhy(rez, fullfile(fpath));