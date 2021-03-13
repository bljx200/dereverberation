* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


	  BaNa Fundamental Frequency (F0) Detection Android App


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

Thomas Horta, visiting student at the University of Rochester, implemented the BaNa F0 detection algorithm on an Android platform as part of Project Bridge at the University of Rochester within the Wireless Communications and Networking Group: http://www.ece.rochester.edu/projects/wcng/project_bridge.html. The installation package 'BaNa.apk' is available for download at the University of Rochester Wireless Communications and Networking Group's website:  http://www.ece.rochester.edu/projects/wcng/code.html.  Project Bridge is funded by the National Institute of Health NICHD (Grant R01 HD060789).

The BaNa Algorithm was described in the paper: Na Yang, He Ba, Weiyang Cai, Ilker Demirkol, and Wendi Heinzelman, "BaNa: A Noise Resilient Fundamental Frequency Detection Algorithm for Speech and Music," under revision for IEEE Transactions on Audio, Speech, and Language Processing. Please contact He Ba at he.ba@rochester.edu or Na Yang at nayang@rochester.edu with any questions. The code for Cepstrum F0 calculation included in the BaNa algorithm was provided by Lawrence R. Rabiner from Rutgers University and the University of California at Santa Barbara.

To detect F0, the user can either load a speech file that is stored on the phone, or record a short piece of speech. Some basic parameters in the BaNa algorithm can be adjusted by the user:
- f0min: lower bound of human speech F0. Default value: 50 Hz
- f0max: upper bound of human speech F0. Default value: 600 Hz
- framelength: frame length in seconds.  Default value: 0.06 s
- timestep: time step of detected F0 in seconds. Default value: 0.01 s
- pthr1: amplitude ratio of the two highest Cepstrum peaks, used for voiced/unvoiced detection. A higher value provides a more stringent threshold for voiced frame detection. If pthr1 = 1, all frames are regarded as voiced. pthr1 is a value greater than or equal to 1. Default value: 1.5

There are also several performance parameters that can be tuned by the user:
- BaNa Thread Number: since the F0 candidates and their confidence scores can be calculated separately for each frame, we can take advantage of multithreading to speed up the BaNa app. Single-core and multi-core devices can both benefit from multithreading through an increased utilization of the processor(s). Default value: 2
- FFT Thread Number: multithreading in computing the FFT. Default value: 4
- fftpower: the size of the FFT is 2 to the power of fftpower. Default value: 13 (FFT size = 2^13)

The generated F0 detection results are stored in a text file at: BaNa/results/BaNa_output.txt. We are continuing development of the BaNa app in order to plot the F0 detection results on the screen and to turn this into a real-time F0 detector.

Version: August 2013.


