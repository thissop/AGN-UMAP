c ##################################################

      subroutine basic(loop,dir,nh,refn,cfluxn,cflux,cfw1,cfw2,
     $wave1,wave2,zred,pow2,bloop,feyn,feoyn,a4,sample,pol2yn)

      real nh,refn,cfluxn,cfw1(14),cfw2(14),cflux(14),wave1,wave2
      real cn1,zred,lpwin1,lpwin2,pfl,pfh,bflux
      integer ncw,loop,bloop,bbin
      character*11 dir(2000)
      character*1 pow2,feyn,feoyn,pol2yn
      character*40 a4
      character*4 sample


      if(bloop.eq.1)then
      write(1,200)                         ! # Continuum Starting parameters
      write(1,390)                         ! # POWER LAW
      write(1,395)refn,refn,refn,cfluxn    ! powlaw1d[con1](1.:0.:5.,
      write(1,400)                         ! # DE-REDDENNING
      write(1,405)nh,nh,nh,refn,refn,refn  ! usermodel[umdr](7:7:7,1,3.1,
      write(3,200)                         ! # Continuum Starting parameters
      write(3,395)refn,refn,refn,cfluxn    ! powlaw1d[con1](1.:0.:5.,
      write(3,405)nh,nh,nh,refn,refn,refn  ! usermodel[umdr](7:7:7,1,3.1,
      endif

 200  format('# Continuum Starting parameters')
 390  format('# POWER LAW')
 395  format('powlaw1d[con1](1.:-5.:10.,',f7.1,':',f7.1,':',f7.1,
     $',',f6.3,':0.0:100.)')
 400  format('# DE-REDDENNING')
 405  format('usermodel[umdr](7:7:7,1:1:1,3.1:3.1:3.1,',f5.2,':',f5.2,
     $':',f5.2,',',f7.1,':',f7.1,':',f7.1,',0.:0.:0.,0.:0.:0.,0:0:0)')


c for long spec covering either side of 4220 A window:
      if(pow2.eq.'y')goto 700

c ---------------------

c CONTINUUM WINDOWS - if redshift is too high for 1320 (lowest standard window)
c    to be in window then use the flux at 1275:1280 or 1140:1150. If these are
c    outside window the window then choose the red end of the spectrum.
c Standard Windows
c      14) 1455:1470 = 1462,  13) 1690:1700 = 1695,  12) 2160:2180 = 2170, 
c      11) 2225:2250 = 2237,  10) 1320:1330 = 1325,  9) 3010:3040 = 3025,
c       8) 3480:3520 = 3400,   7) 3790:3810 = 3800,  6) 4210:4230 = 4220,
c       5) 5080:5100 = 5090,   4) 5600:5630 = 5615,  3) 5970:6000 = 5985,
c       2) 1275:1280 = 1277,   1) 1140:1150 = 1145

c 3010:3040  may still have some Fe II contamination

      write(3,*)'Continuum windows'
      write(1,2200)                  ! ignore all

      ncw=0
      do 410 i=3,14
         if(cflux(i).ne.0.0)then
            write(1,2600)cfw1(i),cfw2(i)       ! notice filter ',f7.1,':',f7.1
            call galactic(cfw1(i),cfw2(i))     ! ignore galactic lines
            write(3,*)cfw1(i),cfw2(i)
            ncw=ncw+1
         endif
 410  continue

      if(ncw.eq.0) then
         if(cflux(2).ne.0.0)then
            write(1,415)                   ! # Blue continuum window
            write(3,*)cfw1(2),cfw2(2)
         write(1,2600)cfw1(2),cfw2(2)    ! notice filter ',f7.1,':',f7.1
         call galactic(cfw1(2),cfw2(2))    ! ignore galactic lines
         endif
         if(cflux(1).ne.0.0 .and. cflux(2).eq.0.0)then
            write(1,415)                   ! # Blue continuum window
            write(3,*)cfw1(1),cfw2(1)
         write(1,2600)cfw1(1),cfw2(1)    ! notice filter ',f7.1,':',f7.1
         call galactic(cfw1(1),cfw2(1))    ! ignore galactic lines
         endif
         if(cflux(1).eq.0.0 .and. cflux(2).eq.0.0)then
            write(1,420)                       ! # Flux at red end of spectrum
            write(3,*)(wave2-10.0),wave2
            write(1,2600)(wave2-10.0),wave2   ! notice filter ',f7.1,':',f7.1
            call galactic((wave2-10.0),wave2)  ! ignore galactic lines
         endif
         ncw=1
      endif

