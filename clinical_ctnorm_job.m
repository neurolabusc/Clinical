function clinical_ctnorm_job(job)
% normalization of ct scans

images = job.images;
les = job.ctles;
bb = job.bb;
vox = job.vox;
mask = job.brainmaskct;
DelIntermediate = job.DelIntermediate;

Vi     = spm_vol(strvcat(images));
n      = numel(Vi);                %-#images
if n==0, error('no input images specified'), end

for i=1:length(images)
  [pth,nam,ext] = fileparts(images{i});
  filename = fullfile(pth,[nam ext]);
  if length(les) >= i
  	[pth,nam,ext] = fileparts(les{i});
  	ales = fullfile(pth,[nam ext]);
  else
  	ales = '';
  end;
  clinical_ctnorm(filename, ales, vox, bb,DelIntermediate, mask, false, job.AutoSetOrigin);
end;