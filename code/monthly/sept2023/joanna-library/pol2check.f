c ######################################################################

      subroutine pol2check(pol2yn,dir,loop,sample)

c To check for a polynomial continuum component
c Sets pol2yn=y

      implicit real(a-h,l-z)
      integer loop
      character*1 pol2yn
      character*11 dir(2000)
      character*50 a5
      character*4 sample
      character*10 dummy

      pol2yn='n'

      a5(1:10)='/data/kf1/'
      a5(11:14)=sample
      a5(15:27)='data/ASCSAVE/'
      a5(28:38)=dir(loop)
      a5(39:43)='.SAVE'
      if(sample.eq.'mdm_')a5(9:9)='3'

      open(unit=11,status='old',file=a5(1:43))
      df1=0.0
      df2=0.0
      do 100 i=1,10000
         read(11,527,err=526)dummy
         if(dummy(1:10).eq.'polynom1d[')then
            pol2yn='y'
            write(*,*)'polynomial continuum present'
         endif
         if(dummy(1:10).eq.'polynom1d[')goto 526
 100  continue
 526  close(11)
 527  format(a10)

      return
      end
