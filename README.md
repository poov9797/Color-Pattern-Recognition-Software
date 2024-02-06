# Color Pattern Recognition in MATLAB

## Overview
This MATLAB project automates the recognition of color patterns in images, inspired by Lego's Life of George game. The software reads a supplied image, detects color patterns using image processing techniques, and outputs an array of color names. The implementation achieves up to 91% accuracy, with functions for image loading, circle detection, distortion correction, and color extraction.

## Getting Started
1. Ensure you have MATLAB installed on your system.
2. Clone the repository to your local machine.
   ```bash
   git clone https://github.com/your-username/color-pattern-recognition.git
   ```
3. Open MATLAB and navigate to the project directory.

## Usage
1. Run the `findColours` function with the filename of the image you want to process.
   ```matlab
   colorArray = findColours('your_image.png');
   disp(colorArray);
   ```
2. View the processed image with corrected distortion by the `correctImage` function.

## Functions
- **`loadImage(filename)`**: Loads an image and converts it to a double-precision array.
- **`findCircles(image)`**: Detects the coordinates of the four largest black circles in the image.
- **`correctImage(coordinates, image)`**: Corrects image distortion using specified coordinates.
- **`getColours(image)`**: Extracts color patterns from the image and returns a 4x4 matrix of color names.

## Results
Check the provided table for success rates on sample images, including accuracy percentages and notes on challenges.

## References
Explore the code's foundation based on techniques like connected component labeling, image thresholding, and perspective transformation. See references in the provided appendix.

## Contributors
Poovarasan Rajendiran
