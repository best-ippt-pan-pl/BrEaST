%% Import breast ultrasound data
%
% When more than one mask is assigned to an image, the subsequent masks are
% stored as the next dimension, e.g: The image is 600x800 and three 
% different masks are assigned to it, so the variable for the masks of this 
% image will be 600x800x3.
% 
%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 22);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["CaseID", "Image_filename", "Mask_tumor", "Mask_other", "Pixel_sizeX", "Pixel_sizeY", "Age", "Tissue_composition", "Signs", "Symptoms", "Shape", "Margin", "Echogenicity", "Posterior_features", "Halo", "Calcifications", "Skin_thickening", "Interpretation", "BIRADS", "Verification", "Diagnosis", "Classification"];
opts.VariableTypes = ["double", "string", "string", "string", "double", "double", "double", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical", "categorical"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Image_filename", "Mask_tumor", "Mask_other"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Image_filename", "Mask_tumor", "Mask_other", "Tissue_composition", "Signs", "Symptoms", "Shape", "Margin", "Echogenicity", "Posterior_features", "Halo", "Calcifications", "Skin_thickening", "Interpretation", "BIRADS", "Verification", "Diagnosis", "Classification"], "EmptyFieldRule", "auto");

% Import the data
breast_dataset = table2struct(readtable("./breast_dataset.csv", opts));

%% Clear temporary variables
clear opts

%% Import Images and Masks
folder = "images_and_masks/";
for i=1:height(breast_dataset)
    breast_dataset(i).Images = rgb2gray(imread(strcat(folder,breast_dataset(i).Image_filename)));
    if (breast_dataset(i).Mask_tumor=="")==0
        mask=imread(strcat(folder,breast_dataset(i).Mask_tumor));
        mask = rgb2gray(mask) > 0;
        if (breast_dataset(i).Mask_other=="")==0
            if contains(breast_dataset(i).Mask_other, '&')
                names = split(breast_dataset(i).Mask_other, '&');
                for ii=1:length(names)
                    tmp=imread(strcat(folder,names(ii)));
                    tmp = rgb2gray(tmp) > 0;
                    mask(:,:,ii+1) = tmp;
                end
            else
                tmp=imread(strcat(folder,breast_dataset(i).Mask_other));
                tmp = rgb2gray(tmp) > 0;
                mask(:,:,2) = tmp;
            end
        end
        breast_dataset(i).Mask=mask;
        clear tmp mask names
    end
end

clear folder i ii

%% Remove 'Image_filename', 'Mask_tumor', 'Mask_other'
breast_dataset = rmfield(breast_dataset,{'Image_filename', 'Mask_tumor', 'Mask_other'});