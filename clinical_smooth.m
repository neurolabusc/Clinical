function smth = clinical_smooth (P,FWHM);
% Creates binary lesion mask for an image with prefix 's'
%  P : filename(s) [optional]
%  FWHM = full-width half-maximum of smoothing kernel [optional]
% Example
%   clinical_8bit ('C:\ct\script\xwsctemplate_final.nii',3);
if nargin <1 %no files
 P = spm_select(inf,'image','Select CT[s] to normalize');
end;
if nargin < 2 %no FWHM specified
 FWHM = 8;
end;

for i=1:size(P,1)
  ref = deblank(P(i,:));
  [pth,nam,ext] = spm_fileparts(ref);
  src = fullfile(pth,[nam ext]);
  smth = fullfile(pth, ['s' nam ext]);
  spm_smooth(src,smth,FWHM,0);  
end