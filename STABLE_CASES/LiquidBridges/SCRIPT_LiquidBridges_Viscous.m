%%
%
% IMPORTANT WARNING : THIS PART OF THE CODE IS STILL UNDER DEVELOPMENT
%

function [] = LiquidBridges()
%close all;
run('../../SOURCES_MATLAB/SF_Start.m');
system('mkdir FIGURES');
figureformat = 'png';
%%
%%%%%% CHAPTER 0 : creation of initial mesh for cylindrical bridge, L=4

L = 4;gamma=1;rhog=0;
density=20;


%% parametres physiques manip chireux
muPHYS = 1.0000e-06;
rhoPHYS = 1;
gammaPHYS = 0.07
RPHYS = 180e-6;
Oh = muPHYS/sqrt(rhoPHYS*gammaPHYS*RPHYS)


%%
%%%%% CHAPTER 3 : Construction of equilibrium shapes WITH VOLUME
%%%%% CORRESPONDING TO THAT OF TOUCHING SPHERES (Chireux et al.)
%%%%% 

m=0;
nu = 0;
color = 'r--';
%tracebranches(m,nu,color);
pause(0.1);

m=1;
nu =0;
color = 'b--';
%tracebranches(m,nu,color);
pause(0.1);

m=0;
nu = 1e-2;
color = 'ro';
tracebranches(m,nu,color);
pause(0.1);

m=1;
nu = 1e-2;
color = 'bo';
tracebranches(m,nu,color);
pause(0.1);

m=0;
nu = Oh;
color = 'r+';
tracebranches(m,nu,color);
pause(0.1);

m=1;
nu = Oh;
color = 'b+';
tracebranches(m,nu,color);
pause(0.1);


figure(32);
title('frequencies of m=0 (red) and m=1 (blue) modes vs. L');
xlabel('L/R');ylabel('\omega_r');
ylim([0 6]);
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*1;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 14);
saveas(gca,'FIGURES/Bridges_NV_coal_omega',figureformat);

figure(33);
title('damping rates of m=0 (red) and m=1 (blue) modes vs. L');
xlabel('L/R');ylabel('\omega_i/\Omega_R');
ylim([-.1 0 ]);
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*1;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 14);
saveas(gca,'FIGURES/Bridges_NV_L3_5_coal_omegaL',figureformat);
 
figure(34);
title('damping rates of m=0 (red) and m=1 (blue) modes vs. L');
xlabel('L/R');ylabel('\beta/\beta_R');
ylim([0 35]);
box on; pos = get(gcf,'Position'); pos(4)=pos(3)*1;set(gcf,'Position',pos); % resize aspect ratio
set(gca,'FontSize', 14);
saveas(gca,'FIGURES/Bridges_NV_L3_5_coal_L',figureformat);
end





%%
function [] = tracebranches(m,nu,color) 

figureformat = 'png';gamma=1;rhog = 0;
density=10;
% CHAPTER 3a : First loop in the interval [3.5,7] (increasing values)
L = 3.5;
ffmesh = SF_Mesh('MeshInit_Bridge.edp','Params',[0 L density]); %% creation of an initial mesh (cylindrical liquid bridge)
V = pi*L/2*(1+L^2/12);
ffmesh = SF_Mesh_Deform(ffmesh,'V',V,'typestart','pined','typeend','pined','gamma',gamma,'rhog',rhog);
evm0 =  SF_Stability(ffmesh,'nev',30,'m',m,'nu',nu,'shift',5i); % starting point

tabL = 3.5:.1:7; Lans= tabL(1);
tabV = [];
tabP = [];
tabEVm0 = []; tabEVm1=[]; 
for L = tabL
    L
    ffmesh = SF_MeshStretch(ffmesh,1,L/Lans);
    V = pi*L/2*(1+L^2/12);
    ffmesh = SF_Mesh_Deform(ffmesh,'V',V,'typestart','pined','typeend','pined','gamma',gamma,'rhog',rhog);
    tabV = [tabV ffmesh.Vol]; tabP = [tabP ffmesh.P0];
    evm0 =  SF_Stability(ffmesh,'nev',30,'m',m,'nu',nu,'shift',5i,'sort','cont');
    tabEVm0 = [tabEVm0 evm0];
    Lans = L;
end
figure(32);hold on;
for num=1:15
    tabL
    tabEVm0(num,:)
    plot(tabL,imag(tabEVm0(num,:)),color);%,tabL);%imag(tabEVm1(num,:)),'bo-');
end
figure(33);hold on;
for num=1:5
    plot(tabL,real(tabEVm0(num,:)),color)%,tabL,%,imag(tabEVm1(num,:)).*tabL.^1.5,'bo-');
end
figure(34);hold on;
for num=1:15
    plot(tabL,-real(tabEVm0(num,:))/nu*(abs(real(tabEVm0(num,:)))>1e-4),color)%,tabL,%,imag(tabEVm1(num,:)).*tabL.^1.5,'bo-');
end

% CHAPTER 3ab : First loop in the interval [3.5,2] (decreasing values)
L = 3.5;
ffmesh = SF_Mesh('MeshInit_Bridge.edp','Params',[0 L density]); %% creation of an initial mesh (cylindrical liquid bridge)
V = pi*L/2*(1+L^2/12);
ffmesh = SF_Mesh_Deform(ffmesh,'V',V,'typestart','pined','typeend','pined','gamma',gamma,'rhog',rhog);
evm0 =  SF_Stability(ffmesh,'nev',30,'m',m,'nu',nu,'shift',5i);

tabL = 3.5:-.1:2; Lans= tabL(1);
tabV = [];
tabP = [];
tabEVm0 = []; tabEVm1=[]; 
for L = tabL
    L
    ffmesh = SF_MeshStretch(ffmesh,1,L/Lans);
    V = pi*L/2*(1+L^2/12);
    ffmesh = SF_Mesh_Deform(ffmesh,'V',V,'typestart','pined','typeend','pined','gamma',gamma,'rhog',rhog);
    tabV = [tabV ffmesh.Vol]; tabP = [tabP ffmesh.P0];
    evm0 =  SF_Stability(ffmesh,'nev',30,'m',m,'nu',nu,'shift',5i,'sort','cont');
    tabEVm0 = [tabEVm0 evm0];
    Lans = L;
end
figure(32);hold on;
for num=1:15
    plot(tabL,imag(tabEVm0(num,:)),color);
end
figure(33);hold on;
for num=1:15
    plot(tabL,real(tabEVm0(num,:)),color);
end
figure(34);hold on;
for num=1:15
    plot(tabL,-real(tabEVm0(num,:))/nu*(abs(real(tabEVm0(num,:)))>1e-4),color);
end

end


