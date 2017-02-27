%{
1. First run runcodeonefile60X on a directory with all samples in folders
and images stored in andor format montage. _m%%%%_w%%%%_z%%%%
Script will create two folders, masks and mask_tif. Masks should have
MATLAB dat format images of MIP and masks_tif the TIF version of MIP across
multiple wavelengths and positions. 
2. Next runRegistration should be run after specifying data folders.
runRegistration will create two folders, multi and composite and 
save the nuclei channels in composite and append all the wavelengths
across hyb rounds into one tif file. It will do all this while ensuring the
images are aligned.
3. Next run ilastik on the files in the composite folder created above
4. Next h5tobinmaskdriveSHORT should read in directory for exported ilastik
files, create binary masks, save them in a folder bwmask 
WARNING: The above function cannot create the individual folders for each
sample into which it writes the data. For simplicity, simply copy the
folders for each sample from within the folder of masks_tif.
h5tobinmaskdriveSHORT is being worked on to add the feature of discard
non-aligned multi image tifs and move the correctly aligned tifs to a
folder called 
