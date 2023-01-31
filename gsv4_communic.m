%% Programmed by Elis Castro & Michel Amberg 
%%% communication with the 4 channel measuring amplifier GSV-4 (feb 2021)%%%
clc; clear all;

unlock = char([38 1 98 101 114 108 105 110]);       % you can find these codes on the datasheet, page 38
lock   = char([38 0 98 101 114 108 105 110]);
efw    = char([59 43 1  0 1 50 52 49 20 13 10]);

f0x=3.282125833333333e+04;                          % for our device, these were the values for (fx,fy,fz)=(0,0,0)
f0y=3.285770000000000e+04;
f0z=3.026341666666667e+04;

% check presence and start communication
if exist('gsv')
%     read(s, 1000, "char");
    clear('gsv'); 
end
gsv = serialport('COM3', 115200, 'Timeout', 1);     % Timeout in seconds. COM3 was the name attributed in my pc, please check it for yours in your device manager

write(gsv,35,"char");                               % stop transmission
read(gsv, 30, "char");

write(gsv,'+',"char");                              % '+' or 43 - ask for firmware version (also in the datasheet, page 33)
fwn = read(gsv, 11, "char");
if (string(fwn) ~= string(efw))                     % confirm the firmware version
    disp(double(fwn));
    error('GSW4 not connected or Firmware error!'); 
end

% initialization
write(gsv,unlock,"char");                           % '...1 berlin'
write(gsv,[18 160+8],"char");                       % configurer la vitesse ('8'=25 mesures/s)

write(gsv,36,"char");                               % start transmission
fz = 0;
while 1
    l  = read(gsv,11,'char');                       % force values - prefix channel1 channel2 channel3 channel4 postfix
                                                    % *0.000980661 -> conversion to newtons
    fx = (double(l(2))*256 + double(l(3))-f0x)*0.000980661;
    fy = (double(l(4))*256 + double(l(5))-f0y)*0.000980661;
    fz = (double(l(6))*256 + double(l(7))-f0z)*0.000980661;
    disp([double(fx) double(fy) double(fz)]);
end