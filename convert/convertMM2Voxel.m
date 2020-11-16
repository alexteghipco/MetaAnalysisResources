function [outCoords] = convertMM2Voxel(inFile,inCoords)
% exactly like convertVoxel2MM.m but in the other direction
% alex.teghipco@uci.edu

if isempty(inFile) == 0
    inFileNifti = load_nifti(inFile);
    tsfMat = inFileNifti.sform;
else
    % convert to MNI coordinates
    warning('Assuming your coordinates are in 2mm MNI space');
    scriptPath = which('convertVoxel2MM');
    scriptPath = scriptPath(1:end-18);
    template = load([scriptPath '/2mmTemplate.mat'],'template');
    template = template.template;
    tsfMat = vertcat(template.hdr.hist.srow_x,template.hdr.hist.srow_y,template.hdr.hist.srow_z,[0 0 0 1]);
end

tsfMatInvt = inv(tsfMat);
tsfMatInvt(4,:) = [];

% find which dimensions are of size 3
 dimdim = find(size(inCoords) == 3);

% 3x3 matrices are ambiguous
% default to coordinates within a row
if dimdim == [1 2]
  disp('input is an ambiguous 3 by 3 matrix')
  disp('assuming coordinates are row vectors')
  dimdim = 2;
end

% transpose if necessary
if dimdim == 2
  inCoords = inCoords';
end

% apply the transformation matrix
inCoords = [inCoords; ones(1, size(inCoords, 2))];
inCoords = tsfMatInvt * inCoords;

% format the outpoints, transpose if necessary
outCoords = fix(inCoords(1:3, :));
if dimdim == 2
  outCoords = outCoords';
end
