function [] = convertTAL2MNIImage(inFiles,thresh,binarize)

% for conversion of one file, please place your file in a cell {'file'}
% for multiple files, either generate a cell array, or leave inFiles empty (i.e., []) to summon a gui and select files for conversion
% output file will have same name as input but appended with '_TAL'. Output naming assumes input file is nii.gz and not .nii.
% alex.teghipco@uci.edu

if isempty(inFiles) == 1
    inFiles = uipickfiles;
else

outNifti = load_nifti(inFiles{1});

for i = 1:length(inFiles)
    [voxelROI_matlabSpaceS, voxelROI_niftiSpaceS, voxelROI_empty_matlabSpaceS, voxelROI_empty_niftiSpaceS, voxelROI_matlabSpaceI, emptyVoxels_matlabSpaceI, voxelROI_mm, emptyVoxels_mm, voxelData] = voxelize(inFiles{i},'false');
    [tal] = convertTAL2MNI(voxelROI_mm);
    talVox = convertMM2Voxel(inFiles{i},tal);
    ind = sub2ind([size(outNifti.vol)],talVox(:,1)+1,talVox(:,2)+1,talVox(:,3)+1);
    outNifti.vol = zeros(size(outNifti.vol));
    outNifti.vol(ind) = voxelData;
    save_nifti(outNifti,[inFiles{i}(1:end-6) '_TAL.nii.gz'])
end
