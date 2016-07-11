function clinical_h2c (fnms)
% This script converts a CT scan from Hounsfield Units to Cormack
%   fnms: image name(s) [optional]
% Example
%   clinical_h2c('C:\ct.nii');
fprintf('CT Hounsfield to Cormack version 4/4/2016\n');
if ~exist('fnms','var')
 fnms = spm_select(inf,'image','Select CT[s] to normalize');
end;
for i=1:size(fnms,1)
 h2cSub( deblank(fnms(i,:)) );
end
%end clinical_h2c - local functions follow

function fnm = h2cSub (fnm)
%converts a CT scan from Hounsfield Units to Cormack
% fnm: image name [optional]
%Example
% h2c('C:\ct\script\ct.nii');
if ~exist('fnm','var')
 fnm = spm_select(1,'image','Select CT to convert');
end;
hdr  = spm_vol(deblank(fnm));
img = spm_read_vols(hdr);
mx = max(img(:));
mn = min(img(:));
range = mx-mn;
if (range < 1999) || (mn > -500)
	fprintf('Warning: image intensity range (%f) does not appear to be in Hounsfield units.\n',range);
    return;
end %CR 5/5/2014: only scale if values are sensible!
if (mn < -1024) %some GE scanners place artificial rim around air
    img(img < -1024) = -1024;
    mn = min(img(:));
    range = mx-mn;
end;
fprintf('%s intensity range: %d\n',fnm,round(range));
fprintf(' Ignore QFORM0 warning if reported next\n');
%constants for conversion
kUninterestingDarkUnits = 900; % e.g. -1000..-100
kInterestingMidUnits = 200; %e.g. -100..+300
kScaleRatio = 10;% increase dynamic range of interesting voxels by 3
%convert image
img = img - mn; %transloate so min value is 0
extra1 = img - kUninterestingDarkUnits;
extra1(extra1 <= 0) = 0; %clip dark to zero
extra9=extra1;
extra9(extra9 > kInterestingMidUnits) = kInterestingMidUnits; %clip bright
extra9 = extra9 * (kScaleRatio-1); %boost mid range
%transform image
img = img+extra1+extra9; %dark+bright+boostedMidRange
%save output
[pth,nam,ext] = spm_fileparts(hdr.fname);
hdr.fname = fullfile(pth, ['c' nam ext]);
hdr.private.dat.scl_slope = 1;
hdr.private.dat.scl_inter = 0;
spm_write_vol(hdr,img);
fnm = hdr.fname; %return new filename
%end h2cSub()