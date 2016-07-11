function clinical_mrnorm(anatomical, lesion, pathological, vox, bb, DeleteIntermediateImages, UseTemplateMask, Modality, AutoSetOrigin)
% Use normalise functions to warp clinical scans to stereotaxic space
%  anatomical    = filename[s] of scan[s] to normalize
%  lesion        = filename[s] of lesion maps. Drawn on V, unless pathscan
%  pathological  = filename[s] of images use
%  vox           = voxel size of normalized image[s]
%  bb            = bounding box of normalized image[s]
%  DeleteIntermediateImages =   if 1, then temporary images used between steps are deleted
%  Modality      =   1,2,3,4: Use 1 for T1 scans, 2 for T2 scans, 3 for FLAIR, any other value for combined T1/T2 [e.g. often works well with DWI]
%
% Prior to running this script, use SPM's DISPLAY
%   Use this to set 0 0 0 mm to point to the Anterior Commissure
% Example
%   clinical_mrnorm('C:\dir\img.nii');

fprintf('MR normalization version 7/7/2016 - for use with low-resolution or low-contrast images that do not allow accurate normalization-segmentation\n');

%use mni T2 template
t2template = fullfile(spm('Dir'),'templates','T2.nii');
if ~exist(t2template, 'file')
    t2template = fullfile(spm('Dir'),'toolbox','OldNorm','T2.nii');
end
%report if templates are not found
if (clinical_filedir_exists(t2template) == 0) %report if files do not exist
  disp(sprintf('Please put the T2 template in the SPM template folder'));
  return
end;
%use mni T1 template
t1template = fullfile(spm('Dir'),'templates','T1.nii');
if ~exist(t1template, 'file')
    t1template = fullfile(spm('Dir'),'toolbox','OldNorm','T1.nii');
end
%report if templates are not found
if (clinical_filedir_exists(t1template) == 0) %report if files do not exist
  disp(sprintf('Please put the T1 template in the SPM template folder'));
  return
end;

if nargin <1 %no files specified
 anatomical = spm_select(inf,'image','Select images to normalize');
end;

if nargin < 1 %no files
 lesion = spm_select(inf,'image','Optional: select lesion maps (same order as images)');
else
 if nargin <2 %T1 specified, no lesion map specified
   lesion = '';
 end;
end;

if nargin <1 %no files specified
 pathological = spm_select(inf,'image','Select images used to map lesions (optional)');
end;

if nargin < 4 %no voxel size
	vox = [2 2 2];
end;

if nargin < 5 %no bounding box
	bb = [-78 -112 -50; 78 76 85]; %[  -90 -126  -72;  90   90  108];
end;

if nargin < 6 %delete images
  DeleteIntermediateImages = 1;
end;

if nargin < 7 %delete images
  UseTemplateMask= 0;
end;

if nargin < 8 %Modality
  Modality = 0;
end;
if exist('AutoSetOrigin', 'var') && (AutoSetOrigin)
	for i=1:size(anatomical,1)
 		v = deblank(anatomical(i,:));
 		if ~isempty(lesion)
 			v = strvcat(v, deblank(lesion(i,:))  );
 		end
 		if ~isempty(pathological)
 			v = strvcat(v, deblank(pathological(i,:))  );
 		end
 		if Modality == 2
			clinical_setorigin(v,2); %coregister to T2
		else
			clinical_setorigin(v,1); %coregister to T1
		end
	end;
end;
if UseTemplateMask== 1
	TemplateMask = fullfile(spm('Dir'),'apriori','brainmask.nii');
    if (clinical_filedir_exists(TemplateMask ) == 0)
		TemplateMask = fullfile(spm('Dir'),'toolbox','FieldMap','brainmask.nii');
	end;
	if (clinical_filedir_exists(TemplateMask ) == 0) %report if files do not exist
  		fprintf('clinical_mrnorm error: Mask not found %s\n',mfilename, TemplateMask );
  		return
	end;
end;

if (size(lesion) > 1)
 if (size(lesion) ~= size(V))
   fprintf('You must specify the same number of lesions as T2 scans\n');
   return;
 end;
end;

smoothlesion = true;


for i=1:size(anatomical,1)
 r = deblank(anatomical(i,:));
 [pth,nam,ext, vol] = spm_fileparts(r);
 ref = fullfile(pth,[nam ext]);
 if (exist(ref ) ~= 2)
 	fprintf('Error: unable to find source image %s.\n',ref);
	return;
 end;
   %next - prepare lesion mask
   if (length(lesion) > 0) && (length(pathological) > 0)
       lesionname = deblank(lesion(i,:));
       pathologicalname = deblank(pathological(i,:));
       [slesionname, maskname] = clinical_lesion_coreg(ref,lesionname,pathologicalname,true);
       matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = {[maskname ,',1']};
       matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {[slesionname ,',1'];[ref,',1']};
   elseif length(lesion) > 0
	   lesionname = deblank(lesion(i,:));
       if (clinical_filedir_exists(lesionname ) == 0)  %report if files do not exist
        disp(sprintf(' No lesion image found named:  %s', lesionname ))
        return
       end;
       maskname = clinical_smoothmask(lesionname);
       if smoothlesion == true
       	slesionname = clinical_smooth(lesionname, 3); %lesions often drawn in plane, with edges between planes - apply 3mm smoothing
       else
       	slesionname = lesionname;
       end; %if smooth lesion
       matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = {[maskname ,',1']};
       matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {[slesionname ,',1'];[ref,',1']};
   else % if no lesion
   	matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
   	matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {[ref,',1']};
   end;
   %next normalize
   matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source = {[ref,',1']};
   if Modality== 1
   	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = {[t1template ,',1']};
   elseif Modality== 2
   	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = {[t2template ,',1']};
   elseif Modality== 3
	%FLAIRtemplate  = fullfile(fileparts(which(mfilename)),'gg-flair-181-asym-8mmFWHM.nii');
	FLAIRtemplate  = fullfile(fileparts(which(mfilename)),'GG-366-FLAIR-2.0mm-8mmFWHM.nii');
   	fprintf('using FLAIR template from  Anderson Winkler and David Glahn''s team (http://glahngroup.org/Members/anderson/flair-templates/flair-templates) %s\n', FLAIRtemplate );
	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = {[FLAIRtemplate ,',1']};
   else
   	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = {[t1template ,',1'];[t2template ,',1']};
   end;
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
   matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.interp = 1;
   matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
   matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';
   spm_jobman('run',matlabbatch);
   if (DeleteIntermediateImages == 1)
     if length(lesion) > 0
     	clinical_delete(maskname);
     	if smoothlesion == true
       		clinical_delete(slesionname);
       	end; %if smoothed lesions
     end; %if lesions
   end;% if delete
   %make lesion binary, create voi
   if length(lesion) > 0 %we have a lesion
        [pthL,namL,extL] = spm_fileparts(slesionname);
        clinical_binarize(fullfile(pthL,['w' namL extL])); %lesion maps are considered binary (a voxel is either injured or not)
		if (DeleteIntermediateImages == 1) clinical_delete(fullfile(pthL,['w' namL extL])); end; %we can delete the continuous lesion map
	     clinical_nii2voi(fullfile(pthL,['bw' namL extL]));
   end;

end; %for each volume