c ------------------------------

c BAD BLUE CONTINUUM FIX - ignore region below 4000A observed frame for power
c   FOR LBQS               law fit. and add a region 20A wide at red end
      if(sample.eq.'lbqs' .and. loop.le.1060)then
         write(1,412)
 412  format('ignore filter 0:4000.0')
         write(1,2600)(wave2-50.0),(wave2-5.1) ! notice filter ',f7.1,':',f7.1
         call galactic((wave2-50.0),(wave2-5.1))
      endif
c --------------------------

      if(bloop.eq.1)write(1,422) ! source 1 = 1e-14*(con1*umdr); freeze umdr; 
      if(bloop.gt.1)then
         if(feyn.ne.'y' .and. feoyn.ne.'y')write(1,422) 
         if(feyn.eq.'y')write(1,424) 
         if(feoyn.eq.'y')write(1,426) 
      endif
      write(1,2150)              ! freeze con1
      write(1,427)               ! thaw con1.3; fit; freeze con1
      write(1,428)               ! thaw con1.1
c 2 or less continuum windows => freeze power law slope to 1.0
      if(ncw.le.2) write(1,430)     ! con1.1=1.0; freeze con1.1
      write(1,435)               ! fit
      write(1,440)               ! thaw con1.3; fit; freeze con1

 415  format('# Blue continuum window')
 420  format('# Flux at red end of spectrum')
 422  format('source 1 = 1e-14*(con1*umdr); freeze umdr')
 424  format('source 1 = 1e-14*(umdr*(con1+umfe)); freeze umdr umfe')
 426  format('source 1 = 1e-14*(umdr*(con1+umfeo)); freeze umdr umfeo')
 427  format('thaw con1.3; fit; freeze con1')
 428  format('thaw con1.1')
 430  format('con1.1=1.0; freeze con1.1')
 435  format('fit')
 440  format('thaw con1.3; fit; freeze con1')

c BAD BLUE CONTINUUM FIX - ignore region below 4000A observed frame for power
c   FOR LBQS               law fit. Then add a 2nd order polynomial with
c                          a low pass filter below the nearest cont. window
c                          redward of 4000A.

c Don't do poly fit in LBQS or 2 powerlaw fit in either sample 
c if Ly alpha region > 4000 i.e 1170*(1+zred) > 4000 
      if(zred.gt.2.42)goto 1000
c Don't do poly fit in FOS, PGBG sample or composite LBQS data
c (loop=1059 1060 1061)
c The 2 powerlaw fit has already skiped to 700
      if(sample.eq.'fos_' .or. loop.gt.1060)goto 1000
      if(sample.eq.'pgbg')goto 1000

c --------------------------------------------------

c POLY fit for LBQS and MDM samples
      pol2yn='y'

      lpwin1=20000.0
      lpwin2=0.0
      pfh=0.0
      do 500 i=1,14
c         write(*,*)cfw1(i),cfw2(i),cflux(i)
         if(cflux(i).gt.0.0)then
            cn=((cfw2(i)-cfw1(i))/2.0)+cfw1(i)
            if(cn.gt.4000.0 .and. cn.lt.lpwin1)pfh=cflux(i)
            if(cn.gt.4000.0 .and. cn.lt.lpwin1)lpwin1=cn
         endif
 500  continue
c      write(*,*)lpwin1,pfl,pfh

      pfl=pfh
      do 505 i=1,14
         if(cflux(i).gt.0.0)then
            cn=((cfw2(i)-cfw1(i))/2.0)+cfw1(i)
            if(cn.lt.4000.0 .and. cflux(i).lt.pfl)lpwin2=cn
            if(cn.lt.4000.0 .and. cflux(i).lt.pfl)pfl=cflux(i)
         endif
 505  continue

