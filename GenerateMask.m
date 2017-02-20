function mask = GenerateMask(fn)

vol = ReadFile(fn,64,0);
mask = BrainMask(vol,0,0);