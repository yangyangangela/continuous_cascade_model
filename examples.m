%% An example on using the continuous cascade model.
% The details of all the functions can be found in ../library/@stateV1

clear all;

% The model is written as a class "stateV1" saved in library.
addpath(genpath('../library'));


%% Step 0: initiate the class
% Input the name of a mpc that is saved in /library/matpower5.1.
% Examples include "case9", "case39", "iceland", and etc. Check the
% matpower5.1 folder in library.
S = stateV1('case39');


%% Step 1: Try out some built-in functions in the model

% Example 0: Find the nearest fixed point starting from a given state.
current_state = S.x;
x_star = fixed_points_nearby(S,current_state);

% Example 1: break the state vector into w (frequency), ga (generator
% angle), ba (bus angle), and eita (line status).
[w,ga,ba,eita] = unpack_x(S,S.x);

% Example 3: the value of lyapunov function on current_state.
energy = lyapunov_energy(S,current_state);

% Example 4: return the edge_list of the power grid.
elist = edge_list(S);


%% Step 2: Some functions that can be used in cascade model.
% 2.0) A cascade model starts from a steady state solution.
% 2.1) Cascade is triggered by a line removal
% 2.2) Solve the dynamic and observe if at any time point there is a
% overload. If there is, remove the line and solve the dynamic from the
% time point of removal.

% Example 0: solve dynamics for certain amount of time.
time_length = 10; % indicate the total time to model
[Tspan, Y1] = solve_dynamic(S,time_length);

% Example 1: remove certain lines.
E = edge_list(S);% get the edgelist
I = E('from');J=E('to');IJ=[I J];
line = IJ(1,:);% select a line.
S.x = turn_off_lines(S,line);% update the state x

% Example 2: calculate the power flow (or energy) on each lines (virtual and real).
[Pf_vir,Pf_line] = power_flow(S, current_state);