c MEASURE FLUX AT BLUE END OF THE SPECTRUM
      bflux=0.0
      bbin=0
      if(pfl.eq.pfh)then
      open(unit=5,status='old',file=a4(1:39))
      do 507 i=1,50000
         read(5,*,err=509)w,f1,f2
         f1=(log10(f1))+14.0
         f1=10.0**f1
         if(w.le.(wave1+20.0) .and. f1.gt.0.0)bflux=bflux+f1
         if(w.le.(wave1+20.0) .and. f1.gt.0.0)bbin=bbin+1
 507  continue
 509  close(5)
      pfl=bflux/bbin
      lpwin2=wave1
c      write(*,*)lpwin2,pfl,lpwin1,pfh
      endif

c POLYNOMIAL COEFFICIENTS
      cp1=(pfh-pfl)/(lpwin2-lpwin1)
      cp2=0.0
      cp2=cp1/(lpwin2-lpwin1)
c      if(cp1.lt.0.0)cp2=cp1/(lpwin2-lpwin1)
c      write(*,*)cp1,cp2,lpwin1,lpwin2

      write(1,510)
      write(1,520)cp1,lpwin1
      write(1,530)lpwin1
      write(1,532)lpwin1

 510  format('# POLYNOMIAL FIT OF BAD BLUE CONTINUUM')
 520  format('poly[pol2](0:0:100,',e11.4,':-100:100,0:-10.:10.,',
     $'0,0,0,0,0,0,',f7.1,')')
 530  format('lowpass[lpass](',f7.2,':0.0:10000.0,1.0)')
 532  format('highpass[hpass](',f7.2,':0.0:10000.0,1.0)')


c fit narrow window to get constant flux to match flux at crossover window
      write(1,2200)                  ! ignore all
      write(1,534)(lpwin1-30.0),(lpwin1+30.0)
      write(1,535)
      write(1,536)cfluxn
      write(1,537)cp1

 534  format('notice filter ',f7.1,':',f7.1)
 535  format('source 1 = 1e-14*pol2; freeze pol2')
 536  format('pol2.2=0.0; thaw pol2.1; pol2.1=',f6.3)
 537  format('fit; freeze pol2; pol2.2=',e11.4)

      write(1,2200)                  ! ignore all

      ncw=0
      do 540 i=3,14
         if(cflux(i).ne.0.0)then
            write(1,2600)cfw1(i),cfw2(i)       ! notice filter ',f7.1,':',f7.1
            call galactic(cfw1(i),cfw2(i))     ! ignore galactic lines
            ncw=ncw+1
         endif
 540  continue

      if(ncw.eq.0) then
         if(cflux(2).ne.0.0)then
            write(1,415)                   ! # Blue continuum window
            write(1,2600)cfw1(2),cfw2(2)    ! notice filter ',f7.1,':',f7.1
            call galactic(cfw1(2),cfw2(2))    ! ignore galactic lines
         endif
         if(cflux(1).ne.0.0 .and. cflux(2).eq.0.0)then
            write(1,415)                   ! # Blue continuum window
            write(1,2600)cfw1(1),cfw2(1)    ! notice filter ',f7.1,':',f7.1
            call galactic(cfw1(1),cfw2(1))    ! ignore galactic lines
         endif
         if(cflux(1).eq.0.0 .and. cflux(2).eq.0.0)then
            write(1,420)                       ! # Flux at red end of spectrum
            write(1,2600)(wave2-10.0),wave2    ! notice filter ',f7.1,':',f7.1
            call galactic((wave2-10.0),wave2)  ! ignore galactic lines
         endif
         ncw=1
      endif

      if(bflux.ne.0.0)then  
         write(1,550)                             ! # Flux at blue end of spec
         cn1=wave1/(1.0+zred)
         cn2=wave1+4.9
c shift 50A redward if edge of spec falls on bright emission line
c Ly alpha 1215
         if(cn1.ge.1165.0 .and. cn1.lt.1265.0)cn2=1300.0*(1.0+zred)
