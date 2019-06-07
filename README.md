# alter_structfile
Modify a dicom RTSTRUCT file to delete or rename ROIs inside the file

%   Edits DICOM structure files, can rename and delete contours
%   written by Rene Monshouwer, Radboudumc, 2019
% 
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
%
%   from Matlab 2018 on you can use **/*.dcm like arguments to go to 
%   deeper folder levels

