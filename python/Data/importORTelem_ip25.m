function data = importORTelem_ip25(filename)
%    importORTelem(filename, Cx, Cy, Cz, Dx, Dy, Dz)
     
%  importOrTelem(filename, calibs)  Imports telemtry data recorded from the
%  OctoRoACH robot, saved into a CSV file in the expected format. The
%  arguments provided are the filename, and a 6-vector of the accelerometer
%  calibrations, in the format: [Cx Cy Cz Dx Dy Dz], such that:
%  XLx = ((AccelX - Dx)/Cx)^2 , where XLx has the units of G's, and AccelX
%  has the units of raw integer output, as recorded from the ADXL345.

    %format = '%n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n';
    format = repmat('%n ',1,22);
    
    XL_SCALE = 4096; % 4096 LSB/g

    fid = fopen(filename,'r');

    data = struct()

    %Import CSV data, and automatically skip header lines
    C = textscan(fid,format,'delimiter',',','commentstyle','%');
    D = cell2mat(C);

    if any(isnan(D))
        error('Imported data seems to contain a NaN. You are probably importing something with the wrong number of columns. Aborting.');
    end

    % To convert gyro counts to deg/sec
    %count2deg = 1/14.3750;
    count2deg = 1; %NEED TO UPDATE FOR MPU6000!!!

    % Unpack the rows of D
    data.times = D(:,1);              % microseconds
    data.inputL = D(:,2);             % raw counts, max = vbat
    data.inputR = D(:,3);             % raw counts, max = vbat
    data.DCA = D(:,4);                % PWM counts, max = 3999 (see AP for details)
    data.DCB = D(:,5);                % PWM counts, max = 3999 (see AP for details)
    data.DCC = D(:,6);                % PWM counts, max = 3999 (see AP for details)
    data.DCD = D(:,7);                % PWM counts, max = 3999 (see AP for details)
    data.wx = D(:,8) * count2deg;     % degrees / second
    data.wy = D(:,9) * count2deg;     % degrees / second
    data.wz = D(:,10) * count2deg;     % degrees / second
    data.wzavg = D(:,11) * count2deg;  % degrees / second
    data.xlx = D(:,12);            % raw counts, converted to G's below
    data.xly = D(:,13);            % raw counts, converted to G's below
    data.xlz = D(:,14);            % raw counts, converted to G's below
    data.BEMFA = D(:,15);             % ADC counts
    data.BEMFB = D(:,16);             % ADC counts
    data.BEMFC = D(:,17);             % ADC counts
    data.BEMFD = D(:,18);             % ADC counts
    data.steeringIn = D(:,19);       % raw counts, no max
    data.steeringOut = D(:,20);       % raw counts, no max
    data.vbatt = D(:,21);       % raw counts, no max
    data.yawAngle = D(:,22);

    % Apply important calibrations to accel data before returning:
    %accelx = ((accelx - Dx)/Cx);
    %accely = ((accely - Dy)/Cy);
    %accelz = ((accelz - Dz)/Cz).^2 ;
    
    data.xlx = data.xlx ./ XL_SCALE;
    data.xly = data.xly ./ XL_SCALE;
    data.xlz = data.xlz ./ XL_SCALE;

    data.stimes = data.times / 10^6;

    % Cleanup
    dims = size(D);
    disp(['Got ', num2str(dims(1)), ' samples'])
    fclose(fid);

end
