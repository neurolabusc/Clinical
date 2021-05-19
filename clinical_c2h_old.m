function clinical_c2h (V);
% This script converts a CT scan from Cormack to Hounsfield Units
%   V: image name(s) [optional]
% Example
%   clinical_c2h('C:\ct\script\Pat1nolesion.nii');
fprintf('CT Cormack to Hounsfield version 2/2/2012\n');
if nargin <1 %no files
 V = spm_select(inf,'image','Select CT[s] to normalize');
end;

for i=1:size(V,1)
 ref = deblank(V(i,:));
 [pth,nam,ext] = spm_fileparts(ref); 
 ref = fullfile(pth,[ nam ext]);
 if (exist(ref) ~= 2) 
 	fprintf('clinical_c2h error: unable to find source image %s.\n',ref);
	return;  
 end;
 Vi  = spm_vol(strvcat(V(i,:)));
 % next scale from Hounsfield to Cormack
   clear img; %reassign for each image, in case dimensions differ
  VO       = Vi;
  [pth,nam,ext] = spm_fileparts(ref);
  VO.fname = fullfile(pth,['h' nam '.nii']);
  VO.private.dat.scl_slope = 1;
  VO.private.dat.scl_inter = -1024;
  VO.pinfo(1) = VO.private.dat.scl_slope;
  VO.pinfo(2) = VO.private.dat.scl_inter;
    VO       = spm_create_vol(VO);
  for i=1:Vi.dim(3),
    img      = spm_slice_vol(Vi,spm_matrix([0 0 i]),Vi.dim(1:2),0);
    for px=1:length(img(:)),
        img(px) = c2hsub(img(px));
      end; %for each pixel
  	VO       = spm_write_plane(VO,img,i);
   end; %for each slice
fprintf('Please check that the header sets the intercept to -1024\n');
end; %for each volume


%end clinical_c2h()

function x = c2hsub(x);
%Convert Cormack to Hounsfield 
 [kUninterestingDarkUnits, kInterestingMidUnits] = clinical_cormack();
 kScaleRatio = 10;% increase dynamic range of interesting voxels by 3
 kMax = kInterestingMidUnits * (kScaleRatio+1); 
 if x > kUninterestingDarkUnits 
    lExtra = x- kUninterestingDarkUnits;
    if (lExtra > kMax) 
    	lExtra = kInterestingMidUnits + (lExtra-kMax);
    else
    	lExtra = round(lExtra/(kScaleRatio+1));
    end;
    x = kUninterestingDarkUnits + lExtra;
 else
    x = x; %
 end; %if conditions
 x = x-1024; %air is darkest at ~-1000: most 12-bit CT systems encode as -1024