c C IV 1549
         if(cn1.ge.1500.0 .and. cn1.lt.1600.0)cn2=1620.0*(1.0+zred)
c C III 1909
         if(cn1.ge.1860.0 .and. cn1.lt.1960.0)cn2=1980.0*(1.0+zred)
c Mg II 2800
         if(cn1.ge.2750.0 .and. cn1.lt.2850.0)cn2=2870.0*(1.0+zred)
         cn1=cn2
         cn2=cn1+30.0
         write(1,2600)cn1,cn2    ! notice filter ',f7.1,':',f7.1
         call galactic(cn1,cn2)  ! ignore gala
      endif
 550  format('# Flux at blue end of spectrum')

c NOTICE very red end of spec (LBQS only)
      write(1,2600)(wave2-50.0),(wave2-5.1)  ! notice filter ',f7.1,':',f7.1
      call galactic((wave2-50.0),(wave2-5.1))

c IGNORE extreme blue end
      write(1,555)(wave1-1.0),(wave1+4.9)
 555  format('ignore filter ',f7.1,':',f7.1)


      write(1,560)
      write(1,562)
      write(1,564)
      if(cp2.ne.0.0)write(1,566)cp2
      if(cp2.ne.0.0)write(1,568)


 560  format('source 1 = 1e-14*(((con1*umdr)*hpass)+(pol2*lpass))')
 562  format('freeze con1 umdr pol2 lpass hpass')

 564  format('thaw pol2.2; fit; freeze pol2')
 566  format('pol2.3 = ',e11.4)
 568  format('thaw pol2.3; fit; thaw pol2.2; fit; freeze pol2')

      goto 1000

c --------------------------------------------------
c Long spectrum 2 power law model

 700  continue

      if(bloop.eq.1)then
