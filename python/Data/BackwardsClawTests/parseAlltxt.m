% parses all CSV OptiTrack files in a directory

%Parses all CSV files in directory

files = dir('*.txt');
numfiles = length(files);

for n=1:numfiles;
    disp(['Importing ' files(n).name]);
    DATA(n) = importVRTelem_ip25_JL(files(n).name);
end