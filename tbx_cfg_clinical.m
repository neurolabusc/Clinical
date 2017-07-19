function clinical = tbx_cfg_clinical
% Configuration file for toolbox 'Clinical'

% Chris Rorden
% $Id: tbx_cfg_clinical.m

if ~isdeployed,
	addpath(fullfile(spm('Dir'),'toolbox','Clinical'));
end

% ---------------------------------------------------------------------
% bb Bounding box
% ---------------------------------------------------------------------
bb         = cfg_entry;
bb.tag     = 'bb';
bb.name    = 'Bounding box';
bb.help    = {'The bounding box (in mm) of the volume which is to be written (relative to the anterior commissure). Popular choices are [-78 -112  -50; 78   76   85] and [  -90 -126  -72;  90   90  108]'};
bb.strtype = 'e';
bb.val     = {[-78 -112 -50; 78 76 85]};
%to match ch2 images   bb.val     = { [  -90 -126  -72;  90   90  108]};
bb.num     = [2 3];
%bb.def     = @(val)spm_get_defaults('normalise.write.bb', val{:});

% ---------------------------------------------------------------------
% vox Voxel sizes
% ---------------------------------------------------------------------
vox         = cfg_entry;
vox.tag     = 'vox';
vox.name    = 'Voxel sizes';
vox.help    = {'The voxel sizes (x, y & z, in mm) of the written normalised images. [1 1 1] and [2 2 2] are standard and more than sufficient for statistical analysis, but [0.735 0.735 0.735] provides nice volume rendering visualization.'};
vox.strtype = 'e';
vox.num     = [1 3];
vox.val	  = {[1 1 1]};
%to match ch2 images vox.val	  = {[1 1 1]};
% [0.735 0.735 0.735] with the default bounding box yields a 213x256x184 voxel image that works well for rendering (some inexpensive GPUs limited to volumes with 256 voxels)
%vox.def     = @(val)spm_get_defaults('normalise.write.vox', val{:});

% ---------------------------------------------------------------------
% Anat Volumes
% ---------------------------------------------------------------------
anat         = cfg_files;
anat.tag     = 'anat';
anat.name    = 'Anatomicals';
anat.help    = {'Select anatomical scans (typically T1-weighted). These will be used to compute normalization parameters.'};
anat.filter = 'image';
anat.ufilter = '.*';
anat.num     = [1 Inf];

% ---------------------------------------------------------------------
% Lesion map Volumes
% ---------------------------------------------------------------------
les         = cfg_files;
les.tag     = 'les';
les.name    = 'Lesion maps';
les.help    = {'Select lesions. Same order as anatomicals. If specified, lesions will be used to mask normalization, and will be resliced to standard space. Optional: e.g. not required for neurologically healthy controls'};
les.filter = 'image';
les.ufilter = '.*';
les.num     = [1 Inf];
les.val    = {''};

% ---------------------------------------------------------------------
% T2 Volumes
% ---------------------------------------------------------------------
t2         = cfg_files;
t2.tag     = 't2';
t2.name    = 'Pathological scans';
t2.help    = {'Select pathological scans used to draw lesions (e.g. T2, FLAIR). Same order as anatomicals. Optional: only used if lesion maps are used, and only used if lesion maps are not drawn on anatomical images. Often the full extent of brain injury is better visualized on a T2 scan, but the T1 provides better resolution and tissue contrast. In this case, you can draw the lesion on the T2, coregister the T2 to T1, reslice lesion to T1 space and then normalize the T1.'};
t2.filter = 'image';
t2.ufilter = '.*';
t2.num     = [0 Inf];
t2.val    = {''};

% ---------------------------------------------------------------------
% Template
% ---------------------------------------------------------------------
clinicalTemplate         = cfg_menu;
clinicalTemplate.tag     = 'clinicaltemplate';
clinicalTemplate.name    = 'Template';
clinicalTemplate.help    = {
                   'Choose the template for your analyses. You can use the elderly template (which is based on older adults, and thus has large ventricles), or the young adult template (using the MNI152 template of young adults).'
                   }';
clinicalTemplate.labels = {
                  'T1 younger'
                  'T1 older'
                  }';
clinicalTemplate.values = {
                  0
                  1
                  }';
clinicalTemplate.val    = {1};


% ---------------------------------------------------------------------
% Cleanup
% ---------------------------------------------------------------------
clean         = cfg_menu;
clean.tag     = 'clean';
clean.name    = 'Cleanup level';
clean.help    = {
                   'Choose tissue cleanup level: this attempts to remove islands of gray or white matter that are distant from gray matter.'
                   }';
