# Clinical Toolbox for SPM

##### About

This toolbox is designed to help SPM12 normalize scans from indviduals with brain injury. For details visit the [NITRC wiki](https://www.nitrc.org/plugins/mwiki/index.php/clinicaltbx:MainPage)

##### Installation

There are two ways to install this toolbox.

- Click the green "Download or Clone" button, download as a zip file. Unzip the contents. Place the "Clinical" folder inside SPM12's "toolbox" folder. Restart SPM and press the "Batch" button. Use the Batch window's SPM/Tools/Clinical menu item to select the normalization you wish to compute. For more details see the included Word document or the Wiki listed above.
- Run the following script in Matlab to install the software (assumes you have 'git' installed)
```
if isempty(which('spm')) || ~strcmp(spm('Ver'),'SPM12'), error('SPM12 required'); end;
pth = fullfile(spm('Dir'),'toolbox');
if ~exist(pth,'file'), error('SPM12 toolboxes not installed'); end;
cd(pth);
tbx = 'Clinical';
cmd = ['git clone git@github.com:neurolabusc', filesep, tbx, '.git'];
system(cmd);
pth = fullfile(pth, tbx);
if ~exist(pth,'file'), error('Unable to install toolbox'); end;
fprintf('Installed toolbox %s: to use launch SPM, choose "Batch" and select the SPM/Tools menu\n', tbx);
```

##### Recent Versions

9-May-2017
 - Automatic check for updates.
 - Compatibility fixes for SPM12
 - Segment-Normalize includes the ability to use 6-tissue segmentation maps (instead of 3 tissue segmentation maps). Requires SPM12. This is the new default, older 3-tissue is still available for compatibility.

7-July-2016
 - Enhanced support for SPM12 (SPM8 not tested still might work).
 - The command "MR segment-normalize" now includes the option for my implementation of enantiomorphic normalization (see Nachev et al., 2008). Users may also want to explore my script [nii_enat_norm](https://github.com/neurolabusc/nii_preprocess/blob/master/nii_enat_norm.m).


##### License

This software includes a [BSD license](https://opensource.org/licenses/BSD-2-Clause)

##### References

Nachev P, Coulthard E, Jäger HR, Kennard C, Husain M. ([2008](https://www.ncbi.nlm.nih.gov/pubmed/18023365)) Enantiomorphic normalization of focally lesioned brains. Neuroimage. 39(3):1215-26.

Rorden C, Bonilha L, Fridriksson J, Bender B, Karnath HO ([2012](https://www.ncbi.nlm.nih.gov/pubmed/22440645)) Age-specific CT and MRI templates for spatial normalization. NeuroImage. 61(4):957-65.


