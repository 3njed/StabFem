clear all
format shortG


run('/Users/theomouyen/Documents/GitHub/StabFem/SOURCES_MATLAB/SF_Start.m');
close all;

%ffdatadir = './WORK/'; %% to be fixed : this should be "./WORK" but some of the solvers are not yet operational

%%% PARAMETRES

Rbody = 0.5; Lel = 1; Lcyl = 5;Rpipe = 0.75; xmin = -10; xmax = 100;


Lbody=Lcyl+Lel;
bctype = 1;

Hmax = 0.25; %taille max des mailles
n=2; %densit� du m�illage: voir meshInit_BluntbodyInTube.edp

%%% FIN PARAMETERS

    disp('computing base flow and adapting mesh');
    
    Re_start = [10,30,60,100,200]; 
    bf = SF_Init('meshInit_BluntBodyInTube.edp',[Rbody Lel Lcyl Rpipe xmin xmax bctype]); 
    for Rei = Re_start
        bf=SF_BaseFlow(bf,'Re',Rei);
        bf=SF_Adapt(bf,'Hmax',Hmax);
        disp(['delta min : ',num2str(bf.mesh.deltamin)]);
        disp(['delta max : ',num2str(bf.mesh.deltamax)]);
    end
   
% compute a spectrum  

%  [ev1,eigenmode1] = SF_Stability(bf,'m',1,'shift',0,'nev',10,'plotspectrum','yes');   
%  [ev2,eigenmode2] = SF_Stability(bf,'m',1,'shift',0.4i,'nev',10,'plotspectrum','yes');   
%  [ev3,eigenmode3] = SF_Stability(bf,'m',1,'shift',0.8i,'nev',10,'plotspectrum','yes');   
%  [ev4,eigenmode4] = SF_Stability(bf,'m',1,'shift',1.2i,'nev',10,'plotspectrum','yes');   
%  [ev5,eigenmode5] = SF_Stability(bf,'m',1,'shift',1.6i,'nev',10,'plotspectrum','yes');   
%  [ev6,eigenmode6] = SF_Stability(bf,'m',1,'shift',2i,'nev',10,'plotspectrum','yes');   
%  [ev7,eigenmode7] = SF_Stability(bf,'m',1,'shift',2.4i,'nev',10,'plotspectrum','yes');   
% 
%  pause(0.1);
% 
% evtot=[ev1 ev2 ev3 ev4 ev5 ev6 ev7]

Spectrum_Evolution;
%% Guess des nombres de Reynolds

ReSi=150;
guessReS=0i;

ReIi=200;
guessReI=1.7i;

Readjust;           %Pour la premi�re paire de modes

%% COMPUTING THE UNSTEADY BRANCH (going backwards)
ReIi;
ReIf=ReIi-50;
    Re_RangeI = [ReIi:-10:ReIf];EVI = [];
        guessI = ev01;
        bf=SF_BaseFlow(bf,'Re',ReIi);
        [ev,em] = SF_Stability(bf,'m',1,'shift',guessI,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        
        for Re = Re_RangeI
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        EVI = [EVI ev];
        end  
 
%% COMPUTING THE STEADY BRANCH (going backwards)
ReSi;
ReSf=ReSi-50;
    Re_RangeS = [ReSi:-10:ReSf];EVS = [];
        guessS = ev00;
        bf=SF_BaseFlow(bf,'Re',ReSi);
        [ev,em] = SF_Stability(bf,'m',1,'shift',guessS,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        
        for Re = Re_RangeS
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        EVS = [EVS ev];
        end  
     
 %% R�sultat 1:
 
[ReCS,ReCI,ImCI]=Recritique(guessReS,guessReI,EVS,EVI,Re_RangeS,Re_RangeI,bf,Hmax); 

M1= [[1 2]' [bctype bctype]' [Rpipe Rpipe]' [Lbody Lbody]' [ReCS ReCI]' [0  ImCI]'];
save(['dataC' num2str(bctype) '_E2_Rp' num2str(Rpipe*100) 'LD' num2str(Lbody*100) '(1).txt'],'M1','-ascii');

        
%% Deuxi�me couple
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
ReIi=375;
guessReI=2.3i;

ReSi=400;
guessReS=0i;

Readjust2;        % Pour la deuxi�me paire de modes       

%% COMPUTING THE UNSTEADY BRANCH (going backwards)
ReIi;
ReIf=ReIi-50;
    Re_RangeI = [ReIi:-10:ReIf];EVI = [];
        guessI = ev01;
        bf=SF_BaseFlow(bf,'Re',ReIi);
        [ev,em] = SF_Stability(bf,'m',1,'shift',guessI,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        
        for Re = Re_RangeI
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        EVI = [EVI ev];
        end  
 
%% COMPUTING THE STEADY BRANCH (going backwards)
ReSi;
ReSf=ReSi-50;
    Re_RangeS = [ReSi:-10:ReSf];EVS = [];
        guessS = ev00;
        bf=SF_BaseFlow(bf,'Re',ReSi);
        [ev,em] = SF_Stability(bf,'m',1,'shift',guessS,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        bf = SF_Adapt(bf,em,'Hmax',Hmax);
        [ev,em] = SF_Stability(bf,'m',1,'shift',ev,'nev',1);
        
        for Re = Re_RangeS
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'m',1,'nev',1,'shift','cont');
        EVS = [EVS ev];
        end  
     
 %% R�sultat 2: 
 

[ReCS,ReCI,ImCI]=Recritique(guessReS,guessReI,EVS,EVI,Re_RangeS,Re_RangeI,bf,Hmax);

M2= [[3 4]' [bctype bctype]' [Rpipe Rpipe]' [Lbody Lbody]' [ReCS ReCI]' [0  ImCI]'];
save(['dataC' num2str(bctype) '_E2_Rp' num2str(Rpipe*100) 'LD' num2str(Lbody*100) '(2).txt'],'M2','-ascii');


