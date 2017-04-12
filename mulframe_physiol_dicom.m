% This is an example code showing the possibility to save physiol data as dicom
% file, while try to make the file dicom-compliant, so existing dicom tools can
% read it without special hack. 
% 
% The major idea is to use NumberOfFrames to store the trace of physiol signal.
% While Rows, Columns and number of slices (no general dicom tag for slices)
% suffer from 16-bit limitation, NumberOfFrames does not (Thanks its 'IS' VR). 
% 
% The only special note users need to know is that NumberOfFrames represents
% number of points of physiol traces.

% 20170412 Xiangrui Li (xiangrui.li at gmail.com)

% fake some physiol data: 400Hz, 200 secs, 4 channels
t = linspace(0, 200, 400*200);
img = zeros(400*200, 4);
img(:,1) = sin(2*pi*70/60*t)/2 + 0.5; % sin pulse, 70 / minute
img(:,2) = cos(2*pi*18/60*t)/2 + 0.5; % cos respiration, 18 /per minute
img = uint16(img * 5000); % Siemens signal range 0~5000
img = permute(img, [2:4 1]); % trace into 4th dim, dicomwrite treats it as frames
% The unknown: Does Siemens MRI console support multiframe dicom?

% s is the dicom info struct based on EPI dicom.
% As an example, just fake several tags here:
clear s
s.TransferSyntaxUID = '1.2.840.10008.1.2.1';
s.SOPClassUID = dicomuid;
s.AcquisitionDate = '20160831';
s.AcquisitionTime = '152013.890000';
s.Manufacturer = 'SIEMENS';
s.PatientName = '4447JW';
s.ProtocolName = 'run1';

% following tags need to set up for physiol series
s.ImageType = 'DERIVED\PHYSIOLOGY\TRACES';
s.InstanceNumber = 1; % this can use SeriesNumber of EPI dicom
s.SeriesDescription = 'Pulse Respiration ECG Ext'; % order of channels
s.SeriesNumber = 998; % we can put all physiol dicom into one series
s.SeriesInstanceUID = dicomuid; % unique ID for a series
s.TemporalResolution = 2.5; % in ms, meaning 400 Hz

% % Following tags are for img size. dicomwrite will set them up based on img
% s.NumberOfFrames = size(img, 4); % number of points of physiol trace
% s.Rows = size(img, 1); % number of channels
% s.Columns = 1; % we don't use this due to limit of 2^16-1

% save the dicom file with fake info and traces
rst_nam = 'tmp_mulFrame_physiol.dcm';
warning('off', 'images:dicomwrite:inconsistentIODAndCreateModeOptions');
dicomwrite(img, rst_nam, s, 'CreateMode', 'Copy'); % Matlab image toolbox

% verify the created dicom img
img_saved = dicomread(rst_nam); % also should try other tools
isequal(img, img_saved) 
