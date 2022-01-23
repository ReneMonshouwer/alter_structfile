# alter_structfile

To modify a dicom RTSTRUCT file to delete or rename ROIs inside the dicomfile

Use at your own risk and not for clinical appliations (only research)

The code is in Matlab so (preferably) matlab R2018b is needed to use the program.
Earlier Matlab versions are also working, only the "**/*" (nested wildcard) does not work before 2018b

see example.bat for examples for calling the executable

The executable : alter_structfile.exe can be used after installation of the matlab runtime environment on your computer
This is possible without a Matlab licence

See link below for instructions to install the runtime environment
https://nl.mathworks.com/help/compiler/install-the-matlab-runtime.html





#### written by Rene Monshouwer, Radboudumc, 2019

functionality ( see also alter_structfile.m file )
````
%   options : 
%   -r rename option : call with 
%        alter_structfile -r a.dcm oldname1 newname1 oldname2 newname2 ..
%   -d delete option : call with
%        alter_structfile -d a.dcm name1 name2 name3 name4 ..
%   -l leave option : leaves only the roi's given, delete all others
%      call with
%        alter_structfile -l a.dcm name1 name2 name3 name4 ..
%   -p print option : print all rois
%       alter_structfile -p a.dcm
%   -t tag editing option : create or change a tag
%       alter_structfile -t a.dcm tag_name tag_value
%       tag_name is in Matlab format, alter_structfile -t a.dcm plots all 
%       tags (to easily investigate the syntax / find the tag names)
%       for tag_value : 'EMPTY', an empty string ('') is inserted
%   -c coloring option to change color of the roi
%       alter_structfile -c a.dcm roiname1 c1 c2 c3 roiname2 c1' c2' c3
%       where c1,c2,c3 are the three elements of the color vector (0..255)
%       (when using the routine in subroutine style: enter c#'s as string,
%       compiled version can be used without quotes).
%       ROI name comparison is case insensitive
````
