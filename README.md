# connect4
Minimax connect 4 algorithm as well as a pygame-built GUI. From the video you can see that the algorithm (who played yellow) doesn't differentiate between a guaranteed victory now or a guaranteed victory later.

The minimax file must be compiled for your system using cython (`pip install Cython`).

All the files should be in the same folder. Then, while in that folder, compile the processor.pyx file by running
`py compiler.py build_ext --inplace`

Then run connect4.py to play.
