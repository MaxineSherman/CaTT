%INTERO_MAKECMAP make a color map that goes from col0 to col1  
%   usage: cmap = intero_makecmap(col0,col1)
%
% ========================================================================
%  CaTT TOOLBOX v2.0
%  Sackler Centre for Consciousness Science, BSMS
%  m.sherman@sussex.ac.uk
%  08/08/2021
% =========================================================================

function cmap = catt_makecmap(col0,col1)

r0 = col0(1); g0 = col0(2); b0 = col0(3);
r1 = col1(1); g1 = col1(2); b1 = col1(3);

cmap = [ linspace(r0,r1,256)' ,...
         linspace(g0,g1,256)' ,...
         linspace(b0,b1,256)' ];
    
end