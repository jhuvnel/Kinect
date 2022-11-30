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

### getCMdata

This function finds the 3D coordinates of the center of mass for each set of kinect data points in the jointData array (see getJointData function for more info) and centers the data based on mean or median, if specified.

Required inputs:
* jointData: n x m x j double
	* output of getJointData function
	* n = number of dimensions (3)
	* m = number of data points per joint
	* j = number of joints (25)
* mass: double
	* Mass of the subject in kg
* gender: char
	* Either 'f' for female or 'm' for male
	* The coefficients used in the CM calculations are different for males and females

Optional input:
* center_opt: string
	* Either 'mean' or 'median'
	* The specified metric for each dimension will be subtracted from all data points in that dimension to center the data.
	* If left blank, the function will return the uncentered data

Output:
* fullbody_cm: n x m double
	* n = number of data point sets
	* m = number of dimensions (3)
	
### truncateSignalandTimeData

This function truncates  a joint info or CM array, timeInts vector, and timeVec vector based on user specified cutoffs.
* Name changed from truncateCMandTimeData

Inputs
* Signal: n x m double
	* Can be obtained from the getCMdata function
	* n = number of data point sets
	* m = number of dimensions
* timeVec: double
	* Vector of timestamp values
	* Obtained from the getJointData function
* timeInts: double
	* Vector of elapsed time between consecutive data points
	* Appended with 33 (copied from Meg's scripts)
	* Obtained from the getJointData function
* lower_cutoff: double
	* All points that occur before this many seconds have elapsed will be truncated
	* ex: if lower_cutoff = 10, the first 10 seconds will be deleted
* upper_cutoff: double
	* all points that occur less than this many seconds from the end of the data will be truncated
	* ex: if upper_cutoff = 10, the last 10 seconds will be deleted

Outputs
* truncated_signal: n x m double
	* n = number of data point sets after truncation
	* m = number of dimensions
* truncated_timeVec: double
	* truncated vector of timestamp values
* truncated_timeInts: double
	* truncated vector of elapsed time between consecutive data points


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
* basis for getCMdata function

### linearSwayDist
* finds the length of the sway path for specified joints
* can be modified to include center of mass

### sway_metrics
* will eventually be used to extract relevant metrics from kinect sway data

### balansens_truncation
* script for attempting to truncate trial data based on balansens data for better trial start/stop accuracy

### start_stop_signal_test
* script for finding the start and stop of trials from a hand signal

### visualize_truncation
* creates a plot of truncated data to confirm truncation cutoffs are accurate

### mvi_excel_template
* template script for creating spreadsheets to organize kinect data
