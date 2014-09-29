
clear all
clc
parseAlltxt

%get maxPower and maxTorque for all runs
for i = 1:length(DATA);
    PowerR = DATA(i).PowerR;
    PowerL = DATA(i).PowerL;
    MaxPower = max(max(PowerL),max(PowerR));
    Power(i,1) = i+70;
    Power(i,2) = MaxPower;
    
    TorqueR = DATA(i).TorqueR;
    TorqueL = DATA(i).TorqueL;
    MaxTorque = max(max(TorqueL),max(TorqueL));
    Torque(i,1) = i+70;
    Torque(i,2) = MaxTorque;
end



 
    
    
    

