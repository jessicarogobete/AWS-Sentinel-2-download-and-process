function SL2P_MSI(varargin)

if nargin ~= 2, disp({'!!!!!!!!!!!!!!!!!!!!!!!!ERROR!!!!!!!!!!!!!!!!!!!!!!!!';'--usage : python SL2P_MSI [input_file: ...\S2X_MSIL2A_xxxx.SAFE]   [output_path]'});return; end;

file_name=varargin{1};
file_name=strsplit(file_name,'/');
file_name=file_name{end};
%% 1. Read data........................................................

disp({'===============',file_name,'==============='});
disp({'--Reading data--------------------------------------'});
Input_NNT=[]; 
for bb=["B3","B4","B5","B6","B7","B8A","B11","B12"]
    file_name_band=[file_name,'_',char(bb),'.tif'];
    [band,xb,yb,Ib] = geoimread([varargin{1},'/',file_name_band]);
    [r,c]=size(band);
    Input_NNT= [Input_NNT,double(reshape(band,r*c,1))]; 
end;

for bb=["view_zenith_mean","sun_zenith","view_azimuth_mean","sun_azimuth"]
    file_name_band=[file_name,'_',char(bb),'.tif'];
    [band0,x0,y0,I0] = geoimread([varargin{1},'/',file_name_band]);
    [r0,c0]=size(band0);
    band=NaN(r,c);
    px=x0(2)-x0(1);
    py=y0(2)-y0(1);  
    for rr=1:r0
        for cc=1:c0
            cc_i=find(xb>=x0(cc)& xb<(x0(cc)+px));
            rr_i=find(yb<=y0(rr)& yb>(y0(rr)+py));
            band(rr_i,cc_i)=band0(rr,cc);
        end;
    end;
   Input_NNT= [Input_NNT,double(reshape(band,r*c,1))];
end;
Input_NNT(:,end-1)=abs(Input_NNT(:,end-1)-Input_NNT(:,end));Input_NNT(:,end)=[];
Input_NNT(:,1:end-3)=Input_NNT(:,1:end-3)/10000;
Input_NNT(:,end-2:end)=cos(deg2rad(Input_NNT(:,end-2:end))); 

%% 2. Simulating biophysical parameters.....................................
disp({'--Simulating----------------------------------------'});
%main_path=pwd;
%cd  NNET
load LAI_NNET_S2_20m
load LAI_Cab_NNET_S2_20m
load LAI_CW_NNET_S2_20m
load FAPAR_NNET_S2_20m
load FCOVER_NNET_S2_20m

LAI=reshape([sim(LAI_NET,Input_NNT')]',r,c);
LAI_Cab=reshape([sim(LAI_Cab_NET,Input_NNT')]',r,c);
LAI_Cw=reshape([sim(LAI_Cw_NET,Input_NNT')]',r,c);
FAPAR=reshape([sim(FAPAR_NET,Input_NNT')]',r,c);
FCOVER=reshape([sim(FCOVER_NET,Input_NNT')]',r,c);
%% 3. Mask indesireable targets.....................................
%eval (['cd ',main_path])
file_name_band=[file_name,'_quality_scene_classification.tif'];
[SCL,xb,yb,Ib] = geoimread([varargin{1},'/',file_name_band]);
LAI(~ismember(SCL,[4,5]))=NaN;
LAI_Cab(~ismember(SCL,[4,5]))=NaN;
LAI_Cw(~ismember(SCL,[4,5]))=NaN;
FAPAR(~ismember(SCL,[4,5]))=NaN;
FCOVER(~ismember(SCL,[4,5]))=NaN;
%% . Exporting outputs.........................................................
disp({'--Exporting-----------------------------------------'});  
output_path=[varargin{2},file_name(1:end-5),'/'];
if ~isdir(output_path)
    mkdir(output_path)
end

bbox=Ib.BoundingBox;
utmzone=strsplit(Ib.GeoAsciiParamsTag,' ');
utmzone=utmzone{6};utmzone=[utmzone(1:2),' ',utmzone(3)];
[bbox(:,2),bbox(:,1)] = utm2deg(bbox(:,1),bbox(:,2),[utmzone;utmzone]);
bit_depth=32;

for bb=["LAI","LAI_Cab","LAI_Cw","FAPAR","FCOVER"]
    out_filename=[output_path,strrep(file_name,'L2A','L3A'),'_',char(bb),'.tif'];
    geotiffwrite(out_filename, bbox, eval(bb), bit_depth, Ib);
end;
disp({'--Done !---------------------------------------------------------'});
end


