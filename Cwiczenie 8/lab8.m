clc;
close all;
clear all;

%pocz¹tkowe nastawy
K = 1;
Ti = 10000000000;
Ki = 1/Ti;
Td = 0;

%sta³e
m = 0.5;
d = 1;
T_o = 0.1;
klucz = "PID_MP"; %"PID_Skok", "PI_Skok", "PID_MP", "PI_MP"

%symulacja
symulacja = sim("symulacja_OL.slx");
y_out = symulacja.get('y_out');
dy_out = symulacja.get('dy_out');
t = symulacja.get('tout');

%dobieranie nastawów za pomoc¹ odpowiedzi skokowej
  %wyznaczanie parametrów
for i = 1:length(dy_out)
    if dy_out(i) == max(dy_out)
        Kv = dy_out(i);
        h = Kv * t;
        a = h(i) - y_out(i);
        h = Kv * t - a;
        break;
    end
end
for i = 1:length(h)
    if h(i) >= 0
        L = t(i);
        break;
    end
end

%Wykres skok
%figure;
%plot(t,y_out);
%hold on;
%plot(t,dy_out);
%plot(t,h);

%dobieranie nastawów przy pomocy metody przekaŸnikowej
Kp = 1;
Kr = 0.3;
y_sp = 0.1;

symulacja2 = sim('symulacja_MP.slx');
y_out_MP = symulacja2.get('y_out_MP');
u_r = symulacja2.get('u_r');
t = symulacja2.get('tout');

%obliczanie Tu
t_sum = 0;
bool1 = 0;
for i = 1:length(t)
    t_sum = t_sum + t(i);
    if t_sum >= 10
        if u_r(i) == Kr && u_r(i-1) == -Kr && bool1 == 0
            bool1 = 1;
            t1 = t(i);
        elseif u_r(i) == Kr && u_r(i-1) == -Kr && bool1 == 1
            bool1 = 0;
            t2 = t(i);
        end
    end
end
Tu = t2 - t1;

%obliczani Ku
y_out_MP_temp = y_out_MP(100:length(y_out_MP));
y_max = max(y_out_MP_temp);
y_min = min(y_out_MP_temp);
Ku = (4*(Kr-(-Kr)))/(pi*(y_max-y_min));

%Wykres MP
%figure;
%plot(t,y_out_MP);
%hold on;
%plot(t,u_r);

  %obliczanie nastaw
if klucz == "PID_Skok"
    K = (0.45)/(Kv*L);
    Ti = 8*L;
    Td = 0.5*L;
end
if klucz == "PI_Skok"
    K = (0.35)/(Kv*L);
    Ti = 13.4*L;
end
if klucz == "PID_MP"
    kappa = 1/(Kp*Ku);
    K = (0.3 - 0.1*(kappa.^4))*Ku;
    Ti = (0.6*Tu)/(1+2*kappa);
    Td = ((0.15*(1-kappa))*Tu)/(1-0.95*kappa);
end
if klucz == "PI_MP"
    kappa = 1/(Kp*Ku);
    K = 0.16*Ku;
    Ti = Tu/(1+4.5*kappa);
end

%Koñcowe nastawy regulatora
K
Ti
Td
%symulacja koñcowa
symulacja3 = sim('symulacja_CL.slx');
y_out = symulacja3.get('y_out');
dy_out = symulacja3.get('dy_out');
t = symulacja3.get('tout');

figure;
plot(t,y_out);

%Wra¿liwoœæ uk³adu
s = tf('s');
GR = K*(1 + 1/(s*Ti) + s*Td);
GP = tf([1/d],[m/d 1 0], 'InputDelay', 0.1);
G = GR * GP;
n = 1000;
theta = linspace(0, 2*pi, n);
x = cos(theta);
y = sin(theta);
figure;
nyquist(G);
hold on;
plot(x-1, y,'red');