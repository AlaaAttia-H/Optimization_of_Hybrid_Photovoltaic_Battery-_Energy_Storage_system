EL = zeros(1, 8760);
EG = zeros(1, 8760);

MinEgen = 0.04; % by 1 PV panel
MaxEgen = 0.063; % by 1 PV panel
MinEload = 33; % by 100 houses in Egypt
MaxEload = 45; % by 100 houses in Egypt

i = 1;
while i <= 8760
% generating different Egen by one pv panel
    % And Eload by 20 houses in Egypt every hour for 1 year
    EL(i) = MinEload + (MaxEload - MinEload) * rand();
    EG(i) = (MinEgen + (MaxEgen - MinEgen) * rand());
    i = i +1;
end    