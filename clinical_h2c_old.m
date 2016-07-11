function clinical_h2c (V);
% This script converts a CT scan from Hounsfield Units to Cormack
%   V: image name(s) [optional]
% Example
%   clinical_h2c('C:\ct.nii');

fprintf('CT normalization version 4/4/2016\n');

if nargin <1 %no files
 V = spm_select(inf,'image','Select CT[s] to normalize');
end;

for i=1:size(V,1)
 ref = deblank(V(i,:));
 [pth,nam,ext] = spm_fileparts(ref);
 ref= fullfile(pth,[nam ext]);
 if (exist(ref) ~= 2)
 	fprintf('Error: unable to find source image %s.\n',ref);
	return;
 end;
 Vi  = spm_vol(strvcat(V(i,:)));
 % determine range...
  clear img; %reassign for each image, in case dimensions differ
 mx = -Inf;
 mn =  Inf;
 for p=1:Vi.dim(3),
	img = spm_slice_vol(Vi,spm_matrix([0 0 p]),Vi.dim(1:2),1);
	msk = find(isfinite(img));
	mx  = max([max(img(msk)) mx]);
	mn  = min([min(img(msk)) mn]);
 end;
 range = mx-mn;
 %Hounsfield units, in theory
 %  min = air = ~-1000
 %  max = bone = ~1000
 %  in practice, teeth fillings are often >3000
 %  Therefore, raise warning if range < 2000
 %   or Range > 6000 then generate warning: does not appear to be in Hounsfield units
 if (range < 1999) | (range > 8000)
	fprintf('Error: image intensity range (%f) does not appear to be in Hounsfield units.\n',range);
	%return
 end;
 fprintf('%s intensity range: %d\n',ref,round(range));
 fprintf(' Ignore QFORM0 warning if reported next\n');

 % next scale from Hounsfield to Cormack
  VO       = Vi;
  [pth,nam,ext] = spm_fileparts(ref);
  VO.fname = fullfile(pth,['c' nam '.nii']);
  %spm_type(Vi.dt(1),'maxval')
  VO.pinfo(1) = 1; %2014 - change slope in pinfo as well as private
  VO.pinfo(2) = 0; %2014 - change intercept in pinfo as well as private
  VO.private.dat.scl_slope = 1;
  VO.private.dat.scl_inter = 0;
  if   h2csub(mx,mn) > spm_type(Vi.dt(1),'maxval')
  	fprintf('clinical_h2c: image data-type increased to 32-bit float %s\n',VO.fname);
  	VO.dt(1) = 16; %2014
  end;
    VO       = spm_create_vol(VO);
  clipped = 0;
  for i=1:Vi.dim(3),
    img      = spm_slice_vol(Vi,spm_matrix([0 0 i]),Vi.dim(1:2),0);
    for px=1:length(img(:)),
        img(px) = h2csub(img(px),mn);
      end; %for each pixel
  	VO       = spm_write_plane(VO,img,i);
   end; %for each slice
end; %for each volume

function out = h2csub(in,min);
%======================
%Convert Hounsfiled to Cormack
 kUninterestingDarkUnits = 900; % e.g. -1000..-100
 kInterestingMidUnits = 200; %e.g. -100..+300
 kScaleRatio = 10;% increase dynamic range of interesting voxels by 3

 v16 = in-min;
 lExtra = v16-kUninterestingDarkUnits;
 if lExtra > kInterestingMidUnits
   lExtra = kInterestingMidUnits;
 end;
 if lExtra > 0
   lExtra = lExtra*kScaleRatio;
  else
   lExtra = 0;
 end;
  out = v16+lExtra;