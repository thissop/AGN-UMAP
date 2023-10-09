c ###################################################

      subroutine he2reg(he2yn,feoyn,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,sample,stage,nalines,al,afw,
     $pol2yn,wmin,hbyn,hbres)

      implicit real(a-h,l-z)
      real zred,wave1,wave2,f1,f2,w,cflux(14),cfw1(14),cfw2(14)
      real lc,peak,peak1
      real cfl1,wmin,linec
      real dls,dll,dlu,cn1
      integer loop,cf(14),hbres,mark
      character*11 dir(2000)
      character*1 he2yn,feoyn,pow2,pol2yn,hbyn
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

c He II 4686
c -------------------------

 1500 he2yn='y'
      lc=4686.5*(1.0+zred)
      if(wave1.gt.lc .or. wave2.lt.lc) then
         write(1,1505)
         write(3,1505)
 1505    format('# He II region (4686 A) not in spectrum')
         he2yn='n'
      endif
      if(he2yn.eq.'n')goto 3000

      write(1,5005)
 5005 format('he2o.1.min=2.5')
      write(1,5006)
 5006 format('he2o.1=10.0')

      write(1,2100) ! #
      write(1,300)  ! # He II (4686) REGION
      write(3,300)  ! # He II (4686) REGION
 300  format('# He II (4686) REGION')

c ------------------------------------------------------------
c Skip line parameter setting if past stage 1
      if(stage.eq.'two ')goto 1527

c Estimate peak flux of He II
      peak=-10.0
      open(unit=5,status='old',file=a4(1:39))
      do 1510 i=1,50000
      read(5,*,err=1515)w,f1,f2
      if(w.gt.(lc-20.0) .and. w.lt.(lc+20.0)) then
         f1=(log10(f1))+14.0
         f1=10.0**f1
         if(f1.gt.peak)peak=f1
      endif
 1510 continue
 1515 close(5)
      if(peak.le.0.0)peak=0.001

c Estimate continuum under line for He II
      i=6
      j=5
      call cfest(i,j,lc,cf,cflux,cfw1,cfw2,cfl1)
c Subtract continuum
      if(cfl1.lt.peak)peak1=peak-cfl1
      if(peak1.le.0.0)peak1=peak

c Define model components
      win1=4580.0*(1.0+zred)
      win2=4790.0*(1.0+zred)
      linec=4686.0
      call resmin(win1,win2,a4,sample,wave2,zred,linec,wmin)

      cn1=((1.0+zred)**2.0)/2.99793e5
      dls=1000.0*cn1*4686.0
      dll=100.0*cn1*4686.0
      dlu=2.0e4*cn1*4686.0
      if(dls.lt.wmin)dls=wmin
      if(dll.lt.wmin)dll=wmin
      if(dlu.lt.wmin)dlu=wmin+10.0
      lc=4686.0*(1.0+zred)
      write(1,1520)                             ! # He II
      write(1,1522)dls,dll,dlu,lc,(lc-20.0),(lc+20.0),
     $(peak1*0.95),(peak1*1.5)                  ! gauss1d[he2o](10.:0.1:200.:..
      write(3,1522)dls,dll,dlu,lc,(lc-20.0),(lc+20.0),
     $(peak1*0.95),(peak1*1.5)

 1520 format('# He II (4686)')
 1522 format('gauss1d[he2o](',f9.3,':',f9.3,':',f9.3,',',
     $f7.1,':',f7.1,':',f7.1,',',f7.3,':0.0:',f9.4,')')

c --------------------------------------------------
c come to here if stage is > 1 (i.e. models have already been defined)
 1527 continue

c full window range to include all abs lines in region
      win1=4580.0*(1.0+zred)
      win2=4790.0*(1.0+zred)

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

      if(feoyn.ne.'y')then
      if(pol2yn.ne.'y')then
         if(hbyn.eq.'y' .and. hbres.eq.0)write(1,1540)   ! src 1 = he2o hbb
         if(hbyn.ne.'y' .or. hbres.ne.0)write(1,1530)    ! src 1 = he2o
      else
         if(hbyn.eq.'y' .and. hbres.eq.0)write(1,1541)   ! src 1 = he2o hbb pol
         if(hbyn.ne.'y' .or. hbres.ne.0)write(1,1531)    ! src 1 = he2o pol
      endif
      write(1,1532)                                      ! freeze umdr...
      endif
      if(feoyn.eq.'y')then
      if(pol2yn.ne.'y')then
         if(hbyn.eq.'y' .and. hbres.eq.0)write(1,1543) ! src 1 = he2o hbb umfeo
         if(hbyn.ne.'y' .or. hbres.ne.0)write(1,1533)  ! src 1 = he2o umfeo
      else
         if(hbyn.eq.'y' .and. hbres.eq.0)write(1,1544) ! src 1 = he2o hbb umfeo
         if(hbyn.ne.'y' .or. hbres.ne.0)write(1,1534)  ! src 1 = he2o umfeo
      endif
      write(1,1535)                                      ! freeze umdr...
      endif
      write(1,2150)                                      ! freeze con1
      if(pol2yn.eq.'y')write(1,1536)                     ! freeze pol2 hpass
      if(hbyn.eq.'y' .and. hbres.eq.0)write(1,1546)      ! freeze hbb

 1530 format('source 1 = 1e-14*(umdr*(con1+he2o))')
 1540 format('source 1 = 1e-14*(umdr*(con1+he2o+hbb))')
 1531 format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(he2o)))')
 1541 format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(he2o+hbb)))')
 1532 format('freeze umdr he2o')

 1533 format('source 1 = 1e-14*(umdr*(con1+umfeo+he2o))')
 1543 format('source 1 = 1e-14*(umdr*(con1+umfeo+he2o+hbb))')
 1534 format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(umfeo+he2o)))')
 1544 format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(umfeo+he2o+hbb)))')
 1535 format('freeze umdr umfeo he2o')
 1536 format('freeze pol2 hpass lpass')
 1546 format('freeze hbb')

      endif

