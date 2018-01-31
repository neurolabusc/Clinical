function coivox = clinical_setorigin(vols, modality)
%Sets position and orientation of input image(s) to match SPM's templates
% vols: filenames for all images from a session.
%       -if multiple images, the first image is used to determine transforms
%       -if any images are 4D, only supply the file name
%Examples
% clinical_setorigin('T1.nii',1);
% clinical_setorigin(strvcat('T1.nii','fMRI.nii'),1); %estimate from T1, apply to both T1 and all fMRI volumes

%spm_jobman('initcfg');
if ~exist('vols','var') %no files specified
	vols = spm_select(inf,'image','Select images (first image is high resolution)');
end;
if ~exist('modality','var') %modality not specified
    prompt = {'Enter modality (1=T1,2=T2,CT=3,fMRI(T2*)=4'};
    dlg_title = 'Specify contrast of 1st image';
    num_lines = 1;
    def = {'1'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    modality = str2double(answer{1});
end
coivox = ones(4,1); %center of intensity
if ~exist('vols','var') %no files specified
 vols = spm_select(inf,'image','Reset origin for selected image(s) (estimated from 1st)');
end
vols = vol1OnlySub(vols); %only process first volume of 4D datasets...
[pth,nam,ext, ~] = spm_fileparts(deblank(vols(1,:))); %extract filename
fname = fullfile(pth,[nam ext]); %strip volume label
%report if filename does not exist...
if (exist(fname, 'file') ~= 2)
 	fprintf('%s error: unable to find image %s.\n',mfilename,fname);
	return;
end;
hdr = spm_vol([fname,',1']); %load header
img = spm_read_vols(hdr); %load image data
img = img - min(img(:));
img(isnan(img)) = 0;
%find center of mass in each dimension (total mass divided by weighted location of mass
% img = [1 2 1; 3 4 3];
sumTotal = sum(img(:));
coivox(1) = sum(sum(sum(img,3),2)'.*(1:size(img,1)))/sumTotal; %dimension 1
coivox(2) = sum(sum(sum(img,3),1).*(1:size(img,2)))/sumTotal; %dimension 2
coivox(3) = sum(squeeze(sum(sum(img,2),1))'.*(1:size(img,3)))/sumTotal; %dimension 3
XYZ_mm = hdr.mat * coivox; %convert from voxels to millimeters
fprintf('%s center of brightness differs from current origin by %.0fx%.0fx%.0fmm in X Y Z dimensions\n',fname,XYZ_mm(1),XYZ_mm(2),XYZ_mm(3));
for v = 1:   size(vols,1)
    fname = deblank(vols(v,:));
    if ~isempty(fname)
        [pth,nam,ext, ~] = spm_fileparts(fname);
        fname = fullfile(pth,[nam ext]);
        hdr = spm_vol([fname ',1']); %load header of first volume
        fname = fullfile(pth,[nam '.mat']);
        if exist(fname,'file')
            destname = fullfile(pth,[nam '_old.mat']);
            copyfile(fname,destname);
            fprintf('%s is renaming %s to %s\n',mfilename,fname,destname);
        end
        hdr.mat(1,4) =  hdr.mat(1,4) - XYZ_mm(1);
        hdr.mat(2,4) =  hdr.mat(2,4) - XYZ_mm(2);
        hdr.mat(3,4) =  hdr.mat(3,4) - XYZ_mm(3);
        spm_create_vol(hdr);
        if exist(fname,'file')
            delete(fname);
        end
    end
end%for each volume
coregSub(vols, modality);
for v = 1:   size(vols,1)
    [pth, nam, ~, ~] = spm_fileparts(deblank(vols(v,:)));
    fname = fullfile(pth,[nam '.mat']);
    if exist(fname,'file')
        delete(fname);
    end
end%for each volume
%end nii_setOrigin()

function coregSub(vols, modality)
%subroutine coregisters vols to template of specified modality
if modality == 2
    template = fullfile(spm('Dir'),'templates','T2.nii');
    if ~exist(template, 'file')
        template = fullfile(spm('Dir'),'toolbox','OldNorm','T2.nii');
    end
elseif modality == 3
    template  = fullfile(spm('Dir'),'toolbox','Clinical','scct.nii');
elseif modality == 4
    template = fullfile(spm('Dir'),'templates','EPI.nii');
    if ~exist(template, 'file')
        template = fullfile(spm('Dir'),'toolbox','OldNorm','EPI.nii');
    end
else
    template = fullfile(spm('Dir'),'templates','T1.nii');
    if ~exist(template, 'file')
        template = fullfile(spm('Dir'),'toolbox','OldNorm','T1.nii');
    end
end
if ~exist(template,'file')
    error('%s Unable to find template named %s\n', mfilename, template);
end
matlabbatch{1}.spm.spatial.coreg.estimate.ref = {template};
matlabbatch{1}.spm.spatial.coreg.estimate.source = {[deblank(vols(1,:)),',1']};%{'/Users/rorden/Desktop/3D.nii,1'};
matlabbatch{1}.spm.spatial.coreg.estimate.other = cellstr(vols(2:end,:));% {''};
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
spm_jobman('run',matlabbatch);
%end coregSub()

function vols = vol1OnlySub(vols)
%only select first volume of multivolume images '/dir/img.nii' -> '/dir/img.nii,1', '/dir/img.nii,33' -> '/dir/img.nii,1'
oldvols = vols;
vols = [];
for v = 1:   size(oldvols,1)
    [pth,nam,ext, ~] = spm_fileparts(deblank(oldvols(v,:)));
    vols = strvcat(vols, fullfile(pth, [ nam ext ',1']) ); %#ok<REMFF1>
end
%end vol1OnlySub()