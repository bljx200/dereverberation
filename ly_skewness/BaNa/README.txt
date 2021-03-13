
Fundamental Frequency (F0) Detection Program Instructions


The BaNa Algorithm was written by He Ba, Na Yang, and Weiyang Cai, University of Rochester. Please contact He Ba at he.ba@rochester.edu or Na Yang at nayang@rochester.edu with any questions. The code for Cepstrum F0 calculation included in the BaNa algorithm was provided by Lawrence R. Rabiner from Rutgers University and the University of California at Santa Barbara. The BaNa F0 detection algorithm was developed as part of Project Bridge at the University of Rochester within the Wireless Communications and Networking Group: http://www.ece.rochester.edu/projects/wcng/project_bridge.html. This package is available for download at the University of Rochester Wireless Communications and Networking Group's website: http://www.ece.rochester.edu/projects/wcng/code.html.  Project Bridge is funded by the National Institute of Health NICHD (Grant R01 HD060789).

This README file contains instructions for using the MATLAB code for the BaNa algorithm described in the paper:

Na Yang, He Ba, Weiyang Cai, Ilker Demirkol, and Wendi Heinzelman, "BaNa: A Noise Resilient Fundamental Frequency Detection Algorithm for Speech and Music," under revision for IEEE Transactions on Audio, Speech, and Language Processing. 

Since in the BaNa paper we focused on the evaluation of the F0 detection algorithms, voiced/unvoiced detection is not a criteria. Thus, we use the ground-truth F0 detection results as the voice marker, and only evaluate the F0 detection algorithms for the voiced data. Therefore, in the implementation of the BaNa algorithm 'Bana.m' and 'Bana_music.m', the ground-truth voice marker is used as one of the input parameters. For general F0 detection purposes beyond the BaNa paper, the files 'Bana_auto.m' and 'Bana_music_auto.m' should be used instead, as these include a function that can automatically differentiate voiced/unvoiced frames before detecting F0 values.

Version: April 2014.



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


			BaNa F0 detection algorithm


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

All the MATLAB code for the BaNa F0 detection algorithm is included in the folder named 'BaNa F0 detection algorithm'.
- Bana.m: Implementation of the BaNa algorithm for F0 detection in speech. Voice marker is needed as one of the input parameters.

- Bana_auto.m: Implementation of the BaNa algorithm for F0 detection in speech with automatic voiced/unvoiced detection. Not used in the paper.

- Bana_music.m: Implementation of the BaNa music algorithm for F0 detection in music. Music marker is needed as one of the input parameters.

- Bana_music_auto.m: Implementation of the BaNa music algorithm for F0 detection in music with automatic music/not music detection. Not used in the paper.

- f0_decision_maker.m: called by Bana.m. Uses the frequency ratios of spectral peaks to find F0 candidates and their confidence scores.

- findpeaks.m: called by Bana.m. The spectral peak selection function is provided by Thomas O'Haver, http://terpconnect.umd.edu/~toh/spectrum/PeakFindingandMeasurement.htm.

- Path_finder.m: called by Bana.m. Uses the Viterbi algorithm to find a path through F0 candidates for all frames with the minimum cost, which determines the final F0 results.

- Cal_transition_cost_score.m: called by Path_finder.m. Calculates the transition cost between F0 candidates of neighboring frames, based on the F0 difference and the F0 candidate's confidence score.

- Viterbi.m: called by Path_finder.m. Implementation of the Viterbi algorithm.



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


		       Other F0 detection algorithms


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

For research purposes, the source code for other F0 detection algorithms are included in this package as well. The folder named 'Other F0 detection algorithms' contains the source code for the YIN, HPS, Cepstrum, and PEFAC F0 detection algorithms. Since the Praat, SAFE and Wu algorithms are not implemented in MATLAB, we do not include their code in this package. All the references and downloaded information for these algorithms are provided as follows.

YIN:
- YIN.m: Implementation of the YIN algorithm. The file YIN.m and the folder named 'private' contain source code for the YIN algorithm. This code was written by Alain de Cheveigne, CNRS/Ircam, 2002. Copyright (c) 2002 Centre National de la Recherche Scientifique. The source code was downloaded from: http://audition.ens.fr/adc/. A. de Cheveigne and H. Kawahara, "YIN, a fundamental frequency estimator for speech and music," Journal of the Acoustical Society of America, vol. 111, pp. 1917-1930, 2002;

HPS:
- hps.m: Implementation of the HPS algorithm. M. R. Schroeder, "Period histogram and product spectrum: New methods for fundamental frequency measurement," Journal of the Acoustical Society of America, vol. 43, pp. 829-834, 1968. The code hps.m was written by He Ba, University of Rochester.

Cepstrum:
- cepstral.m: Implementation of the Cepstrum method. A. M. Noll, Cepstrum pitch determination, Journal of the Acoustical Society of America, vol. 41, pp. 293-309, 1967. MATLAB code was provided by Dr. Lawrence R. Rabiner, Rutgers University and University of California at Santa Barbara, L. R. Rabiner and R. W. Schafer, "Theory and Application of Digital Speech Processing," Pearson, 2011;

- smoothpitch.m: called by cepstral.m. Cepstrum F0 period smoothing routine based on first and second candidates and associated confidence levels. 

- medf.m: called by cepstral.m. Median filter Cepstrum F0 detection results.

