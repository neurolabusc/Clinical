function clinical_fix_ge_ct (fnms)
% Fixes GE CT images with intensities of -3024 for regions outside imaging radius
% These artificial rims disrupt normalization and coregistration
%   fnms: image name(s) [optional]
% Example
%   ge_fix_ct('C:\ct.nii');
if ~exist('fnms','var')
 fnms = spm_select(inf,'image','Select CT[s] to normalize');
end;
for i=1:size(fnms,1)
 geFixSub( deblank(fnms(i,:)) );
end
%end clinical_h2c - local functions follow

function geFixSub (fnm)
hdr  = spm_vol(deblank(fnm));
img = spm_read_vols(hdr);
mn = min(img(:));
if (mn >= -1024)
	fprintf('%s skipped: This image does not have unusual image intensities: %s.\n',mfilename, fnm);
    return;
end
fprintf('%s version 8/8/2014: clipping artificially dark values in %s\n',mfilename, fnm);
[pth,nam,ext] = spm_fileparts(hdr.fname);
movefile(hdr.fname, fullfile(pth, [ nam '_pre_fix_ge_ct' ext]) );
img(img < -1024) = -1024;         
%hdr.fname = fullfile(pth, ['f' nam ext]);
spm_write_vol(hdr,img);
%end geFixSub()