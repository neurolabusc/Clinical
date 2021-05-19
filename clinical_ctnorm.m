function clinical_ctnorm(V, lesion, vox, bb, DeleteIntermediateImages, UseTemplateMask, UseStrippedTemplate, AutoSetOrigin)
% This script attempts to normalize a CT scan
% V                        =   filename[s] of CT scan[s] to normalize
% lesion                     =   filename[s] of lesion maps. Optional: binary images drawn in same dimensions as CT. For multiple CTs, order of V and lesion must be the same
% vox                      =   voxel size of normalized image[s]
% bb                       =   bounding box of normalized image[s]
% DeleteIntermediateImages =   if 1, then temporary images used between steps are deleted
% UseStrippedTemplate = Normalize to scalp-stripped template (only if your data is already scalp stripped)
% Prior to running this script, use SPM's DISPLAY
%   Use this to set "0 0 0"mm to point to the Anterior Commissure
% Version notes
%  07072016 : improved support for SPM12 (finding brainmask.nii)
% Example
%   clinical_ctnorm ('C:\dir\img.nii');
% clinical_ctnorm('ct.nii', '', [1 1 1], [-78 -112 -50; 78 76 85], true, true);

fprintf('CT normalization version 7/7/2016\n');
if exist('UseStrippedTemplate','var') && (UseStrippedTemplate == true)
    cttemplate = fullfile(fileparts(which(mfilename)),'scct_stripped.nii');

else
    cttemplate = fullfile(fileparts(which(mfilename)),'scct.nii');
end
%use custom 'stroke control' CT templates

%cttemplate = fullfile(spm('Dir'),'templates','Transm.nii');%SPM8 default template
%report if templates are not found
if (clinical_filedir_exists(cttemplate) == 0) %report if files do not exist
  fprintf('Please put the CT template in the SPM template folder\n');
  return
end;

if nargin <1 %no files
 V = spm_select(inf,'image','Select CT[s] to normalize');
end;

if nargin < 1 %no files
 lesion = spm_select(inf,'image','Optional: select lesion maps (same order as CTs)');
else
 if nargin <2 %T1 specified, no lesion map specified
   lesion = '';
 end;
end;
if nargin < 3 %no voxel size
	vox = [2 2 2];
end;
if nargin < 4 %no bounding box
	bb = [-78 -112 -50; 78 76 85];%[  -90 -126  -72;  90   90  108];
end;
if nargin < 5 %delete images
  DeleteIntermediateImages = 1;
end;
if nargin < 6 %UseTemplateMask
  UseTemplateMask= 0;
end;
if UseTemplateMask== 1
	TemplateMask = fullfile(spm('Dir'),'apriori','brainmask.nii');
    if ~exist(TemplateMask, 'file')
        TemplateMask = fullfile(spm('Dir'),'toolbox','FieldMap','brainmask.nii');
    end
    if ~exist(TemplateMask, 'file')
        error('Unable to find %s', TemplateMask);
    end
	if (clinical_filedir_exists(TemplateMask ) == 0) %report if files do not exist
  		fprintf('%s error: Mask not found %s\n',mfilename, TemplateMask );
  		return
	end;
end;

if (size(lesion) > 1)
 if (size(lesion) ~= size(V))
   fprintf('You must specify the same number of lesions as CT scans\n');
   return;
 end;
end;

for i=1:size(V,1) %fix GE images prior to attempting to set origins
    clinical_fix_ge_ct (deblank(V(i,:)));
end

if exist('AutoSetOrigin', 'var') && (AutoSetOrigin)
	for i=1:size(V,1)
 		r = deblank(V(i,:));
 		if ~isempty(lesion)
 			r = strvcat(r, deblank(lesion(i,:))  );
        end
 		clinical_setorigin(r,3); %coregister to CT
	end;
end;

smoothlesion = true;
%spm_jobman('initcfg'); %<- resets batch editor

for i=1:size(V,1)
    r = deblank(V(i,:));
    [pth,nam,ext, ~] = spm_fileparts(r);
    ref = fullfile(pth,[nam ext]);
    if (exist(ref,'file' ) ~= 2)
        fprintf('Error: unable to find source image %s.\n',ref);
        return;
    end;
    cref = h2cSub (ref);
    %next - prepare lesion mask
    if ~isempty(lesion)
	  [pthL,namL,extL] = spm_fileparts(deblank(lesion(1,:)));
       lesionname = fullfile(pthL,[namL extL]);
       if (clinical_filedir_exists(lesionname ) == 0)  %report if files do not exist
        fprintf(' No lesion image found named:  %s\n', lesionname );
        return
       end;
       clinical_smoothmask(lesionname);
       maskname = fullfile(pthL,['x' namL extL]);
       if smoothlesion == true
       	slesionname = clinical_smooth(lesionname, 3); %lesions often drawn in plane, with edges between planes - apply 3mm smoothing
       else
       	slesionname = lesionname;
       end; %if smooth lesion
       matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = {[maskname ,',1']};
       %to turn off lesion masking replacing previous line with next line:
       %matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
       matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {[slesionname ,',1'];[ref,',1']};
       fprintf('masking %s with %s using template %s.\n',ref, slesionname, cttemplate);
   else % if no lesion
   	matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
   	matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {[ref,',1']};
    fprintf('normalizing %s without a mask using template %s.\n',ref, cttemplate);
   end;
   %next normalize
   matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source = {[cref,',1']};
   matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = {[cttemplate ,',1']};
   %matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight = '';
   if UseTemplateMask == 1
	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight = {[TemplateMask ,',1']};
   else
   	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight = '';
   end;
   matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
   matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
   matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
   matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
   matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
   matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
   matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
   matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.bb = bb;
   matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox = vox; %2x2x2mm isotropic
   %matlabbatch{1}.spm.spatial.normalise.write.roptions.bb = [  -90 -126  -72;  90   90  108];
   %matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [2 2 2]; %2x2x2mm isotropic
   %matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox = [1 1 1];
   matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.interp = 1;
   matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
   matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';
   spm_jobman('run',matlabbatch);
   if (DeleteIntermediateImages == 1)
     clinical_delete(cref); %delete cormack image
     if ~isempty(lesion)
     	clinical_delete(maskname);
        if smoothlesion == true
            clinical_delete(slesionname);
        end; %if smoothed lesions
     end; %if lesions
   end;% if delete
   %make lesion binary, create voi
   if ~isempty(lesion) %we have a lesion
	clinical_binarize(fullfile(pthL,['ws' namL extL])); %lesion maps are considered binary (a voxel is either injured or not)
    if (DeleteIntermediateImages == 1)
        clinical_delete(fullfile(pthL,['ws' namL extL]));
    end; %we can delete the continuous lesion map
	clinical_nii2voi(fullfile(pthL,['bws' namL extL]));
   end;
end; %for each volume
%clinical_ctnorm

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
[kUninterestingDarkUnits, kInterestingMidUnits] = clinical_cormack();
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