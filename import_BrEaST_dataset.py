


#Required module
#pip install openpyxl

import pandas as pd
import cv2

#define .xlsx filename and folder containing images and masks
info_filename = r'BrEaST-Lesions-USG-clinical-data-Sep-2023-with-data-dictionary-v2-Nov-7-2023.xlsx'
images_and_masks_foldername = r'BrEaST-Lesions_USG-images_and_masks/'

#read .xlsx file with clinical data
breast_dataset = pd.read_excel(info_filename, sheet_name='BrEaST-Lesions-USG clinical dat')

for i in breast_dataset.index:
    #parse milti-label columns
    breast_dataset.at[i, 'Tissue_composition'] = breast_dataset.loc[i,'Tissue_composition'].split('&')
    breast_dataset.at[i, 'Signs'] = breast_dataset.loc[i,'Signs'].split('&')
    breast_dataset.at[i, 'Symptoms'] = breast_dataset.loc[i,'Symptoms'].split('&')
    breast_dataset.at[i, 'Margin'] = breast_dataset.loc[i,'Margin'].split('&')
    breast_dataset.at[i, 'Interpretation'] = breast_dataset.loc[i,'Interpretation'].split('&')
    breast_dataset.at[i, 'Diagnosis'] = breast_dataset.loc[i,'Diagnosis'].split('&')

    #read image
    breast_dataset.at[i, 'Image_filename']  = cv2.imread(images_and_masks_foldername+breast_dataset.loc[i,'Image_filename'], cv2.IMREAD_UNCHANGED)
    
    #read tumor mask
    if not isinstance(breast_dataset.loc[i,'Mask_tumor_filename'], float):
        mask = cv2.imread(images_and_masks_foldername+breast_dataset.loc[i,'Mask_tumor_filename'], cv2.IMREAD_GRAYSCALE)>0
        breast_dataset.at[i, 'Mask_tumor_filename']  = mask
    else:
        breast_dataset.at[i, 'Mask_tumor_filename'] = []

    #read other mask
    if not isinstance(breast_dataset.loc[i,'Mask_other_filename'], float):
        masks_bool = []
        for mask_path in breast_dataset.loc[i,'Mask_other_filename'].split('&'):
            masks_bool.append(cv2.imread(images_and_masks_foldername+mask_path, cv2.IMREAD_GRAYSCALE)>0)
        breast_dataset.at[i, 'Mask_other_filename'] = masks_bool
    else:
        breast_dataset.at[i, 'Mask_other_filename'] = []

#columns rename
breast_dataset.rename(columns={"Image_filename": "Image", "Mask_tumor_filename": "Mask_tumor", "Mask_other_filename": "Mask_other"})