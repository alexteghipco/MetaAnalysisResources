function [pVec, pVecCorr, pVecQVals] = ZtoP(zVec, multCorr, alpha)

if nargin < 2, multCorr = 'none'; end
if nargin < 3, alpha = 0.05; end
    
pVec = 2*(1 - normcdf(abs(zVec)));

switch multCorr
    case 'none'
        pVecCorr = []; pVecQVals = [];
    case 'FDR'
        [pVecCorr, pVecQVals] = mafdr(pVec);
    case 'bonferonni'
        [pVecCorr,~] = bonf_holm(pVec,alpha);
        pVecQVals = [];
end
        