function Sx = BTP_Code_V3(C, A)

%Calibration Uncertainty
n = 60;
f = polyfit(A, C, 2);
g = polyfit(C, A, 2);
%x = polyval(f, 10);

%Average Reference Function
%C = [10 20 30 40 50 60];
%A = [100 200 300 400 500 600];
C2 = zeros(1,6);
A2 = zeros(1,6);
A3 = zeros(1,6);

A_true = 250;
C_true = polyval(f, A_true);
sum = 0;

for j = 1:n
    
    for i = 1:6
        C2(i) = normrnd(C(i), 0.05*C(i)); %Uncertainty in Concentration
        A2(i) = polyval(g, C2(i)); %Corresponding absorbance using reference function
        A3(i) = normrnd(A2(i), 0.05*A2(i)); %Uncertainty in absorbance
    end
    
    f2 = polyfit(A3, C2, 2);
    sum = sum + (polyval(f2, A_true) - C_true)^2;
    
end

Sx = (sum/(n-1))^0.5;
%disp(Sx);

