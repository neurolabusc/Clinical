function oname = clinical_smoothmask (P)
% Creates binary lesion mask for an image with prefix 'x'
%new filename returned
% Example
%   clinical_smoothmask ('C:\ct\script\xwsctemplate_final.nii');
if nargin <1 %no files
 P = spm_select(inf,'image','Select CT[s] to normalize');
end;

for i=1:size(P,1)
  ref = deblank(P(i,:));
  ref = deblank(P(i,:));
  [pth,nam,ext] = spm_fileparts(ref);
  src = fullfile(pth,[ nam ext]);
  smth =fullfile(pth,['s' nam ext]);
  spm_smooth(src,smth,8,16); 
  %last  uint8=2; int16=4; int32=8; float32=16; float64=64
  Vi  = spm_vol(smth);
  VO       = Vi;
  [pth,nam,ext] = spm_fileparts(ref);
  VO.fname = fullfile(pth,['x' nam ext]);
  VO       = spm_create_vol(VO);
  clipped = 0;
  thresh = 0.001;
  for i=1:Vi.dim(3),
    img      = spm_slice_vol(Vi,spm_matrix([0 0 i]),Vi.dim(1:2),0);

    for px=1:length(img(:)),
      if img(px) > thresh
        img(px) = 0;
        clipped = clipped + 1;
      else
        img(px) = 1;
      end;
    end;
    VO       = spm_write_plane(VO,img,i);
 end;
 %thresholding done - delete the raw smoothed data
 clinical_delete(smth);
 %next downsample to 8 bit [optional]
 clinical_8bit (VO.fname);
 clinical_delete(VO.fname);
 clinical_rename(fullfile(pth,['dx' nam ext]),VO.fname);
 %
 fprintf('clinical_smoothmask: %s had %d voxels >%f\n',VO.fname, clipped,thresh); 
 oname = VO.fname;
end