clear all; close all; clc;
opts = optimset('Display','iter','MaxIter',1e4,'TolFun',1e-8,'TolX',1e-8);
rng(42);

choose_kd2s = [1,5];
choose_ICs = 1:6;

for choose_kd2 = choose_kd2s
    for choose_IC = choose_ICs
        if choose_kd2 == 12
            load('generated_data_N10_fminsearch/data_12.mat');
            kd2_dir = 'generated_data_N10_fminsearch/result_12/';
        elseif choose_kd2 == 5
            load('generated_data_N10_fminsearch/data_5.mat');
            kd2_dir = 'generated_data_N10_fminsearch/result_5/';
        else
            load('generated_data_N10_fminsearch/data_1.mat');
            kd2_dir = 'generated_data_N10_fminsearch/result_1/';
        end
        

        %% Initialization
        % Chosen parameters
        concs = [3.13e-08, 6.25e-08, 1.25e-07, 2.50e-07, 5.00e-07];
        %Rmaxs = [2.53e2, 2.23e2, 1.87e2, 1.56e2, 1.38e2];
        %R0s = [5.81, 1.30e1, 2.34e1, 3.83e1, 5.42e1];
        Rmaxs = [378.657252718080,293.123182844610,232.536966828669,172.684445954644,135.585008911978];
        R0s = [0.180835108773665,9.36648160410458,22.7122970700652,42.0257240967223,61.1465323468423];
        
        true_params = [ka1, ka2, kd1, kd2];
        
        Ydata = output;
        tdata = t;
        
        RUmaxs = max(max(Ydata))*ones(1,length(concs));
        RU0s = Ydata(1,:);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if choose_IC == 1
            IC_params = [6, -1, -2, -3, RUmaxs, RU0s];%[1e1, 1e-2, 1e-2, 1e-2, RUmaxs, RU0s];
        elseif choose_IC == 2
            IC_params = [5, -2, -3, -4, RUmaxs, RU0s];
        elseif choose_IC == 3
            IC_params = [4, -3, -4, -5, RUmaxs, RU0s];
        elseif choose_IC == 4
            IC_params = [3, -4, -5, -6, RUmaxs, RU0s];
        elseif choose_IC == 5
            IC_params = [2, -5, -6, -7, RUmaxs, RU0s];
        else
            IC_params = [1, -6, -7, -8, RUmaxs, RU0s];
        end
        
        IC_name = strcat('IC_',num2str(choose_IC));
        save_dir = strcat(kd2_dir,IC_name,'/');
        if ~exist(save_dir, 'dir')
            mkdir(save_dir)
        end
        save_fig = strcat(save_dir,'fitting.pdf');
        save_result = strcat(save_dir,'result.mat');
        
        % Chosen parameters
        LB = zeros(size(IC_params),'like', IC_params);
        UB = [1e6, 1e-1, 1e-2 , 1e-2];%[1e6, 1e-1, 1e-2, 1e-2];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        [params, fval] = fminsearch(@(params) objective(tdata,Ydata,params,concs,R0s,Rmaxs), IC_params, opts);
        yOut = run_bivalent(tdata,Ydata,params,concs,R0s,Rmaxs);
        
        figure(1)
        plot(t,yOut,'LineWidth',4)
        hold on
        plot(t,Ydata)
        hold off
        saveas(gcf,save_fig)
        save(save_result,'params','fval','IC_params','true_params','Rmaxs','R0s')
        close all;
    end
end


function error = objective(t,Ydata,params,concs,R0s,Rmaxs)
t_asc = t(1:301);
t_dis = t(301:end);


ka1 = 10^params(1);
ka2 = 10^params(2);
kd1 = 10^params(3);
kd2 = 10^params(4);

y_all = zeros(length(t),length(concs));

for i=1:length(concs)
    R0 = params(i+5+4);
    Am = concs(i);
    
    y0 = [params(i+4), 0, 0];
    ode_params = [ka1, ka2, kd1, kd2, Am];
    [~, y_asc] = ode15s(@(t,y) bivalent_rhs(t,y,ode_params), t_asc, y0);
    
    y0 = y_asc(end,:);
    ode_params = [0, 0, kd1, kd2, Am];
    [~, y_dis] = ode15s(@(t,y) bivalent_rhs(t,y,ode_params), t_dis, y0);
    
    y_all(:,i) = R0 + [y_asc(:,2) + y_asc(:,3); y_dis(2:end,2) + y_dis(2:end,3)];
end

error = sum(sum((Ydata - y_all).^2));
end

function y_all = run_bivalent(t,Ydata,params,concs,R0s,Rmaxs)
t_asc = t(1:301);
t_dis = t(301:end);

ka1 = 10^params(1);
ka2 = 10^params(2);
kd1 = 10^params(3);
kd2 = 10^params(4);

y_all = zeros(length(t),length(concs));

for i=1:length(concs)
    R0 = params(i+5+4);
    Am = concs(i);
    
    y0 = [params(i+4), 0, 0];
    ode_params = [ka1, ka2, kd1, kd2, Am];
    [~, y_asc] = ode15s(@(t,y) bivalent_rhs(t,y,ode_params), t_asc, y0);
    
    y0 = y_asc(end,:);
    ode_params = [0, 0, kd1, kd2, Am];
    [~, y_dis] = ode15s(@(t,y) bivalent_rhs(t,y,ode_params), t_dis, y0);
    
    y_all(:,i) = R0 + [y_asc(:,2) + y_asc(:,3); y_dis(2:end,2) + y_dis(2:end,3)];
end
end

function dy = bivalent_rhs(t,y,params)
L = y(1);
X1 = y(2);
X2 = y(3);

Am = params(5);

ka1 = params(1);
ka2 = params(2);
kd1 = params(3);
kd2 = params(4);

% ODE equations
dL = -(2*ka1*Am*L - kd1*X1) - (ka2*X1*L - 2*kd2*X2);
dX1 = (2*ka1*Am*L - kd1*X1) - (ka2*X1*L - 2*kd2*X2);
dX2 = ka2*X1*L - 2*kd2*X2;
dy = [dL; dX1; dX2];
end