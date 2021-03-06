%> @file SOURCES_MATLAB/SF_Adapt.m
%> @brief Matlab driver for Mesh Adaptation
%> 
%> Usage : 
%> 1/ mesh-associated mode (for linear problems without baseflows, e.g. sloshing, acoustics...)
%> [mesh [,flow1,flow2,...] ] = SF_Adapt(mesh,flow1 [,flow2,...] [,'opt1','val1']) 
%> 
%> 2/ baseflow-associated mode (for stability problems with baseflow)
%> [flow1 [,flow2,...] ] = SF_Adapt(flow1 [,flow2,...] [,'opt1','val1']) 
%>
%> @param[in] mesh : mesh-object (only when using in mesh-associated mode)
%> @param[in] flow1 : flow provided for mesh adaptation.
%> @param[in] (optional) flow2, flow3, etc... 
%>             additional flows for adaptation to multiple flows (max number currently 3) 
%> OPTIONS :
%> 
%> @param[out] flow1: flow structure reprojected on adapted mesh
%> @param[out] flow2; ... if asked, eigenmode recomputed on adapted mesh
%>
%> IMPORTANT NOTE : if using mode 2 and if flow1 is of type "BaseFlow" then it is recomputed
%>                  after flow adatpation. additional flows are simply reprojected 
%>                  on new mesh, not recomputed.
%>
%>
%> @author David Fabre & J. Sierra, redesigned in nov. 2018
%> @version 2.1
%> @date 02/07/2017 Release of version 2.1


function varargout = SF_Adapt(varargin)
global ff ffdir ffdatadir sfdir verbosity

varargout = {}; % introduced to avoid a bug at line 227 in some cases (to be rationalized)

mydisp(1, '### ENTERING SF_ADAPT')

% managament of optional parameters
% NB here the parser had to be customized because input parameter number 2
% is optional and is a structure ! we should find a better way in future



%% sorting the input parameters into fields and options.
nfields=0;vararginopt={};
for i=1:nargin
if(isstruct(varargin{i}))
    % input mode for adaptation to base flow
    nfields=nfields+1;
%    flowforadapt(i) = varargin{i} % This does not work in this way ! see
%    below.
end
end
%nfields = length(flowforadapt)
narginopt = nargin-nfields;
vararginopt = {varargin{nfields+1:end}};

if(strcmpi(varargin{1}.datatype,'mesh'))
    vararginfields = {varargin{2:nfields}};
    nfields = nfields-1;
    ffmesh = varargin{1};
else
    vararginfields = {varargin{1:nfields}};
    ffmesh = varargin{1}.mesh;
end

% creating an array of structures "flowtoadapt"
% here we want to do 
%   flowtoadapt = [varargin{1:nfields}] 
% but this does not because the fields may have dissimilar structures !
% below is a WORKAROUND found there 
% https://fr.mathworks.com/matlabcentral/answers/152580-converting-a-cell-array-of-dissimilar-structs-to-an-array-of-structs
uniqueFields = unique(char(cellfun(@(x)char(fieldnames(x)),{vararginfields{1:nfields}},'UniformOutput',false)),'rows');
for k=1:nfields
     for u=1:size(uniqueFields,1)
         fieldName = strtrim(uniqueFields(u,:));
         if ~isfield(vararginfields{k}, fieldName)
             vararginfields{k}.(fieldName) = [];
         end
     end
end
flowforadapt = [vararginfields{1:nfields}];
% END WORKAROUND 

%% designation of the adapted mesh
if(isfield(ffmesh,'meshgeneration'))
     meshgeneration = ffmesh.meshgeneration;
else
    meshgeneration = 0;
end
designation = ['_adapt',num2str(meshgeneration+1)];
% this desingation will be added to the names of the mesh/BF files

if(strcmpi(flowforadapt(1).datatype,'BaseFlow'))
if (isfield(flowforadapt(1),'Re'))
   designation = [designation, '_Re' , num2str( flowforadapt(1).Re)];
end
if (isfield(flowforadapt(1),'Ma'))
   designation = [designation, '_Ma' , num2str( flowforadapt(1).Ma) ];
