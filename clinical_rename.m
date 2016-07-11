function clinical_rename (Src,Dest);
% This script renames NIfTI images
%  If passed .nii then renames one file,
%  If passed .hdr or .img it renames BOTH files
% Example
%   clinical_rename('C:\dir\img.nii','C:\dir\ximg.nii');

[pth,nam,ext] = spm_fileparts(deblank(Src(1,:)));
fname = fullfile(pth,[ nam ext]);

[opth,onam,oext] = spm_fileparts(deblank(Dest(1,:)));
oname =fullfile(opth, [ onam oext]);

if (exist(fname) ~= 2) 
 	fprintf('clinical_rename warning unable to find file %s.\n',fname);
	return;  
end;
movefile(fname,oname);

upext = upper(ext);
if strcmp(upext,'.IMG')
 	fname =  fullfile(pth,[ nam '.hdr']);
 	oname =  fullfile(opth,[onam '.hdr']);
 	if (exist(fname) == 2)
		movefile(fname,oname);
 	end; 
end;

if strcmp(upext,'.HDR')
 	fname =  fullfile(pth,[ nam '.img']);
 	oname = fullfile(opth, [onam '.img']);
 	if (exist(fname) == 2)
 	  movefile(fname,oname);
 	end; 
end;

