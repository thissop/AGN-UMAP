c ##################################################

      subroutine fe2(zred,loop,dir,feyn,feoyn,wave1,wave2,a4,pow2,
     $bloop,sample,pol2yn)

      real zred,wave1,wave2
      real few(10),exln1,exln2,df1
      integer loop,bloop,mark
      character*11 dir(2000)
      character*1 feyn,feoyn,pow2,pol2yn
      character*40 a4
      character*50 a3
      character*4 sample
      character*17 dummy


 200  format(3x,f8.3,3x,e11.4,3x,e11.4)


c Fe II TEMPLATE
c --------------

c Windows 1) 2900:3000 2) 2250:2650 3) 2020:2120 4) 4400:4750 5) 5150:5550

c NEED TO EXCLUDE THE FOLLOWING REGIONS DUE TO STRONG NARROW LINES
c win 2) 2310-2340 C II,  2410-2440 [Ne IV], 2455-2485 [O II],
c  2495-2525 He II, 2615,2645 [Mg VII]
c win 4) 4665-4705 He II

      if(bloop.eq.1)then
      few(1)=0.0
      few(2)=0.0
      few(3)=0.0
      few(4)=0.0
      few(5)=0.0
      few(6)=0.0
      few(7)=0.0
      few(8)=0.0
      few(9)=0.0
      few(10)=0.0

      if(2900.0*(1.0+zred).lt.wave2)then
      if(3000.0*(1.0+zred).gt.wave1)then
         few(1)=2900.0*(1.0+zred)
         few(2)=3000.0*(1.0+zred)
         feyn='y'
      endif
      endif
      if(2250.0*(1.0+zred).lt.wave2)then
      if(2650.0*(1.0+zred).gt.wave1)then
         few(3)=2250.0*(1.0+zred)
         few(4)=2650.0*(1.0+zred)
         feyn='y'
      endif
      endif
      if(2020.0*(1.0+zred).lt.wave2) then
      if(2120.0*(1.0+zred).gt.wave1)then
         few(5)=2020.0*(1.0+zred)
         few(6)=2120.0*(1.0+zred)
         feyn='y'
      endif
      endif
      if(4400.0*(1.0+zred).lt.wave2) then
      if(4750.0*(1.0+zred).ge.wave1)then
         few(7)=4400.0*(1.0+zred)
         few(8)=4750.0*(1.0+zred)
         feoyn='y'
      endif
      endif
      if(5150.0*(1.0+zred).lt.wave2) then
      if(5550.0*(1.0+zred).ge.wave1)then
         few(9)=5150.0*(1.0+zred)
         few(10)=5550.0*(1.0+zred)
         feoyn='y'
      endif
      endif


c S/N ratio of Fe II areas (not needed?)
c      if(feyn.eq.'y') then
c      signal=0.0
c      noise=0.0
c      open(unit=5,status='old',file=a4(1:39))
c      do 510 i=1,10000
c      read(5,*,err=512)w,f1,f2
c      j=1
c 505  if(w.ge.few(j) .and. w.le.few(j+1)) then
c         f1=(log10(f1))+14.0
c         f1=10.0**f1
c         signal=signal+f1
c         f2=(log10(f2))+14.0
c         f2=10.0**f2
c         noise=noise+f2
c      endif
c      j=j+2
c      if(j.le.5)goto 505
c 510  continue
c 512  close(5)
c      snrat=signal/noise
cc      write(*,*)loop,snrat
cc      if(snrat.lt.3.0)feyn='n'
c      endif

      endif
c BLOOP ENDIF


      if(feyn.eq.'y') then

         write(1,2100)          ! #
         write(1,300) ! # Fe II UV template fitting
 300     format('# Fe II template fitting')

c for long spec covering either side of 4220 A window:
      if(pow2.eq.'y')then
         write(1,2100)  ! #
         write(1,400)   ! con1.1 => con3.1....
         write(1,2100)  ! #
      endif
 400  format('con1.1 => con3.1; con1.2 => con3.2; con1.3 => con3.3')

         write(1,2200)           ! ignore all

         if(few(1).ne.0.0) then
            write(1,520)              ! # Fe II 1 TEMPLATE (rest 2900 - 3000 A)
            write(3,520)              ! # Fe II 1 TEMPLATE (rest 2900 - 3000 A)
            write(1,2600)few(1),few(2) ! notice filter ',f6.1...
            call galactic(few(1),few(2))         ! ignore galactic lines
         endif
         if(few(3).ne.0.0) then
            write(1,521)              ! # Fe II 2 TEMPLATE (rest 2250 - 2650 A)
            write(3,521)              ! # Fe II 2 TEMPLATE (rest 2250 - 2650 A)
            write(1,2600)few(3),few(4) ! notice filter ',f6.1...
            call galactic(few(3),few(4))         ! ignore galactic lines
