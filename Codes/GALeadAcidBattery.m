clc; close all; clear;
tic

m = 200;
pe = ceil(0.2* m);
pc = ceil(0.7 * m);
pm = m - (pe + pc);

K = 20;
alpha = 0.75;

imax = 1000;
MinNpv = 100;
MaxNpv = 1500;
MinNbat = 100;
MaxNbat = 4000;
DPSPmax = 0.05;

PopArray = zeros(m ,5);
CrossOver = zeros(pc, 5);
CostArray = zeros(1, imax + 1);
NpvArray = zeros(1, imax + 1);
NbatArray = zeros(1, imax + 1);
Mutation = zeros(pm, 5);
    
j = 1;
% Generating Initial Population
while j <= m
    Npv = randi([MinNpv MaxNpv]);
    Nbat = randi([MinNbat MaxNbat]);
    [PopulationFitnessValue, DPSP, TLCC] = costFunction(Npv, Nbat);

    if DPSP < DPSPmax
        PopArray(j, 1) = PopulationFitnessValue;
        PopArray(j, 2) = Npv;
        PopArray(j, 3) = Nbat;
        PopArray(j, 4) = DPSP;
        PopArray(j, 5) = TLCC;
        j = j + 1;
    end
end

PopulationSorted = sortrows(PopArray);
BestSolution = PopulationSorted(1, :);
CostArray(1,1) = PopArray(1, 1);
NpvArray(1, 1) = PopArray(1, 2);
NbatArray(1, 1) = PopArray(1, 3);

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
    %Elite Generation
    Elite =  PopulationSorted(1:pe, 1:5);

    %Mutation Generation using Random Resetting
    MutationCandidates = PopulationSorted(pc+pe+1:pc+pe+pm, 1:5);
    row = pc + pe;

    q = 1;
    while q < pm 
        % Choose random gene and change it with random feasible gene.
        col = randi([2, 3]);

        if col == 2
            NPv = randi([MinNpv, MaxNpv]);
            NBat = PopArray(row, 3);
        else
            NBat = randi([MinNbat, MaxNbat]);
            NPv = PopArray(row, 2);
        end

        [PopulationFitnessValue, DPSP, TLCC] = costFunction(NPv, NBat);

        if DPSP < DPSPmax
        Mutation(q, 1) = PopulationFitnessValue;
        Mutation(q, 2) = NPv;
        Mutation(q, 3) = NBat;
        Mutation(q, 4) = DPSP;
        Mutation(q, 5) = TLCC;
        q = q + 1;
        row = row + 1;
        end
    end

    %Cross Over Process
    k = 1;
    while k < pc + 1
        %parents selection using K-way tournament where K = 20
        Index = randi([1, m], 2*K, 1);
        Index = unique(Index);
        s = size(Index, 1);
        Tournament = zeros(s-1, 5);
        n = 1;

        while n < s
            Tournament(n, 1) = PopArray(Index(n, 1), 1);
            Tournament(n, 2) = PopArray(Index(n, 1), 2);
            Tournament(n, 3) = PopArray(Index(n, 1), 3);
            Tournament(n, 4) = PopArray(Index(n, 1), 4);
            Tournament(n, 5) = PopArray(Index(n, 1), 5);
            n = n + 1;
        end

        Tournament = sortrows(Tournament);

        P1 = Tournament(1, :);
        P2 = Tournament(2, :);

        % Crossover using Whole Arithemtic Recombination
        C1 = ceil(alpha * P1(2:3) + (1-alpha) * P2(2:3));
        C2 = ceil(alpha * P2(2:3) + (1-alpha) * P1(2:3));

        while C1(1, 1) > MaxNpv || C1(1, 1) < MinNpv
            C1(1, 1) = randi([MinNpv MaxNpv]);
        end

        while C1(1, 2) > MaxNbat || C1(1, 2) < MinNbat
            C1(1, 2) = randi([MinNbat MaxNbat]);
        end

        while C2(1, 1) > MaxNpv || C2(1, 1) < MinNpv
            C2(1, 1) = randi([MinNpv MaxNpv]);
        end

        while C2(1, 2) > MaxNbat || C2(1, 2) < MinNbat
            C2(1, 2) = randi([MinNbat MaxNbat]);
        end

        if DPSP < DPSPmax
        [PopulationFitnessValue, DPSP, TLCC] = ...
            costFunction(C1(1 , 1), C1(1 , 2));
        CrossOver(k, 1) = PopulationFitnessValue;
        CrossOver(k, 2) = C1(1 , 1);
        CrossOver(k, 3) = C1(1 , 2);
        CrossOver(k, 4) = DPSP;
        CrossOver(k, 5) = TLCC;
        k = k + 1;

        [PopulationFitnessValue, DPSP, TLCC] = ...
            costFunction(C2(1 , 1), C2(1 , 2));
        CrossOver(k, 1) = PopulationFitnessValue;
        CrossOver(k, 2) = C1(1 , 1);
        CrossOver(k, 3) = C1(1 , 2);
        CrossOver(k, 4) = DPSP;
        CrossOver(k, 5) = TLCC;
        k = k + 1;
        end
    end

    %Updating the solution
    PopArray = [Elite; CrossOver; Mutation];

    %Sorting The Solutions based on their fittness
    PopulationSorted = sort(PopArray);

    if PopulationSorted(1, 1) < BestSolution(1, 1)
        BestSolution = PopulationSorted(1, :);
        disp(BestSolution(1, 1));
    end

    % save the cost of alpha solution of this iteration
    CostArray(1, i + 1) = BestSolution(1, 1);
    set(Figures.Cost,'XData',0:1:i,'YData', CostArray(1, 1 : i + 1));
    subplot(1, 3, 1);
    title(['Current Cost Value: ' num2str(CostArray(1, i + 1))]);

    NpvArray(1, i + 1) = BestSolution(1, 2);
    set(Figures.PV,'XData',0:1:i,'YData', NpvArray(1, 1 : i + 1));
    subplot(1, 3, 2);
    title(['Current Number of PV panels: ' num2str(NpvArray(1, i+1))]);

    NbatArray(1, i + 1) = BestSolution(1, 3);
    set(Figures.Batt,'XData',0:1:i,'YData', NbatArray(1, 1 : i + 1));
    subplot(1, 3, 3);
    title(['Current Number of Batteries: ' num2str(NbatArray(1, i+1))]);
    pause(0.05);
    disp(i);
end

timeElapsed = toc;
disp(BestSolution(1, 1));
disp(BestSolution(1, 2));
disp(BestSolution(1, 3));
disp(BestSolution(1, 4));
disp(BestSolution(1, 5));
disp(timeElapsed);