end
end


%% Interpreting parameters
p = inputParser;
%    addRequired(p,'baseflow');
%    addOptional(p,'eigenmode',0);
addParameter(p, 'Hmax', 10);
addParameter(p, 'Hmin', 1e-4);
addParameter(p, 'Ratio', 10.);
addParameter(p, 'InterpError', 1e-2);
addParameter(p, 'rr', 0.95);
addParameter(p, 'Splitin2', 0);
parse(p, vararginopt{:});

%% Writing parameter file for Adapmesh
writeParamFile('Param_Adaptmesh.edp',p.Results); %% see function defined at bottom


%% constructing option string and positioning files
optionstring = [' ', num2str(nfields), ' '];
for i=1:nfields;
     mycp(flowforadapt(i).mesh.filename, [ffdatadir, 'mesh.msh']);
     mycp(flowforadapt(i).filename, [ffdatadir, 'FlowFieldToAdapt',num2str(i),'.txt']);
%    if(isfield(flowforadapt(i),'datastoragemode')) 
    [dumb,storagemode,nscalars] = fileparts(flowforadapt(i).datastoragemode); % this is to extract two parts of datastoragemode, e.g. 
    if(strcmp(nscalars,''))
        nscalars = '0';
    else
        nscalars = nscalars(2:end); %to remove the dot
    end
%    else 
%        storagemode = 'ReP2P2P1';
%        nscalars = 1;
%    end
    optionstring = [optionstring, ' ', storagemode, ' ' , nscalars , ' '];
end


%    if (verbosity >= 1)
%        meshinfo = importFFdata(flowforadapt(1).mesh, 'mesh.ff2m');
%        mydisp(3, ['      #   Number of points np = ', num2str(meshinfo.np), ...
%            ' ; Ndof = ', num2str(meshinfo.Ndof)]);
%        mydisp(3, ['      #  h_min, h_max : ', num2str(meshinfo.deltamin), ' , ', ...
%            num2str(meshinfo.deltamax)]);
        %  mydisp(1,['      # h_(A,B,C,D) : ',num2str(meshinfo.deltaA),' , ',...
        %        num2str(meshinfo.deltaB),' , ',num2str(meshinfo.deltaC),' , ',num2str(meshinfo.deltaD) ]);
%    end
 
%% Invoking FreeFem++ program AdaptMesh.edp   
command = ['echo ', optionstring, ' | ', ff, ' ', ffdir, 'AdaptMesh.edp'];
errormessage = 'ERROR : FreeFem ADAPTmesh aborted';
status = mysystem(command, errormessage);
if(status) 
    command
    error(errormessage);
end
          
    
%    mydisp(1, ['### ADAPT mesh to ',nfields ' fields ; '
 %       ' InterpError = ', num2str(p.Results.InterpError), '  ; Hmax = ', num2str(p.Results.Hmax)])
    %     mydisp(1,[' ; Number of points np = ',num2str(meshinfo.np) ' ; Ndof = ' num2str(meshinfo.Ndof)]; ])
%    if (verbosity >= 1)
%        meshinfo = importFFdata(flowforadapt(1).mesh, 'mesh.ff2m');
%        mydisp(3, ['#   Number of points np = ', num2str(meshinfo.np), ...
%            ' ; Ndof = ', num2str(meshinfo.Ndof)]);
%        mydisp(3, ['#  deltamin, deltapax : ', num2str(meshinfo.deltamin), ' , ', ...
%            num2str(meshinfo.deltamax)]);
        %  mydisp(1,['      #  delta_(A,B,C,D) : ',num2str(meshinfo.deltaA),' , ',...
        %        num2str(meshinfo.deltaB),' , ',num2str(meshinfo.deltaC),' , ',num2str(meshinfo.deltaD) ]);
%    end


