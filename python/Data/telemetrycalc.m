clear;
close all;

makemovie=0;
plotalltelemetry=1;
plotpower=1;

cd 'C:\Users\Jessica Lee\Documents\Research\Code\roach\python\Data';
dirname='C:\Users\Jessica Lee\Documents\Research\Code\roach\python\Data';
pathfig='C:\Users\Jessica Lee\Documents\Research\Code\roach\python\Data';
% pathmov='D:\Dropbox\Work\Grass\working\telemetry\movies\';
pathmov='C:\Users\Jessica Lee\Documents\Research\Code\roach\python\Data\Movies';

filenamelist=0;clear filenamelist;
ddtop=dir(dirname);

count=1;

for jj=3:size(ddtop,1);
    
    filename=ddtop(jj).name;
    filenamenoext=filename;
    filenamenoext(length(filename)-3:length(filename))=[];

    filenamelist{count}=filenamenoext;
    
    count=count+1;
end

filenamelist=filenamelist';

lff=length(filenamelist);

%%

voltage_constant=3.3*3.7/1023/2.7;  %3.3 V is ADc positive reference
Resistance=3.9882;  %3.9882 Ohm
KT=0.0013124;   %motor constant for SS7-3.3 motor CHECK UNIT

samplingfreq=100;
runlength=16;
filterfreq=500;

windowwidth=1;
avgwidth=1;
movstep=1;
lnwz=2;
    
for jj=1:lff
    
    filename=filenamelist{jj};
    cd 'C:\Users\Jessica Lee\Documents\Research\Code\roach\python\Data';
     bb1=importORTelem_ip25_edited(strcat(filename,'.txt'));    
%    bb1=importORTelem_ip25(strcat(filename,'.txt'));   
    time=bb1.stimes;
    timez=0:(1/samplingfreq):runlength;
