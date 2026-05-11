function [FittnessValue, DPSP, TLCC] = costFunction(Npv, NBat)

syms k

I = 0.1325; % Interest Rate
PVCost = 614; % PV panel cost
InvertersCost = 2000; % Inverter cost
BatCost = 153.4; % Lead Acid Battery cost

NIN = ceil((0.04108 * Npv) / 2.85); % Number of inverters

CRF = (I*(1+I)^20)/(((1+I)^20)-1); % Capital recovery factor for one year

% Maintainance Cost of Pv Panels
MCPV = Npv * 0.02 * PVCost * symsum(1/(1+I)^k, k, 0, 19) * CRF;
% Capital Cost of Pv Panels
CCPV = CRF * Npv * PVCost;
% Life Cycle Cost of Pv Panels
LCCPV = round(CCPV + MCPV);

% Maintainance Cost of Inverters
MCIN = NIN * 0.02 * InvertersCost * symsum(1/(1+I)^k, k, 0, 19) * CRF;
% Present Worth of Inverter
PWIN = InvertersCost * ((1/(1+I)^0) + (1/(1+I)^10));
% Capital Cost of Inverters
CCIN = CRF * NIN * PWIN;
% Life Cycle Cost of Inverters
LCCIN = round(CCIN + MCIN);

% Maintainance Cost of Lead Acid Batteries
MCBAT = NBat * 0.02 * BatCost;
% Present Worth of Lead Acid Battery
PWBAT = BatCost * symsum(1/((1+I)^(2*k)), k, 0, 9);  %Change This based on battery Type
% Capital Cost of Lead Acid Batteries
CCBAT = CRF * NBat * PWBAT;
% Life Cycle Cost of Lead Acid Batteries
LCCBAT = round(CCBAT + MCBAT);

% Total Life Cycle Cost
TLCC = LCCPV + LCCIN + LCCBAT;

% The Energy of Batteries and PV panels

NCBat = 1.3; % Nominal Capacity of the battery
DOD = 0.6; % Depth of discharge
SelfDischarge = 0.02; % Self Discharge of Lead Acid Battery
Invertereff = 0.95; % Inverter Efficiency
Bateff = 0.85; % Lead Acid Battery Efficiency

EbatInit = 0.52; % Assuming each battery is 50% charged

% Min energy that can be stored in all batteries
MinEbat = ((1 - DOD) * NCBat) * NBat;
% MAx energy that can be stored in all batteries
MaxEbat = NCBat * NBat;
% Total energy stored in the batteries initially
Ebat = NBat * EbatInit;

TotalDPS = 0;
EloadSum = 0;

% EG is random (genrated power) values based on minimmum and maximmum
% values that one Pv Panel can generate in one hour for a year, and it
% ranges between (0.04 - 0.063) kWh.
EG = cell2mat(struct2cell(load('VAL.mat', 'EG')));

% EL is random (load power) values for a year based on minimmum
% and maximmum values of load in 100 houses in egypt, it ranges
% between (33 - 45) kWh.
EL = cell2mat(struct2cell(load('VAL.mat', 'EL')));

for i = 1:1:8760

    Egen = EG(i) * Npv; % Generated Power In hour (i)
    Eload = EL(i); % Load Demand in hour (i)

    % If Generated Power exceeds Load Demand, charge the battery.
    if Egen > Eload

        %Battery Charging eq:
        Ebat = Ebat * (1 - SelfDischarge) + ...
            (Egen - (Eload/Invertereff)) * Bateff;

        % Checking if the excess power is larger than its
        % Nominal capacity (Max), it will be just lost.

        if Ebat > MaxEbat
            Ebat = MaxEbat;
        end

        DPS = 0;

        % If Generated Power is not sufficient for Load Demand, supply
        % from batteries (discharge the battery).
    else
        % Calculating the level of energy in all batteries after
        % discharging. Battery discharging eq:
        BAF = Ebat * (1 - SelfDischarge) -...
            ((Eload/Invertereff) - Egen) / Bateff;

        if BAF < MinEbat
            % Batteries couldn't satisfy shortage in power, so
            % Deficit in Power Supply is calculated.
            DPS = Eload - (Egen + Ebat - MinEbat) * Invertereff;
        else
            % Batteries can satisfy the load, when there was shortage
            % in the generated power.
            Ebat = BAF;
            DPS = 0;
        end

    end
    % The Total Deficit in Power Supply in a year.
    TotalDPS = TotalDPS + DPS;
    % The Total Load demanded in a year.
    EloadSum = EloadSum + Eload;
end

% Deficit in Power Supply Probability
DPSP = TotalDPS / EloadSum;
FittnessValue = TLCC + DPSP * 10^5;
end