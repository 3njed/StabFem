%Point de d�part pour les m�thodes it�ratives:
%Obtenir les valeurs propres des modes � des nombres de Reynolds choisis 
%Entr�e :   guessS et guessI (coordonn�es suppos�es des modes)
%           ReSi et ReIi (nombres de Reynolds l�g�rement sup�rieurs 
%                       aux nombres de Reynolds critiques recherch�s.)




% 1er mode

bf=SF_BaseFlow(bf,'Re',ReSi); 
bf=SF_Adapt(bf,'Hmax',Hmax); 

[ev00,eigenmode00] = SF_Stability(bf,'m',1,'shift',guessReS,'nev',1,'plotspectrum','yes');   


ev00


% Calcul du bae flow inerm�diaire

ReInt=(ReIi+ReSi)/2;

        bf=SF_BaseFlow(bf,'Re',ReInt); 
        bf=SF_Adapt(bf,'Hmax',Hmax);


%2eme mode

bf=SF_BaseFlow(bf,'Re',ReIi); 
bf=SF_Adapt(bf,'Hmax',Hmax); 

[ev01,eigenmode01] = SF_Stability(bf,'m',1,'shift',guessReI,'nev',1,'plotspectrum','yes');   


ev01
