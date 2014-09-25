%Plotting Power and Torque

%Plot for with claws

weight = [
    10
    20
    40
    60
    70
    80];
Power = [4.469266667
4.7371
4.635766667
4.3014
4.517766667
4.060166667];

Torque = [1.471833333
1.587966667
1.587733333
1.516
1.565133333
1.505966667];



%Plot for Without Claws
figure('color','white');
weightNC = [10
20
30
40
50];

PowerNC = [4.218033333
4.0488
3.969666667
3.9318
3.620766667];

TorqueNC = [1.4988
1.470533333
1.481933333
1.4885
1.412633333];

plot(weight,Power,':b*',weightNC, PowerNC, '--go')
xlabel('Weight [grams]');
ylabel('Power (W)')
title('Power')
legend('with Claws', 'No Claws')

figure('color','white');
plot(weight,Torque,':b*',weightNC, TorqueNC, '--go')
xlabel('Weight [grams]');
ylabel('Torque(mN*m)')
title('Torque')
legend('with Claws', 'No Claws')


