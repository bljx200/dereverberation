This package contains a Matlab reference implementation of a novel algorithm
to estimate the direct-to-reverberant energy ratio (DRR)
blindly from a dual-channel reverberant speech signal.

Within the Matlab script 'DRR_est_example.m', a speech
signal is convolved with room impulse responses
having various DRR values. The subsequent framewise
DRR estimation procedure is illustrated over time
showing also the true DRR obtained directly from
the room impulse response.

Related paper:
M. Jeub, C.M. Nelke, C. Beaugeant, and P. Vary:
"Blind Estimation of the Coherent-to-Diffuse Energy Ratio From Noisy
Speech Signals", Proceedings of European Signal Processing Conference
(EUSIPCO), Barcelona, Spain, 2011

Copyright (c) 2011, Marco Jeub
Institute of Communication Systems and Data Processing
RWTH Aachen University, Germany
Contact information: jeub@ind.rwth-aachen.de

Version history:
v1.0 - initial version (August 2011)

The provided speech signal is taken from the TSP
database and the room impulse responses from the
AIR database.