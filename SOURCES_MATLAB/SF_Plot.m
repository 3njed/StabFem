function handle = SF_Plot(FFdata, varargin);
%  function plotFF
%  plots a data field imported from freefem.
%  This function is part of the StabFem project by D. Fabre & coworkers.
%
%  Usage :
%  1/ handle=plotFF(mesh); (if mesh is a mesh object)
%  2/ handle=plotFF(ffdata,'field'); to plot isocontours of a P1 field
%  3/ handle=plotFF(ffdata,'field.re'); to plot isocontours of a P1 complex
%  field (specify '.re' or '.im')
%  4/ handle=plotFF(ffdata,'field',[PARAM,VALUE,..])
%      where [PARAM,VALUE] is any couple of parameters accepted by ffpdeplot.
%       (See Below)
%
%  FFdata is the structure containing the data to plot
%  'field' is the field to plot (the data may comprise multiple fields)
%
%   This version of plotFF is based on ffpdeplot developed by chloros2
%   as an Octave-compatible alternative to pdeplot from toolbox pdetools
%   (https://github.com/samplemaker/freefem_matlab_octave_plot)
%
%   [PARAM,VALUE] are any couple of name/value parameter accepted by
%   ffpdeplot. 
%   The list of accepted parameters are the same as accepted by ffpdeplot,
%   plus two specific ones : 'symmmetry' and 'logsat'.
%   NB : parameter 'colomap' accepts  a few custom ones including 'redblue' and 'ice'. 
%
%   specifies parameter name/value pairs to control the input file format
%
%       Parameter       Value
%      'XYData'      Data in order to colorize the plot
%                       FreeFem++ point data | FreeFem++ triangle data
%      'XYStyle'     Coloring choice
%                       'interp' (default) | 'off'
%      'ZStyle'      Draws 3D surface plot instead of flat 2D Map plot
%                       'continuous' | 'off' (default)
%      'ColorMap'    ColorMap value or matrix of such values
%                       'cool' (default) | colormap name | three-column matrix of RGB triplets
%                       NB : In addition to default ones ('cool', jet', etc...) 
%                            we provide a few custom ones ('redblue', 'ice', etc...)
%      'ColorBar'    Indicator in order to include a colorbar
%                       'on' (default) | 'off' | 'northoutside' ...
%      'CBTitle'     Colorbar Title
%                       (default=[])
%      'ColorRange'  Range of values to adjust the color thresholds
%                       'minmax' (default) | 'centered' | 'cropminmax' | 'cropcentered' | [min,max]
%      'Mesh'        Switches the mesh off / on
%                       'on' | 'off' (default)
%      'Boundary'    Shows the domain boundary / edges
%                       'on' | 'off' (default)
%      'BDLabels'    Draws boundary / edges with a specific label
%                       [] (default) | [label1,label2,...]
%      'BDColors'    Colorize boundary / edges with color (linked to 'BDLabels')
%                       'r' (default) | ['r','g', ... ]
%      'BDShowText'  Shows the labelnumber on the boundary / edges
%                       'on' | 'off' (default)
%      'Contour'     Isovalue plot
%                       'off' (default) | 'on'
%      'CXYData'     Use extra (overlay) data to draw the contour plot
%                       FreeFem++ points | FreeFem++ triangle data
%      'CStyle'      Contour plot style
%                       'patch' (default) | 'patchdashed' | 'patchdashedneg' | 'monochrome' | 'colormap'
%      'CColor'      Isovalue color
%                       [0,0,0] (default) | RGB triplet | 'r' | 'g' | 'b' |
%      'CLevels'     Number of isovalues used in the contour plot
%                       (default=10)
%      'CGridParam'  Number of grid points used for the contour plot
%                       'auto' (default) | [N,M]
%      'Title'       Title
%                       (default=[])
%      'XLim'        Range for the x-axis
%                       'minmax' (default) | [min,max]
%      'YLim'        Range for the y-axis
%                       'minmax' (default) | [min,max]
%      'ZLim'        Range for the z-axis
%                       'minmax' (default) | [min,max]
%      'DAspect'     Data unit length of the xy- and z-axes
%                       'off' | 'xyequal' (default) | [ux,uy,uz]
%      'FlowData'    Data for quiver plot
%                       FreeFem++ point data | FreeFem++ triangle data
%      'FGridParam'  Number of grid points used for quiver plot
%                       'auto' (default) | [N,M]
%
%       'symmetry'  symmetry property of the flow to plot
%                       'no' (default) | 'YS' (symmetric w.r.t. Y axis) | 'YA' (antisymmetric w.r.t. Y axis) | 'XS' | 'XA' 
%                                      | 'XM' (mirror image w/r to X axis) | 'YM'  
%       'logsat'    use nonlinearly scaled colorange using filter function f_S
%                   colorange is linear when |value|<S and turns into logarithmic when |value|>S  
%                   (use this option to plot fields with strong spatial amplifications)
%                   NB : is S = 0 the colorrange is purely logarithmic
%                   -1 (default, disabled) | S
%     Notes :


global ff ffdir ffdatadir sfdir verbosity


% first check if 'colormap' is a custom one 
%   (a few customs are defined at the bottom of this function)
for i=1:length(varargin)-1
    if(strcmp(lower(varargin{i}),'colormap'))
        switch(lower(varargin{i+1}))
            case('redblue')
                varargin{i+1} = redblue(); % defined at the bottom
            case('french')
                varargin{i+1} = french();
            case('ice')
                varargin{i+1} = ice();
            case('fire')
                varargin{i+1} = fire();
            case('seashore')
                varargin{i+1} = seashore();
            case('dawn')
                varargin{i+1} = dawn();
                %otherwise varargin{i+1} should be a standard colormap
        end    
    end   
end

% check if 'contour' is part of the parameters and recovers its value
contourval='off';
for i=1:length(varargin)-1
      if(strcmp(varargin{i},'contour'))
           icontour = i;
           contourval = varargin{i+1};
      end    
end

% check if 'symmetry' is part of the parameters and recovers it
symmetry = 'no';
for i=1:length(varargin)-1
      if(strcmp(varargin{i},'symmetry'))
           isymmetry = i;
           symmetry = varargin{i+1};
      end    
end
if (strcmp(symmetry,'no')~=1)
       varargin = { varargin{1:isymmetry-1} ,varargin{isymmetry+2:end}} ;
end

% check if 'logsat' is part of the parameters and recovers it
logscaleS = -1;
for i=1:length(varargin)-1
      if(strcmp(varargin{i},'logsat'))
           ilogscale = i;
           logscaleS = varargin{i+1};
           mydisp(2,['using colorrange with logarithmic saturation ; S = ',num2str(logscaleS)]);
      end    
end
if (logscaleS~=-1)
       varargin = { varargin{1:ilogscale-1} ,varargin{ilogscale+2:end}} ;
end

% check if 'amp' is part of the parameters and recovers it
iAmpplot = 0;Ampplot = 1;
for i=1:length(varargin)-1
      if(strcmpi(varargin{i},'amp'))
           iAmpplot = i;
           Ampplot = varargin{i+1};
           mydisp(2,['using amplitude ; A = ',num2str(Ampplot)]);
      end    
end
if (iAmpplot~=0)
       varargin = { varargin{1:iAmpplot-1} ,varargin{iAmpplot+2:end}} ;
end



%%% prepares to invoke ffpdeplot...
if (mod(nargin, 2) == 1) % plot mesh in single-entry mode : mesh
    mesh = FFdata;
    varargin = {varargin{:}, 'mesh', 'on'};
    if(isfield(mesh,'xlim'))
        varargin = { varargin{:}, 'xlim', mesh.xlim};
    end
    if(isfield(mesh,'ylim'))
        varargin = { varargin{:}, 'ylim', mesh.ylim};
    end
    mydisp(15, ['launching ffpeplot with the following options :']);
    if (verbosity >= 15)
        varargin
    end;
    if(strcmpi(symmetry,'xm'))
        mesh.points(2,:) = -mesh.points(2,:);
        symmetry = 'no';
 elseif(strcmpi(symmetry,'ym'))
        mesh.points(1,:) = -mesh.points(1,:); 
        symmetry ='no';
    end
  
    handle = ffpdeplot(mesh.points, mesh.bounds, mesh.tri, varargin{:});
    
else % plot mesh in single-entry mode : data
    mesh = FFdata.mesh;
    field1 = varargin{1};
    varargin = {varargin{2:end}};
     if(isfield(mesh,'xlim'))
        varargin = {varargin{:}, 'xlim', mesh.xlim};
    end
    if(isfield(mesh,'ylim'))
        varargin = {varargin{:}, 'ylim', mesh.ylim};
    end
    if (strcmp(field1, 'mesh')) % plot mesh ins double-entry mde
        varargin = {varargin{:}, 'mesh', 'on'};
        
        mydisp(15, ['launching ffpeplot with the following options :']);
        if (verbosity >= 15)
            varargin
        end;
         if(strcmpi(symmetry,'xm'))
        mesh.points(2,:) = -mesh.points(2,:);
        symmetry = 'no';
 elseif(strcmpi(symmetry,'ym'))
        mesh.points(1,:) = -mesh.points(1,:); 
        symmetry ='no';
         end  
  
        handle = ffpdeplot(mesh.points, mesh.bounds, mesh.tri, varargin{:});
        
    else
        % plot data
        
        % check if data to plot is the name of a field or a numerical dataset
        if (~isnumeric(field1))
            [~, field, suffix] = fileparts(field1); % to extract the suffix
            if (strcmp(suffix, '.im') == 1)
                data = imag(Ampplot*getfield(FFdata, field));
            else
                data = real(Ampplot*getfield(FFdata, field));
            end
        else
            data = field1;
        end
        if (logscaleS~=-1)
            varargin = {varargin{:}, 'ColorRangeTicks', logscaleS};
            data = logfilter(data,logscaleS);
        end
        
        if (strcmpi(contourval,'off')~=1&&strcmpi(contourval,'on')~=1)
        varargin{icontour} = 'on';
        [~, field, suffix] = fileparts(contourval); % to extract the suffix
            if (strcmp(suffix, '.im') == 1)
                xydata = imag(getfield(FFdata, field));
            else
                xydata = real(getfield(FFdata, field));
            end
        varargin = { varargin{:} , 'cxydata',xydata } ;
        end

        mydisp(20, ['launching ffpeplot with the following options :']);
        if (verbosity >= 20)
            varargin
        end;
          
 pointsS = FFdata.mesh.points;
 if(strcmpi(symmetry,'xm'))
        pointsS(2,:) = -pointsS(2,:);
        symmetry = 'no';
 elseif(strcmpi(symmetry,'ym'))
        pointsS(1,:) = -pointsS(1,:); 
        symmetry ='no';
 end
  

  handle = ffpdeplot(pointsS, FFdata.mesh.bounds, FFdata.mesh.tri, 'xydata', data, varargin{:});


%%% SYMMETRIZATION OF THE PLOT
if(strcmp(symmetry,'no'))
        mydisp(20,'No symmetry');
else   
     mydisp(20,['Symmetrizing the plot with option ',symmetry]);
  pointsS = FFdata.mesh.points;
  switch(symmetry)
    case('XS')
        pointsS(2,:) = -pointsS(2,:);dataS = data;
    case('XA')
       pointsS(2,:) = -pointsS(2,:);dataS = -data;
    case('YS')
        pointsS(1,:) = -pointsS(1,:);dataS = data;
    case('YA')
        pointsS(1,:) = -pointsS(1,:);dataS = -data;
    case({'XM','YM'})
          % do nothing as these case has already been treated
      otherwise
        error(' Error in plotFF with option symmetry ; value must be XS,XA,YS,YA,XM,YM or no')      
  end
  
    hold on;
    handle = ffpdeplot(pointsS, FFdata.mesh.bounds, FFdata.mesh.tri, 'xydata', dataS, varargin{:});
end

end

end

end

% custom colormaps
function cmap = redblue()
%colmapdef=[193,0,0; 235,164,164; 235,235,235; 196,196,255; 127,127,255]/255;
colmapdef=[127,127,255; 196,196,255; 235,235,235; 235,164,164; 193,0,0  ]/255;
[sz1,~]=size(colmapdef);
cmap=interp1(linspace(0,1,sz1),colmapdef,linspace(0,1,255));
end

function cmap = french()
colmapdef=[255,0,0; 255,255,255; 0,0,255]/255;
[sz1,~]=size(colmapdef);
cmap=interp1(linspace(0,1,sz1),colmapdef,linspace(0,1,255));
end

function cmap = ice()
%definition of the colormap "ice"
colmapdef=[255,255,255; 125,255,255; 0,123,255; 0,0,124; 0,0,0]/255;
[sz1,~]=size(colmapdef);
cmap=interp1(linspace(0,1,sz1),colmapdef,linspace(0,1,255));
end

function cmap = fire()
% definition of colormap "fire"
colmapdef = [255   255   255
             255   255   151
             255   207    89
             255   148    45
             255    99    13
             253    57     0];
         colmapdef = colmapdef/255;
[sz1,~]=size(colmapdef);
cmap=interp1(linspace(0,1,sz1),colmapdef,linspace(0,1,255));
end

function cmap = dawn()
% definition of colormap "dawn"
colmapdef = [255   255   195
   255   255   139
   255   179   126
   204    77   127
   101     0   127
     0     0   126];
     colmapdef = colmapdef/255;
[sz1,~]=size(colmapdef);
cmap=interp1(linspace(0,1,sz1),colmapdef,linspace(0,1,255));
end

function cmap = seashore()
% definition of colormap "seashore"
colmapdef = [[255   255   195];[255   255   139];[179   255   126];[77   204   127];[ 0   101   127];[0     0   126]]
colmapdef = colmapdef/255;
[sz1,~]=size(colmapdef);
cmap=interp1(linspace(0,1,sz1),colmapdef,linspace(0,1,255));
end

% Note for future (and for Javier) : here is the way to convert a [255,3]
% array into a [5,3] array producing an equivalent colormap
% colmapdef = colmapdef(1+255*(0:5)/5,:)
% colmapdef = colmapdef/255;


function y = logfilter(x,S)
y = S*sign(x).*log(1+abs(x)/S);
end
