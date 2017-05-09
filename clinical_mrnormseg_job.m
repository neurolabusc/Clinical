function clinical_mrnormseg_job(job)
% normalization of mri scans using normalized normalization-segmentation

anat = job.anat;
les = job.les;
t2 = job.t2;
bb = job.bb;
ssthresh = job.ssthresh;
DelIntermediate = job.DelIntermediate;
vox = job.vox;
old = job.clinicaltemplate;
cleanup = job.clean;
Enantiomorphic = job.Enantiomorphic;
Vi     = spm_vol(strvcat(anat));
n      = numel(Vi);                %-#images
if n==0, error('no input images specified'), end

for i=1:length(anat)
  [pth,nam,ext] = fileparts(anat{i});
  aanat = fullfile(pth,[nam ext]);
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
  if Enantiomorphic == 2
    if ~strcmpi(spm('ver'),'SPM12'), error('6 tissue Enantiomorphic normalization requires SPM12'); end;
    clinical_mrnormseg12(aanat,ales,at2, old, vox, bb, DelIntermediate, ssthresh, job.AutoSetOrigin)

  else
    clinical_mrnormseg(aanat,ales,at2,old, vox,bb, DelIntermediate,ssthresh, cleanup, Enantiomorphic, job.AutoSetOrigin);
  end;
end;