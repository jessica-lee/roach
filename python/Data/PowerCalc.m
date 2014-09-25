RMotor = 3.3;
Kt = 1.41;

telem = importVRTelem_ip25_JL('2014.09.22_16.20.07_trial102_imudata.txt')


time = telem.times;
DCR = telem.DCR;
DCL = telem.DCL;
GyroX = telem.wx;
GyroY = telem.wy;
GyroZ = telem.wz;
RBEMF = telem.BEMFR;
LBEMF = telem.BEMFL;
VBatt = telem.vbatt;

% "#Power calculation\n",
%       "# i_m = (VBatt - BEMF)/R\n",
%       "# V_m is just VBatt\n",
PowerR = abs((DCR./4096.0).*VBatt.*(VBatt - RBEMF)./RMotor); % P = V_m i_m x duty cycle\n",
PowerL = abs((DCL./4096.0).*VBatt.*(VBatt - LBEMF)./RMotor); % P = V_m i_m x duty cycle\n",
%       "\n",
a = size(VBatt);
length = a(1,1);
 Energy = zeros(length);
 time = time./1000; % time in seconds\n",
dt = (time(2) - time(1));
%       "print 'dt=', dt\n",
% %       "#energy calculation\n",
for i = 2:length;
     Energy(i) = Energy(i-1) + (PowerR(i) + PowerL(i)) * dt;
end
% 	
%torque calculation
TorqueR = (DCR./4096.0).*Kt.*(VBatt - RBEMF)./RMotor; % \\Tau = Kt i_m x duty cycle\n",
TorqueL = (DCL./4096.0).*Kt.*(VBatt - LBEMF)./RMotor; % \\Tau = Kt i_m x duty cycle\n",

% Motor Voltage, R,L
VMotorR = VBatt.*DCR;
VMotorL = VBatt.*DCL;

figure
subplot(3,2,1)
plot(time, DCR)
hold on
plot(time, DCL,'k')
xlabel('time (s)')
ylabel('Duty Cycle')
legend('Right', 'Left')

subplot(3,2,2)
plot(time, TorqueR)
hold on
plot(time, TorqueL,'k')
xlabel('time (s)')
ylabel('Torque (mN*m)')
legend('Right', 'Left')

subplot(3,2,3)
plot(time, PowerR)
hold on
plot(time, PowerL,'k')
xlabel('time (s)')
ylabel('Power (W)')
legend('Right', 'Left')

subplot(3,2,4)
plot(time, Energy)
xlabel('time (s)')
ylabel('Energy (J)')




