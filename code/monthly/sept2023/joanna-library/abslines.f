c ###################################################

      subroutine abslines(sample,loop,dir,stage,zred,wave2,
     $nalines,al,afw,wmin)

c Initializes the absorption line gaussians from the data produced by
c FINDSL. The total number of absorption lines = nalines

      implicit real(a-h,l-z)
      real zred,al(1000),afw(1000),wave2,wmin,low,upp
      real reg(14,2)
      integer loop,nalines,mark
      character*11 dir(2000),alname
      character*40 a44
      character*4 stage,sample

c reset
      nalines=0
      do 10,i=1,1000
         al(i)=0.0
         afw(i)=0.0
 10   continue


      if(stage.eq.'one ') goto 2000
      if(sample.eq.'pgbg')goto 2000

c Check for existance of line list

      if(stage.eq.'two ')open(unit=10,status='old',
     $file='abslines1.list')
      if(stage.eq.'thre')open(unit=10,status='old',
     $file='abslines2.list')
      mark=0
      do 470 i=1,2000
         read(10,472,err=475)alname
         if(alname.eq.dir(loop))mark=1
 470  continue
 472  format(a11)
 475  close(10)
      if(mark.eq.0)goto 2000


c Read line parameters
      a44(1:10)='/data/kf1/'
      a44(11:14)=sample
      if(stage.eq.'two ')a44(15:22)='findsl1/'
      if(stage.eq.'thre')a44(15:22)='findsl2/'
      a44(23:33)=dir(loop)
      a44(34:40)='/s1.SLs'


c Set up emission line regions
      do 85 i=1,14
         reg(i,1)=-100.0
         reg(i,2)=-99.0
 85   continue
      reg(1,1)=1010.0*(1.0+zred)
      reg(1,2)=1060.0*(1.0+zred)
      reg(2,1)=1170.0*(1.0+zred)
      reg(2,2)=1350.0*(1.0+zred)
      reg(3,1)=1350.0*(1.0+zred)
      reg(3,2)=1720.0*(1.0+zred)
      reg(4,1)=1820.0*(1.0+zred)
      reg(4,2)=1970.0*(1.0+zred)
      reg(5,1)=2700.0*(1.0+zred)
      reg(5,2)=2900.0*(1.0+zred)
      reg(6,1)=3390.0*(1.0+zred)
      reg(6,2)=3460.0*(1.0+zred)
      reg(7,1)=3700.0*(1.0+zred)
      reg(7,2)=3760.0*(1.0+zred)
      reg(8,1)=3810.0*(1.0+zred)
      reg(8,2)=3930.0*(1.0+zred)
      reg(9,1)=4000.0*(1.0+zred)
      reg(9,2)=4200.0*(1.0+zred)
      reg(10,1)=4240.0*(1.0+zred)
      reg(10,2)=4440.0*(1.0+zred)
      reg(11,1)=4580.0*(1.0+zred)
      reg(11,2)=4790.0*(1.0+zred)
      reg(12,1)=4750.0*(1.0+zred)
      reg(12,2)=5100.0*(1.0+zred)
      reg(13,1)=5825.0*(1.0+zred)
      reg(13,2)=5900.0*(1.0+zred)
      reg(14,1)=6300.0*(1.0+zred)
      reg(14,2)=6800.0*(1.0+zred)

      open(unit=10,status='old',file=a44(1:40))
      read(10,'(x)')
      read(10,'(x)')
      do 100 i=1,1000
 90      read(10,120,err=110)al(i),afw(i)
c Check to see if absorption line is in emission line regions (temporary?)
         mark=0
         do 95 j=1,14
            if(al(i).ge.reg(j,1) .and. al(i).le.reg(j,2))mark=1
 95      continue
         if(mark.ne.1)goto 90
c change FWHM from km/s to A
         afw(i)=(al(i)*afw(i))/2.99793e5
         afw(i)=afw(i)+wmin
 100  continue
 110  close(10)
      nalines=i-1

      write(*,*)'     ',nalines,' absorption lines'

 120  format(4x,f8.2,24x,f6.3)

      write(1,900)                  ! #
      write(1,150)                  ! # Absorption lines from FINDSL
      write(3,150)                  ! # Absorption lines from FINDSL
 150  format('# Absorption lines from FINDSL')

c Line center should not shift by more than 3 resolution elements
c Line width not fitted in first iteration

      do 300 i=1,nalines
         low=al(i)-(3.0*wmin)
         upp=al(i)+(3.0*wmin)
      if(i.lt.10)write(1,200)i,afw(i),wmin,al(i),low,upp
      if(i.lt.10)write(3,200)i,afw(i),wmin,al(i),low,upp
      if(i.ge.10)write(1,210)i,afw(i),wmin,al(i),low,upp
      if(i.ge.10)write(3,210)i,afw(i),wmin,al(i),low,upp

 200  format('gauss1d[a',i1,'](',f5.1,':',f5.1,':20.0,',
     $f7.1,':',f7.1,':',f7.1,',-0.01:-100.0:0)')
 210  format('gauss1d[a',i2,'](',f5.1,':',f5.1,':20.0,',
     $f7.1,':',f7.1,':',f7.1,',-0.01:-100.0:0)')

 300  continue

      write(1,900)                  ! #


 900  format('# ')


 2000 return
      end

c ##################################################
