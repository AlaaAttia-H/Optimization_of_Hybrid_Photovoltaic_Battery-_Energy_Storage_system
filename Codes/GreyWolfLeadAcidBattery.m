clc; close all;
tic
WolfPopulation = 100;
imax = 500;
MinNpv = 100;
MaxNpv = 1500;
MinNbat = 100;
MaxNbat = 4000;
DPSPmax = 0.05;

WolfArray = zeros(WolfPopulation, 5);

CostArray = zeros(1, imax + 1);
NpvArray = zeros(1, imax + 1);
NbatArray = zeros(1, imax + 1);

j = 1;
% Generating Initial Population
while j <= WolfPopulation
    Npv = randi([MinNpv, MaxNpv]);
    Nbat = randi([MinNbat, MaxNbat]);
    [WolfFitnessValue, DPSP, TLCC] = costFunction(Npv, Nbat);

    if DPSP < DPSPmax
        WolfArray(j, 1) = WolfFitnessValue;
        WolfArray(j, 2) = Npv;
        WolfArray(j, 3) = Nbat;
        WolfArray(j, 4) = DPSP;
        WolfArray(j, 5) = TLCC;
        j = j + 1;
    end
end

WolfArray = sortrows(WolfArray);
XAlpha = WolfArray(1, 2:3);
XBeta = WolfArray(2, 2:3);
XDelta = WolfArray(3, 2:3);

CostArray(1, 1) = WolfArray(1, 1);
NpvArray(1, 1) = WolfArray(1, 2);
NbatArray(1, 1) = WolfArray(1, 3);

Figures.Main_fig = figure;  %create new figure
subplot(1, 3, 1);  %in the 1st location in the figure
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

figure(Figures.Main_fig);
subplot(1, 3, 2);
Figures.PV = plot(0, NpvArray(1, 1),'co','LineWidth',1.6);
xlim([0, imax]); %define limits in X-direction
ylim([MinNpv, max(NpvArray)*1.1]); %define limits in Y-direction
grid on; %initialize the grid to be on
axis square; %make the axes look like square
xlabel('Number of Iterations'); ylabel('Number of Pv Panels');
title('The Number of Pv Panels'); %give title to figure
legend('Number of PV panels');

figure(Figures.Main_fig);
subplot(1, 3, 3);
Figures.Batt = plot(0, NbatArray(1, 1),'ko','LineWidth',1.6);
xlim([0, imax]); %define limits in X-direction
ylim([MinNbat, max(NbatArray)*1.1]); %define limits in Y-direction
grid on; %initialize the grid to be on
axis square; %make the axes look like square
xlabel('Number of Iterations'); ylabel('Number of Batteries');
title('The Number of Batteries'); %give title to figure
legend('Number of Batteries');



for i = 1:1:imax
    j = 4;
    while j <= WolfPopulation
        % Gnerating A, C, and a values.
        r1 = (1-0).*rand(1, 2, 'double') + 0;
        r2 = (1-0).*rand(1, 2, 'double') + 0;

        a = 2 - (2/imax) * i;
        A = 2 * r1 * a - a * [1 1];
        C = 2 * r2;

        MagnitudeA = sqrt(sum(A.^2));

        if  MagnitudeA < 1
            % Generate new solution using shrinking encirclement.
            Dalpha = C .* XAlpha - WolfArray(j, 2:3);
            Dbeta = C .* XBeta - WolfArray(j, 2:3);
            Ddelta = C .* XDelta - WolfArray(j, 2:3);
            X1 = XAlpha - MagnitudeA * Dalpha;
            X2 = XBeta - MagnitudeA * Dbeta;
            X3 = XDelta - MagnitudeA * Ddelta;

            WolfCoordinates = abs((X1 + X2 + X3)/3);

            if WolfCoordinates(1, 1) > MaxNpv || ...
                    WolfCoordinates(1, 1) < MinNpv
                WolfCoordinates(1, 1) = randi([MinNpv, MaxNpv]);
            end

            if WolfCoordinates(1, 2) > MaxNbat || ...
                    WolfCoordinates(1, 2) < MinNbat
                WolfCoordinates(1, 2) = randi([MinNbat, MaxNbat]);
            end

            [WolfFitnessValue, DPSP, TLCC] = costFunction...
                (WolfCoordinates(1, 1),  WolfCoordinates(1, 2));

            if DPSP < DPSPmax
                WolfArray(j, 1) = WolfFitnessValue;
                WolfArray(j, 2) = WolfCoordinates(1, 1);
                WolfArray(j, 3) = WolfCoordinates(1, 2);
                WolfArray(j, 4) = DPSP;
                WolfArray(j, 5) = TLCC;
                j = j + 1;
            end

        else
            Dalpha = C .* XAlpha - WolfArray(j, 2:3);
            Dbeta = C .* XBeta - WolfArray(j, 2:3);
            Ddelta = C .* XDelta - WolfArray(j, 2:3);
            X1 = XAlpha + MagnitudeA * Dalpha;
            X2 = XBeta + MagnitudeA * Dbeta;
            X3 = XDelta + MagnitudeA * Ddelta;
            WolfCoordinates = abs((X1 + X2 + X3)/3);

            if WolfCoordinates(1, 1) > MaxNpv || ...
                    WolfCoordinates(1, 1) < MinNpv
                WolfCoordinates(1, 1) = randi([MinNpv, MaxNpv]);
            end

            if WolfCoordinates(1, 2) > MaxNbat || ...
                    WolfCoordinates(1, 2) < MinNbat
                WolfCoordinates(1, 2) = randi([MinNbat, MaxNbat]);
            end

            [WolfFitnessValue, DPSP, TLCC] = costFunction...
                (WolfCoordinates(1, 1),  WolfCoordinates(1, 2));

            if DPSP < DPSPmax
                WolfArray(j, 1) = WolfFitnessValue;
                WolfArray(j, 2) = WolfCoordinates(1, 1);
                WolfArray(j, 3) = WolfCoordinates(1, 2);
                WolfArray(j, 4) = DPSP;
                WolfArray(j, 5) = TLCC;
                j = j + 1;
            end
        end
    end

    WolfArray = sortrows(WolfArray);
    XAlpha = WolfArray(1, 2:3);
    XBeta = WolfArray(2, 2:3);
    XDelta = WolfArray(3, 2:3);

    % save the cost of alpha solution of this iteration
    CostArray(1, i + 1) = WolfArray(2, 1);
    set(Figures.Cost,'XData',0:1:i,'YData', CostArray(1, 1 : i + 1));
    subplot(1, 3, 1);
    title(['Current Cost Value: ' num2str(CostArray(1, i + 1))]);

    NpvArray(1, i + 1) = XAlpha(1, 1);
    set(Figures.PV,'XData',0:1:i,'YData', NpvArray(1, 1 : i + 1));
    subplot(1, 3, 2);
    title(['Current Number of PV panels: ' num2str(NpvArray(1, i+1))]);

    NbatArray(1, i + 1) = XAlpha(1, 2);
    set(Figures.Batt,'XData',0:1:i,'YData', NbatArray(1, 1 : i + 1));
    subplot(1, 3, 3);
    title(['Current Number of Batteries: ' num2str(NbatArray(1, i+1))]);

    pause(0.05);
end

timeElapsed = toc;
disp(WolfArray(1, 1));
disp(WolfArray(1, 2));
disp(WolfArray(1, 3));
disp(WolfArray(1, 4));
disp(WolfArray(1, 5));
disp(timeElapsed);