clc; close all;
tic

MinNpv = 100;
MaxNpv = 1500;
MinNbat = 100;
MaxNbat = 4000;
DPSPmax = 0.05;
imax = 700;
i = 1;
Ti = 1000;
Tf = 0.001;
T = Ti;
alpha = 0.75;

CostArray = zeros(1, imax + 1);
Temp_fcn_curve = zeros(1, imax + 1);
NpvArray = zeros(1, imax + 1);
NbatArray = zeros(1, imax + 1);

Npv = randi([MinNpv, MaxNpv]);
Nbat = randi([MinNbat, MaxNbat]);
% Random Initial Feasible Solution.
CurrentSolution = [Npv Nbat];

% Cost function of the "Initial Soltuion".
[CurrentFitnessValue, CurrentDPSP, CurrentTLCC] ...
    = costFunction(CurrentSolution(1, 1), CurrentSolution(1, 2));

% Initializng the Best Solution
BestSolution = CurrentSolution;
BestFitnessValue = CurrentFitnessValue;
BestDPSP = CurrentDPSP;
BestTLCC = CurrentTLCC;

% Intializning the Curve.
CostArray(1, 1) = CurrentFitnessValue;
%save the temp of initial solution
Temp_fcn_curve(1, 1) = Ti;
NpvArray(1, 1) = Npv;
NbatArray(1, 1) = Nbat;

Figures.Main_fig = figure;  %create new figure
subplot(2, 2, 1);  %in the 1st location in the figure
%plot the initial cost
Figures.Cost = plot(0, CostArray(1, 1), 'mo', 'LineWidth', 1.6);
%define limits in X-direction
xlim([0,imax]);
%define limits in Y-direction
ylim([0,max(CostArray)*1.1]);
%initialize the grid to be on
grid on;
%make the axes look like square
axis square;
xlabel('Number of Iterations'); ylabel('Cost function');
%give title to figure
title('The Cost Function');
legend('Cost Function');

figure(Figures.Main_fig);  %access the main figure
subplot(2, 2, 2);
Figures.Temp = plot(0,Temp_fcn_curve(1, 1),'bo','LineWidth',1.6); %plot the initial temperature
xlim([0,imax]); %define limits in X-direction
ylim([0,Ti*1.1]); %define limits in Y-direction
grid on; %initialize the grid to be on
axis square; %make the axes look like square
xlabel('Number of Iterations'); ylabel('Temperature (Celcius)');
title('The Temperature Function');  %give title to figure
legend('Temp function (C)');

figure(Figures.Main_fig);
subplot(2, 2, 3);
Figures.PV = plot(0, NpvArray(1, 1),'co','LineWidth',1.6);
xlim([0, imax]); %define limits in X-direction
ylim([MinNpv, max(NpvArray)*1.1]); %define limits in Y-direction
grid on; %initialize the grid to be on
axis square; %make the axes look like square
xlabel('Number of Iterations'); ylabel('Number of Pv Panels');
title('The Number of Pv Panels'); %give title to figure
legend('Number of PV panels');

figure(Figures.Main_fig);
subplot(2, 2, 4);
Figures.Batt = plot(0, NbatArray(1, 1),'ko','LineWidth',1.6);
xlim([0, imax]); %define limits in X-direction
ylim([MinNbat, max(NbatArray)*1.1]); %define limits in Y-direction
grid on; %initialize the grid to be on
axis square; %make the axes look like square
xlabel('Number of Iterations'); ylabel('Number of Batteries');
title('The Number of Batteries'); %give title to figure
legend('Number of Batteries');

while i <= imax
    r1 = randi([-50, 50]);
    r2 = randi([-300, 300]);
    NewSolution(1, 1) = CurrentSolution(1, 1) + r1;
    NewSolution(1, 2) = CurrentSolution(1, 2) + r2;

    while NewSolution(1, 1) > MaxNpv || NewSolution(1, 1) < MinNpv
        r1 = randi([-50, 50]);
        NewSolution(1, 1) = CurrentSolution(1, 1) + r1;
    end

    while NewSolution(1, 2) > MaxNbat || NewSolution(1, 2) < MinNbat
        r2 = randi([-300, 300]);
        NewSolution(1, 2) = CurrentSolution(1, 2) + r2;
    end

    [NewFitnessValue, NewDPSP, NewTLCC] = ...
        costFunction(NewSolution(1, 1), NewSolution(1, 2));

    % Solution should not be accepted if DPSP > DPSPmax and a new
    % random feasible solution should be generated until constrain is
    % satisfied.
    if NewDPSP < DPSPmax
        NewFitnessValue = round(NewFitnessValue);
        % If Fitness Value of new solution is less than the previous one,
        % accept the solution.
        if NewFitnessValue - CurrentFitnessValue < 0
            CurrentSolution = NewSolution;
            CurrentFitnessValue = NewFitnessValue;
            CurrentDPSP = NewDPSP;
            CurrentTLCC = NewTLCC;

            % If Fitness Value of new solution is larger than the previous one,
            % generate probability to accept or reject this new solution.
        else
            deltaFV = NewFitnessValue - CurrentFitnessValue;
            p = exp(-deltaFV/T);
            r = rand(0,1);
            if r < p
                CurrentSolution = NewSolution;
                CurrentFitnessValue = NewFitnessValue;
                CurrentDPSP = NewDPSP;
                CurrentTLCC = NewTLCC;
            end
        end
        i = i + 1;
    end

    % Updating the best solution:
    if CurrentFitnessValue < BestFitnessValue
        BestSolution = CurrentSolution;
        BestFitnessValue = CurrentFitnessValue;
        BestDPSP = CurrentDPSP;
        BestTLCC = CurrentTLCC;
    end

    CostArray(1, i + 1) = CurrentFitnessValue;
    set(Figures.Cost,'XData',0:1:i,'YData', CostArray(1, 1 : i + 1));
    subplot(2, 2, 1);
    title(['Current Cost Value: ' num2str(CostArray(1, i + 1))]);

    T = Ti * ((alpha) ^ i);
    Temp_fcn_curve(1, i + 1) = T;
    set(Figures.Temp,'XData',0:1:i,'YData',Temp_fcn_curve(1, 1 : i + 1));
    subplot(2, 2, 2);
    title(['Current Temperature: ' num2str(T)]);

    NpvArray(1, i + 1) = CurrentSolution(1, 1);
    set(Figures.PV,'XData',0:1:i,'YData', NpvArray(1, 1 : i + 1));
    subplot(2, 2, 3);
    title(['Current Number of PV panels: ' num2str(NpvArray(1, i+1))]);

    NbatArray(1, i + 1) = CurrentSolution(1, 2);
    set(Figures.Batt,'XData',0:1:i,'YData', NbatArray(1, 1 : i + 1));
    subplot(2, 2, 4);
    title(['Current Number of Batteries: ' num2str(NbatArray(1, i+1))]);

    pause(0.05);
end

timeElapsed = toc;
disp(BestSolution(1, 1));
disp(BestSolution(1, 2));
disp(BestTLCC);
disp(BestDPSP);
disp(BestFitnessValue);
disp(timeElapsed);



