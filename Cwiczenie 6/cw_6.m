clc;
close all;
clear all;

Kp = 2;
Ki = 0.2;
Kc = 1;
u_sat = 10;
y_ref = 10;
simulation = sim('simulation');
y_r = simulation.get('y_r');
y = simulation.get('y');
u_PI = simulation.get('u_PI');
u_s = simulation.get('u_s');
e = simulation.get('e');
t = simulation.get('tout');
t_elapsed = 400;
T_s = t_elapsed/length(t);

I_IAE = sum(abs(e))
przeregulowanie = ((max(y)-y_r(40))/y_r(40))*100;
