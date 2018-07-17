% Test script to show the effects of complex mapping

clear all;
% close all;
run('../../SOURCES_MATLAB/SF_Start.m');
figureformat='png'; AspectRatio = 0.56; % for figures
tinit = tic;
verbosity=20;



% parameters for mesh creation 
% Outer Domain 
xinfm=-35.; xinfv=70.; yinf=35;
alpha = 0.0;
method = 'CM';
symm = 1;
symmEig = 0;

BoxXpCoeff = 0.2;
BoxXnCoeff = -0.3;
BoxYpCoeff = 0.15;
LaXpCoeff = 1.01;
LaXnCoeff = 1.01;
LaYpCoeff = 1.01;
LcXpCoeff = 0.4;
LcXnCoeff = 0.5;
LcYpCoeff = 0.35;
gcXpCoeff = 0.0;
gcXnCoeff = 1.0;
gcYpCoeff = 0.0;


mysystem(['echo "xinfm= ' num2str(xinfm) '; xinfv= ' num2str(xinfv) ...
          '; yinf= ' num2str(yinf) ';" > SF_Mesh.edp']); 
mysystem(['echo "alpha= ' num2str(alpha) '; method= \"' method ...
    '\"; symmetryBaseFlow= ' num2str(symm)...
    '; symmetryEigenmode= ' num2str(symmEig) ... 
    '; BoxXpCoeff= ' num2str(BoxXpCoeff) ... 
    '; BoxXnCoeff= ' num2str(BoxXnCoeff) ... 
    '; BoxYpCoeff= ' num2str(BoxYpCoeff) ... 
    '; LaXpCoeff= ' num2str(LaXpCoeff) ... 
    '; LaXnCoeff= ' num2str(LaXnCoeff) ... 
    '; LaYpCoeff= ' num2str(LaYpCoeff) ... 
    '; LcXpCoeff= ' num2str(LcXpCoeff) ... 
    '; LcXnCoeff= ' num2str(LcXnCoeff) ... 
    '; LcYpCoeff= ' num2str(LcYpCoeff) ... 
    '; gcXpCoeff= ' num2str(gcXpCoeff) ... 
    '; gcXnCoeff= ' num2str(gcXnCoeff) ... 
    '; gcYpCoeff= ' num2str(gcYpCoeff) ';" > SF_Method.edp']);

% Ma = 0.5 Nonlinear analysis
Ma = 0.1
Omegac = 0.7272
Rec = 46.94

bf = SF_Init('Mesh_Cylinder.edp',[xinfm,xinfv,yinf]);
bf=SF_BaseFlow(bf,'Re',10,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(1,bf,'typeField1','CxP2P2P1P1P1','Hmax',10);
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
bf=SF_Adapt(1,bf,'typeField1','CxP2P2P1P1P1','Hmax',10);
[evD,emD] = SF_Stability(bf,'shift',+ Omegac*i,'nev',1,'type','D','sym','A','Ma',Ma);
bf=SF_Adapt(2,bf,emD,'typeField1','CxP2P2P1P1P1',...
            'typeField2','CxP2P2P1P1P1','Hmax',5, 'InterpError', 4e-2);

% [evD,emD] = SF_Stability(bf,'shift',+ Omegac*i,'nev',1,'type','D','sym','A','Ma',Ma);
% [evA,emA] = SF_Stability(bf,'shift',+ Omegac*i,'nev',1,'type','A','sym','A','Ma',Ma);
bf=SF_BaseFlow(bf,'Re',Rec,'Mach',Ma,'ncores',1,'type','NEW');
[ev,em] = SF_Stability(bf,'shift',1i*Omegac,'nev',1,'type','S','sym','A','Ma',Ma); % type "S" because we require both direct and adjoint
[wnl,meanflow,mode] = SF_WNL(bf,em,'Retest',47.3,'Normalization','L'); % Here to generate a starting point for the next chapter

figure();
% plot the base flow for Re = 60
bf.xlim = [-1.5 4.5]; bf.ylim=[0,3];
plotFF(bf,'ux','Contour','on','Levels',[0 0]);
%plotFF(bf,'ux');
str = 'Box $$B_3$$ Baseflow with complex mapping';
title(str,'Interpreter','latex');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);

figure();
% plot the eigenmode for Re = Rec
em.xlim = [-2 8]; em.ylim=[0,5];
plotFF(em,'ux1Adj');
str = ' Adjoint Eigenmode with $$\gamma_c = 1.0$$';
title(str,'Interpreter','latex');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);

figure();
% plot the eigenmode for Re = Rec
em.xlim = [-2 8]; em.ylim=[0,5];
plotFF(em,'ux1');
str = 'Eigenmode with $$\gamma_c = 0.0$$';
title(str,'Interpreter','latex');
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);

% plot the mesh (full size)
figure()
plotFF(bf,'mesh');
str = 'Refined mesh';
title(str,'Interpreter','latex');box on; %pos = get(gcf,'Position'); pos(4)=pos(3)*AspectRatio;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 18);
saveas(gca,'Cylinder_Mesh_Full',figureformat); 

