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
This applies to processdir and bwmask directory. 
h5tobinmaskdriveSHORT is being worked on to add the feature of discard
non-aligned multi image tifs and move the correctly aligned tifs to a
folder called processedir. 

5. Finally we can run either controlmRNAIntensity or masterBCcount. 
Both script generate voronoi polygons from the bwmask, find intersection of
polygon and original bwmask and uses the new mask with regionprops to find
intensity across XFP and mRNA channels. This information along with
centroid is stored in xfpdata(pos) struct under headers, centroid, cfp, yfp,
r1 and r2 (561 round 1 and 2), fr1 and fr2 (640 round 1 and 2). Each struct
dataset is stored in a folder data under folder name of the sample

ControlmRNAIntensity provides easy running to generate histograms and set
thresholds. It is the script that is modified to interface with data
masterBCcount is a less modifiable script. It uses thresholds to assign
barcode ID to the struct variables created before.
%}