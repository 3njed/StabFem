function value = autorun(isfigures);
% Autorun function for StabFem. 
% This function will produce sample results for the case VESSEL (sloshing modes)
%
% USAGE : 
% autorun(0) -> automatic check
% autorun(1) -> produces the figures used for the manual

%%
close all;
run('../../SOURCES_MATLAB/SF_Start.m');verbosity=10;
system('mkdir FIGURES');
figureformat = 'png';
if(nargin==0) 
    isfigures=0; verbosity=0;
end;
value =0;


%% CHAPTER 1 : flat surface, free condition
gamma=0.002;
rhog=1;
R = 1;
L =2;


density=100;
 %creation of an initial mesh 
 
ffmesh = SF_Mesh('MeshInit_Vessel.edp','Params',[L density]);
ffmesh = SF_Mesh_Deform(ffmesh,'P',0,'gamma',gamma,'rhog',rhog,'typestart','pined','typeend','axis');
%figure();plot(ffmesh.xsurf,ffmesh.ysurf);hold on;quiver(ffmesh.xsurf,ffmesh.ysurf,ffmesh.N0r,ffmesh.N0z); % to plot normal vectors
 

disp('###first test : flat surface, free condition')


[evm1,emm1] =  SF_Stability(ffmesh,'nev',10,'m',1,'shift',2.1i,'typestart','freeV','typeend','axis');
% NB with this value of the shift the modes number n=1,2,3 will be found with index (2,1,3)

evTheory = [1.3606    2.3737    3.1274]; % see script Analytical solution
error1 = abs(imag(evm1(2))/evTheory(1)-1)+abs(imag(evm1(1))/evTheory(2)-1)+abs(imag(evm1(3))/evTheory(3)-1)

if(error1>1e-2) 
    value = value+1 
end

if(isfigures)
figure(1);
plot(imag(evm1),0*real(evm1),'r+');hold on;
legend('flat, free');

figure(2);suptitle('m=1 sloshing modes : Horizontal surface, free condition');hold on;
subplot(1,3,1);
plotFF(emm1(2),'phi.im','title',{'Mode (m,n)= (1,1)',['freq = ',num2str(imag(evm1(2)))]},'symmetry','YA');hold on;plotFF_ETA(emm1(2),'symmetry','YA');
subplot(1,3,2);
plotFF(emm1(1),'phi.im','title',{'Mode (m,n)= (1,2)',['freq = ',num2str(imag(evm1(1)))]},'symmetry','YA');hold on;plotFF_ETA(emm1(1),'symmetry','YA');
subplot(1,3,3);
plotFF(emm1(3),'phi.im','title',{'Mode (m,n)= (1,3)',['freq = ',num2str(imag(evm1(3)))]},'symmetry','YA');hold on;plotFF_ETA(emm1(3),'symmetry','YA');
pos = get(gcf,'Position'); pos(3)=pos(4)*2.6;set(gcf,'Position',pos); % resize aspect ratio
saveas(gcf,'FIGURES/SloshingMmodes_H2_Bo500_flat_free_m1',figureformat);
pause(0.1);
end


%% CHAPTER 2 : flat surface, pined condition

disp('### Second test : flat surface, pined condition')

[evm1,emm1] =  SF_Stability(ffmesh,'nev',10,'m',1,'shift',2.1i,'typestart','pined','typeend','axis');

evTheory = [1.4444    2.4786    3.2671]; % There is a paper by Miles with analytical solution... 
error2 = abs(imag(evm1(2))/evTheory(1)-1)+abs(imag(evm1(1))/evTheory(2)-1)+abs(imag(evm1(3))/evTheory(3)-1)

if(error2>1e-2) 
    value = value+1 
end

if(isfigures)
figure(1);
plot(imag(evm1),0*real(evm1),'b+');hold on;
legend('flat, pined');

