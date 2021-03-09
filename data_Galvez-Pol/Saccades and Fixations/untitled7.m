clear all;close all;clc

param = intero_init; global param; param.wrap2 = 'rpeak';

files = dir('Sub*.mat');
for i = 1:32
    load(files(i).name);
    intero.IBI = Saccades_Mx2(:,3);
    intero.onsets = Saccades_Mx2(:,2);

%     intero.IBI = Saccades_Mx3(:,4);
%     intero.onsets = Saccades_Mx3(:,2); 2; 
    
    clc;disp(i);
    [pval(i,1),stats{i}]  = intero_bootstrap_clust(intero,'omnibus',1000);
    pval2(i,1) =circ_rtest( intero_wrap2heart(intero.onsets,intero.IBI) );
end

% combine pvalues
combine_pvalues(pval,1,1)
combine_pvalues(pval2,1,1)

% calculate all test stats as a function of null
for i = 1:32
    z(i,1) = (stats{i}.test_stat - mean(stats{i}.null))/std(stats{i}.null);
end

nanmean(z)
P = 1-normcdf(abs(nansum(z)))