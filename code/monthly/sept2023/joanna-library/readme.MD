Old Program for Fitting HST/FOS Spectra.

Routines: 
    > create_asc.f: main fortran program which makes sherpa scripts, for obtaining continuum    
      +emission+absorption line fits.

Subroutines:
    > basic.f: subroutine for finding continuum windows
    > galactic.f: subroutine which finds Galactic lines to be ignored during continuum fitting
    > fe2.f: subroutine for finding blended iron emission (uses templated with different widths)
    > c4reg.f: subroutine for fitting the CIV emission line region with Gaussians
    > sio4reg.f:  subroutine for fitting  SiIV+OIV emission line region with Gaussians

Other: 
    > table2.pdf is a table with continuum windows used

Notes

- does not contain other subroutines for fitting emission line regions other than CIV and SiIV.
- Other subroutines in the tar file aren't important to use (delete?)

The create_asc.f program makes sherpa scripts and I give an example
for one of the FOS spectra you have (0005+0203oa):
0005+0203oa.asc - sherpa script for continuum fitting
0005+0203oa.ast1 - sherpa script (stage 1) for continuum+emission line
fits (where line position is fixed, and the line amplitude and width
are freed; continuum has already been fitted previously)
0005+0203oa.ast2 - sherpa stage 2 continuum+emission line fits (where
line position, width, amplitude are freed)
0005+0203oa.ast3 - sherpa script for continuum+emission
lines+absorption lines fit

I hope this helps somehow, but as you will see this code will not be
as straightforward for you to use/implement as you would like, I am afraid.