%% OUTPUT    
% WARNING : the mesh-associated data in the structures will most likely be wrong !    
    if(exist([ffdatadir, 'MESHES'])==0)
        mkdir([ffdatadir, 'MESHES']); %% put it elsewhere !
    end
    
     mycp([ffdatadir 'SF_Init.ff2m'],[ffdatadir 'MESHES/SF_Init.ff2m']); %% put it elsewhere ! 
     mycp([ffdatadir, 'mesh_adapt.msh'], [ffdatadir, 'MESHES/mesh',designation,'.msh']);
     mycp([ffdatadir, 'mesh_adapt.ff2m'], [ffdatadir, 'MESHES/mesh',designation,'.ff2m']);


newmesh = importFFmesh(['MESHES/mesh',designation,'.msh']);
newmesh.meshgeneration=flowforadapt(1).mesh.meshgeneration+1;


if(strcmpi(varargin{1}.datatype,'mesh')) % UGLY FIX TO BE DONE BETTER
    nargoutF=nargout-1;
else
    nargoutF=nargout;
end
for i = 1:nargoutF
    varargout{i} = flowforadapt(i); %  copies the structure but the fields may be wrong !
    varargout{i}.filename = [ffdatadir,'FlowFieldAdapted',num2str(i),'.txt'];
    varargout{i}.mesh = newmesh;
    % remove unneccesary fields from structure (see WORKAROUND at beginning)
    for u=1:size(uniqueFields,1)
         fieldName = strtrim(uniqueFields(u,:));
         if (length(getfield(varargout{i},fieldName))==0);
             varargout{i} = rmfield(varargout{i},fieldName);
         end
    end
end

%% if first field is a base flow we have to recompute it !     
    
if(strcmp(varargin{1}.datatype,'BaseFlow')) 
    mydisp(2,' SF_Adapt : recomputing base flow');
    baseflowNew = SF_BaseFlow(varargout{1}, 'type', 'POSTADAPT'); 
     if (baseflowNew.iter > 0)
     %  Newton successful : Store adapted mesh/base flow in directory "MESHES"
     mycp([ffdatadir, 'BaseFlow.txt'], [ffdatadir, 'MESHES/BaseFlow',designation, '.txt']);
     mycp([ffdatadir, 'BaseFlow.ff2m'], [ffdatadir, 'MESHES/BaseFlow',designation '.ff2m']);
     baseflowNew.filename = [ffdatadir, 'MESHES/BaseFlow',designation, '.txt'];
     varargout{1} = baseflowNew; 
     myrm([ffdatadir '/BASEFLOWS/*']); % after adapt we clean the "BASEFLOWS" directory as the previous baseflows are no longer compatible => Now done in SF_BaseFlow ??? 
     myrm([ffdatadir '/MEANFLOWS/*']); 
     
     else
         error('ERROR in SF_Adapt : baseflow recomputation failed');
     end
    
end

%% if first input was a mesh, then first output will be the mesh
if(strcmpi(varargin{1}.datatype,'mesh'))
    varargout  = { newmesh varargout{:}};   
end

myrm([ffdatadir 'Eigenmode*']); % remove all eigenmode files

end

function [] = writeParamFile(filename,p);
fid = fopen(filename, 'w');
fprintf(fid, '// Parameters for adaptmesh (file generated by matlab driver)\n');
fprintf(fid, ['real Hmax = ', num2str(p.Hmax), ' ;\n']);
fprintf(fid, ['real Hmin = ', num2str(p.Hmin), ' ;\n']);
fprintf(fid, ['real Ratio = ', num2str(p.Ratio), ' ;\n']);
fprintf(fid, ['real error = ', num2str(p.InterpError), ' ;\n']);
fprintf(fid, ['real rr = ', num2str(p.rr), ' ;\n']);
fprintf(fid, ['int Nbvx	= 100000; \n']);		
fprintf(fid, 'real Thetamax	= 1e-3; \n');
fprintf(fid, 'real Verbosity	= 1; \n');
fprintf(fid, 'bool Splitpbedge= false; \n');
if (p.Splitin2 == 0)
    fprintf(fid, ['bool Splitin2 = false ;']);
else
    fprintf(fid, ['bool Splitin2 = true ;']);
end
fclose(fid);
end


