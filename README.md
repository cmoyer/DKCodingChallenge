# DKCodingChallenge

## Running this code:
In order to run this code, you will need to add the `latestSwing.csv` file to the Resources folder in the playground. This way the code will be able to extract all of the data into our data structure and run the functions against it. 

## Code Organization
I tried to break up this playground file into various sections and tag them with `//MARK:` as I would do in actual iOS projects. 

### Data Model
At the beginning of the file you will see the Data Model which is the model class that stores the information about a single swing. 

### Custom Error Handling
The next section was the start of custom error handling that I would implement in an actual application so that if one of our validations failed, we could return a nice, easy to understand error message rather than just returning -1.

### Validation functions for the parameters
This section includes functions that validate the parameters that were used when calling the functions. This ensures that we have non-negative values for our index parameters among other validations.

### The 4 main functions
This section is where you will find the 4 main functions for the coding challenge. 

### Unit Tests
This section contains two classes: `ValidationTests` and `MainFunctionTests`. These our the unit tests for all of our validation functions as well as the 4 main functions. 

### Get data from csv file
In this section, we look for a resource file named `latestSwing` with an extension of `.csv`. If we find the file, we loop through and gather all of the data and put it in our data structure `FullSwing`.

### Run our 4 functions
The last section is just an if let statement that unwraps the latestSwing variable and calls each of the 4 main functions with parameters related to data found in the .csv file.

## Data Structure Reasoning:
I decided on using arrays as the main datastructure for the data based on a few things. Initially when I first read Mike's suggestion in the email about operating on this data in a sequential fashion, I immediately thought of using linked lists because it is very quick and easy to add additional elements to the end of the linked list (O(1)) compared to the speed of adding new elements to the end of the array (O(n)). Once I thought about what we were trying to gather with our four main functions (the starting index of continuity or start/end pairs of indices), I realized that an array would probably be better because it is quicker to access an array at an exact point (O(1)) compared to a linked list (O(n)). We only would need to store the information initially at the beginning, but we could run functions on the data multiple times so in terms of time complexity, I decided it would be better to go with an array. 

## Assumptions:
For our functions in this coding challenge, I am making the assumption that when searching for continuity, we are actually just ensuring we don't have any large spikes between data points. In the code I check to make sure the jump isn't larger than 2. This would allow us to handle some potentially aggressive acceleration & rotation, but also recognize outliers where we have spikes that increase or decrease by values larger than 10.

## Interesting Threshold Values:
When looking through the data I found some threshold values that would produce some interesting/meaningful data based on which Signal we are processing. Below are some of the values I thought contained some meaningful data.

Ax: Around the 2.5 or -2.5 mark 
Ay: Above 1.2
Az: Around the 1.5 or -1.5 mark

Wx: Between -4.0 & 4.0
Wy: Around the 2.5 or -2.5 mark
Wz: between ~ -7 to -1 or above the 1.2 mark

For the threshold values of our Accelerometer [Ax, Ay, Az], I chose these values because this seems like the area where the batter is really starting to drive the power behind their swing. The resting values seem to be near the range of -0.5 to 0.5 which can be attributed to the effect of gravity on the accelerometer.

For the threshold values of our Gyroscope [Wx, Wy, Wz], I chose these values because the gyroscope is measuring the rotation of the swing. As a player or hitting coach, I would be most interested in how the bat is rotating during the start of the swing prior to making contact with the ball, as well as, the rotation of the bat after making contact with the ball. These sets of rotations are what will drastically improve my hitting ability and the placement of the ball once it exits the bat. 

## Finding Threshold Automatically:
If we were to try and find these threshold values automatically, my first thought would be to use linear regression on the dataset so we can find the trendline of the points. We could then use that trendline value as the starting basis for our threshold.

## Additional Thoughts:
While working with the data in latestSwing.csv, it occurred to me that the handedness of the hitter could affect the positive/negative aspect of the values. E.g. If this file is someone that is a right-handed hitter, do the positive and negative values swap if someone who is left-handed swings the bat?

## Finally, when do we actually hit the baseball?
I believe that the batter actually makes contact with the baseball near row 878 of the data (timestamp: 1095092) or potentially a little before it. The reason I think it is at row 878 is that all of the values leading up to this point seem to be getting larger in a positive or negative fashion. Right around this index, we see a lot of the data break continuity in an extreme fashion. However, almost immediately after this index, we see the data swap the sign values for each Signal respectively. To me, this indicates a a batter starting to rotate the bat through the ball, around their body, back towards the catcher/umpire. This would be acceleration and rotation in the opposite direction than the beginning of the swing which is why we see the Signal values swap their signs.
