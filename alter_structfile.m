function alter_structfile(option,filename,varargin)
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

%   to compile
%   mcc -mv -o alter_structfile alter_structfile.m

list=dir(filename);
save_this_data=1;
    
% loop over all files found
for f=1:size(list,1)
    %check  file modality continue to next file if no RTSTRUCT
    f_filename=fullfile(list(f).folder,list(f).name);
    fprintf('\nReading File %s .....\n',f_filename );
    % use dicominfo fix for large rtstructs (available since r2016a)
    info=dicominfo(f_filename,'UseVRHeuristic', false);
    if(strcmp(info.Modality,'RTSTRUCT') ~= 1)
        disp(' is no rtstructfile .....');
        continue;
    end;
    
    %read # contours
    n_contours=size(fieldnames(info.StructureSetROISequence),1);
    fprintf('File %s has %i contours',f_filename,n_contours);

    switch(option)
        
        %
        % rename
        %
        case '-r'
            fprintf('\nRename option selected' );
            if(rem(nargin-2,2)==1)
                disp(['\nnumber of arguments should be pairs '...
                    ' so : old new thus an even number']);
                return
            end;
            %here make loop over all orig/new pairs and after 
            %loop over all rois
            for k=1:2:nargin-2
                orig=varargin{k};
                new=varargin{k+1};

                fprintf(['\n\n checking all contours for name : %s'...
                    'to replace with : %s\n'],orig,new);
                for i=1:n_contours
                    value=eval(sprintf(['info.StructureSetROI'...
                        'Sequence.Item_%i.ROIName'],i));
                    fprintf('%i:%s/',i,value);
                    if( sum(strcmp(value,orig)) == 1 )
                        fprintf(['\n***item nr %i is %s  replacing'...
                            'with %s *******\n'],i,orig,new);
                            eval(sprintf(['info.StructureSet'...
                            'ROISequence.Item_%i.ROIName=''%s''; '],i,new));
                    end;
                end; 
            end;
             
        %
        %   delete and leave
        %
        case {'-d','-l'}
            %fprintf('\n Delete or Leave option selected' );
            if( strcmp(option,'-d') == 1 )
                condition=0;
                fprintf('\n Delete  option selected' );
            else
                condition=1;
                fprintf('\n Leave  option selected' );
                if(nargin==2)
                    fprintf('\n No contours entered to leave, probably an error so will not rewrite file' );
                    save_this_data=0;
                end
            end;
            
            %here make loop over all contours entered and after loop over
            %all in dicom rois
            cnt=1;
            items_to_delete=[];
            for k=1:nargin-2
                name=varargin{k};

                fprintf('\nChecking contours for name : %s to select, found :',name);
                for i=1:n_contours
                    value = eval(  sprintf('info.StructureSetROISequence.Item_%i.ROIName',i)  );
                    if( strcmp(value,name)  )
                        items_to_delete(cnt)=i;
                        fprintf('%i/',i);
                        cnt=cnt+1;
                    else
                        fprintf('.',i);
                    end;
                end; 
            end;
            %now do the real deleting
            for k=1:n_contours
                ismember(k,items_to_delete);
                type =  eval(  sprintf('info.ROIContourSequence.Item_%i.ContourSequence.Item_1.ContourGeometricType',k)  );
                if(ismember(k,items_to_delete) ~= condition && ~strcmp(type,'POINT') )
                    fprintf('\n*******item nr %i is being deleted..... ******',k);
                    name_item=sprintf('Item_%i',k);
                    info.ROIContourSequence=rmfield(info.ROIContourSequence,name_item);
                    info.StructureSetROISequence=rmfield(info.StructureSetROISequence,name_item);
                    info.RTROIObservationsSequence=rmfield(info.RTROIObservationsSequence,name_item);
                end;
            end;
               
        %
        %   print
        %
        case {'-p'}
            %fprintf('\n Print option selected' );
            %here make loop over all contours entered and after loop over
            %all in dicom rois
            save_this_data=0;
            for i=1:n_contours
                name = eval(  sprintf('info.StructureSetROISequence.Item_%i.ROIName',i)  );
                try
                    type = eval(  sprintf('info.ROIContourSequence.Item_%i.ContourSequence.Item_1.ContourGeometricType',i)  );
                catch
                    type = ' ContourGeometricType not found';
                end;
                fprintf('\n%i\t%s\t%s',i,name,type);
            end;
              
            
    otherwise
          fprintf('\nInvalid option\n' );
          return;
    end
    if(save_this_data==1);
        fprintf('\nSaving file ' );
        dicomwrite([ ],f_filename, info, 'CreateMode', 'Copy');
    end;
end
fprintf('\nfinished\n');
