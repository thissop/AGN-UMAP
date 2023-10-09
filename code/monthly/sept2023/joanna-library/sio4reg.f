c ##################################################

      subroutine sio4reg(si4yn,feyn,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,sample,stage,nalines,al,afw,pol2yn,wmin)

      implicit real(a-h,l-z)
      real zred,wave1,wave2,f1,f2,w,cflux(14),cfw1(14),cfw2(14)
      real lc,peak
      real cfl1,wmin,linec
      real dls,dll,dlu,cn1
      integer loop,cf(14)
      character*11 dir(2000)
      character*1 si4yn,feyn,pow2,pol2yn
      character*40 a4
      character*4 sample,stage

      real al(1000),afw(1000)
      integer nal1,nal2,a(100),nalines
      character*2 pa,pna
      character*1 brac
      character*200 fmt

      do 10 i=1,100
         a(i)=i
 10   continue

      pa='+a'
      pna=' a'
      brac=')'


 200  format(3x,f8.3,3x,e11.4,3x,e11.4)


c START WITH Si IV/O IV blend at 1394-1413   -------------------
 900  si4yn='y'
      lc=1400.0*(1.0+zred)
      if(wave1.gt.lc .or. wave2.lt.lc) then
         write(1,901)
         write(3,901)
 901     format('# Si IV/O IV region (1400 A) not in spectrum')
         si4yn='n'
      endif

      if(si4yn.eq.'n')goto 1000

c FIX c4b 2 comp => 1 comp
c      goto 1000

      write(1,2100) ! #
      write(1,300)  ! # Si IV / O IV  REGION
      write(3,300)  ! # Si IV / O IV  REGION
 300  format('# Si IV / O IV  REGION')

c      if(wave1.lt.lc .and. wave2.gt.lc) then

c ------------------------------------------------------------
c Skip line parameter setting if past stage 1
      if(stage.eq.'two ')goto 916

c Estimate peak flux of Si IV/O IV blend
      peak=-10.0
      open(unit=5,status='old',file=a4(1:39))
      do 902 i=1,50000
      read(5,*,err=905)w,f1,f2
      if(w.gt.(lc-20.0) .and. w.lt.(lc+20.0)) then
         f1=(log10(f1))+14.0
         f1=10.0**f1
         if(f1.gt.peak)peak=f1
      endif
 902  continue
 905  close(5)
      if(peak.le.0.0)peak=0.001

c Estimate continuum under line for Si IV/O IV blend
      i=10
      j=14
      call cfest(i,j,lc,cf,cflux,cfw1,cfw2,cfl1)
c Subtract continuum
      if(cfl1.lt.peak)peak=peak-cfl1

c Define model component
      win1=1350.0*(1.0+zred)
      win2=1450.0*(1.0+zred)
      linec=1400.0
      call resmin(win1,win2,a4,sample,wave2,zred,linec,wmin)

      cn1=((1.0+zred)**2.0)/2.99793e5
      dls=2000.0*cn1*1400.0
      dll=200.0*cn1*1400.0
      dlu=3.0e4*cn1*1400.0
      if(dls.lt.wmin)dls=wmin
      if(dll.lt.wmin)dll=wmin
      if(dlu.lt.wmin)dlu=wmin+10.0
      write(1,910)                             ! # Si IV/O IV blend
      write(1,915)dls,dll,dlu,lc,(lc-20.0),(lc+20.0),peak,
     $(peak*1.5)                               ! gauss1d[sio4](20.:1.:95.:...
      write(3,915)dls,dll,dlu,lc,(lc-20.0),(lc+20.0),peak,
     $(peak*1.5)
 910  format('# Si IV/O IV blend')
 915  format('gauss1d[sio4](',f8.3,':',f8.3,':',f8.3,',',
     $f7.1,':',f7.1,':',f7.1,',',f7.3,':0.0:',f9.4,')')

c --------------------------------------------------
c come to here if stage is > 1 (i.e. models have already been defined)
 916  continue

c Fit Si IV/O IV region
      write(1,2100)                    ! #
      write(1,918)                     ! # Si IV/O IV blend first
 918  format('# Si IV/O IV blend first')

c -----------------------

c full window range to include all abs lines in region
      win1=1350.0*(1.0+zred)
      win2=1450.0*(1.0+zred)

      nal1=0
      nal2=0
      if(stage.eq.'two ' .and. nalines.gt.0)then
         do 310 i=1,nalines
            if(nal1.eq.0)then
               if(al(i).gt.win1 .and. al(i).le.win2)nal1=i
            endif
            if(nal1.ne.0)then
               if(al(i).gt.win1 .and. al(i).le.win2)nal2=i
            endif
 310     continue
      endif
c      write(*,*)win1,win2,al(1),al(2),al(3),nalines,nal1,nal2

c --------------------

      if(stage.ne.'two ' .or. nal1.eq.0)then

      if(sample.eq.'fos_' .or. zred.gt.2.42 .or. loop.gt.1060)then
         if(feyn.ne.'y')write(1,920)           ! source 1 = 1e-14
         if(feyn.eq.'y')write(1,925)           ! source 1 = 1e-14
      endif
      if(pol2yn.eq.'y')then
c      if(sample.eq.'lbqs' .and. zred.le.2.42 .and. loop.le.1060)then
         if(feyn.ne.'y')write(1,930) ! source 1 = 1e-14
         if(feyn.eq.'y')write(1,935) ! source 1 = 1e-14
      endif
      write(1,2150)            ! freeze con1
      write(1,940)                                        ! freeze umdr sio4
      if(feyn.eq.'y')write(1,945)                         ! freeze umfe
      if(pol2yn.eq.'y')write(1,950) ! freeze pol2 hpass
c      if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,950) ! freeze pol2 hpass

 920  format('source 1 = 1e-14*(umdr*(con1+sio4))')
 925  format('source 1 = 1e-14*(umdr*(con1+umfe+sio4))')
 930  format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(sio4)))')
 935  format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(umfe+sio4)))')
 940  format('freeze umdr sio4')
 945  format('freeze umfe')
 950  format('freeze pol2 hpass lpass')
      endif
