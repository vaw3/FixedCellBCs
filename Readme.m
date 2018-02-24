%{
1. First run ControlImgtoHist and Rawimgtoalignmask while in the directory
with the raw image data files. Both files align images and make nucleus
only composites under mergectrl and mergenuclear directories
respectively.

RUN ILASTIK ON MERGECTRL AND mergenuclear FILES

After ILASTIK processing of nucleus composites, both files also have
separate sections that process h5 files into binary TIFs. Additionally
ControlImgtoHist also generates XFPCTRLData variable which stores
non-specific mRNA binding for all rounds of hyb after building voronoi
polygons from the control masks in ctrlmasks. 

2. Next run masterBC which accesses true sample binary masks in masks
folder and aligned raw image TIFs in testout. It creates voronoi polygons
and proccesses debris in masks. It then uses regionprops to extract
intensity in nuclei vicinity for mRNA across hybs and the fluorescent
protein. It stores information in xfpdata variable and saves it to active
folder.

3. Next run analysishist which bins distribution of mRNA and XFP intensity
of cells for both true samples and controls across both hybridizations. 

4. Finally run AssignBarcodes by setting appropriate thresholds from the
histograms. AssignBarcodes adds in a boolean and string vector of the
barcodes associated with each cell in xfpdata creating lineages.
Implementation of categorical analysis of lineages underway. Finally, this
script saves nuclearcomposite images of each position of true sample in
lineageimg with the lineage ID printed on centroid of nucleus. 

5. Run lineagehistogram and lineageanalysis
%}