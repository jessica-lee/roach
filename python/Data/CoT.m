clear all
clc

V = 3.7;
m = 33/1000;
g = 9.81;
vel = 0.08;

info = pullRobot('2014.08.06_12.33.38_trial37_imudata.txt')
time = info.t;
%Duty Cycle
DutyCycleR = info.DCR;
DutyCycleL = info.DCL;
DCR= mean(DutyCycleR+1)/2;
DCL= mean(DutyCycleL+1)/2;

%current - multiply by duty cycle to get useful current
current = info.motorCurrent;
iR = mean(current(:,1))*DCR;
iL = mean(current(:,2))*DCL;

CoT_R = iR*(V/(m*g*vel))
CoT_L = iL*(V/(m*g*vel))

% plot(info.t,info.DCR);
% hold on
% plot(info.t,iR, 'g');

% plot(time,CoT_R);
% hold on
% plot(time,CoT_L, 'g');
% 
% plot(time,iR,'r');
power = info.motorPower;
power_R = mean(power(:,1))
CoT_P = power_R/(m*g*vel)



