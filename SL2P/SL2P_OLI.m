function SL2P_OLI(file_path,output_path)

disp({'--usage : python SL2P_OLI [input_file: [:,8].\xxxx.mat] [output_path: .\output_path\]'})

% 1. Importing data........................................................
SPECT=importdata(file_path);
load LAI_NNET_L8_30m
load LAI_Cab_NNET_L8_30m
load LAI_Cw_NNET_L8_30m
load FAPAR_NNET_L8_30m
load FCOVER_NNET_L8_30m

% 2. Creating output_path..................................................
if ~isdir(output_path)
    mkdir(output_path)
end

% 4. Simulating biophysical parameters.....................................
BIO(:,1)=[sim(LAI_NNET_L8_30m,SPECT')]';
BIO(:,2)=[sim(LAI_Cab_NNET_L8_30m,SPECT')]';
BIO(:,3)=[sim(LAI_Cw_NNET_L8_30m,SPECT')]';
BIO(:,4)=[sim(FAPAR_NNET_L8_30m,SPECT')]';
BIO(:,5)=[sim(FCOVER_NNET_L8_30m,SPECT')]';

% . Saving outputs.........................................................
output_file=strsplit(file_path(1:end-4),'\');
output_file=['BIO_',output_file{end}];

eval([output_file,' = ', 'BIO',';']);
save ([output_path,output_file,'.mat'],num2str(output_file));

end