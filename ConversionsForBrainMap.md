# Converting between spaces and formatting coordinates

Various functions in BrainMap may require you to convert between MNI and TAL spaces. In neurosynth, a lot of this was automatically handled for you. There are plenty of situations where you might need to convert between spaces, whether it's to prep your data for decoding in mango, or to simply have all of the cooridnates you've hand picked from studies be in the same space, or in the correct space for gingerALE. This readme will take you through some simple code provided in this repository that might be helpful for doing that.

*This is a note from future Alex: I've been using BrainMap a bit more and I've noticed that even if you request for sleuth to report/save coordinates in MNI (i.e., translate from it's natively saved TAL coordinates), it will occasionally fail to do so. You'll be able to tell by inspecting the text file. If some but not all of the coordinates are rounded up to the nearest mm, I would inspect the rounded up coordinates in the original study. If the original study shows these coordinates to be TAL, you can quickly convert them using convertMNI2TAL.m*

* voxelize.m will take any nfiti file you give it (representing a statistical map or not) and spit out the coordinates in the file. The important thing is that it will give you both mm coordinates and voxel coordinates (among others). This will be especially useful for preparing your data for decoding in mango (see main readme). All scripts for converting coordinates live in ./convert

  * voxelize.m reads/writes in files using load_nifti.m and save_nifti.m. These are [freesurfer](https://surfer.nmr.mgh.harvard.edu) functions that are redistributed in this repository. Make sure these are in your matlab path before you run anything else (they are in ./helpers/freesurfer). I understand that now matlab imaging toolbox has a native function for reading/writing nifti files so you can edit a few lines of this code to update it if you'd like.

  * voxelize.m converts voxel coordinates to mm coordinates using convertVoxel2MM.m, which relies on the sform matrix in the nifti header of your file. If coordinates rather than a file is passed, then this script will use info from a 2mm MNI space template.

    * convertMM2Voxel.m will allow you to transform coordinates in the reverse direction if you ever need to (and in the same way as convertVoxel2MM.m)

* convertMNI2TALImage.m will convert an MNI image into a TAL image. 

  * convertTAL2MNI.m will convert a TAL image into MNI.
  
  * Both of these scripts can take in multiple files as input. If inFiles is passed as empty, they will launch a file selection GUI called uipickfiles (redistributed here from [elsewhere](https://www.mathworks.com/matlabcentral/fileexchange/10867-uipickfiles-uigetfile-on-steroids) and placed in ./helpers). You'll want to make sure this script is in your MATLAB path as well.

  * convertMNI2TALImage.m relies on convertMNI2TAL.m which is really a snippet of code from [a paper](http://brainmap.org/pubs/LancasterHBM07.pdf) documenting a reliable mni to talaraich transform (and specifically for BrainMap!). BrainMap does also provide a GUI that converts coordinates using both this and a few other transformation matrices (though this is the recommended one). However, the code here is a more lightweight solution that can be used with code like convertMNI2TALImage.m in order to convert an entire map automatically.
  
* Finally, if you have a bunch of coordinates compiled from papers that you'd like to meta-analyze with gingerALE, aleTemplate.m will help you put them into a text file that can be easily loaded up in gingerAle.