c EXCLUDE STRONG LINE REGIONS
 517  format('ignore 1 filter ',f7.1,':',f7.1)
c win 2) 2310-2340 C II,  2410-2440 [Ne IV], 2455-2485 [O II],
c  2495-2525 He II, 2615,2645 [Mg VII]
            exln1=2310.0*(1.0+zred)
            exln2=2340.0*(1.0+zred)
            write(1,517)exln1,exln2
            exln1=2410.0*(1.0+zred)
            exln2=2440.0*(1.0+zred)
            write(1,517)exln1,exln2
            exln1=2455.0*(1.0+zred)
            exln2=2485.0*(1.0+zred)
            write(1,517)exln1,exln2
            exln1=2495.0*(1.0+zred)
            exln2=2525.0*(1.0+zred)
            write(1,517)exln1,exln2
            exln1=2615.0*(1.0+zred)
            exln2=2645.0*(1.0+zred)
            write(1,517)exln1,exln2
         endif
         if(few(5).ne.0.0) then
            write(1,522)             ! # Fe II 3 TEMPLATE (rest 2020 - 2120 A)
            write(3,522)             ! # Fe II 3 TEMPLATE (rest 2020 - 2120 A)
            write(1,2600)few(5),few(6) ! notice filter ',f6.1...
            call galactic(few(5),few(6))         ! ignore galactic lines
         endif

      if(bloop.eq.1)write(1,530)zred,zred,zred ! usermodel[umfe](7:7:7,2,...
      if(bloop.eq.1)write(3,530)zred,zred,zred ! usermodel[umfe](7:7:7,2,...

      mark=0
      if(sample.eq.'lbqs' .and. zred.le.2.42)mark=1
      if(sample.eq.'lbqs' .and. loop.gt.1060)mark=0
      if(sample.eq.'mdm_')mark=1
      if(mark.eq.0)then
         write(1,532)
      else
         if(pol2yn.eq.'y')write(1,533) ! source 1 =
         if(pol2yn.ne.'y')write(1,532) ! source 1 =
      endif

 530  format('usermodel[umfe](7:7:7,2:2:2,0.:0.:0.,0.:0.:0.,0.:0.:0.,',
     $f8.5,':',f8.5,':',f8.5,',0.2:0.0:1000.0,5:0:37)')
 532  format('source 1 = 1e-14*(umdr*(con1+umfe))')
 533  format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(umfe)))')


 520  format('# Fe II TEMPLATE 1 (rest 2900 - 3000 A)')
 521  format('# Fe II TEMPLATE 2 (rest 2250 - 2650 A)')
 522  format('# Fe II TEMPLATE 3 (rest 2020 - 2120 A)')
 523  format('# Fe II TEMPLATE 4 (rest 4400 - 4750 A)')
 524  format('# Fe II TEMPLATE 5 (rest 5150 - 5550 A)')

c Start UV Fe II template with 
c HST FOS -- 20% of I Zw 1 flux and FWHM = 2000 km/s = 5

c LBQS use 25% of con3.3 or con1.3 for starting ampl from save file in
c /data/kf1/lbqsdata/ASCSAVE/',a11,'.SAVE and FWHM=8000 km/s = 29
      a3(1:10)='/data/kf1/'
      a3(11:14)=sample
      a3(15:27)='data/ASCSAVE/'
      a3(28:38)=dir(loop)
      a3(39:43)='.SAVE'
      if(sample.eq.'mdm_')a3(9:9)='3'
      open(unit=11,status='old',file=a3(1:43))
      df1=0.0
      do 525 i=1,10000
         read(11,527,err=526)dummy
         if(pow2.eq.'y')then
         if(dummy(1:15).eq.'con3.ampl.max =')then
            read(11,528)dummy,df1
            write(1,529)df1/4.0                  ! umfe.7=0.1; umfe.8=4
         endif
         endif
         if(pow2.ne.'y')then
         if(dummy(1:15).eq.'con1.ampl.max =')then
            read(11,528)dummy,df1
            write(1,529)df1/4.0                  ! umfe.7=0.1; umfe.8=4
         endif
         endif
         if(f1.ne.0.0)goto 526
 525  continue
 526  close(11)
 527  format(a15)
 528  format(a17,f10.5)
 529  format('umfe.7=',f10.5,'; umfe.8=4')


C FIT AMPLITUDE
         write(1,535)                       ! freeze umdr umfe; thaw umfe.7
         write(1,2150)                      ! freeze con1
         if(pol2yn.eq.'y')write(1,536)      !freeze pol2 lpass
c         if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,536)          !freeze pol2 lpass

         write(1,537)         ! fit
c CHANGE FITTING TO GRID MINIMIZATION
         write(1,540)         ! freeze umfe; thaw umfe.8
         write(1,541)         ! method grid
         write(1,542)         ! grid.nloop01=37
         write(1,543)         ! grid.iterations=10
