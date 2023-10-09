c ######################################################################

      subroutine resmin(w1,w2,a4,sample,wave2,zred,linec,wmin)

c     measures the resolution near the line to set minimum FWHM

      implicit real(a-h,l-z)
      real w1,w2,wmin,w,f1,f2,tflux,zred,linec,cn1,wave2,res
      character*40 a4
      character*4 sample

c SET MINIMUM RESOLUTION
      if(sample.eq.'mdm_')wmin=4.5
      if(sample.eq.'lbqs')wmin=10.0
      if(sample.eq.'lbqs' .and. wave2.gt.6850)wmin=6.0
      if(sample.ne.'fos_')goto 150

      open(unit=5,status='old',file=a4(1:39))
      j=0
      tflux=0.0
      do 100 i=1,50000
      read(5,*,err=110)w,f1,f2
      if(w.ge.w1 .and. w.le.w2)j=j+1
 100  continue
 110  close(5)
      wmin=3.0*((w2-w1)/j)

c delta lambda = 3 x pixel resolution
c km/s = ( delta lambda / lambda ) *  c

 150  cn1=2.99793e5
      res=(wmin/linec)*cn1
      write(1,200)wmin,res
      write(3,200)wmin,res
 200  format('# Minimum FWHM = ',f7.3,' Angstroms ( = ',
     $f7.1,' km/s)')

c      write(*,*)w1,' ',w2,' ',a4,' ',sample,' '
c      write(*,*)wave2,' ',zred,' ',linec
c      write(*,*)wmin,res

 300  return
      end

c ######################################################################
