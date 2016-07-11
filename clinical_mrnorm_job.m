function clinical_mrnorm_job(job)
% normalization of t2 scans

images = job.anat;
les = job.les;
t2 = job.t2;
bb = job.bb;
vox = job.vox;
mask = job.brainmask;
DelIntermediate = job.DelIntermediate;
modality = job.modality;

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
  if length(t2) >= i
    [pth,nam,ext] = fileparts(t2{i});
    at2 = fullfile(pth,[nam ext]);
  else
  	at2 = '';
  end;
  clinical_mrnorm(filename, ales,at2,vox,bb,DelIntermediate,mask,modality, job.AutoSetOrigin);
end;