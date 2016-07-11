This folder contains files that let you test the normalization of images from stroke patients.
  It assumes that the toolbox\aging folder is in your SPM toolbox folder, e.g. c:\spm8\toolbox\aging
  
Normalization of a CT scan
Here we have a CT scan named 'CTnolesion' that we wish to normalize
1.) Launch Matlab
2.) Launch SPM8 from Matlab ('spm fmri' from Matlab prompt)
3.) Press 'Batch' from SPM8
4.) From Batch window, select SPM/Tools/Aging/CTnormalization (if this option is not visible, the toolbox is not installed)
5.) Choose 'Input Images' node and press 'Select Files' - choose 'CTnolesion'
6.) From Batch window, choose File/RunBatch


Normalization of a T1 scan with lesion (mapped on T1)
Here we have a T1-weighted MRI scan named 'T1' that we wish to normalize. A map of the lesion was created by drawing on the T1 image (lesionT1).
1.) Launch Matlab
2.) Launch SPM8 from Matlab ('spm fmri' from Matlab prompt)
3.) Press 'Batch' from SPM8
4.) From Batch window, select SPM/Tools/Aging/MRInormalization (if this option is not visible, the toolbox is not installed)
5.) Choose 'Anatomicals' node and press 'Select Files' - choose 'T1'
6.) Choose 'Lesion Maps' node and press 'Select Files' - choose 'lesionT1'
7.) Optional: Choose 'Voxel sizes' node and press 'Edit value' - set this to "1 1 1"
8.) From Batch window, choose File/RunBatch

Normalization of a T1 scan with lesion (mapped on T2)
While T1 images tend to have the best resolution and grey-white matter contrast, they often do not show the extent of the injury well. Therefore, we draw the lesion maps on scans that show the lesion better (T2, FLAIR, DWI, etc). Therefore, we need to coregsiter this pathological scan to the T1 prior to normalizing the T1. Here we have a T1-weighted MRI scan named 'T1' that we wish to normalize. A map of the lesion ('lesionT2') was created by drawing on the T2 image ('T2').
1.) Launch Matlab
2.) Launch SPM8 from Matlab ('spm fmri' from Matlab prompt)
3.) Press 'Batch' from SPM8
4.) From Batch window, select SPM/Tools/Aging/MRInormalization (if this option is not visible, the toolbox is not installed)
5.) Choose 'Anatomicals' node and press 'Select Files' - choose 'T1'
6.) Choose 'Lesion Maps' node and press 'Select Files' - choose 'lesionT2'
7.) Choose 'Pathological scans' node and press 'Select Files' - choose 'T2'
8.) Optional: Choose 'Voxel sizes' node and press 'Edit value' - set this to "1 1 1"
9.) From Batch window, choose File/RunBatch