%     timez=1/samplingfreq:(1/samplingfreq):runlength;

    Vbat=interp1(time,bb1.vbatt*voltage_constant,timez,'linear');%battery voltage
    VbemfL=interp1(time,bb1.BEMFA*voltage_constant,timez,'linear');%left motor back EMF
    VbemfR=interp1(time,bb1.BEMFB*voltage_constant,timez,'linear');%right motor back EMF
    DcL=interp1(time,bb1.DCL,timez,'linear');%left motor duty cycle
    DcR=interp1(time,bb1.DCR,timez,'linear');%right motor duty cycle

    % ImotL=(Vbat-VmotL)/Resistance.*DcL;
    % ImotR=(Vbat-VmotL)/Resistance.*DcR;
    % PowerL=(Vbat-VmotL)/Resistance.*VmotL.*DcL;%left motor power
    % PowerL_LF=PowerL-smooth(PowerL,100)';
    % PowerR=(Vbat-VmotR)/Resistance.*VmotR.*DcR;%right motor power
    % PowerR_LF=PowerR-smooth(PowerR,100)';
    % TorqueL=ImotL*KT;    %TorqueL_LF=TorqueL-smooth(TorqueL,50);
    % TorqueR=ImotL*KT;    %TorqueR_LF=TorqueR-smooth(TorqueR,50);

    VmotL=Vbat-VbemfL;   %motor voltage
    VmotR=Vbat-VbemfR;
    ImotL=VmotL/Resistance.*DcL;    %motor average current
    ImotR=VmotR/Resistance.*DcR;
    PowerL=ImotL.*VmotL;    %motor power
    PowerR=ImotR.*VmotR;
    PowerTotal=PowerL+PowerR;
    TorqueL=ImotL*KT;    %motor torque
    TorqueR=ImotR*KT;
    FreqL=PowerL./TorqueL/2/pi; %calculated motor frequency
    FreqR=PowerR./TorqueR/2/pi;

    fPowerL=butterfilter(PowerL,filterfreq,5);
    fPowerR=butterfilter(PowerR,filterfreq,5);

    trimind=min(find(abs(diff(VmotL))>0.3))-2;
    timez(length(timez)-trimind+1:length(timez))=[];
    Vbat(1:trimind)=[];
    VbemfL(1:trimind)=[];
    VbemfR(1:trimind)=[];
    DcL(1:trimind)=[];
    DcR(1:trimind)=[];
    VmotL(1:trimind)=[];
    VmotR(1:trimind)=[];
    ImotL(1:trimind)=[];
    ImotR(1:trimind)=[];
    PowerL(1:trimind)=[];
    PowerR(1:trimind)=[];
    PowerTotal(1:trimind)=[];
    TorqueL(1:trimind)=[];
    TorqueR(1:trimind)=[];
    FreqL(1:trimind)=[];
    FreqR(1:trimind)=[];

    % timez=1:0.01:16;
    % tmp2=interp1(time,Vbat-VmotL,timez','linear');

    %%
    
    if plotalltelemetry==1

        h1=figure(1);clf;
        set(gcf,'color','w');

        subplot(3,2,1);hold all;box on;
        plot(timez,VmotL,'b-');
        plot(timez,VmotR,'r-');
        plot(timez,Vbat,'k-');
        ylabel('V_{mot} (V)');
        xlabel('t (s)');
        xlim([0 runlength]);

        subplot(3,2,2);hold all;box on;
        plot(timez,DcL,'b-');
        plot(timez,DcR,'r-');
        ylabel('Dc');
        xlabel('t (s)');
        xlim([0 runlength]);

        subplot(3,2,3);hold all;box on;
        plot(timez,ImotL,'b-');
        plot(timez,ImotR,'r-');
        ylabel('I_{mot} (A)');
        xlabel('t (s)');
        xlim([0 runlength]);

        subplot(3,2,4);hold all;box on;
        plot(timez,PowerL,'b-');
        plot(timez,PowerR,'r-');
        plot(timez,PowerTotal,'k-');
        ylabel('Power (W)');
        xlabel('t (s)');
        xlim([0 runlength]);

        subplot(3,2,5);hold all;box on;
        plot(timez,TorqueL,'b-');
        plot(timez,TorqueR,'r-');
        ylabel('Torque (N.m)');
        xlabel('t (s)');
        xlim([0 runlength]);

        subplot(3,2,6);hold all;box on;
        plot(timez,FreqL,'b-');
        plot(timez,FreqR,'r-');
        ylabel('f_{mot}^{calc} (Hz)');
        xlabel('t (s)');
        xlim([0 runlength]);

        set(h1,'Position',[50,100,1600,800]);
        saveas(h1,strcat(pathfig,filename,'_telemetry.fig'),'fig');
        saveas(h1,strcat(pathfig,filename,'_telemetry.jpg'),'jpg');
    %     export_fig(strcat(pathfig,filename,'_telemetry.jpg'),gca,'-nocrop');
        close(h1);
        
    end
    
    if plotpower==1

        h2=figure(2);clf;hold all;box on;
        set(gcf,'color','w');
        plot(timez,PowerL,'b-');
        plot(timez,PowerR,'r-');
        plot(timez,PowerTotal,'k-');
        ylabel('Power (W)');
        xlabel('Time (s)');
        xlim([0 runlength-trimind/samplingfreq]);
        ylim([0 max(PowerTotal(5:length(PowerTotal)))]);
        legend('L','R','Total');
        set(h2,'Position',[100,100,1280,200]);
%         saveas(h2,strcat(pathfig,filename,'_power.fig'),'fig');
    %     saveas(h2,strcat(pathfig,filename,'_telemetry.jpg'),'jpg');
%         export_fig(strcat(pathfig,filename,'_power.jpg'),gca,'-nocrop');
        close(h2);
        
    end
    
    timezmat{jj}=timez;
    PowerLmat{jj}=PowerL;
    PowerRmat{jj}=PowerR;
    PowerTotalmat{jj}=PowerTotal;
    
    %%
    
    if makemovie==1

        h3=figure(3);clf;
        set(gcf,'color','w');

        meanPowerTotal=zeros(1,length(timez));

        for ii=1:movstep:length(timez)

            if ii-avgwidth*samplingfreq/2<1
                avgind=1:(1+avgwidth*samplingfreq);
            else if ii+avgwidth*samplingfreq/2>length(timez)-trimind/samplingfreq
                    avgind=(length(timez)-avgwidth*samplingfreq):length(timez);
                else
                    avgind=(ii-avgwidth*samplingfreq/2):(ii+avgwidth*samplingfreq/2);
                end
            end
            meanPowerTotal(ii)=mean(PowerTotal(avgind));

            clf;hold on;box on;

    %         subplot(1,2,1);hold on;box on;
    %         plot(timez,PowerL,'b-');
    %         plot(timez,PowerR,'r-');
    %         plot(timez,PowerTotal,'k-');
    %         plot(timez(ii),PowerL(ii),'bo','markerfacecolor','b');
    %         plot(timez(ii),PowerR(ii),'ro','markerfacecolor','r');
    %         plot(timez(ii),PowerTotal(ii),'ko','markerfacecolor','k');
    %         ylabel('Power (W)');
    %         xlabel('t (s)');
    %         xlim([0 runlength-trimind/samplingfreq]);
    %         ylim([0 max(PowerTotal(5:length(PowerTotal)))]);
    % %         legend('L','R');

    %         subplot(1,2,2);hold on;box on;
            line([min(avgind)/samplingfreq max(avgind)/samplingfreq],[meanPowerTotal(ii) meanPowerTotal(ii)],'linestyle','--','color','k','linewidth',lnwz);        
            plot(timez,PowerL,'b-');
            plot(timez,PowerR,'r-');
            plot(timez,PowerTotal,'k-','linewidth',lnwz);
            plot(timez(ii),PowerL(ii),'bo','markerfacecolor','b');
            plot(timez(ii),PowerR(ii),'ro','markerfacecolor','r');
            plot(timez(ii),PowerTotal(ii),'ko','markerfacecolor','k');
            xlim([min([max([ii/samplingfreq windowwidth/2]-windowwidth/2) runlength-trimind/samplingfreq-windowwidth]) min([max([ii/samplingfreq windowwidth/2])+windowwidth/2 runlength-trimind/samplingfreq])]);
            ylim([0 max(PowerTotal(5:length(PowerTotal)))]);
            ylabel('Power (W)','fontsize',15);
            xlabel('Time (s)','fontsize',15);
            set(gca,'fontsize',15);
            title(strcat('P_{mean}=',num2str(meanPowerTotal(ii)),'W'));
    %         xlim([0 runlength-trimind/samplingfreq]);
    %         ylim([0 max([max(PowerL(5:length(PowerL))) max(PowerR(5:length(PowerR)))])]);

            set(h3,'Position',[100,100,1500,250]);
            cd D:\Desktop\movies\;
            mkdir(filename);
            cd(filename);
            export_fig(strcat(num2str(ii,'%04d'),'.jpg'),gca,'-nocrop');
            hold off;
            
        end

    end
    
end
