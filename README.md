Biomedical Optics Laboratory Segmentation Code
==============================================
Directory Contents:
-------------------

###Calibration Data

True-positive and false-positive sets for neural network training. Kept for records. If applied to a new set of images, it is best to use your own training images for best results.

###Cropped Images for Hand Segmentation

Hand Segmented Images, used for comparison as a standard.

###GMRF

Gaussian Markov Random Field Segmentation Algorithm (Luck et al. 2005)

###HS_Script

Outputs segmentation analysis for given image. Use HS_script.

###Image Model

Image model generator. Use imodel.m to generate initial model. Use imodel2 to add contrast and noise. The image model generates a "8-bit" image in a 16-bit container, so output may not be visible to the user (This allows for pixel values greater than 255).

###Overlap

Compares segmentation results between two images. Defines object/pixel overlap. Use overlap.m

###SCM_GUI_V2_FINAL

SCM segmentation algorithm. Use SCM_seg.m

###Training Images

Training images at 4 depths. 