clean.labels = {
                  'none'
                  'light'
                  'thorough'
                  }';
clean.values = {
                0
                1
                2
                  }';
clean.val    = {2};

% ---------------------------------------------------------------------
%Enantiomorphic
% ---------------------------------------------------------------------
AutoSetOrigin         = cfg_menu;
AutoSetOrigin.tag     = 'AutoSetOrigin';
AutoSetOrigin.name    = 'Automatically Set Origin';
AutoSetOrigin.help    = {'Normalization can fail if the origin is not near the anterior commissure. This option attempts to automatically adjust the origin. Try normalizing with this set to TRUE: if normalization fails next set the origin manually and re-run normalization with this feature switched to FALSE.'};
AutoSetOrigin.labels = {
                  'False'
                  'True'
                  }';
AutoSetOrigin.values = {
                  0
                  1
                  }';
AutoSetOrigin.val    = {1};

% ---------------------------------------------------------------------
%Enantiomorphic
% ---------------------------------------------------------------------
Enantiomorphic         = cfg_menu;
Enantiomorphic.tag     = 'Enantiomorphic';
Enantiomorphic.name    = 'Enantiomorphic normalization';
Enantiomorphic.help    = {'Enantiomorphic normalization can outperform lesion masking, especially for large lesions. Newer 6-tissue is probably better but disables ignores some options (tissue cleanup) and requires SPM12. See Nachev et al., 2008: http://www.ncbi.nlm.nih.gov/pubmed/18023365'};
Enantiomorphic.labels = {
                  'False'
                  'True(3-tissue old segment)'
                  'True(6-tissue new segment)'
                  }';
Enantiomorphic.values = {
                  0
                  1
                  2
                  }';
Enantiomorphic.val    = {2};

% ---------------------------------------------------------------------
% Delete Intermediate
% ---------------------------------------------------------------------
DelIntermediate         = cfg_menu;
DelIntermediate.tag     = 'DelIntermediate';
DelIntermediate.name    = 'Intermediate images';
DelIntermediate.help    = {'Many images are created during normalization that are often not required for final analyses. Do you wish to keep these intermediate images?'};
DelIntermediate.labels = {
                  'Keep'
                  'Delete'
                  }';
DelIntermediate.values = {
                  0
                  1
                  }';
DelIntermediate.val    = {0};

% ---------------------------------------------------------------------
% T2 Input Images
% ---------------------------------------------------------------------
T2         = cfg_files;
T2.tag     = 'T2';
T2.name    = 'Images';
T2.help    = {'Select the scans you would like to normalize (each scan from a different participant).'};
T2.filter  = 'image';
T2.ufilter = '.*';
T2.num     = [1 Inf];


% ---------------------------------------------------------------------
% modality
% ---------------------------------------------------------------------
modality = cfg_menu;
modality.tag     = 'modality';
modality.name    = 'Modality';
modality.help    = {'The template will be selected to match the tissue intensities of your images. Choose T1 if your scan is T1-weighted, T2 for T2-weighted, FLAIR for fluid-attenuated T2, else select Other [e.g. DWI]. This function always uses the default SPM templates that are based on young adults, except the FLAIR option that uses a symmetrical template from 181 people, Mean age: 39.9y, std dev: 9.3y, range: 26-76y, 102 females (see  http://www.glahngroup.org/Members/anderson/flair-templates)'
                   }';
modality.labels = {
                  'T1'
                  'T2'
		  'FLAIR'
                  'Other'
                  }';
modality.values = {
                  1
                  2
                  3
		  4
                  }';
modality.val    = {4};

% ---------------------------------------------------------------------
% images Input Images
% ---------------------------------------------------------------------
images         = cfg_files;
images.tag     = 'images';
images.name    = 'Input Images';
images.help    = {'Select the CT scans you would like to normalize.'};
images.filter  = 'image';
images.ufilter = '.*';
images.num     = [1 Inf];


% ---------------------------------------------------------------------
% Lesions Input Images
% ---------------------------------------------------------------------
ctles         = cfg_files;
ctles.tag     = 'ctles';
ctles.name    = 'Input lesions';
ctles.help    = {'Optional lesion maps. Must have same dimensions as CT scans. If multiple scans, order must be identical.'};
ctles.filter  = 'image';
ctles.ufilter = '.*';
ctles.num     = [1 Inf];
ctles.val    = {''};

% ---------------------------------------------------------------------
% brainmask - default switched on for CT scans, as skull has strong signal
% ---------------------------------------------------------------------
brainmaskct         = cfg_menu;
brainmaskct.tag     = 'brainmaskct';
brainmaskct.name    = 'Template mask';
brainmaskct.help    = {'Apply a brain mask to the template? Initial coarse normalization is applied to the entire scan. However, it is often useful to apply a brain mask to the template for the subsequent fine normalization. This helps reduce the influence of skull and scalp features, improving the accuracy of the final normalization.'
                   }';