c         write(1,544)         ! umfe.8=0.0
         write(1,545)         ! fit
c CHANGE FITTING BACK TO POWELL
         write(1,546)  ! method powell; powell.iterations=100; powell.verbose=5;
c                      ! powell.eps=0.001
         write(1,535)  ! freeze umdr umfe; thaw umfe.7
         write(1,2150) ! freeze con1
         write(1,548)  ! thaw umfe.8; fit
         write(1,550)  ! freeze umfe

 535  format('freeze umdr umfe; thaw umfe.7')
 536  format('freeze pol2 lpass hpass')
 537  format('fit')

 540  format('freeze umfe; thaw umfe.8')
 541  format('method grid')
 542  format('grid.nloop01=37')
 543  format('grid.iterations=10')
 544  format('umfe.8=0.0')
 545  format('fit')
 546  format('method powell; powell.iterations=100; powell.verbose=5;',
     $' powell.eps=0.001')
 548  format('thaw umfe.8; fit')
 550  format('freeze umfe')

      endif
c endif for feyn=y

c OPTICAL Fe II TEMPLATE
c ----------------------

c S/N ratio of Fe II areas (not needed?)
c 560  if(feoyn.eq.'y')then
c      signal=0.0
c      noise=0.0
c      open(unit=5,status='old',file=a4(1:39))
c      do 570 i=1,10000
c      read(5,*,err=572)w,f1,f2
c      j=7
c 565  if(w.ge.few(j) .and. w.le.few(j+1)) then
c         f1=(log10(f1))+14.0
c         f1=10.0**f1
c         signal=signal+f1
c         f2=(log10(f2))+14.0
c         f2=10.0**f2
c         noise=noise+f2
c      endif
c      j=j+2
c      if(j.le.9)goto 565
c 570  continue
c 572  close(5)
c      snrat=signal/noise
cc      write(*,*)loop,snrat
cc      if(snrat.lt.3.0)feoyn='n'
c      endif

      if(feoyn.eq.'y')then

c for long spec covering either side of 4220 A window:
      if(pow2.eq.'y')then
         write(1,2100)  ! #
         write(1,570)   ! con1.1 => con4.1....
         write(1,2100)  ! #
      endif
 570  format('con1.1 => con4.1; con1.2 => con3.2; con1.3 => con3.3')


         write(1,2200)                   ! ignore all
         if(few(7).ne.0.0) then
            write(1,523)             ! # Fe II 4 TEMPLATE (rest 4400 - 4750 A)
            write(1,2600)few(7),few(8) ! notice filter ',f6.1...
            call galactic(few(7),few(8))              ! ignore galactic lines
c win 4) 4665-4705 He II
            exln1=4665.0*(1.0+zred)
            exln2=4705.0*(1.0+zred)
            write(1,517)exln1,exln2
         endif
         if(few(9).ne.0.0) then
            write(1,524)             ! # Fe II 5 TEMPLATE (rest 5150 - 5550 A)
            write(1,2600)few(9),few(10) ! notice filter ',f6.1...
            call galactic(few(9),few(10))         ! ignore galactic lines
         endif

c Start OPT Fe II template with 20% of I Zw 1 flux and FWHM = 2000 km/s = 5
       if(bloop.eq.1)write(1,572)zred,zred,zred ! usermodel[umfeo](7:7:7,3...
       if(bloop.eq.1)write(3,572)zred,zred,zred ! usermodel[umfeo](7:7:7,3...

 572  format('usermodel[umfeo](7:7:7,3:3:3,0.:0.:0.,0.:0.:0.,0.:0.:0.,',
     $f8.5,':',f8.5,':',f8.5,',0.2:0.0:1000.0,5:0:37)')

      mark=0
      if(sample.eq.'lbqs' .and. zred.le.2.42)mark=1
      if(sample.eq.'lbqs' .and. loop.gt.1060)mark=0
      if(sample.eq.'mdm_')mark=1
      if(mark.eq.0)then
         write(1,573)
      else
         if(pol2yn.eq.'y')write(1,574) ! source 1 =
         if(pol2yn.ne.'y')write(1,573) ! source 1 =
      endif

 573  format('source 1 = 1e-14*(umdr*(con1+umfeo))')
 574  format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*umfeo))')


      a3(1:10)='/data/kf1/'
      a3(11:14)=sample
      a3(15:27)='data/ASCSAVE/'
      a3(28:38)=dir(loop)
      a3(39:43)='.SAVE'
      if(sample.eq.'mdm_')a3(9:9)='3'
      open(unit=11,status='old',file=a3(1:43))
      df1=0.0
      do 575 i=1,10000
         read(11,577,err=576)dummy
         if(pow2.eq.'y')then
         if(dummy(1:15).eq.'con3.ampl.max =')then
            read(11,578)dummy,df1
            write(1,579)df1/4.0                  ! umfeo.7=0.1; umfeo.8=4
         endif
         endif
         if(pow2.ne.'y')then
         if(dummy(1:15).eq.'con1.ampl.max =')then
            read(11,578)dummy,df1
            write(1,579)df1/4.0                  ! umfeo.7=0.1; umfeo.8=4
         endif
         endif
         if(f1.ne.0.0)goto 576
 575  continue
 576  close(11)
 577  format(a15)
 578  format(a17,f10.5)
 579  format('umfeo.7=',f10.5,'; umfeo.8=4')


