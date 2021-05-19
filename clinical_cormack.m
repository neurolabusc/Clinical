function [kUninterestingDarkUnits, kInterestingMidUnits] = clinical_cormack()
%set invertable scaling between Hounsfield and Cormack Units
kUninterestingDarkUnits = 900; % e.g. -1000..-100
kInterestingMidUnits = 200; %e.g. unenhanced CT: -100..+100
%kInterestingMidUnits = 400; %e.g. unenhanced CT: -100..+300