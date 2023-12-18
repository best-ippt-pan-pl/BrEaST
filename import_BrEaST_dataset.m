%%%%%%%%%%%%%%%%%%%%BrEaST dataset%%%%%%%%%%%%%%%%%%%%
%doi 1
%doi 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%define .xlsx filename and folder containing images and masks
info_filename = 'BrEaST-Lesions-USG-clinical-data-Sep-2023-with-data-dictionary-v2-Nov-7-2023.xlsx';
images_and_masks_foldername = 'BrEaST-Lesions_USG-images_and_masks/';

%read .xlsx file with clinical data
breast_dataset = readtable(info_filename);

for i = 1:size(breast_dataset)
    %parse multi-label columns
    breast_dataset{i,'Tissue_composition'} = {split(breast_dataset{i,'Tissue_composition'},'&')'};
    breast_dataset{i,'Signs'} = {split(breast_dataset{i,'Signs'},'&')'};
    breast_dataset{i,'Symptoms'} = {split(breast_dataset{i,'Symptoms'},'&')'};
    breast_dataset{i,'Margin'} = {split(breast_dataset{i,'Margin'},[" - ","&"])'};
    breast_dataset{i,'Interpretation'} = {split(breast_dataset{i,'Interpretation'},'&')'};
    breast_dataset{i,'Diagnosis'} = {split(breast_dataset{i,'Diagnosis'},'&')'};
    
    %read image
    [img, ~, alpha] = imread([images_and_masks_foldername breast_dataset.Image_filename{i}]);
    img_size = size(img);
    breast_dataset.Image_filename{i} = cat(3, img, alpha);
    
    %read tumor mask
    if(~isempty(breast_dataset{i,'Mask_tumor_filename'}{1}))
        [~, ~, alpha] = imread([images_and_masks_foldername breast_dataset.Mask_tumor_filename{i}]);
        masks = logical(alpha);
    else
        masks = [];
    end
    breast_dataset.Mask_tumor_filename{i} = masks;
    
    %read other mask
    if(~isempty(breast_dataset{i,'Mask_other_filename'}{1}))
        paths = split(breast_dataset{i,'Mask_other_filename'},'&');
        masks = false(img_size(1), img_size(2), size(paths,1));
        for j = 1:size(paths,1)
            [~, ~, alpha] = imread([images_and_masks_foldername paths{j,1}]);
            masks(:,:,j) = logical(alpha);
        end
    else
        masks = [];
    end
    breast_dataset.Mask_other_filename{i} = masks;

end

%rename columns and clear workspace
breast_dataset = renamevars(breast_dataset,["Image_filename","Mask_tumor_filename","Mask_other_filename"],["Image","Mask_tumor","Mask_other"]);
clearvars -except breast_dataset
