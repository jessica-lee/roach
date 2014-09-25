function Robot = pullRobot(fname)

config.legScale  = 95.8738e-6;   % 16 bit to radian
config.xlScale   = (1/4096) * 9.81;   %XL read to m/s^2 (\pm 8g range)
config.gyroScale = (1/16.384) * (pi/180);   %Gyro read to rad/s (\pm 2000 deg/s range)

robotRaw = importdata(fname);
offsetVector = ones(size(robotRaw.data(:,1)));
Robot.t = (robotRaw.data(:,1) - offsetVector .* robotRaw.data(1,1)) ./ 1e6;

%Remove offsets
for i = 8:15
    robotRaw.data(:,i) = robotRaw.data(:,i) - offsetVector .* robotRaw.data(1,i);
end

Robot.legPosRight = robotRaw.data(:,2) * config.legScale;
Robot.legPosLeft = robotRaw.data(:,3) * config.legScale;
% Commanded Leg Position L,R
Robot.legComRight = robotRaw.data(:,4)* config.legScale;
Robot.legComLeft = robotRaw.data(:,5)* config.legScale; 
% Duty Cycle L,R
Robot.DCR = robotRaw.data(:,6)/3800;
Robot.DCL = robotRaw.data(:,7)/3800;
% BEMF L,R
Robot.BEMFR = robotRaw.data(:,14);
Robot.BEMFL = robotRaw.data(:,15);
% VBatt
Robot.vBatt = robotRaw.data(:,16);

%Compute Power
vref = 3.3;             % MAKE SURE THESE ARE RIGHT
vdivide = 3.7/2.7;
vbatt = robotRaw.data(:,16); %last column of data is batt voltage in adc counts
vbatt = vbatt*vdivide*vref/1023; %configert battery voltage to Volts
emf(:,1) = vdivide*vref/1023*(-robotRaw.data(:,14));
emf(:,2) = vdivide*vref/1023*(-robotRaw.data(:,15));        
pwm(:,1) = -robotRaw.data(:,6)/4000;
pwm(:,2) = -robotRaw.data(:,7)/4000;    
pwm(find(pwm(:,1) < -4000 )) = -4000;
pwm(find(pwm(:,2) < -4000 )) = -4000;

%Calculate Motor current...
%This is VERY wrong
R = 3.9882;
motori(:,1) = (vbatt - emf(:,1))/R;
motori(:,2) = (vbatt - emf(:,2))/R;

motorp(:,1) = motori(:,1).*vbatt.*pwm(:,1);
motorp(:,2) = motori(:,2).*vbatt.*pwm(:,2);

Robot.motorVoltage(:,1) = vbatt.*pwm(:,1);
Robot.motorVoltage(:,2) = vbatt.*pwm(:,2);
Robot.motorCurrent = motori;
Robot.motorPower = motorp;

% Accelerometer: Robot frame, x,y,z

Robot.xlX = robotRaw.data(:,12) .* config.xlScale;
Robot.xlY = -robotRaw.data(:,11) .* config.xlScale;
Robot.xlZ = robotRaw.data(:,13) .* config.xlScale;


% calTime = 500;
% offsetVector = ones(size(XL(:,1)));
% offset = mean(XL(1:calTime,:)) + [0, 0, -9.81];     %assumes z is aligned with gravity
% for i = 1:3
%     Robot.XL(:,i) = XL(:,i) - offset(:,i) .* offsetVector;
% end

% Gyroscope: Robot frame, x,y,z

Robot.gyroX =  robotRaw.data(:,9)  .* config.gyroScale;
Robot.gyroY =  -robotRaw.data(:,8)  .* config.gyroScale;
Robot.gyroZ =  robotRaw.data(:,10) .* config.gyroScale;