c --------------------

      if(stage.eq.'two ' .and. nal1.ne.0)then

      if(sample.eq.'fos_' .or. zred.gt.2.42 .or. loop.gt.1060)then
      fmt(1:32)='(\'source 1 = 1e-14*(umdr*(con1+'
      if(feyn.ne.'y')then
         fmt(33:38)='sio4\''
         call setfmt(38,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
      endif
      if(feyn.eq.'y')then
         fmt(33:43)='umfe+sio4\''
         call setfmt(43,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
      endif
      endif

      if(pol2yn.eq.'y')then
c      if(sample.eq.'lbqs' .and. zred.le.2.42 .and. loop.le.1060)then
      fmt(1:52)='(\'source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+'
      if(feyn.ne.'y')then
         fmt(53:65)='(umdr*(sio4\''
         call setfmt(65,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
      endif
      if(feyn.eq.'y')then
         fmt(53:70)='(umdr*(umfe+sio4\''
         call setfmt(70,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
      endif
      endif

      write(1,2150)             ! freeze con1
      write(1,940)                             ! freeze umdr sio4
      do 530 i=nal1,nal2
         if(i.lt.10)write(1,535)i  ! freeze a1 - 9
         if(i.ge.10)write(1,536)i  ! freeze a10...
 530  continue
 535  format('freeze a',i1)
 536  format('freeze a',i2)

      if(feyn.eq.'y')write(1,945)              ! freeze umfe
      if(pol2yn.eq.'y')write(1,950) ! freeze pol2 hpass
c      if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,950) ! freeze pol2 hpass



c ------------------------------

c Fit around each absorption line (FWHM frozen!)
      write(1,2100)                                ! #
      write(1,459)                                ! # Absorption line fitting
 459  format('# Absorption line fitting')
      do 458 i=nal1,nal2
      write(1,2200)                                ! ignore all
      win1=al(i)-(5.0*wmin)
      win2=al(i)+(5.0*wmin)
      write(1,2600)win1,win2                       ! notice filter xxxx:xxxx

      if(i.lt.10)write(1,456)i,i,i
      if(i.ge.10)write(1,457)i,i,i

 456  format('thaw a',i1,'.3; fit; thaw a',i1,'.2; fit; freeze a',i1)
 457  format('thaw a',i2,'.3; fit; thaw a',i2,'.2; fit; freeze a',i2)

 458  continue
      write(1,2100)                                ! #

      endif

c -------------------

      win1=1350.0*(1.0+zred)
      win2=1450.0*(1.0+zred)
      write(1,2200)                                ! ignore all
      write(1,2600)win1,win2                       ! notice filter xxxx:xxxx
      if(stage.eq.'one ' .and. loop.le.1058)call galactic(win1,win2)


      if(stage.ne.'one ')write(1,955)  ! thaw sio4.2; fit
      write(1,960)                     ! thaw sio4.1 sio4.3; fit; freeze sio4

 955  format('thaw sio4.2; fit')
 960  format('thaw sio4.1 sio4.3; fit; freeze sio4')


      call wsrc(loop)          ! notice all
      write(1,2900)dir(loop) 
      write(1,2905)dir(loop)
 2900 format('WRITE source \'',a11,'.full2.src\' ascii')
 2905 format('WRITE residuals \'',a11,'.full2.res\' ascii')

      write(1,2146)                 ! source 1 = sio4
      write(1,2147)dir(loop)        ! WRITE source '<file>.sio4.src' ascii
 2146 format('source 1 = umdr*sio4')
 2147 format('WRITE source \'',a11,'.sio4.src\' ascii')



 2100 format('# ')
 2150 format('freeze con1 ')
 2200 format('ignore all')
 2600 format('notice filter ',f7.1,':',f7.1) 

 1000  return
      end

c ##################################################