PEFAC:
- voicebox: contains source code for the PEFAC F0 detection algorithm. Code downloaded from: http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html. S. Gonzalez and M. Brookes, "A pitch estimation filter robust to high levels of noise (PEFAC)," in In Proc. European Signal Processing Conf., Barcelona, Spain, 2011.

Praat:
- The Praat F0 detection software was download from: http://www.fon.hum.uva.nl/praat/. P. Boersma, "Accurate short-term analysis of the fundamental frequency
and the harmonics-to-noise ratio of a sampled sound," in Proceedings of the Institute of Phonetic Sciences 17, 1993, pp. 97-110. F0 values detected by Praat are included in the folder 'Performance evaluation/Praat detected F0'.

SAFE:
- The SAFE F0 detection toolkit was downloaded from: http://www.ee.ucla.edu/weichu/safe/. W. Chu and A. Alwan, "SAFE: A statistical approach to F0 estimation under clean and noisy conditions," IEEE Transactions on Audio, Speech, and Language Processing, vol. 20, no. 3, pp. 933-944, March 2012.

WU:
- The Wu F0 detection toolkit was downloaded from: http://www.cse.ohio-state.edu/pnl/software.html. M. Wu, D. Wang, and G. J. Brown, "A multipitch tracking algorithm for noisy speech," Speech and Audio Processing, IEEE Transactions on, vol. 11, no. 3, pp. 229-241, May 2003.



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
                                                                          
                                              
		      F0 detection performance evaluation                       
                                                                         

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Audio files and code for F0 detection performance evaluation for all algorithms on noisy speech or music files. Used to generate the results in the BaNa paper.

***********************************
	Generate noisy files

***********************************
- add_noise.m: add each one of the 8 types of noise with different levels of SNR (0 dB to 20 dB) to clean speech files or music files. The added noise's energy level is adjusted according to the original signal's energy. The signal's Root Mean Square (RMS) energy is only calculated on audible signal segments. The generated noisy speech files are stored in the folder 'Audio files/Noisy speech', and the generated noisy music files are stored in the folder 'Audio files/Noisy music'.

- Cal_RMS.m: called by add_noise.m. Calculate the root mean square value (RMS) of a vector, which is further used to calculate the signal's energy.

- srconv.m: called by add_noise.m. Function to convert sampling rate from one sampling rate to another, so long as the sampling rates have an integer least common multiple. Used to resample the pure noise signal before adding it to the clean speech or music signal.


***********************************
      F0 detection evaluation

***********************************
Evaluate all the F0 detection algorithms on noisy speech or music samples. This is used to generate the evaluation results in the BaNa paper.

- Evaluate_speech.m: read noisy speech files and then apply F0 detection algorithms BaNa, YIN, HPS, Praat, Cepstrum, and PEFAC to the files. F0 values detected by all the algorithms are compared with the ground truth. The F0 detection performance is calculated in terms of Gross Pitch Error (GPE) rate, which is the percentage of incorrectly detected F0 values in voiced speech or music segments. For speech, detected F0 values deviating more than 10% of the ground truth are counted as errors. Plots for performance comparisons are generated. 

- Evaluate_music.m: read noisy music files and then apply F0 detection algorithms BaNa, YIN, HPS, Praat, and Cepstrum to the files. F0 values detected by all the algorithms are compared with the ground truth. GPE rates for all the algorithms are calculated. For music, detected F0 values deviating more than 3% (one music quarter tone) of the ground truth are counted as errors. Plots for performance comparisons are generated.

Note that the user needs to generate the noisy speech files or noisy music files first, using add_noise.m, before running the performance evaluation programs.


***********************************
	Speech Databases 

***********************************
Clean speech samples are in the folder: Audio files/Clean speech

Links for speech databases:
- LDC: "Emotional prosody speech and transcripts database from Linguistic Data Consortium (LDC)," http://www.ldc.upenn.edu/Catalog/catalogEntry.jsp?catalogId=LDC2002S28.

- Arctic: "CMU Arctic Database," http://www.festvox.org/cmu arctic/.

- CSTR and KEELE speech samples are included in the SAFE toolkit: http://www.ee.ucla.edu/weichu/safe/.


***********************************
	Music Samples

***********************************
Clean music samples are in the folder: Audio files/Clean music. These music pieces include a piece of 3.7 s long violin with 9 notes, a piece of 12.9 s long trumpet with 12 notes, a piece of 5.3 s long clarinet with 4 notes, and a piece of 7.8 s long piano with 8 notes. Music pieces are selected and downloaded from: "Freesound website for short pieces of music download," http://www.freesound.org/.


***********************************
	Noise Samples 

***********************************
Eight pure noise files are in the folder: Audio files/Pure noise. These noise files are selected from the noise database from Rice University: http://spib.ece.rice.edu/spib/data/signals/noise/.


***********************************
	F0 Ground Truth

***********************************
F0 ground truth values are derived from clean speech files or clean music files, and are stored in the folder 'Ground truth'. For speech, F0 ground truth values are calculated by averaging the detected F0 values of three algorithms: BaNa, YIN and Praat. For F0 detection in music, we use hand-labeled ground-truth F0 values, which are determined by manually inspecting the spectrum and locating the F0 peaks for each frame.

- Cal_groundtruth.m: calculate F0 ground truth F0 values for speech wave files. 

- plot_groundtruth: plot F0 ground truth values for one speech file.



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 


			BaNa Android app


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











