%INTERO_UPDATE update intero structure, kicking out bad trials
%   usage: intero = intero_update(intero,trials_to_keep)
%
%   
%
% ========================================================================
%  INTERO TOOLBOX v1.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  23/04/2020
% =========================================================================

function intero = intero_update( intero , trials_to_keep )

% for each field in intero, retain only trials_to_keep
intero.keepTrial      = ones(numel(trials_to_keep),1);
intero.retained_idx   = [1:numel(trials_to_keep)]';

intero.ECG.raw        = intero.ECG.raw( trials_to_keep );
intero.ECG.times      = intero.ECG.times( trials_to_keep );
intero.ECG.processed  = intero.ECG.processed( trials_to_keep );
intero.responses      = intero.responses( trials_to_keep );
intero.onsets         = intero.onsets( trials_to_keep );

intero.tlock.rPeaks      = intero.tlock.rPeaks( trials_to_keep );
intero.tlock.rPeaks_msec = intero.tlock.rPeaks_msec( trials_to_keep );
%intero.tlock.rPeaks_amp  = intero.tlock.rPeaks_amp( trials_to_keep );

% recompute IBI and HRV
intero.IBI        = [];
intero.HRV        = [];

for i = 1:numel( intero.responses )
    intero.IBI(i,1) = intero_IBI( intero.tlock.rPeaks_msec{i} );
    intero.HRV(i,1) = intero_HRV( intero.tlock.rPeaks_msec{i} , 'r', intero.HRV_method );
end

end