c Tie powerlaws to flux at 4220A
      refn=4220.0*(1.0+zred)
      cfluxn=cflux(6)
      write(1,710)                         ! # 2 POWER LAW FIT NEEDED
      write(1,720)refn,refn,refn,cfluxn    ! powlaw1d[con3](1.:0.:5.,
      write(1,725)refn,refn,refn,cfluxn    ! powlaw1d[con4](1.:0.:5.,
      write(3,710)
      write(3,720)refn,refn,refn,cfluxn    ! powlaw1d[con3](1.:0.:5.,
      write(3,725)refn,refn,refn,cfluxn    ! powlaw1d[con4](1.:0.:5.,
      endif
 710  format('# 2 POWER LAW FIT NEEDED')
 720  format('powlaw1d[con3](1.:0.:10.,',f7.1,':',f7.1,':',f7.1,
     $',',f6.3,':0.0:100.)')
 725  format('powlaw1d[con4](1.:-5.:10.,',f7.1,':',f7.1,':',f7.1,
     $',',f6.3,':0.0:100.)')

      write(3,*)'Continuum windows'
      write(1,2200)                  ! ignore all

      ncw=0

c BLUE FIRST
      write(1,760)                            ! # BLUE SPEC FIRST
 760  format('# BLUE SPEC FIRST')
      do 770 i=6,14
         if(cflux(i).ne.0.0)then
            write(1,2600)cfw1(i),cfw2(i)       ! notice filter ',f7.1,':',f7.1
            call galactic(cfw1(i),cfw2(i))     ! ignore galactic lines
            write(3,*)cfw1(i),cfw2(i)
            ncw=ncw+1
         endif
 770  continue

c BAD BLUE CONTINUUM FIX ? for LBQS
      if(sample.eq.'lbqs' .and. loop.le.1060)write(1,412) ! ig filter 0:4000

      if(bloop.eq.1)write(1,780)    ! source 1 = 1e-14*(con3*umdr); 
      if(bloop.gt.1 .and. feyn.ne.'y')write(1,780)    ! source 1 = 1e-14*(...
      if(bloop.gt.1 .and. feyn.eq.'y')write(1,785)    ! source 1 = 1e-14*((co
      write(1,786)                  !  thaw con3.3 fit; freeze con3
      write(1,787)                  !  thaw con3.1; fit; freeze con3

 780  format('source 1 = 1e-14*(con3*umdr); freeze con3 umdr')
 785  format('source 1 = 1e-14*(umdr*(con3+umfe)); ',
     $' freeze con3 umdr umfe')
 786  format('thaw con3.3; fit; freeze con3')
 787  format('thaw con3.1; fit; thaw con3.3; fit; freeze con3')

c Red Second
      write(1,790)                            ! # RED SPEC SECOND
 790  format('# RED SPEC SECOND')

      write(1,2200)                  ! ignore all
      do 800 i=3,6
         if(cflux(i).ne.0.0)then
            write(1,2600)cfw1(i),cfw2(i)       ! notice filter ',f7.1,':',f7.1
            call galactic(cfw1(i),cfw2(i))     ! ignore galactic lines
            write(3,*)cfw1(i),cfw2(i)
            ncw=ncw+1
         endif
 800  continue

c Add final window at red end of spec (keep at least 35A from S II)
      if(wave2.gt.(6775.0*(1.0+zred)))then
      cn1=wave2-40.0
      if(cn1.lt.6770.0*(1.0+zred))cn1=6770.0*(1.0+zred)
      write(1,2600)cn1,wave2       ! notice filter ',f7.1,':',f7.1
      call galactic(cn1,wave2)     ! ignore galactic lines
      write(3,*)cn1,wave2
      endif

c NOTICE very red end of spec (LBQS only)
      if(sample.eq.'lbqs')write(1,2600)(wave2-30.0),(wave2-4.9) ! notice filter
      if(sample.eq.'lbqs')call galactic((wave2-30.0),(wave2-4.9))

c match ref wavelength and ref amplitude!
      if(bloop.eq.1)write(1,810) ! source 1 = 1e-14*(con4*umdr); freeze umdr
      if(bloop.gt.1 .and. feoyn.ne.'y')write(1,810) ! source 1 = 1e-14*((con..
      if(bloop.gt.1 .and. feoyn.eq.'y')write(1,812) ! source 1 = 1e-14*((con
      write(1,815)      ! thaw con4.1
      write(1,820)      ! con4.2 => con3.2; con4.3 => con3.3
      write(1,825)      ! fit

 810  format('source 1 = 1e-14*(con4*umdr); freeze umdr')
 812  format('source 1 = 1e-14*(umdr*(con4+umfeo)); freeze umdr umfeo')
 815  format('thaw con4.1')
 820  format('con4.2 => con3.2; con4.3 => con3.3')
 825  format('fit; freeze con4.1')


c BAD BLUE CONTINUUM FIX - ignore region below 4000A observed frame for power
c  FOR LBQS                law fit. Then subtract a 2nd order polynomial with
c                          a low pass filter below the nearest cont. window
c                          redward of 4000A.

c DOn't do poly fit if Ly alpha region > 4000 i.e. 1170(1+z) > 4000
      if(zred.gt.2.42 .or. sample.eq.'fos_' .or. loop.gt.1060)goto 1000
      if(sample.ne.'lbqs')goto 1000

c Polynomial fit
      pol2yn='y'

      lpwin1=20000.0
      lpwin2=0.0
      pfh=0.0

      do 980 i=1,14
c         write(*,*)cfw1(i),cfw2(i),cflux(i)
         if(cflux(i).gt.0.0)then
            cn=((cfw2(i)-cfw1(i))/2.0)+cfw1(i)
            if(cn.gt.4000.0 .and. cn.lt.lpwin1)pfh=cflux(i)
            if(cn.gt.4000.0 .and. cn.lt.lpwin1)lpwin1=cn
         endif
 980  continue
c      write(*,*)lpwin1,pfl,pfh

      pfl=pfh
      do 982 i=1,14
         if(cflux(i).gt.0.0)then
            cn=((cfw2(i)-cfw1(i))/2.0)+cfw1(i)
            if(cn.lt.4000.0 .and. cflux(i).lt.pfl)lpwin2=cn
            if(cn.lt.4000.0 .and. cflux(i).lt.pfl)pfl=cflux(i)
         endif
 982  continue

c      write(*,*)lpwin1,pfl,pfh

      if(pfl.eq.pfh)then
c MEASURE FLUX AT BLUE END OF THE SPECTRUM
      bflux=0.0
      bbin=0
      open(unit=5,status='old',file=a4(1:39))
      do 984 i=1,50000
         read(5,*,err=985)w,f1,f2
         f1=(log10(f1))+14.0
         f1=10.0**f1
         if(w.le.(wave1+20.0))bflux=bflux+f1
         if(w.le.(wave1+20.0))bbin=bbin+1
 984  continue
 985  close(5)
      pfl=bflux/bbin
      lpwin2=wave1
c      write(*,*)lpwin2,pfl,lpwin1,pfh
      endif

c POLYNOMIAL COEFFICIENTS
      cp1=(pfh-pfl)/(lpwin2-lpwin1)
      cp2=0.0
      cp2=cp1/(lpwin2-lpwin1)
c      if(cp1.lt.0.0)cp2=cp1/(lpwin2-lpwin1)
c      write(*,*)cp1,cp2,lpwin1,lpwin2

      write(1,510)            ! # POLYNOMIAL FIT OF BAD BLUE CONTINUUM
      write(1,520)cp1,lpwin1  ! poly[pol2](0:0:100,',e11
      write(1,530)lpwin1      ! [lpass]
      write(1,532)lpwin1      ! [hpass]


c fit narrow window to get constant flux to match flux at crossover window
      write(1,2200)                  ! ignore all
      write(1,534)(lpwin1-30.0),(lpwin1+30.0)
      write(1,535)
      write(1,536)cfluxn
      write(1,537)cp1

      write(1,2200)                  ! ignore all

c USE ONLY BLUE WINDOWS AND CON3
      do 988 i=6,14
         if(cflux(i).ne.0.0)then
            write(1,2600)cfw1(i),cfw2(i)       ! notice filter ',f7.1,':',f7.1
            call galactic(cfw1(i),cfw2(i))     ! ignore galactic lines
            ncw=ncw+1
         endif
 988  continue

      if(bflux.ne.0.0)then  
         write(1,550)           ! # Flux at blue end of spectrum
         cn1=wave1/(1.0+zred)
         cn2=wave1+4.9
c shift 50A redward if edge of spec falls on bright emission line
c Ly alpha 1215
         if(cn1.ge.1165.0 .and. cn1.lt.1265.0)cn2=1300.0*(1.0+zred)
c C IV 1549
         if(cn1.ge.1500.0 .and. cn1.lt.1600.0)cn2=1620.0*(1.0+zred)
c C III 1909
         if(cn1.ge.1860.0 .and. cn1.lt.1960.0)cn2=1980.0*(1.0+zred)
c Mg II 2800
         if(cn1.ge.2750.0 .and. cn1.lt.2850.0)cn2=2870.0*(1.0+zred)
         cn1=cn2
         cn2=cn1+30.0
         write(1,2600)cn1,cn2    ! notice filter ',f7.1,':',f7.1
         call galactic(cn1,cn2)  ! ignore gala
      endif
c IGNORE extreme blue end
      write(1,555)(wave1-1.0),(wave1+4.9)

      write(1,990)                    ! source 1 = 1e-14*(((con3*umdr)*...
      write(1,991)                    ! freeze con3 umdr pol2 lpass hpass
      write(1,564)                    ! thaw pol2.2; fit; freeze pol2
      if(cp2.ne.0.0)write(1,566)cp2   ! pol2.3 = ',e11.4
      if(cp2.ne.0.0)write(1,568)      ! thaw pol2.3; fit; thaw pol2.2; fit;....

 990  format('source 1 = 1e-14*(((con3*umdr)*hpass)+(pol2*lpass))')
 991  format('freeze con3 umdr pol2 lpass hpass')

 2150 format('freeze con1 ')
 2200 format('ignore all')
 2600 format('notice filter ',f7.1,':',f7.1) 

 1000 return
      end
