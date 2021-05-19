function clinical_c2h (V)
% This script converts a CT scan from Cormack to Hounsfield Units
%   V: image name(s) [optional]
% Example
%   clinical_c2h('C:\ct\script\Pat1nolesion.nii');
fprintf('CT Cormack to Hounsfield version 4/4/2016\n');
if nargin <1 %no files
 V = spm_select(inf,'image','Select CT[s] to normalize');
end;
for i=1:size(V,1)
 ref = deblank(V(i,:));
 [pth,nam,ext] = spm_fileparts(ref);
 ref= fullfile(pth,[nam ext]);
 if (exist(ref,'file') ~= 2)
 	fprintf('Error: unable to find source image %s.\n',ref);
	return;
 end;
 hdr  = spm_vol(deblank(V(i,:)));
 % determine range...
 img = spm_read_vols(hdr);
 img(~isfinite(img)) = 0;
 fprintf('%s input intensity range %.0f %.0f\n',ref,round(min(img(:))),round(max(img(:))));
 fprintf(' Ignore QFORM0 warning if reported next\n');
 % next scale from Hounsfield to Cormack
 [pth,nam,ext] = spm_fileparts(hdr.fname);
 hdr.fname = fullfile(pth,['h' nam ext]);
 img = c2hsub(img(:));
 img = reshape(img,hdr.dim);
 if spm_type(hdr.dt(1),'minval') >= 0
    slope = 1;
    hdr.dt(1) = 16; %2014
    fprintf('Saving %s as 32-bit floating point\n',hdr.fname);
 elseif spm_type(hdr.dt(1),'intt')
    %Hounsfield values -1024...max(img)
    mx = max(max(img(:)), abs(min(img(:))) );
    slope = mx/ spm_type(hdr.dt(1),'maxval') ;
else
    slope = 1;
end
hdr.pinfo(1) = slope; %2014 - change slope in pinfo as well as private
hdr.pinfo(2) = 0; %2014 - change intercept in pinfo as well as private
spm_write_vol(hdr,img);
end; %for each volume
%end clinical_c2h()

function out = c2hsub(img)
%Convert Cormack to Hounsfield
[kUninterestingDarkUnits, kInterestingMidUnits] = clinical_cormack();
kScaleRatio = 10;% increase dynamic range of interesting voxels by 3
kMax = kInterestingMidUnits * (kScaleRatio+1);
if (min(img(:)) < 0)
    error('c2h error: negative brightnesses impossible in the Cormack scale');
end
img = img-kUninterestingDarkUnits; %out now correct for 0..UninterestingUnits
out = img; %out now correct for 0..UninterestingUnits
v = img/(kScaleRatio+1);
idx = intersect (find(img > 0),find(img <= kMax));
%end c2hsub()
out(idx) = v(idx);  %out now correct for 0..UninterestingUnits+kInterestingMidUnits
v = img - kMax + (kMax/(kScaleRatio+1)); %compute voxels brighter than interesting
idx = find(img > kMax);
out(idx) = v(idx);  %out now correct for all intensities
out = out+(kUninterestingDarkUnits-1024); %air is darkest at ~-1000: most 12-bit CT systems encode as -1024
%end c2hsub()