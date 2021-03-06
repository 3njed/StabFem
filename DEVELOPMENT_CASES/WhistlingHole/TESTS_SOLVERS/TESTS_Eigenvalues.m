

% This script computes eigenvalues for a whistling jet through a hole with beta = 1.

% NOT WORKING YET, BUT THIS IS TO DEMONSTRATE HOW IT (doesn't) WORK...



run('../../SOURCES_MATLAB/SF_Start.m');
verbosity=10;


%% chi = 1
Params = [0 17 2.5 0. 5 17]; % Lm, LA, LC, gammac, yA, yB
chi = 1;
Re = 1500;
if(exist('bf'))
    bf = SF_BaseFlow(bf,'Re',Re,'type','NEW','MappingParams',Params);
else
    bf = SmartMesh_Hole(chi);
end

% FOR Re = 1500, according to impedance predictions, there should be a 
% nearly-neutral eigenvalue close to omega = \pm 2.1i
%
% If i'm right the complex-mapping method should allow to calculate the
% eigenvalue with negative imaginary part (lambda = sigma - i omega with omega >0) 

% First test : USING general solver Stab_Axi_COMPLEX.edp (adapted from other sources of the StabFem project) 
% nev = 20 => Slepc solver

%% 


[evG,emG] = SF_Stability(bf,'shift',2.1i,'m',0,'nev',20)
% % nev = 1 => shift-invert solver
%[evG1,emG1] = SF_Stability(bf,'shift',2.1i,'m',0,'nev',1)


% SECOND test : USING solver  Stab_Axi_COMPLEX_m0.edp adapted from Raffaele's sources
% note that this solver is switched on by the "trick" m = 0+1i...
% nev = 20 => Slepc solver
[ev,em] = SF_Stability(bf,'shift',-2.1i,'m',0,'nev',20,'solver','StabAxi_COMPLEX_m0.edp')
% nev = 1 => shift-invert solver
%[ev1,em1] = SF_Stability(bf,'shift',-2.1i,'m',0,'nev',1,'solver','StabAxi_COMPLEX_m0.edp')

close;
%plot(evG,evG1,ev,ev1)
plot(real(evG), -imag(evG),'b+')
hold on;
%plot(real(evG1),-imag(evG1),'bo')

plot(real(ev),imag(ev),'r+')
hold on;
%scatter(real(ev1),imag(ev1),'ro')

legend('Stab_Axi_Complex.edp, nev=20','Stab_Axi_Complex.edp, nev=1','Stab_Axi_Complex_m0.edp, nev=20','Stab_Axi_Complex_m0.edp, nev=1');