function res = SF_LinearForced(bf,varargin)
%>
%> Function SF_LinearForced
%>
%> This function solves a linear, forced problem for a single value of
%> omega or for a range of omega (for instance impedance computations)
%>
%> Usage :
%> 1/ res = SF_LinearForced(bf,'omega',omega) (single omega mode)
%>      in this case res will be a flowfield structure 
%> 
%>  2/ res = SF_LinearForced(bf,'omega',omega) (loop-omega mode)
%>      in this case res will be a structure composed of arrays, as specified in the Macro_StabFem.edp 
%>      (for instance omega and Z)
%>
%>  Parameters : 'plot','yes' => the program will plot the impedance and
%>                               Nyquist diagram
%>  Parameters : 'BC','SOMMERFELD' => Boundary condition for the farfield
%>                                    for the acoustic simulations 
%>
%> Copyright D. Fabre, 11 oct 2018
%> This program is part of the StabFem project distributed under gnu licence.

global ff ffMPI ffdir ffdatadir sfdir verbosity

if (mod(length(varargin),2)==1) 
    mydisp(2,'SF_LinearForced : recommended to use [''Omega'',omega] in list of arguments ');  
    varargin = {'omega',varargin{:}};
end
    
   p = inputParser;
   addParameter(p,'omega',1); 
   addParameter(p,'plot','no',@ischar); 
   addParameter(p,'solver','default');
   addParameter(p,'BC','SOMMERFELD',@ischar);
   parse(p,varargin{:});

   omega = p.Results.omega;
   
   p.Results

% Position input files
if(strcmpi(bf.datatype,'Mesh')==1)
       % first argument is a simple mesh
       ffmesh = bf; 
       mycp(ffmesh.filename,[ffdatadir 'mesh.msh']); % this should be done in this way in the future
else
       % first argument is a base flow
       ffmesh = bf.mesh;
       mycp(bf.filename,[ffdatadir 'BaseFlow.txt']);
       mycp(bf.mesh.filename,[ffdatadir 'mesh.msh']); % this should be done in this way in the future
end

switch ffmesh.problemtype
    case('AxiXRCOMPLEX')
        solver = [ffdir 'LinearForcedAxi_COMPLEX_m0.edp'];
        FFfilename = [ffdatadir 'Field_Impedance_Re' num2str(bf.Re) '_Omega' num2str(omega(1))];
        FFfilenameStat = [ffdatadir 'Impedances_Re' num2str(bf.Re)];
        paramstring = [' array ' num2str(length(omega))];
    case('AxiXR') % Jet sifflant Axi Incomp.
        solver = [ffdir  'LinearForcedAxi_m0.edp'];
        FFfilename = [ffdatadir 'Field_Impedance_Re' num2str(bf.Re) '_Omega' num2str(omega(1))];
        FFfilenameStat = [ffdatadir 'Impedances_Re' num2str(bf.Re)];
        paramstring = [' array ' num2str(length(omega))];
    case({'2D','2DMobile'}) % VIV
        solver = [ffdir 'LinearForced2D.edp'];
        FFfilename = [ffdatadir 'Field_Impedance_Re' num2str(bf.Re) '_Omega' num2str(omega(1))];
        FFfilenameStat = [ffdatadir 'Impedances_Re' num2str(bf.Re)];
        paramstring = [' array ' num2str(length(omega))];
    case('AcousticAxi') % Acoustic-Axi (Helmholtz).
        solver = [ffdir  'LinearForcedAcoustic.edp'];
        FFfilename = [ffdatadir 'Field_Impedance_Re_Omega' num2str(omega(1))];
        FFfilenameStat = [ffdatadir 'Impedances_Re'];
        paramstring = [p.Results.BC, ' array ' num2str(length(omega))];
    otherwise
        error(['Error : problemtype ' ffmesh.problemtype ' not recognized']);
end

if(strcmp(p.Results.solver,'default'))
    mydisp(2,['      ### USING STANDARD StabFem Solver ',solver]);        
else
    if(exist(p.Results.solver)==2)
        solver = p.Results.solver;
        
    elseif(exist([ffdir  p.Results.solver])==2)
           solver = [ffdir  p.Results.solver];
    else
        error(['Error : solver ',p.Results.solver, ' could not be found !']);
    end
    mydisp(2,['      ### USING CUSTOM FreeFem++ Solver ',solver]);
end 

for i=1:length(omega)
    paramstring = [paramstring ' ' num2str(real(omega(i))),' ',num2str(imag(omega(i))) ];
end

 solvercommand = ['echo ',paramstring,' | ', ff, ' ', solver];
 errormsg = 'Error in SF_ForcedFlow';
 mysystem(solvercommand, errormsg);
 
 if(length(omega)==1)
    mycp([ffdatadir 'ForcedFlow.ff2m'],[FFfilename, '.ff2m']);
    mycp([ffdatadir 'ForcedFlow.txt'],[FFfilename, '.txt']);
    res = importFFdata(ffmesh, [FFfilename, '.ff2m']);
    
 else
    mycp([ffdatadir 'LinearForcedStatistics.ff2m'],[FFfilenameStat,'.ff2m']);
    res = importFFdata(ffmesh, [FFfilenameStat,'.ff2m']);
    
    %plots...
    if(~strcmp(p.Results.plot,'no'))
    subplot(1,2,1); hold on;
    plot(res.omega,real(res.Z),'b-',res.omega,-imag(res.Z)./res.omega,'b--');hold on;
    plot(res.omega,0*real(res.Z),'k:','LineWidth',1)
    xlabel('\omega');ylabel('Z_r, -Z_i/\omega');
    title(['Impedance for Re = ',num2str(bf.Re)] );
    subplot(1,2,2);hold on;
    plot(real(res.Z),imag(res.Z)); title(['Nyquist diagram for Re = ',num2str(bf.Re)] );
    xlabel('Z_r');ylabel('Z_i');ylim([-10 2]);
    box on; pos = get(gcf,'Position'); pos(4)=pos(3)*.5;set(gcf,'Position',pos);
    pause(0.1);
    end
    
    
 end

 
end