C FIT AMPLITUDE
         write(1,580)                       ! freeze umdr umfeo; thaw umfeo.7
         write(1,2150)                      ! freeze con1
         if(pol2yn.eq.'y')write(1,536)      ! freeze pol2 lpass
c         if(sample.eq.'lbqs' .and. zred.le.2.42 .and.
c     $loop.le.1060)write(1,536) ! freeze pol2 lpass
         write(1,537)         ! fit
c CHANGE FITTING TO GRID MINIMIZATION
         write(1,582)         ! freeze umfeo; thaw umfeo.8
         write(1,541)         ! method grid
         write(1,542)         ! grid.nloop01=37
         write(1,543)         ! grid.iterations=10
c         write(1,584)         ! umfeo.8=0.0
         write(1,545)         ! fit

c CHANGE FITTING BACK TO POWELL
         write(1,586)  ! method powell; powell.iterations=100; powell.verbose=5;
c                      ! powell.eps=0.001
         write(1,580)                       ! freeze umdr umfeo; thaw umfeo.7
         write(1,2150) ! freeze con1
         write(1,588)  ! thaw umfeo.8; fit
         write(1,590)  ! freeze umfeo

 580  format('freeze umdr umfeo; thaw umfeo.7')
 581  format('freeze con1 umdr umfeo; thaw umfeo.7')

 582  format('freeze umfeo; thaw umfeo.8')
 584  format('umfeo.8=0.0')

 586  format('method powell; powell.iterations=100; powell.verbose=5;',
     $' powell.eps=0.001')
 588  format('thaw umfeo.8; fit')
 590  format('freeze umfeo')

      endif
c ENDIF for feoyn=y         

c NO Fe II
      if(bloop.eq.1)then
      if(feyn.ne.'y' .and. feoyn.ne.'y')then
         write(1,2100)     ! #
         write(1,599)     ! # No Fe II subtraction
         write(3,599)     ! # No Fe II subtraction
         write(1,2100)     ! #
      endif
      endif
      if(feyn.ne.'y' .and. feoyn.ne.'y')goto 3000

 599  format('# No Fe II subtraction')

c WRITE source to files (on 3rd loop for FOS and only one Fe fit for LBQS)

      if(bloop.eq.3 .or. sample.ne.'fos_')then
         write(1,2100)                     ! #
         write(1,690)                      ! # WRITE TO FILE
         write(1,695)                      ! notice all
      if(feyn.eq.'y')then
         write(1,700)           ! source 1 = umdr*umfe
         write(1,705)dir(loop)  ! WRITE source '<file>.fe.src' ascii
         write(1,800)           ! source 1 = 1e-14*(umdr*umfe)
         write(1,805)dir(loop)  ! WRITE residuals '<file>.fe.res' ascii
         write(1,707)           ! freeze umfe
      endif
      if(feoyn.eq.'y')then
         write(1,710)           ! source 1 = umdr*umfeo
         write(1,715)dir(loop)  ! WRITE source '<file>.feo.src'
         write(1,717)           ! freeze umfeo
         write(1,810)           ! source 1 = 1e-14*(umdr*umfeo)
         write(1,815)dir(loop)  ! WRITE residuals '<file>.feo.res' ascii
      endif
         write(1,2100)                     ! #
      endif

 690  format('# WRITE TO FILE')
 695  format('notice all')
 700  format('source 1 = umdr*umfe')
 705  format('WRITE source \'',a11,'.fe.src\' ascii')
 707  format('freeze umfe')
 710  format('source 1 = umdr*umfeo')
 715  format('WRITE source \'',a11,'.feo.src\' ascii')
 717  format('freeze umfeo')

 800  format('source 1 = 1e-14*(umdr*umfe)')
 805  format('WRITE residuals \'',a11,'.fe.res\' ascii')
 810  format('source 1 = 1e-14*(umdr*umfeo)')
 815  format('WRITE residuals \'',a11,'.feo.res\' ascii')

 2100 format('# ')
 2150 format('freeze con1 ')
 2200 format('ignore all')
 2600 format('notice filter ',f7.1,':',f7.1)
 3000 return
      end

c ##################################################