figure(3);suptitle('m=1 sloshing modes : Horizontal surface, H/R = 2, Bo = 500, pined condition');hold on;
subplot(1,3,1);
plotFF(emm1(2),'phi.im','title',{'Mode (m,n)= (1,1)',['freq = ',num2str(imag(evm1(2)))]},'symmetry','YA');hold on;
plotFF_ETA(emm1(2),'symmetry','YA');
subplot(1,3,2);
plotFF(emm1(1),'phi.im','title',{'Mode (m,n)= (1,2)',['freq = ',num2str(imag(evm1(1)))]},'symmetry','YA');hold on;
plotFF_ETA(emm1(1),'symmetry','YA');
subplot(1,3,3);
plotFF(emm1(3),'phi.im','title',{'Mode (m,n)= (1,3)',['freq = ',num2str(imag(evm1(3)))]},'symmetry','YA');hold on;
plotFF_ETA(emm1(3),'symmetry','YA');
pos = get(gcf,'Position'); pos(3)=pos(4)*2.6;set(gcf,'Position',pos); % resize aspect ratio
saveas(gcf,'FIGURES/SloshingMmodes_H2_Bo500_flat_pined_m1',figureformat);
pause(0.1);
end


%% Chapter 3 : meniscus (theta = 45?), free conditions

% This case is the same as in Viola, Gallaire & Brun
% cannot work yet in this directory (Selpc not working yet for "block"
% matrices)
% 
% % first compute equilibrium shape and corresponding mesh
% gamma = 0.002;
% thetaE = pi/4;
% hmeniscus = sqrt(2*gamma*(1-sin(thetaE))); % this is the height of the meniscus (valid for large Bond)
% ffmesh = SF_Mesh('MeshInit_Vessel.edp','Params',[L+hmeniscus, density]);
% P = -rhog*hmeniscus; % pressure in the liquid at z=0 (altitude of the contact line) ; the result will be to lower the interface by this ammount 
% ffmesh = SF_Mesh_Deform(ffmesh,'P',P,'gamma',gamma,'rhog',rhog,'typestart','pined','typeend','axis');
% Vol0 = ffmesh.Vol % volume
% alphastart = ffmesh.alpha(1)*180/pi % this should be 225 degrees (angle with respect to vertical = 45 degrees)
% 
% 
% [evm1,emm1] =  SF_Stability(ffmesh,'nev',10,'m',1,'shift',2.1i,'typestart','freeV','typeend','axis');
% 
% evTheory = [1.3587    2.3630    3.1118]; 
% error3 = abs(imag(evm1(2))/evTheory(1)-1)+abs(imag(evm1(1))/evTheory(2)-1)+abs(imag(evm1(3))/evTheory(3)-1)
% 
% if(error3>1e-2) 
%     value = value+1 
% end
% 
% if(isfigures)
% figure(1);
% plot(imag(evm1),0*real(evm1),'g+');hold on;
% legend('meniscus, free');
% 
% figure(4);suptitle('m=1 sloshing modes : Meniscus (45?), H/R = 2, Bo = 500, free condition');hold on;
% subplot(1,3,1);
% plotFF(emm1(2),'phi.im','title',{'Mode (m,n)= (1,1)',['freq = ',num2str(imag(evm1(2)))]},'symmetry','YA');hold on;plotFF_ETA(emm1(2),'Amp',0.05,'symmetry','YA');
% subplot(1,3,2);
% plotFF(emm1(1),'phi.im','title',{'Mode (m,n)= (1,2)',['freq = ',num2str(imag(evm1(1)))]},'symmetry','YA');hold on;plotFF_ETA(emm1(1),'Amp',0.05,'symmetry','YA');
% subplot(1,3,3);
% plotFF(emm1(3),'phi.im','title',{'Mode (m,n)= (1,3)',['freq = ',num2str(imag(evm1(3)))]},'symmetry','YA');hold on;plotFF_ETA(emm1(3),'Amp',0.05,'symmetry','YA');
% pos = get(gcf,'Position'); pos(3)=pos(4)*2.6;set(gcf,'Position',pos); % resize aspect ratio
% saveas(gcf,'FIGURES/SloshingMmodes_H2_Bo500_thetaS45_free_m1',figureformat);
% 
% %% check if boundary condition is correctly verified
% figure(5);title('eta (plain), d eta /ds + K0a cot(alpha) eta (dashed), limit (dotted)');
% DetaDs = diff(emm1(1).eta)./diff(ffmesh.S0);
% plot(ffmesh.xsurf,emm1(1).eta,'-'); hold on; 
% plot((ffmesh.xsurf(1:end-1)+ffmesh.xsurf(2:end))/2,DetaDs,'--');
% plot(ffmesh.xsurf,-ffmesh.K0a.*cot(ffmesh.alpha).*(abs(cot(ffmesh.alpha))<1e2).*emm1(1).eta);
% end

end
