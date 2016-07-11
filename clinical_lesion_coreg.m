function [lesionname, maskname] = clinical_lesion_coreg (RefImg,LesionImg,SrcImg, smoothlesion);
%Coregister ScrImg to match alignment of Stationary RefImg, and use parameters to reslice LesionImg
%Essentially, shadow register LesionImg that was drawn on SrcImg to match RefImg
% Inputs
%   RefImg: Stationary reference image
%   LesionImg: This image is initially aligned to SrcImg, and will be replaced to match RefImg
%   SrcImg: This image is jiggled to match reference
%   smoothlesion: If TRUE, replaced lesion smoothed with 3mm FWHM to remove jagged edges
% Outputs
%   lesionname: name of replaced lesion
%   maskname: name of dilated lesion mask

% Example: Coregister lesion drawn on flair image to match T1 image
%    clinical_lesion_coreg('C:\t1','C:\flairlesion.nii', 'C:\flair.nii');

if nargin <1 %no TargetImg
 RefImg = spm_select(1,'image','Select stationary reference image');
end;
if nargin < 2 %no SrcImg
 SrcImg = spm_select(1,'image','Select moving image: jiggled to match the target image');
end;
if nargin <3 %no lesion map specified
 LesionImg = spm_select(1,'image','Select lesion image: will be resliced from moving image to stationary image');
end;
if nargin <4 %no lesion map specified
 smoothlesion = true;
end;
fprintf('clinical_lesion_coreg: coregistering %s to match %s and applying transforms to %s\n',SrcImg, RefImg,smoothlesion); 
%spm_jobman('initcfg'); %<- resets batch editor

coregbatch{1}.spm.spatial.coreg.estwrite.ref = {[RefImg ,',1']};
coregbatch{1}.spm.spatial.coreg.estwrite.source = {[SrcImg ,',1']};
coregbatch{1}.spm.spatial.coreg.estwrite.other = {[LesionImg ,',1']};
coregbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
coregbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
coregbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
coregbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
coregbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 1;
coregbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
coregbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
coregbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
spm_jobman('run',coregbatch);

[pth,nam,ext] = spm_fileparts(deblank(LesionImg));
lesionname = fullfile(pth,['r' nam ext]); 
maskname = clinical_smoothmask(lesionname); 
if smoothlesion == true
	lesionname = clinical_smooth(lesionname, 3); %lesions often drawn in plane, with edges between planes - apply 3mm smoothing 
end; %if smooth lesion
