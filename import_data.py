## Import breast ultrasound data
#
# Masks are stored in a list of NumPy Array.
#
 
import pandas as pd
import cv2

def import_data(csv_file, image_folder):
    # Read the CSV file
    breast_dataset = pd.read_csv(csv_file, delimiter=',')

    # Initialize list to store masks
    masks_list = []
    
    # Initialize list to store images
    images_list = []

    # Import Images and Masks
    for i in range(len(breast_dataset)):
        image = cv2.cvtColor(cv2.imread(image_folder + breast_dataset.loc[i, 'Image_filename']), cv2.COLOR_BGR2GRAY)
        images_list.append(image)
        
        masks = []
        
        if pd.notnull(breast_dataset.loc[i, 'Mask_tumor']):
            mask_tumor = cv2.cvtColor(cv2.imread(image_folder + breast_dataset.loc[i, 'Mask_tumor']), cv2.COLOR_BGR2GRAY) > 0
            masks.append(mask_tumor)
            
            if pd.notnull(breast_dataset.loc[i, 'Mask_other']):
                if '&' in breast_dataset.loc[i, 'Mask_other']:
                    names = breast_dataset.loc[i, 'Mask_other'].split('&')
                    for name in names:
                        mask_other = cv2.cvtColor(cv2.imread(image_folder + name.strip()), cv2.COLOR_BGR2GRAY) > 0
                        masks.append(mask_other)
                else:
                    mask_other = cv2.cvtColor(cv2.imread(image_folder + breast_dataset.loc[i, 'Mask_other']), cv2.COLOR_BGR2GRAY) > 0
                    masks.append(mask_other)

        masks_list.append(masks)
    
    # Add 'Images' column to the dataset
    breast_dataset['Images'] = images_list
    
    # Add 'Masks' column to the dataset
    breast_dataset['Masks'] = masks_list

    # Remove 'Image_filename', 'Mask_tumor', 'Mask_other'
    breast_dataset = breast_dataset.drop(['Image_filename', 'Mask_tumor', 'Mask_other'], axis=1)
    
    return breast_dataset

# Function call
csv_file = 'breast_dataset.csv'
image_folder = 'images_and_masks/'
processed_dataset = import_data(csv_file, image_folder)

# Display the structure
print(processed_dataset)    