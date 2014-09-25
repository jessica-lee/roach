function data = importVRTelem_ip25(filename)
%    importORTelem(filename, Cx, Cy, Cz, Dx, Dy, Dz)
     
%  importOrTelem(filename, calibs)  Imports telemtry data recorded from the
%  VelociRoACH robot, saved into a CSV file in the expected format. The
%  arguments provided are the filename, and a 6-vector of the accelerometer
%  calibrations, in the format: [Cx Cy Cz Dx Dy Dz], such that:
%  XLx = ((AccelX - Dx)/Cx)^2 , where XLx has the units of G's, and AccelX
%  has the units of raw integer output, as recorded from the ADXL345.

    %format = '%n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n';
    format = repmat('%n ',1,20);
    
    
    fid = fopen(filename,'r');

    data = struct();

    %Import CSV data, and automatically skip header lines
    C = textscan(fid,format,'delimiter',',','commentstyle','%');
    D = cell2mat(C);

    if any(isnan(D))
        error('Imported data seems to contain a NaN. You are probably importing something with the wrong number of columns. Aborting.');
    end

    

    % Unpack the rows of D
    data.times = D(:,1);              % microseconds
    data.encR = D(:,2);               % counts
    data.encL = D(:,3);               % counts
    data.inputR = D(:,4);             % raw counts
    data.inputL = D(:,5);             % raw counts
    data.DCA = D(:,6);                % PWM counts, max = 3999 (see AP for details)
    data.DCB = D(:,7);                % PWM counts, max = 3999 (see AP for details)
    data.DCC = D(:,8);                % PWM counts, max = 3999 (see AP for details)
    data.DCD = D(:,9);                % PWM counts, max = 3999 (see AP for details)
    data.wx = D(:,10);                % raw, converted to rad/s below
    data.wy = D(:,11);                % raw, converted to rad/s below
    data.wz = D(:,12);                % raw, converted to rad/s below
    data.xlx = D(:,13);               % raw counts, converted to G's below
    data.xly = D(:,14);               % raw counts, converted to G's below
    data.xlz = D(:,15);               % raw counts, converted to G's below
    data.BEMFA = D(:,16);             % ADC counts
    data.BEMFB = D(:,17);             % ADC counts
    data.BEMFC = D(:,18);             % ADC counts
    data.BEMFD = D(:,19);             % ADC counts
    data.vbatt = D(:,20);             % raw counts, converted to V below

    % Apply important calibrations to accel data before returning:
    %accelx = ((accelx - Dx)/Cx);
    %accely = ((accely - Dy)/Cy);
    %accelz = ((accelz - Dz)/Cz).^2 ;
    
    % Scale counts to radians for leg position
    data.encR = data.encR*95.8738e-6;
    data.encL = data.encL*95.8738e-6;
    data.inputR = data.inputR*95.8738e-6;
    data.inputL = data.inputL*95.8738e-6;
    
    % Simple gyro scaling, to degrees/sec
    GYRO_SCALE = (1/16.384)*(pi/180.0); %deg/sec
    data.wx = data.wx * GYRO_SCALE;
    data.wy = data.wy * GYRO_SCALE;
    data.wz = data.wz * GYRO_SCALE;
    
    % Simple accelerometer scaling to g's
    XL_SCALE = 4096; % 4096 LSB/g
    %XL_SCALE = 16384; % 16384 LSB/g , for +-2g setting
    %XL_SCALE = 8192;  % 8192 LSB/g , for +-4g setting
    data.xlx = data.xlx ./ XL_SCALE;
    data.xly = data.xly ./ XL_SCALE;
    data.xlz = data.xlz ./ XL_SCALE;
    
    % Convert battery voltage to volts
    vdivide = 3.7/2.7;
    vref = 3.3;
    data.vbatt = data.vbatt*vdivide*vref/1023.0;
    
    % Convert BEMF to V
    vgain = 15/47;
    data.BEMFA = data.BEMFA*vref/1024.0/vgain;
    data.BEMFB = data.BEMFB*vref/1024.0/vgain;
    data.BEMFC = data.BEMFC*vref/1024.0/vgain;
    data.BEMFD = data.BEMFD*vref/1024.0/vgain;
    
    data.stimes = data.times / 10^6;

    % Cleanup
    dims = size(D);
    disp(['Got ', num2str(dims(1)), ' samples'])
    fclose(fid);

end
