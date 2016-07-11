function biname = clinical_binarize (P);
% input is grayscale image (continuous), output image created that is black or white (binary)
% The image Max and Min are used to calculate the intensity midpoint (Min+(Max-Min)/2);
%  Any voxel below this value is set to zero, else set to one
% Example 
%   clinical_binarize('C:\dir\img.nii');


if nargin <1 %no files
 P = spm_select(inf,'image','Select CT[s] to normalize');
end;


for i=1:size(P,1)
  %load image
  ref = deblank(P(i,:));
  [pth,nam,ext] = spm_fileparts(ref);
  Vin = spm_vol(ref);
  XYZ = spm_read_vols(Vin);
  %find min and max
  mx = max(max(max(XYZ(:,:,:,:)))); 
  mn = min(min(min(XYZ(:,:,:,:)))); 
  if (mx == mn) 
 	fprintf('clinical_binarize error: no intensity variability in image %s.\n',Vin.fname);
	return;  
  end;
  mid = mn + ((mx-mn)/2);
  tmp      = find((XYZ)< mid);
  XYZ(tmp) = 0;
  tmp      = find((XYZ)>= mid);
  XYZ(tmp) = 1;
  vox1 = length(tmp);
  biname = fullfile(pth,['b' nam ext]);
  Vin.fname = biname;
  spm_write_vol(Vin,XYZ);
  fprintf('%s has %d voxels with intensities of 1 \n',biname, vox1); 	
end