brainmaskct.labels = {
                  'no template mask'
                  'apply template mask'
                  }';
brainmaskct.values = {
                  0
                  1
                  }';
brainmaskct.val    = {1};


% ---------------------------------------------------------------------
% brainmask - default switched off for MRI, as low res scans often have poor coarse alignment
% ---------------------------------------------------------------------
brainmask         = cfg_menu;
brainmask.tag     = 'brainmask';
brainmask.name    = 'Template mask';
brainmask.help    = {'Apply a brain mask to the template? Initial coarse normalization is applied to the entire scan. However, it is often useful to apply a brain mask to the template for the subsequent fine normalization. This helps reduce the influence of skull and scalp features, improving the accuracy of the final normalization.'
                   }';
brainmask.labels = {
                  'no template mask'
                  'apply template mask'
                  }';
brainmask.values = {
                  0
                  1
                  }';
brainmask.val    = {0};

% ---------------------------------------------------------------------
% Threshold for scalp strip
% ---------------------------------------------------------------------
ssthresh         = cfg_entry;
ssthresh.tag     = 'ssthresh';
ssthresh.name    = 'Scalp strip threshold';
ssthresh.help    = {
                'Enter threshold for scalp stripping. E.G. if set to 0.5 than only voxels deemed to have a combined gray+white matter probability of at least 50% will be included in the stripped image.'
}';
ssthresh.strtype = 'e';
ssthresh.num     = [1  1];
ssthresh.val = {0.005};

% ---------------------------------------------------------------------
% MRsegnorm
% ---------------------------------------------------------------------
MRnormseg 	= cfg_exbranch;
MRnormseg.tag     = 'MRnormseg';
MRnormseg.name    = 'MR segment-normalize';
MRnormseg.val     = {anat les t2 clinicalTemplate clean bb vox ssthresh DelIntermediate, Enantiomorphic AutoSetOrigin};
MRnormseg.help    = {'This procedure is designed for normalizing T1-weighted MRI scans from older people, including those with brain injury. This uses a unified segmentation-normalization algorithm. It can coregister a T2/FLAIR image to a T1 image and then normalize the T1 image. Vers 2/2/2012'};
MRnormseg.prog = @clinical_local_mrnormseg;
%MRnormseg.vout = @vout_sextract;

% ---------------------------------------------------------------------
% CTnorm
% ---------------------------------------------------------------------
CTnorm         = cfg_exbranch;
CTnorm.tag     = 'CTnorm';
CTnorm.name    = 'CT normalize';
CTnorm.val     = {images ctles brainmaskct bb vox DelIntermediate AutoSetOrigin};
CTnorm.help    = {'This procedure is designed for normalizing CT scans from older people, including those with brain injury. Vers 2/2/2012'};
CTnorm.prog = @clinical_local_ctnorm;

% ---------------------------------------------------------------------
% MRnorm
% ---------------------------------------------------------------------
MRnorm         = cfg_exbranch;
MRnorm.tag     = 'MRnorm';
MRnorm.name    = 'MR normalize';
MRnorm.val     = {anat les t2 modality brainmask bb vox DelIntermediate AutoSetOrigin};
MRnorm.help    = {'This procedure is designed for normalizing MRI scans - it is useful when you only have low-resolution or low-quality scans. If you have a high-quality scans, use MR segment-normalize instead. Vers 2/2/2012'};
MRnorm.prog = @clinical_local_mrnorm;


% ---------------------------------------------------------------------
% clinical
% ---------------------------------------------------------------------
clinical         = cfg_choice;
clinical.tag     = 'MRI';
clinical.name    = 'Clinical';
clinical.help    = {'Toolbox that aids in normalization of brain images of older individuals.'};
clinical.values  = {MRnormseg CTnorm MRnorm};

%======================================================================
function clinical_local_mrnormseg(job)
%if ~isdeployed, addpath(fullfile(spm('dir'),'toolbox','Clinical')); end
clinical_mrnormseg_job(job);

%======================================================================
function clinical_local_ctnorm(job)
%if ~isdeployed, addpath(fullfile(spm('dir'),'toolbox','Clinical')); end
clinical_ctnorm_job(job);

%======================================================================
function clinical_local_mrnorm(job)
%if ~isdeployed, addpath(fullfile(spm('dir'),'toolbox','Clinical')); end
clinical_mrnorm_job(job);
