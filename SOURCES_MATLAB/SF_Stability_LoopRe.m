function [EV,Rec,omegac] = SF_Stability_LoopRe(bf,Re_Range,guess_ev,varargin)
%
% Construction of a "branch" lambda(Re) with a loop over Re.
%
% Usage : EV =  SF_Stability_LoopRe(bf,Re_range,guess_ev, [Params, Values] )
%
%  [EV,Rec,Omegac] =  SF_Stability_LoopRe(bf,Re_range,guess_ev, [Params, Values] ) 
%
% Re_range is an array of values, typically [Restart:Restep:Reend]
% guess_ev is an approximate value of the eigenvalue at Re=Re_Range(1)
% (will be used as guess for first step, then continuation mode will be used)
%
% in three-output mode Rec and Omegac are the threshold values possibly
% detected on the interval.
%
% The next parameters are couple of [Param, Values] accepted by SF_Stability
% (do not specify the shift and nev; nev will be set to 1)
%
% Example : EV = SF_Stability_LoopRe(bf,[40 : 10 : 100],'m',1,'type','D')
%
% Option 'plot' allows to plot results. Specify  either 'yes' or a color.
%
% This program is part of the StabFem project distributed under gnu licence
% Copyright D. Fabre, october 9 2018
%


EV = NaN*ones(size(Re_Range));
% first step using guess
guessI = guess_ev;
bf=SF_BaseFlow(bf,'Re',Re_Range(1));
ev = SF_Stability(bf,'shift',guessI,'nev',10,varargin{:});% we take nev = 10 to make sure the first computation will be good... -> now made outside
ev = SF_Stability(bf,'shift',ev(1),'nev',1,varargin{:});% to initiate the cont mode
EV(1)= ev;
% then loop...


for i=2:length((Re_Range))
        Re = Re_Range(i);
        bf = SF_BaseFlow(bf,'Re',Re);
        [ev,em] = SF_Stability(bf,'nev',1,'shift','cont',varargin{:});
        if(em.iter==-1)
            mydisp(2,['Warning in SF_Stability_LoopRe : eigenvalue solver failed for Re = ',num2str(Re)]);
            break;
        end
        disp(['Re = ',num2str(Re),' : lambda = ',num2str(ev)]);
        EV(i) = ev;
end

% check if 'colorplot' is part of options...
 colorplot='noplot';
for i=1:nargin-3
    if(strcmpi(varargin{i},'plot'))
       colorplot = varargin{i+1}; % defined at the bottom
    end    
end
if(strcmp(colorplot,'yes'))
   colorplot='r';
end


    RePLOT = Re_Range; %[Re_Range(1:Ic-1) Rec Re_Range(Ic:end)];
    EVPLOT = EV; %[EV(1:Ic-1) 1i*omegac EV(Ic:end)];

% determines a threshold if required
    Rec = [];
    Icc = find(real([EV(1) EV]).*real([EV EV(end)])<0);omegac=[];Rec=[];
    if(isempty(Icc))
        Rec = NaN;
        omegac = NaN;
    else
        for j=1:length(Icc)
            Ic = Icc(j);
            omegac = [omegac imag((EV(Ic-1)*real(EV(Ic))-EV(Ic)*real(EV(Ic-1)))/(real(EV(Ic))-real(EV(Ic-1))))]; 
            Rec = [Rec (Re_Range(Ic-1)*real(EV(Ic))-Re_Range(Ic)*real(EV(Ic-1)))/(real(EV(Ic))-real(EV(Ic-1)))];
            EVPLOT = [EVPLOT(1:Ic-1+j-1) , 1i*omegac, EVPLOT(Ic+j-1:end)]; % to draw the curves including threshold point
            RePLOT = [RePLOT(1:Ic-1+j-1) , Rec, RePLOT(Ic+j-1:end)];
        end
    end


% plot results if required...
if(strcmp(colorplot,'noplot')==0)
subplot(2,1,1);hold on;
plot(RePLOT,real(EVPLOT),[colorplot,'-'],'linewidth',2);
plot(RePLOT,0*real(EVPLOT),'k:','linewidth',1);
xlabel('Re');ylabel('\sigma'); box on;

subplot(2,1,2);hold on;
plot(RePLOT,imag(EVPLOT),[colorplot '--'],'linewidth',1);
plot(RePLOT(real(EVPLOT)>=0),imag(EVPLOT(real(EVPLOT)>=0)),[colorplot '-'],'linewidth',2);
xlabel('Re');ylabel('\omega') ; box on;   

subplot(2,1,1);hold on;
plot(Rec,0*Rec,[colorplot,'o'],'linewidth',2);
subplot(2,1,2);hold on;
plot(Rec,omegac,[colorplot,'o'],'linewidth',2);
end

pause(0.1);
end


    
