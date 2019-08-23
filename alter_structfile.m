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
                try
                    type =  eval(  sprintf('info.ROIContourSequence.Item_%i.ContourSequence.Item_1.ContourGeometricType',k)  );
                catch
                    type = ' ContourGeometricType not found';
                end;
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
                    eval(  sprintf('c=info.ROIContourSequence.Item_%i.ROIDisplayColor(:);',i)  );
                catch
                    type = ' ContourGeometricType not found';
                    c(1)=0;c(2)=0;c(3)=0;
                end;
                fprintf('\n%i\t%s\t%s\t[%i,%i,%i]',i,name,type,c(1),c(2),c(3));
            end;
            
       %
       %    alter tags
       %
       case {'-t'}  
           %to create or modify a dicom tag
           if( (nargin-2) ~= 2 )
                info
                fprintf('\nExiting ! : number of extra arguments should be 2 for this option\n\n');
                return
            end;
           tag_name=varargin{1};
           tag_value=varargin{2};

           %from commandline it is difficult to specify an 'empty' value
           %therefore this option
           if(strcmp(tag_value,'EMPTY')==1)
               tag_value='';
           end;
           
           command=sprintf('info.%s=''%s'';',tag_name,tag_value)
           eval(command);
           
       %
       %    Color the rois
       %     
        case '-c'
            fprintf('\nColouring option selected' );
            if(rem(nargin-2,4)==1)
                disp(['\nnumber of arguments should be qudruples '...
                    ' so : OARname color1 color2 color3']);
                return
            end;
            %here make loop over all name/color pairs and after 
            %loop over all rois
            for k=1:4:nargin-2
                name=varargin{k};
                c1=varargin{k+1};
                c2=varargin{k+2};
                c3=varargin{k+3};
             

                fprintf(['\n\n checking all contours for name : %s'...
                    ' to set the color\n'],name);
                for i=1:n_contours
                    value=eval(sprintf(['info.StructureSetROI'...
                        'Sequence.Item_%i.ROIName'],i));
                    fprintf('%i:%s/',i,value);
                    
                    if( sum(strcmp(lower(value),lower(name))) == 1 )
                        fprintf(['\n***item nr %i is %s  coloring '...
                            'to [%s,%s,%s]*******\n'],i,name,c1,c2,c3);
                            eval(sprintf(['info.ROIContour'...
                            'Sequence.Item_%i.ROIDisplayColor=[%s;%s;%s];'],i,c1,c2,c3));
                    end;
                end; 
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
