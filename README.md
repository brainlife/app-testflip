# Algorithm to detect bvecs flipping

Incorrect bvecs polarity would lead to incorrect processing of DWI data. This app will quickly check the dwi image to see if any bvecs directions needs to be flipped. The algorithm find bvecs that are pointing toward certain direction and find the volume slice within 4D DWI data and see if the image indeed seems to contain features that are orthogonal to the bvecs directions.


