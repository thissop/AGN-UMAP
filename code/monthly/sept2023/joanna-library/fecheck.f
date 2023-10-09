c ######################################################################

      subroutine fecheck(feyn,feoyn,dir,loop,sample)

c To re-set feyn and feoyn to only choose those objects with non-zero
c Fe flux.

      implicit real(a-h,l-z)
      integer loop
      character*1 feyn,feoyn
      character*11 dir(2000)
      character*50 a5
      character*4 sample
      character*18 dummy

      feyn='n'
      feoyn='n'

      a5(1:10)='/data/kf1/'
      a5(11:14)=sample
      a5(15:27)='data/ASCSAVE/'
      a5(28:38)=dir(loop)
      a5(39:45)='.FESAVE'
      if(sample.eq.'mdm_')a5(9:9)='3'

      open(unit=11,status='old',file=a5(1:45))
      df1=0.0
      df2=0.0
      do 100 i=1,10000
         read(11,527,err=526)dummy
         if(dummy(1:15).eq.'umfe.ampl.max =')then
            read(11,528)dummy,df1
         endif
         if(dummy(1:16).eq.'umfeo.ampl.max =')then
            read(11,528)dummy,df2
            goto 526
         endif
 100  continue
 526  close(11)
 527  format(a16)
 528  format(a18,f12.7)

c      write(*,*)df1,' ',df2

      if(df1.gt.0.0)feyn='y'
      if(df2.gt.0.0)feoyn='y'

      return
      end
