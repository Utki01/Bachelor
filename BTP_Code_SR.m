clear;
clc;

%SR Algorithm - Modified
C = [10 20 30 40 50 60];
A = [100 200 300 400 500 600];
Co = C;
Ao = A;

%Use ONE reference function
u = BTP_Code_V3(C, A); %Uncertainty associated with an initial set of calibrator values
disp(u);
store = zeros(1,2);
new_func = polyfit(C, A, 2);

C_ = zeros(1, 6);

A_ = zeros(1,6);
k_1 = 0;
bool = 0;
TOL = 0.2;

rng(123);
%Bounds for Stochastic Ruler
A_SR = 0.5;
B_SR = 1;
NUM = 10;

time = zeros(NUM,1);
C_array = zeros(NUM,6);
sd_array = zeros(NUM,1);

for ctr = 1:NUM
    fprintf('CTR is %d\n', ctr);
    beep
    tic;
    bool = 0;
    C = Co;
    A = Ao;
    k_1 = 0;
    C_ = zeros(1,6);
    A_ = zeros(1,6);
    
    while bool == 0
        %fprintf('k1 - %i\n', k_1)
        M_k = k_1 + 1;

        %randi([imin,imax],___) 
        %Generating a neighbourhood sample----------------------
        toggle = 1;

        while toggle == 1
            %fprintf('In the loop------------------------------------\n\n');
            counter = 0;

            C_(1) = randi([floor(0.8*C(1)), ceil(1.2*C(1))], 1);
            A_(1) = polyval(new_func, C_(1));
            for i = 2:6
                counter = 0;
                while counter < 10
                    C_(i) = randi([floor(0.8*C(i)), ceil(1.2*C(i))], 1);
                    A_(i) = polyval(new_func, C_(i));

                    if (C_(i)-C_(i-1))/C_(i-1) > 0.1 && C_(i) < 30*i
                        %fprintf('C_(i) for i = %d is %d\n', i, C_(i));
                        %fprintf('Here counter is %d\n', counter);
                        break;
                    end
                    counter = counter + 1;
                end

                if counter == 10
                    %Couldn't generate element satisfying condition
                    break;
                elseif i == 6
                    toggle = 0;
                end
            end
        end
        %Ending here -------------------------------------------
    %     C_(1) = randi([floor(1.1*C(1)), floor(1.3*C(1))], 1);
    %     A_(1) = polyval(new_func, C_(1));
    % 
    %     for i = 2:6  
    %         C_(i) = randi([floor(1.1*C_(i-1)), floor(1.3*C_(i-1))], 1);
    %         A_(i) = polyval(new_func, C_(i));
    %     end
        %fprintf('C right now - ');
        %fprintf('  %d', C_);
        %fprintf(' (Mk is %d)\n', M_k);

        iter = 1;
        check_1 = 0;
        check_2 = 0;
        store1 = -1;
        store2 = 0;

        while iter <= M_k
%             fprintf('   Iteration: %d\n', iter);
              sd = BTP_Code_V3(C_, A_);
%             fprintf('   SD: %d', sd);
              Q_k = A_SR + (B_SR-A_SR)*rand(1);
%             fprintf('   and Qk: %d\n', Q_k);
            if sd > Q_k
                check_1 = check_1 + 1;
            else
                check_2 = check_2 + 1;
            end

            if check_2 >= 0.75*M_k
                store1 = 1;
                break;
            end

            if check_1 >= 0.25*M_k
                store1 = 0;
                break;
            end   
            iter = iter + 1;
        end
        %fprintf('Store1 is %d\n', store1);
        if store1 == 1
            %Check tolerance
            u_avg = 0;
            sd_avg = 0;
            %Generate average u & sd
            for i = 1:20
                u_avg = u_avg + BTP_Code_V3(Co, Ao);
                sd_avg = sd_avg + BTP_Code_V3(C_, A_);
            end
            u_avg = u_avg/20;
            sd_avg = sd_avg/20;
            if (u_avg - sd_avg)/u_avg > TOL %This is a good enough result
                disp('Results Converged!');
                disp('Here C is -');
                disp(C_);
                for z = 1:6
                    C_array(ctr, z) = C_(z);
                end
                fprintf('\nHere sd is: %d\n', sd_avg);
                sd_array(ctr) = sd_avg;
                bool = 1;
            else % We need a better result
                C = C_;
                k_1 = k_1 + 1;
            end
            % If satisfied, end this
        end

        if store1 == 0
            %Just continue the loop
        end

    end
    time(ctr) = toc;
    fprintf('Time is %d\n', time(ctr));
end