c ------------------------------

      if(stage.eq.'two ' .and. nal1.ne.0)then
c test fro broad Hbeta
      mark=0
      if(hbyn.eq.'y' .and. hbres.eq.0)mark=1

      if(pol2yn.ne.'y')then
      fmt(1:32)='(\'source 1 = 1e-14*(umdr*(con1+'
         if(feoyn.ne.'y' .and. mark.eq.0)then
            fmt(33:38)='he2o\''
            call setfmt(38,nal1,nal2,fmt)
            write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
         endif
         if(feoyn.ne.'y' .and. mark.ne.0)then
            fmt(33:42)='he2o+hbb\''
            call setfmt(42,nal1,nal2,fmt)
            write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
         endif
         if(feoyn.eq.'y' .and. mark.eq.0)then
            fmt(33:44)='umfeo+he2o\''
            call setfmt(44,nal1,nal2,fmt)
            write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
         endif
         if(feoyn.eq.'y' .and. mark.ne.0)then
            fmt(33:48)='umfeo+he2o+hbb\''
            call setfmt(48,nal1,nal2,fmt)
            write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
         endif
      endif

      if(pol2yn.eq.'y')then
      fmt(1:52)='(\'source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+'
         if(feoyn.ne.'y' .and. mark.eq.0)then
            fmt(53:65)='(umdr*(he2o\''
            call setfmt(65,nal1,nal2,fmt)
            write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
         endif
         if(feoyn.ne.'y' .and. mark.ne.0)then
            fmt(53:69)='(umdr*(he2o+hbb\''
            call setfmt(69,nal1,nal2,fmt)
            write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
         endif
         if(feoyn.eq.'y' .and. mark.eq.0)then
            fmt(53:71)='(umdr*(umfeo+he2o\''
            call setfmt(71,nal1,nal2,fmt)
            write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
         endif
         if(feoyn.eq.'y' .and. mark.ne.0)then
            fmt(53:75)='(umdr*(umfeo+he2o+hbb\''
            call setfmt(75,nal1,nal2,fmt)
            write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
         endif
      endif

      write(1,2150)            ! freeze con1
      if(feoyn.ne.'y')write(1,1532)           ! freeze umdr he2o
      if(feoyn.eq.'y')write(1,1535)           ! freeze umdr umfeo he2o

      do 530 i=nal1,nal2
         if(i.lt.10)write(1,535)i  ! freeze a1 - 9
         if(i.ge.10)write(1,536)i  ! freeze a10...
 530  continue
 535  format('freeze a',i1)
 536  format('freeze a',i2)

      if(pol2yn.eq.'y')write(1,2700) ! freeze pol2 hpass
      if(mark.ne.0)write(1,1546)      ! freeze hbb
  455 format('freeze ',9(a2,i1),90(a2,i2))

c ------------------------------

c Fit around each absorption line (FWHM frozen!)
      write(1,2100)                                ! #
      write(1,459)                                ! # Absorption line fitting
 459  format('# Absorption line fitting')
      do 458 i=nal1,nal2
      write(1,2200)                                 ! ignore all
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
c ENDIF for stage=2 and nal>0
c ------------------------------

      win1=4580.0*(1.0+zred)
      win2=4790.0*(1.0+zred)
      write(1,2200)                                  ! ignore all
      write(1,2600)win1,win2                         ! notice filter xxxx:xxxx
      if(stage.eq.'one ' .and. loop.le.1058)call galactic(win1,win2)


      if(stage.ne.'one ')write(1,1350)  ! thaw he2o.2; fit; freeze he2o
      write(1,1352)                     ! thaw he2o.1; fit
      if(stage.ne.'one ')write(1,1354)  ! thaw he2o.2
      write(1,1356)                     ! thaw he2o.1 he2o.3; fit; freeze he2o

 1350 format('thaw he2o.2; fit; freeze he2o')
 1352 format('thaw he2o.1; fit')
 1354 format('thaw he2o.2')
 1356 format('thaw he2o.1 he2o.3; fit; freeze he2o')


      call wsrc(loop)
         write(1,1050)dir(loop)
         write(1,1055)dir(loop)
 1050 format('WRITE source \'',a11,'.full5c.src\' ascii')
 1055 format('WRITE residuals \'',a11,'.full5c.res\' ascii')
      write(1,1057)            ! source 1 = he2o
      write(1,1058)dir(loop)   ! WRITE source '<file>.he2o.src' ascii
 1057 format('source 1 = umdr*he2o')
 1058 format('WRITE source \'',a11,'.he2o.src\' ascii')


      if(stage.eq.'two ' .and. nal1.ne.0)then
      do 1027 i=nal1,nal2
         if(i.lt.10)write(1,1010)i
         if(i.ge.10)write(1,1015)i
         if(i.lt.10)write(1,1020)dir(loop),i
         if(i.ge.10)write(1,1025)dir(loop),i
 1010 format('source 1 = umdr*a',i1)
 1015 format('source 1 = umdr*a',i2)
 1020 format('WRITE source \'',a11,'.a',i1,'.src\' ascii')
 1025 format('WRITE source \'',a11,'.a',i2,'.src\' ascii')
 1027 continue
      endif


 2100 format('# ')
 2150 format('freeze con1 ')
 2200 format('ignore all')
 2600 format('notice filter ',f7.1,':',f7.1) 
 2700 format('freeze pol2 hpass lpass')

 3000 return
      end

c ##################################################
