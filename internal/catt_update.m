%CATT_UPDATE update intero structure, kicking out bad trials
%   usage: catt = catt_update(catt,trials_to_keep)
%
%   
%
% ========================================================================
%  CaTT TOOLBOX v1.1
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================

function catt = catt_update( catt , trials_to_keep )

% for each field in intero, retain only trials_to_keep
catt.keepTrial      = ones(numel(trials_to_keep),1);
catt.retained_idx   = [1:numel(trials_to_keep)]';

catt.ECG.raw        = catt.ECG.raw( trials_to_keep );
catt.ECG.times      = catt.ECG.times( trials_to_keep );
catt.ECG.processed  = catt.ECG.processed( trials_to_keep );
catt.responses      = catt.responses( trials_to_keep );
catt.onsets         = catt.onsets( trials_to_keep );

catt.tlock.rPeaks      = catt.tlock.rPeaks( trials_to_keep );
catt.tlock.rPeaks_msec = catt.tlock.rPeaks_msec( trials_to_keep );

% recompute IBI and HRV
catt.IBI        = [];
catt.HRV        = [];

for i = 1:numel( catt.responses )
    catt.IBI(i,1) = catt_IBI( catt.tlock.rPeaks_msec{i} );
    catt.HRV(i,1) = catt_HRV( catt.tlock.rPeaks_msec{i} , 'r', catt.HRV_method );
end

end