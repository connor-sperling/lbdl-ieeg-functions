subj = '';
ref = '';
study = '';
task = '';


fid = fopen('predictorsRT_ST28_Naming.txt');
pred = textscan(fid,'%s %s %s %s %s');
fclose(fid);

load(sprintf('%s_TvD.mat', sabv), 'TvD'); 

elecs = {TvD{:,2}}';

for ii = 1:length(elecs)

   load(sprintf('All_%s_%s_%s.mat', subj, elecs{ii}, ref));
   
   sig_idcs = TvD{ii,5};

   %length(z)*(1000/srate)>200
   z1 = round(srate):round(1200*(srate/1000));
   z2 = (round(1200*(srate/1000))+1):round(1400*(srate/1000));  
   z3 = (round(1400*(srate/1000))+1):round(1600*(srate/1000));  
   z4 = (round(1600*(srate/1000))+1):round(1800*(srate/1000));  
   z5 = (round(1800*(srate/1000))+1):round(2000*(srate/1000));      

   if ~isempty(intersect(z,z1))
       
       y1 = double(squeeze(mean(ERP_A(:,z1),2)));
       
   else
       
       y1=zeros(size(ERP_A,1),1);
       
   end
   
   
   if ~isempty(intersect(z,z2))
       
       y2 = double(squeeze(mean(ERP_A(:,z2),2)));
       
   else
       
       y2=zeros(size(ERP_A,1),1);
       
   end
   
   
   if ~isempty(intersect(z,z3))
       
       y3 = double(squeeze(mean(ERP_A(:,z3),2)));
       
   else
       
       y3=zeros(size(ERP_A,1),1);
       
   end    
   
   
   if ~isempty(intersect(z,z4))
       
       y4 = double(squeeze(mean(ERP_A(:,z4),2)));
       
   else
       
       y4=zeros(size(ERP_A,1),1);
       
   end    
   
   
   if ~isempty(intersect(z,z5))
       
       y5 = double(squeeze(mean(ERP_A(:,z5),2)));
       
   else
       
       y5=zeros(size(ERP_A,1),1);
       
   end    


    %y = double(squeeze(mean(ERP_A(:,z),2))); % all trials at time-points "z"

    RFileName = ['RT_elec_5wind_stim' num2str(e) '.txt'];
    fileID = fopen(RFileName, 'wt');

    % Create column titles and write to file
    sublist = [];
    for i = 1:length(pred)
        sublist = [sublist pred{i}{1} ' '];  % So one column heading for each predictor (same names as R script)
    end
    %sublist = [sublist 'y']; % add column name for ecog data
    sublist = [sublist 'y1 ' 'y2 ' 'y3 ' 'y4 ' 'y5']; % add column name for ecog data
    fprintf(fileID, '%s', sublist);
    fprintf(fileID, '\n');

    % Write each value to the file for R
%             for k = 1:length(y(:,1))  % for each object
%                 sublist = [];
%                 for i = 1:length(pred)  % for each predictor
%                     sublist = [sublist pred{i}{k+1} ' '];  % +1 as first row are headings
%                 end
%                 sublist = [sublist num2str(y(k))];
%                 fprintf(fileID, '%s', sublist);
%                 fprintf(fileID, '\n');
%             end
    for k = 1:length(y1(:,1))  % for each object
        sublist = [];
        for i = 1:length(pred)  % for each predictor
            sublist = [sublist pred{i}{k+1} ' '];  % +1 as first row are headings
        end
        sublist = [sublist num2str(y1(k)) ' ' num2str(y2(k)) ' ' num2str(y3(k)) ' ' num2str(y4(k)) ' ' num2str(y5(k))];
        fprintf(fileID, '%s', sublist);
        fprintf(fileID, '\n');
    end

    fclose(fileID); % Close the stats file

            

        

            
    clear ERP_A terms_f terms_p terms_name start_idx end_idx w terms_f_all terms_p_all terms_name_all
   
end        
% Run the model in R
%!R CMD BATCH --save lme_test_R.r temp_test.out