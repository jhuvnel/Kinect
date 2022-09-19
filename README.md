# Kinect
Analysis of Kinect files for Posture and Gait (BOT2, Modified Romberg)

## Functions
### getJointData
This function loads data from a .txt kinect file into a 3d array of joint coordinates, with optional time vector outputs

To ignore outputs, use ~
* Ex: [~, ~, timeInts] = getJointData(file_path) will return only the timeInts vector for the specified file

Input
* file_path: string
  * Path to .txt kinect file

Outputs
* jointData: n x m x j double
  * n = number of axes
  * m = number of data points per joint
  * j = number of joints (25)
* timeVec: double
  * Returns a vector of timestamps
* timeInts: double
  * Returns elapsed time between consecutive data points
  * Appended with 33 (copied from Meg's scripts)

## Scripts
### jointSway_copy and readJoint_copy
* slightly modified copies of existing scripts written by Meg Chow
* readJoint_copy is the basis for the getJointData function
* jointSway_copy is being adjusted to return sway as the difference in hip and ankle positions

### center_of_mass_single
* finds the center of mass from a single set of kinect points
* basis for center_of_mass_sway

### center_of_mass_sway
* tracks the changes in center of mass position over time for a single kinect recording
* planning to make this a function

### linearSwayDist
* finds the length of the sway path for specified joints
* can be modified to include center of mass

### sway_metrics
* will eventually be used to extract relevant metrics from kinect sway data
