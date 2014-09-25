function data = importVRTelem(filename)
%    importORTelem(filename, Cx, Cy, Cz, Dx, Dy, Dz)
     
%  importOrTelem(filename, calibs)  Imports telemtry data recorded from the
%  OctoRoACH robot, saved into a CSV file in the expected format. The
%  arguments provided are the filename, and a 6-vector of the accelerometer
%  calibrations, in the format: [Cx Cy Cz Dx Dy Dz], such that:
%  XLx = ((AccelX - Dx)/Cx)^2 , where XLx has the units of G's, and AccelX
%  has the units of raw integer output, as recorded from the ADXL345.

    %format = '%n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n';
    format = repmat('%n ',1,16);
    
    
    fid = fopen(filename,'r');

    data = struct();

    %Import CSV data, and automatically skip header lines
    C = textscan(fid,format,'delimiter',',','commentstyle','%');
    D = cell2mat(C);

    if any(isnan(D))
        error('Imported data seems to contain a NaN. You are probably importing something with the wrong number of columns. Aborting.');
    end

    
    % D Haldane's 'roach' firmware telemetry format, according to the wiki:
    %   time | Right Leg Pos | Left Leg Pos | Commanded Right Leg Pos | Commanded Left Leg Pos | DCR | DCL | GyroX | GryoY | GryoZ | AX | AY | AZ | RBEMF | LBEMF | VBatt
    
    
    % Unpack the rows of D
    data.times = D(:,1);              % microseconds
    data.legposR = D(:,2);             
    data.legposL = D(:,3);
    data.legposRcmd = D(:,4);
    data.legposLcmd = D(:,5);
    data.DCR = D(:,6);                % PWM counts, max = 3999 (see AP for details)
    data.DCL = D(:,7);                % PWM counts, max = 3999 (see AP for details)
    data.wx = D(:,8);                 % degrees / second
    data.wy = D(:,9);                 % degrees / second
    data.wz = D(:,10);                % degrees / second
    data.xlx = D(:,11);               % raw counts, converted to G's below
    data.xly = D(:,12);               % raw counts, converted to G's below
    data.xlz = D(:,13);               % raw counts, converted to G's below  
    data.BEMFR = D(:,14);             % ADC counts
    data.BEMFL = D(:,15);             % ADC counts
    data.vbatt = D(:,16);             % raw counts, no max

    % Apply important calibrations to accel data before returning:
    %accelx = ((accelx - Dx)/Cx);
    %accely = ((accely - Dy)/Cy);
    %accelz = ((accelz - Dz)/Cz).^2 ;
    
    % Simple gyro scaling, to degrees/sec
    GYRO_SCALE = 2000; %deg/sec
    count2deg = 1/((2^15 - 1)/GYRO_SCALE);
    data.wx = data.wx * count2deg;
    data.wy = data.wy * count2deg;
    data.wz = data.wz * count2deg;
    
    % Simple accelerometer scaling to g's
    %XL_SCALE = 16384; % 16384 LSB/g , for +-2g setting
    %XL_SCALE = 8192;  % 8192 LSB/g , for +-4g setting
    XL_SCALE = 4096; % 4096 LSB/g , for +-8g
    data.xlx = data.xlx ./ XL_SCALE;
    data.xly = data.xly ./ XL_SCALE;
    data.xlz = data.xlz ./ XL_SCALE;

    data.stimes = data.times / 10^6;

    % Cleanup
    dims = size(D);
    disp(['Got ', num2str(dims(1)), ' samples'])
    fclose(fid);

end
