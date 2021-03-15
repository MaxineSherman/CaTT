function [pID,pN] = fdr_correct(p,q)
% FORMAT [pID,pN] = fdr(p,q)
% 
% p   - vector of p-values
% q   - False Discovery Rate level
%
% pID - p-value threshold based on independence or positive dependence
% pN  - Nonparametric p-value threshold
%______________________________________________________________________________
% $Id: FDR.m,v 1.1 2009/10/20 09:04:30 nichols Exp $

%% MAXINE: i've added this.
x = size(p,1); y = size(p,2);
p = reshape(p,x*y,1);

p = p(isfinite(p));  % Toss NaN's
p = sort(p(:));
V = length(p);
I = (1:V)';

cVID = 1;
cVN = sum(1./(1:V));

pID = p(find(p<=I/V*q/cVID,1,'last' ));
pN  = p(find(p<=I/V*q/cVN, 1,'last' ));

%pID = reshape(pID,x,y);
%pN = reshape(pN,x,y);
