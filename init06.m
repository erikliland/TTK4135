% This file contains the initialization for the helicopter assignment in
% the course TTK4135. Only use this file for the helicopter 6. On It's
% Learning you can find the initialization files for the other helicopters.
% Run this file before you execute QuaRC_ -> Build to build the file
% helikopter.mdl.

% Updated spring 2014, Mansoureh Jesmani

clear all;
clc;
%%%%%%%%%%% Calibration of the encoder and the hardware for the specific
KalibVandring = -0.0430;
KalibPitch =-.08785; 
KalibElevasjon =.0925;
EncoderInputVandring = 0;
EncoderInputPitch = 1;
EncoderInputElevasjon = 2;
joystick_gain_x = 1;
joystick_gain_y = 1;

%%%%%%%%%%% Physical constants
%%wights
m_w = 1.879;                        % Mass of the counterweight
m_h = 1.447;                        % Mass of helicopter
m_g = 0.021;                        % Effective mass of the helicopter
%%Distances
l_a = .652;                          % Distance from elevation axis to helicopter body
l_h = 0.177;                        % Distance from pitch axis to motor
%%Moments
J_e = 2 * m_h * l_a *l_a;           % Moment of interia for elevation
J_p = 2 * ( m_h/2 * l_h * l_h);     % Moment of interia for pitch
J_t = 2 * m_h * l_a *l_a;           % Moment of interia for travel
%Voltage
V_f_eq=.625;                         % Voltage motor in front, Change the value so that it matches the current helicopter
V_b_eq=.6;                          % 0.85;%1.2; Voltage motor in back, Change the value so that it matches the current helicopter
V_s_eq=V_f_eq+V_b_eq;               % Voltage sum, The minimum voltage to keep the helicopter in equilibrium
%Force
K_p = m_g*9.81;                     % Force to lift the helicopter from the ground
K_f = K_p/V_s_eq;                   % Force constant motor
%%%%%%%%%%% Controller
K_ep = 7;
K_ed = 10;
K_ei = 4.3;
K_1 = l_h*K_f/J_p;
K_2 = K_p*l_a/J_t;
K_3 = K_f*l_a/J_e;
K_4 = K_p*l_a/J_e;
w_c  = 6;
K_pd = w_c/K_1;
K_pp = (sqrt(2)*w_c^2)/K_1;