c ##################################################

      subroutine c4reg(c4yn,si4yn,feyn,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,c4res,sample,stage,nalines,al,afw,
     $pol2yn,wmin)

      implicit real(a-h,l-z)
      real zred,wave1,wave2,f1,f2,w,cflux(14),cfw1(14),cfw2(14)
      real lc,lc2,peak,signal,noise,snrat,csnrat,cnoise,csignal
      real cfl1,wmin,linec
      real dls,dll,dlu,cn1
      integer loop,cf(14),c4res,snbin,csnbin
      character*11 dir(2000)
      character*1 c4yn,si4yn,feyn,pow2,pol2yn
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


c Then C IV Broad, Intermediate and Narrow and He II 1640 -----------

      c4yn='y'
      lc=1549.0*(1.0+zred)
      if(wave1.gt.lc .or. wave2.lt.lc) then
         write(1,201)
         write(3,201)
         c4yn='n'
      endif
 201  format('# C IV region not in spectrum')
      if(c4yn.eq.'n' .and. si4yn.eq.'n')goto 3000
      if(c4yn.eq.'n' .and. si4yn.eq.'y')goto 2145

c      if(wave1.lt.lc .and. wave2.gt.lc) then

      write(1,2100)  ! # 
      write(1,300)   ! # C IV REGION
      write(3,300)   ! # C IV REGION
 300  format('# C IV REGION')


c S/N ratio of C IV region
      c4res=1
      snbin=0
      snrat=0.0
      signal=0.0
      noise=0.0
      csnbin=0
      csnrat=0.0
      csignal=0.0
      cnoise=0.0
      open(unit=5,status='old',file=a4(1:39))
      do 350 i=1,50000
      read(5,*,err=355)w,f1,f2

      if(w.ge.1760.0*(1.0+zred)) goto 350
      if(i.lt.5)goto 350

c continuum before line
      if(w.gt.1430.0*(1.0+zred) .and. w.lt.1490.0*(1.0+zred)) then
         csnbin=csnbin+1
         f1=(log10(f1))+14.0
         f1=10.0**f1
         csignal=csignal+f1
         f2=(log10(f2))+14.0
         f2=10.0**f2
         cnoise=cnoise+f2
      endif
c continuum after line
      if(w.gt.1700.0*(1.0+zred) .and. w.lt.1760.0*(1.0+zred)) then
         csnbin=csnbin+1
         f1=(log10(f1))+14.0
         f1=10.0**f1
         csignal=csignal+f1
         f2=(log10(f2))+14.0
         f2=10.0**f2
         cnoise=cnoise+f2
      endif
c line S/N
      if(w.ge.1490.0*(1.0+zred) .and. w.le.1610.0*(1.0+zred)) then
         snbin=snbin+1
         f1=(log10(f1))+14.0
         f1=10.0**f1
         signal=signal+f1
         f2=(log10(f2))+14.0
         f2=10.0**f2
         noise=noise+f2
      endif

 350  continue
 355  close(5)

      if(csignal.gt.0.0)csignal=csignal/csnbin
      if(cnoise.gt.0.0)cnoise=cnoise/csnbin
      if(signal.gt.0.0)signal=signal/snbin
      if(noise.gt.0.0)noise=noise/snbin
      if(signal.gt.0.0)then
         signal=signal-csignal
         noise=sqrt((noise*noise)+(cnoise*cnoise))
         snrat=signal/noise
      endif

c      write(*,*)'c4 ',loop,zred,csignal,cnoise,csnbin,signal,noise,
c     $snbin,snrat

      write(1,340)snrat,snbin
      write(3,340)snrat,snbin
 340  format('# C IV region S/N = ',f5.2,' bins = ',i4)

c 2 comp for C IV
      if(snrat.ge.2.3 .and. lc.ge.3600.0)c4res=0
      if(loop.gt.1058)c4res=0


c FIX 2 comp => 1 comp
c      c4res=1

c ------------------------------------------------------------
c Skip line parameter setting if past stage 1
      if(stage.eq.'two ')goto 963

      peak=-10.0
      peak2=-10.0
      lc2=1640.0*(1.0+zred)
      open(unit=5,status='old',file=a4(1:39))
      do 942 i=1,50000
      read(5,*,err=945)w,f1,f2
c Estimate peak flux of C IV
      if(w.gt.(lc-20.0) .and. w.lt.(lc+20.0)) then
         f1=(log10(f1))+14.0
         f1=10.0**f1
         if(f1.gt.peak)peak=f1
      endif
c Estimate peak flux of He II
      if(w.gt.(lc2-10.0) .and. w.lt.(lc2+10.0)) then
         f1=(log10(f1))+14.0
         f1=10.0**f1
         if(f1.gt.peak2)peak2=f1
      endif
 942  continue
 945  close(5)
      if(peak.le.0.0)peak=0.001
      if(peak2.eq.-10.0)peak2=0.001


c Estimate continuum under line for C IV line
      i=14
      j=13
      call cfest(i,j,lc,cf,cflux,cfw1,cfw2,cfl1)
c Subtract continuum
      if(cfl1.lt.peak)peak=peak-cfl1

c Estimate continuum under line for He II 1640
      i=14
      j=13
      call cfest(i,j,lc2,cf,cflux,cfw1,cfw2,cfl1)
      if(cfl1.lt.peak2)peak2=peak2-cfl1

c Get minimum resolution
      win1=1350.0*(1.0+zred)
      win2=1720.0*(1.0+zred)
      linec=1549.0
      call resmin(win1,win2,a4,sample,wave2,zred,linec,wmin)

c Define 1 model component for C IV
      if(c4res.ne.0)then
      cn1=((1.0+zred)**2.0)/2.99793e5
      dls=3000.0*cn1*1549.0
      dll=100.0*cn1*1549.0
      dlu=3.0e4*cn1*1549.0
      if(dls.lt.wmin)dls=wmin
      if(dll.lt.wmin)dll=wmin
      if(dlu.lt.wmin)dlu=wmin+10.0
      write(1,947)                             ! # C IV (SINGLE)
      write(1,955)dls,dll,dlu,lc,(lc-30.0),(lc+30.0),
     $(peak),peak*1.5                     ! gauss1d[c4n](55.:15.:110.,...
      write(3,955)dls,dll,dlu,lc,(lc-30.0),(lc+30.0),
     $(peak),peak*1.5
      endif
 947  format('# C IV  (SINGLE)')

c Define 2 model components for C IV
      if(c4res.ne.1)then
      cn1=((1.0+zred)**2.0)/2.99793e5
      dls=5000.0*cn1*1549.0
      dll=500.0*cn1*1549.0
      dlu=3.0e4*cn1*1549.0
      if(dls.lt.wmin)dls=wmin
      if(dll.lt.wmin)dll=wmin
      if(dlu.lt.wmin)dlu=wmin+10.0
      write(1,950)                             ! # C IV Broad
      write(1,951)dls,dll,dlu,lc,(lc-30.0),(lc+30.0),
     $(peak*0.2),peak                         ! gauss1d[c4b](55.:15.:110.,...
      write(3,951)dls,dll,dlu,lc,(lc-30.0),(lc+30.0),
     $(peak*0.2),peak

cc 3 components
c      if(c4res.eq.0)then
c         dls=1000.0*cn1*1549.0
c         dll=100.0*cn1*1549.0
c         dlu=1.0e4*cn1*1549.0
c      if(dls.lt.wmin)dls=wmin
c      if(dll.lt.wmin)dll=wmin
c      if(dlu.lt.wmin)dlu=wmin+10.0
c         write(1,952)                             ! # C IV Intermediate
c         write(1,953)dls,dll,dlu,lc,(lc-20.0),(lc+20.0),
c     $(peak*0.3),peak                          ! gauss1d[c4i](55.:15.:110.,...
c         write(3,953)dls,dll,dlu,lc,(lc-20.0),(lc+20.0),
c     $(peak*0.3),peak
c      endif

      dls=350.0*cn1*1549.0
      dll=100.0*cn1*1549.0
      dlu=5000.0*cn1*1549.0
      if(dls.lt.wmin)dls=wmin
      if(dll.lt.wmin)dll=wmin
      if(dlu.lt.wmin)dlu=wmin+10.0
      if(c4res.ne.0)dlu=30000.0*cn1*1549.0
      write(1,954)                             ! # C IV Narrow
      write(1,955)dls,dll,dlu,lc,(lc-20.0),(lc+20.0),
     $(peak*0.5),(peak*1.5)                    ! gauss1d[c4n](55.:15.:110.,...
      write(3,955)dls,dll,dlu,lc,(lc-20.0),(lc+20.0),
     $(peak*0.5),(peak*1.5)
      endif
 950  format('# C IV Broad')
 951  format('gauss1d[c4b](',f8.3,':',f8.3,':',f8.3,',',
     $f7.1,':',f7.1,':',f7.1,',',f7.3,':0.0:',f9.4,')')
 952  format('# C IV Intermediate')
 953  format('gauss1d[c4i](',f8.3,':',f8.3,':',f8.3,',',
     $f7.1,':',f7.1,':',f7.1,',',f7.3,':0.0:',f9.4,')')
 954  format('# C IV Narrow')
 955  format('gauss1d[c4n](',f8.3,':',f8.3,':',f8.3,',',
     $f7.1,':',f7.1,':',f7.1,',',f7.3,':0.0:',f9.4,')')

c NO ABSORPTION FEATURE FOR NOW
c      dls=1000.0*cn1*1549.0
c      dll=300.0*cn1*1549.0
c      dlu=3.0e4*cn1*1549.0
c      if(dls.lt.wmin)dls=wmin
c      if(dll.lt.wmin)dll=wmin
c      if(dlu.lt.wmin)dlu=wmin+10.0
c      write(1,956)                             ! # C IV absorption
c      write(1,957)dls,dll,dlu,(lc-100.0),(lc-150.0),(lc-50.0),
c     $(cflux(14)*-0.1),(cflux(14)*-1.0)        ! gauss1d[c4ba](5.:0.1:120.,...
c      write(3,957)dls,dll,dlu,lc,(lc-20.0),(lc+20.0),
c     $(cflux(14)*-0.1),(cflux(14)*-1.0)
c 956  format('# C IV absorption (blue side of peak)')
c 957  format('gauss1d[c4ba](',f8.3,':',f8.3,':',f8.3,',',
c     $f7.1,':',f7.1,':',f7.1,',',f7.3,':',f8.3,':0.0)')

c Define model component for He II (1640)
      dls=1000.0*cn1*1640.0
      dll=200.0*cn1*1640.0
      dlu=1.0e4*cn1*1640.0
      if(dls.lt.wmin)dls=wmin
      if(dll.lt.wmin)dll=wmin
      if(dlu.lt.wmin)dlu=wmin+10.0
      write(1,960)                             ! # He II 1640
      write(1,962)dls,dll,dlu,lc2,(lc2-20.0),(lc2+20.0),
     $(peak2*0.8),(peak2*1.5)                  ! gauss1d[he2](10.:2.:110.,...
      write(3,962)dls,dll,dlu,lc2,(lc2-20.0),(lc2+20.0),
     $(peak2*0.8),(peak2*1.5)
 960  format('# He II 1640')
 962  format('gauss1d[he2](',f8.3,':',f8.3,':',f8.3,',',
     $f7.1,':',f7.1,':',f7.1,',',f7.3,':0.0:',f9.4,')')

c --------------------------------------------------
c come to here if stage is > 1 (i.e. models have already been defined)
 963  continue

c --------------------

c full window range to include all abs lines in region
      win1=1350.0*(1.0+zred)
      win2=1720.0*(1.0+zred)

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

c FIX 2 comp => 1 comp skip first set of fitting
c Re-fit Fe
c      goto 5000

c --------------------

c Fit C IV region
      write(1,2100)                 ! #
      if(c4res.eq.0)write(1,964)    ! # C IV Broad then Narrow
 964  format('# C IV Broad then Narrow')

      if(stage.ne.'two ' .or. nal1.eq.0)then

      if(c4res.eq.0 .and. feyn.ne.'y')then
      if(sample.eq.'fos_' .or. zred.gt.2.42 .or. 
     $loop.gt.1060)write(1,967)  ! source 1 = 1e-14*
      if(pol2yn.eq.'y')write(1,968) ! source 1 = 1e-14*
c      if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,968) ! source 1 = 1e-14*
      endif
      if(c4res.eq.0 .and. feyn.eq.'y')then
      if(sample.eq.'fos_' .or. zred.gt.2.42 .or. 
     $loop.gt.1060)write(1,970)  ! source 1 = 1e-14*
      if(pol2yn.eq.'y')write(1,971) ! source 1 = 1e-14*
c      if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,971) ! source 1 = 1e-14*
      endif


      if(c4res.ne.0 .and. feyn.ne.'y')then
      if(sample.eq.'fos_' .or. zred.gt.2.42 .or. 
     $loop.gt.1060)write(1,977)  ! source 1 = 1e-14*((
      if(pol2yn.eq.'y')write(1,978) ! source 1 = 1e-14*((
c      if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,978) ! source 1 = 1e-14*((
      endif
      if(c4res.ne.0 .and. feyn.eq.'y')then
      if(sample.eq.'fos_' .or. zred.gt.2.42 .or. 
     $loop.gt.1060)write(1,980)  ! source 1 = 1e-14*((
      if(pol2yn.eq.'y')write(1,981) ! source 1 = 1e-14*((
c      if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,981) ! source 1 = 1e-14*((
      endif

      write(1,973)                                    ! freeze umdr c4n he2
      if(c4res.eq.0)write(1,974)                      ! freeze umdr c4b
      write(1,2150)                                   ! freeze con1
      if(feyn.eq.'y')write(1,982)                     ! freeze umfe
      if(pol2yn.eq.'y')write(1,983)                       ! freeze pol2 hpass
c      if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,983)                       ! freeze pol2 hpass
 
 967  format('source 1 = 1e-14*(umdr*(con1+c4b+c4n+he2))')
 968  format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(c4b+c4n+he2)))')
 970  format('source 1 = 1e-14*(umdr*(con1+umfe+c4b+c4n+he2))')
 971  format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(umfe+c4b+c4n+he2)))')

 977  format('source 1 = 1e-14*(umdr*(con1+c4n+he2))')
 978  format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(c4n+he2)))')
 979  format('freeze umdr c4n he2')
 980  format('source 1 = 1e-14*(umdr*(con1+umfe+c4n+he2))')
 981  format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(umfe+c4n+he2)))')

 973  format('freeze umdr c4n he2')
 974  format('freeze c4b')

 982  format('freeze umfe')
 983  format('freeze pol2 hpass lpass')

      endif
c --------------------

      if(stage.eq.'two ' .and. nal1.ne.0)then

      if(sample.eq.'fos_' .or. zred.gt.2.42 .or. 
     $loop.gt.1060)then
      fmt(1:32)='(\'source 1 = 1e-14*(umdr*(con1+'
      if(c4res.eq.0 .and. feyn.ne.'y')then
         fmt(33:45)='c4b+c4n+he2\''
         call setfmt(45,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
      endif
      if(c4res.eq.0 .and. feyn.eq.'y')then
         fmt(33:50)='umfe+c4b+c4n+he2\''
         call setfmt(50,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
      endif
      if(c4res.ne.0 .and. feyn.ne.'y')then
         fmt(33:41)='c4n+he2\''
         call setfmt(41,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
      endif
      if(c4res.ne.0 .and. feyn.eq.'y')then
         fmt(33:46)='umfe+c4n+he2\''
         call setfmt(46,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
      endif
      endif

      if(pol2yn.eq.'y')then
c      if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)then
      fmt(1:52)='(\'source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+'
      if(c4res.eq.0 .and. feyn.ne.'y')then
         fmt(53:72)='(umdr*(c4b+c4n+he2\''
         call setfmt(72,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
      endif
      if(c4res.eq.0 .and. feyn.eq.'y')then
         fmt(53:77)='(umdr*(umfe+c4b+c4n+he2\''
         call setfmt(77,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
      endif
      if(c4res.ne.0 .and. feyn.ne.'y')then
         fmt(53:68)='(umdr*(c4n+he2\''
         call setfmt(68,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
      endif
      if(c4res.ne.0 .and. feyn.eq.'y')then
         fmt(53:73)='(umdr*(umfe+c4n+he2\''
         call setfmt(73,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
      endif
      endif

      write(1,973)                                    ! freeze umdr c4n he2
      if(c4res.eq.0)write(1,974)                      ! freeze umdr c4b
      write(1,2150)                                   ! freeze con1
      if(feyn.eq.'y')write(1,982)                     ! freeze umfe
      if(pol2yn.eq.'y')write(1,983)                       ! freeze pol2 hpass
c      if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,983)                       ! freeze pol2 hpass
      do 530 i=nal1,nal2
         if(i.lt.10)write(1,535)i  ! freeze a1 - 9
         if(i.ge.10)write(1,536)i  ! freeze a10...
 530  continue
 535  format('freeze a',i1)
 536  format('freeze a',i2)


c ------------------------------

c Fit around each absorption line (FWHM frozen!)
      write(1,2100)                                ! #
      write(1,459)                                 ! # Absorption line fitting
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

c --------------------

      win1=1485.0*(1.0+zred)
      win2=1720.0*(1.0+zred)
      write(1,2200)                               ! ignore all
      write(1,2600)win1,win2                      ! notice filter xxxx:xxxx
      if(stage.eq.'one ' .and. loop.le.1058)call galactic(win1,win2)

      if(c4res.eq.0)then
         if(stage.ne.'one ')write(1,1200) ! thaw c4b.2; fit; freeze he2
         write(1,984)                     ! thaw c4b.1; fit; thaw ...
      endif
c      if(c4res.ne.0)then
c         if(stage.ne.'one ')write(1,1210) ! thaw c4i.2; fit; freeze he2
c         write(1,986)                    ! thaw c4i.1; fit; ...
c         if(stage.ne.'one ')write(1,987) ! thaw c4i; fit; freeze c4i
c      endif
      if(stage.ne.'one ')write(1,988)    ! thaw c4n.2; fit...
      write(1,989)                       ! thaw c4n; fit; freeze c4n...

 1200 format('thaw c4b.2; fit; freeze c4b')
 984  format('thaw c4b.1; fit; thaw c4b.3; fit; freeze c4b')
 985  format('thaw c4b; fit; freeze c4b')
 1210 format('thaw c4i.2; fit; freeze c4i')
 986  format('thaw c4i.1; fit; thaw c4i.3; fit; freeze c4i')
 987  format('thaw c4i; fit; freeze c4i')
 988  format('thaw c4n.2; fit; freeze c4n')
 989  format('thaw c4n.1; fit; thaw c4n.3; fit; freeze c4n')

c --------------------


c Fit He II region
      write(1,2100)                 ! #
      write(1,990)                  ! # He II 1640
 990  format('# He II 1640')
      win1=1610.0*(1.0+zred)
      win2=1700.0*(1.0+zred)
      write(1,2200)                                 ! ignore all
      write(1,2600)win1,win2                        ! notice filter xxxx:xxxx
      if(stage.eq.'one ' .and. loop.le.1058)call galactic(win1,win2)

      write(1,973)                                    ! freeze umdr c4n he2
      if(c4res.eq.0)write(1,974)                      ! freeze umdr c4b
      write(1,2150)                                   ! freeze con1
      if(feyn.eq.'y')write(1,982)                     ! freeze umfe
      if(pol2yn.eq.'y')write(1,983)                       ! freeze pol2 hpass
c      if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,983)                       ! freeze pol2 hpass

c --------------------
      if(stage.eq.'two ' .and. nal1.ne.0)then
      do 991 i=nal1,nal2
         if(i.lt.10)write(1,535)i  ! freeze a1 - 9
         if(i.ge.10)write(1,536)i  ! freeze a10...
 991  continue
      endif

c --------------------

      if(stage.ne.'one ')write(1,1220)  ! thaw he2.2; fit; freeze he2
      write(1,992)                      ! thaw he2.1; fit; thaw he2.3; fit
      if(stage.ne.'one ')write(1,993)   ! thaw he2; fit; freeze he2
 1220 format('thaw he2.2; fit; freeze he2')
 992  format('thaw he2.1; fit; thaw he2.3; fit; freeze he2')
 993  format('thaw he2; fit; freeze he2')

c --------------------

c Fix 2 comp => 1 comp fwhm limits c4n -> 30000
 5000 continue
c 5000 cn1=155.0*(1.0+zred)
c      write(1,6000)cn1
c      write(1,6010)
c 6000 format('c4n.fwhm.max = ',f7.1)
c 6010 format('erase c4b')

c THEN FIT ALL TO THE C IV WINDOW
      write(1,2100)                  ! #
      write(1,2000)                  ! # C IV Region
      win1=1350.0*(1.0+zred)
      win2=1720.0*(1.0+zred)
      write(1,2200)                                 ! ignore all
      write(1,2600)win1,win2                        ! notice filter xxxx:xxxx
      if(stage.eq.'one ' .and. loop.le.1058)call galactic(win1,win2)

 2000 format('# C IV region (inc. Si IV / O IV)')

c --------------------

      if(stage.ne.'two ' .or. nal1.eq.0)then

      if(c4res.eq.0)then
         if(feyn.ne.'y' .and. si4yn.eq.'y')then
         if(sample.eq.'fos_' .or. zred.gt.2.42 .or. 
     $loop.gt.1060)write(1,2020)  ! source 1 = 
         if(pol2yn.eq.'y')write(1,2021) ! source 1 = 
c         if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,2021) ! source 1 = 
         endif
         if(feyn.ne.'y' .and. si4yn.eq.'n')then
         if(sample.eq.'fos_' .or. zred.gt.2.42 .or. 
     $loop.gt.1060)write(1,2024)  ! source 1 = 
         if(pol2yn.eq.'y')write(1,2025) ! source 1 = 
c         if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,2025) ! source 1 = 
         endif
         if(feyn.eq.'y' .and. si4yn.eq.'y')then
         if(sample.eq.'fos_' .or. zred.gt.2.42 .or. 
     $loop.gt.1060)write(1,2030)  ! source 1 = 
         if(pol2yn.eq.'y')write(1,2031) ! source 1 = 
c         if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,2031) ! source 1 = 
         endif
         if(feyn.eq.'y' .and. si4yn.eq.'n')then
         if(sample.eq.'fos_' .or. zred.gt.2.42 .or. 
     $loop.gt.1060)write(1,2034)  ! source 1 = 
         if(pol2yn.eq.'y')write(1,2035) ! source 1 = 
c         if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,2035) ! source 1 = 
         endif
      endif

      if(c4res.ne.0)then
         if(feyn.ne.'y' .and. si4yn.eq.'y')then
         if(sample.eq.'fos_' .or. zred.gt.2.42 .or. 
     $loop.gt.1060)write(1,2040)  ! source 1 = 
         if(pol2yn.eq.'y')write(1,2041) ! source 1 = 
c         if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,2041) ! source 1 = 
         endif
         if(feyn.ne.'y' .and. si4yn.eq.'n')then
         if(sample.eq.'fos_' .or. zred.gt.2.42 .or. 
     $loop.gt.1060)write(1,2044)  ! source 1 = 
         if(pol2yn.eq.'y')write(1,2045) ! source 1 = 
c         if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,2045) ! source 1 = 
         endif
         if(feyn.eq.'y' .and. si4yn.eq.'y')then
         if(sample.eq.'fos_' .or. zred.gt.2.42 .or. 
     $loop.gt.1060)write(1,2050)  ! source 1 = 
         if(pol2yn.eq.'y')write(1,2051) ! source 1 = 
c         if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,2051) ! source 1 = 
         endif
         if(feyn.eq.'y' .and. si4yn.eq.'n')then
         if(sample.eq.'fos_' .or. zred.gt.2.42 .or. 
     $loop.gt.1060)write(1,2054)  ! source 1 = 
         if(pol2yn.eq.'y')write(1,2055) ! source 1 = 
c         if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,2055) ! source 1 = 
         endif
      endif


 2020 format('source 1 = 1e-14*(umdr*(con1+sio4+c4b+',
     $'c4n+he2))')
 2021 format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(sio4+c4b+c4n+he2)))')
 2022 format('freeze umdr sio4 c4b c4n he2')

 2024 format('source 1 = 1e-14*(umdr*(con1+c4b+c4n+he2))')
 2025 format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(c4b+c4n+he2)))')
 2026 format('freeze umdr c4b c4n he2')

 2030 format('source 1 = 1e-14*(umdr*(con1+umfe+sio4+c4b+',
     $'c4n+he2))')
 2031 format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(umfe+sio4+c4b+c4n+he2)))')
 2032 format('freeze umdr umfe sio4 c4b c4n he2')

 2034 format('source 1 = 1e-14*(umdr*(con1+umfe+c4b+c4n+',
     $'he2))')
 2035 format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(umfe+c4b+c4n+he2)))')
 2036 format('freeze umdr umfe c4b c4n he2')


 2040 format('source 1 = 1e-14*(umdr*(con1+sio4+',
     $'c4n+he2))')
 2041 format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(sio4+c4n+he2)))')
 2042 format('freeze umdr sio4 c4n he2')

 2044 format('source 1 = 1e-14*(umdr*(con1+c4n+he2))')
 2045 format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(c4n+he2)))')
 2046 format('freeze umdr c4n he2')

 2050 format('source 1 = 1e-14*(umdr*(con1+umfe+sio4+',
     $'c4n+he2))')
 2051 format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(umfe+sio4+c4n+he2)))')
 2052 format('freeze umdr umfe sio4 c4n he2')

 2054 format('source 1 = 1e-14*(umdr*(con1+umfe+c4n+',
     $'he2))')
 2055 format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+',
     $'(umdr*(umfe+c4n+he2)))')
 2056 format('freeze umdr umfe c4n he2')

      if(si4yn.eq.'y')write(1,2088)
 2088 format('freeze sio4')
      write(1,973)                                    ! freeze umdr c4n he2
      if(c4res.eq.0)write(1,974)                      ! freeze umdr c4b
      write(1,2150)                                   ! freeze con1
      if(feyn.eq.'y')write(1,982)                     ! freeze umfe
      if(pol2yn.eq.'y')write(1,983)                       ! freeze pol2 hpass
c      if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,983)                       ! freeze pol2 hpass


      endif

c --------------------

      if(stage.eq.'two ' .and. nal1.ne.0)then

      if(si4yn.eq.'y')then
      if(sample.eq.'fos_' .or. zred.gt.2.42 .or. 
     $loop.gt.1060)then
      fmt(1:32)='(\'source 1 = 1e-14*(umdr*(con1+'
      if(c4res.eq.0 .and. feyn.ne.'y')then
         fmt(33:50)='sio4+c4b+c4n+he2\''
         call setfmt(50,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
      endif
      if(c4res.eq.0 .and. feyn.eq.'y')then
         fmt(33:55)='umfe+sio4+c4b+c4n+he2\''
         call setfmt(55,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
      endif
      if(c4res.ne.0 .and. feyn.ne.'y')then
         fmt(33:46)='sio4+c4n+he2\''
         call setfmt(46,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
      endif
      if(c4res.ne.0 .and. feyn.eq.'y')then
         fmt(33:51)='umfe+sio4+c4n+he2\''
         call setfmt(51,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
      endif
      endif

      if(pol2yn.eq.'y')then
c      if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)then
      fmt(1:52)='(\'source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+'
      if(c4res.eq.0 .and. feyn.ne.'y')then
         fmt(53:77)='(umdr*(sio4+c4b+c4n+he2\''
         call setfmt(77,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
      endif
      if(c4res.eq.0 .and. feyn.eq.'y')then
         fmt(53:82)='(umdr*(umfe+sio4+c4b+c4n+he2\''
         call setfmt(82,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
      endif
      if(c4res.ne.0 .and. feyn.ne.'y')then
         fmt(53:73)='(umdr*(sio4+c4n+he2\''
         call setfmt(73,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
      endif
      if(c4res.ne.0 .and. feyn.eq.'y')then
         fmt(53:78)='(umdr*(umfe+sio4+c4n+he2\''
         call setfmt(78,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
      endif
      endif

      endif


      if(si4yn.eq.'n')then

      if(sample.eq.'fos_' .or. zred.gt.2.42 .or. 
     $loop.gt.1060)then
      fmt(1:32)='(\'source 1 = 1e-14*(umdr*(con1+'
      if(c4res.eq.0 .and. feyn.ne.'y')then
         fmt(33:45)='c4b+c4n+he2\''
         call setfmt(45,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
      endif
      if(c4res.eq.0 .and. feyn.eq.'y')then
         fmt(33:50)='umfe+c4b+c4n+he2\''
         call setfmt(50,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
      endif
      if(c4res.ne.0 .and. feyn.ne.'y')then
         fmt(33:41)='c4n+he2\''
         call setfmt(41,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
      endif
      if(c4res.ne.0 .and. feyn.eq.'y')then
         fmt(33:46)='umfe+c4n+he2\''
         call setfmt(46,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac
      endif
      endif

      if(pol2yn.eq.'y')then
c      if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)then
      fmt(1:52)='(\'source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass)+'
      if(c4res.eq.0 .and. feyn.ne.'y')then
         fmt(53:72)='(umdr*(c4b+c4n+he2\''
         call setfmt(72,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
      endif
      if(c4res.eq.0 .and. feyn.eq.'y')then
         fmt(53:77)='(umdr*(umfe+c4b+c4n+he2\''
         call setfmt(77,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
      endif
      if(c4res.ne.0 .and. feyn.ne.'y')then
         fmt(53:68)='(umdr*(c4n+he2\''
         call setfmt(68,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
      endif
      if(c4res.ne.0 .and. feyn.eq.'y')then
         fmt(53:73)='(umdr*(umfe+c4n+he2\''
         call setfmt(73,nal1,nal2,fmt)
         write(1,fmt)(pa,a(j),j=nal1,nal2),brac,brac,brac
      endif
      endif

      endif


      if(si4yn.eq.'y')write(1,2088)                   ! freeze sio4
      write(1,973)                                    ! freeze umdr c4n he2
      if(c4res.eq.0)write(1,974)                      ! freeze umdr c4b
      write(1,2150)                                   ! freeze con1
      if(feyn.eq.'y')write(1,982)                     ! freeze umfe
      if(pol2yn.eq.'y')write(1,983)                       ! freeze pol2 hpass
c      if(sample.eq.'lbqs' .and. zred.le.2.42 .and. 
c     $loop.le.1060)write(1,983)                       ! freeze pol2 hpass


      do 2058 i=nal1,nal2
         if(i.lt.10)write(1,535)i  ! freeze a1 - 9
         if(i.ge.10)write(1,536)i  ! freeze a10...
 2058 continue


      endif


c --------------------


      if(c4res.eq.0)then
         if(stage.ne.'one ')write(1,2060)         ! thaw c4b.2
         write(1,2062)                            ! thaw c4b.1 c4b.3; fit; ...
      endif
      if(stage.ne.'one ')write(1,2068)            ! thaw c4n.2
      write(1,2070)                               ! thaw c4n.1 c4n.3; fit; ...
      if(stage.ne.'one ')write(1,2072)            ! thaw he2.2
      write(1,2074)                               ! thaw he2.1 he2.3; fit; ...
      if(si4yn.eq.'y')then
         if(stage.ne.'one ')write(1,2076)         ! thaw sio4.2
         write(1,2078)                            ! thaw sio4.1 sio4.3; fit
      endif
      if(c4res.eq.0)then
         if(stage.ne.'one ')write(1,2060)         ! thaw c4b.2
         write(1,2080)                            ! thaw c4b.1 c4b.3
      endif
      if(stage.ne.'one ')write(1,2084)            ! thaw c4n.2 he2.2       
      write(1,2086)                               ! thaw c4n.1 c4n.3 he2.1 ...
      if(si4yn.eq.'y')write(1,2088)               ! freeze sio4
      if(c4res.eq.0)write(1,2090)                 ! freeze c4b


 2060 format('thaw c4b.2')
 2062 format('thaw c4b.1 c4b.3; fit; freeze c4b')
 2064 format('thaw c4i.2')
 2066 format('thaw c4i.1 c4i.3; fit; freeze c4i')
 2068 format('thaw c4n.2')
 2070 format('thaw c4n.1 c4n.3; fit; freeze c4n')
 2072 format('thaw he2.2')
 2074 format('thaw he2.1 he2.3; fit; freeze he2')
 2076 format('thaw sio4.2')
 2078 format('thaw sio4.1 sio4.3; fit')
 2080 format('thaw c4b.1 c4b.3')
 2082 format('thaw c4i.1 c4i.3')
 2084 format('thaw c4n.2 he2.2')
 2086 format('thaw c4n.1 c4n.3 he2.1 he2.3; fit; freeze c4n he2')
 2090 format('freeze c4b')
 2092 format('freeze c4i')


c --------------------
c FIX 2 comp => 1 comp skip src creation
c      goto 3000

      call wsrc(loop)          ! notice all

      write(1,2900)dir(loop) 
      write(1,2905)dir(loop)

 2900 format('WRITE source \'',a11,'.full2.src\' ascii')
 2905 format('WRITE residuals \'',a11,'.full2.res\' ascii')


      if(c4res.eq.0)write(1,2134)          ! source 1 = umdr*c4b
      if(c4res.eq.0)write(1,2136)dir(loop) ! WRITE source c4b
c      if(c4res.eq.0)write(1,2138)            ! source 1 = umdr*c4i
c      if(c4res.eq.0)write(1,2140)dir(loop)   ! WRITE source '<file>.c4i.src'
      write(1,2141)            ! source 1 = umdr*c4n
      write(1,2142)dir(loop)   ! WRITE source '<file>.c4n.src' ascii
      write(1,2143)            ! source 1 = umdr*he2
      write(1,2144)dir(loop)   ! WRITE source '<file>.he2.src' ascii
 2134 format('source 1 = umdr*c4b')
 2136 format('WRITE source \'',a11,'.c4b.src\' ascii')
 2138 format('source 1 = umdr*c4i')
 2140 format('WRITE source \'',a11,'.c4i.src\' ascii')
 2141 format('source 1 = umdr*c4n')
 2142 format('WRITE source \'',a11,'.c4n.src\' ascii')
 2143 format('source 1 = umdr*he2')
 2144 format('WRITE source \'',a11,'.he2.src\' ascii')

 2145 if(si4yn.eq.'y') then
      if(c4yn.eq.'n')call wsrc(loop)
      write(1,2146)                 ! source 1 = umdr*sio4
      write(1,2147)dir(loop)        ! WRITE source '<file>.sio4.src' ascii
 2146 format('source 1 = umdr*sio4')
 2147 format('WRITE source \'',a11,'.sio4.src\' ascii')
      endif

      if(stage.eq.'two ' .and. nal1.ne.0)then
      do 1050 i=nal1,nal2
         if(i.lt.10)write(1,1010)i                 ! source 1 = umdr*a#
         if(i.ge.10)write(1,1015)i                 ! source 1 = umdr*a##
         if(i.lt.10)write(1,1020)dir(loop),i
         if(i.ge.10)write(1,1025)dir(loop),i
 1010 format('source 1 = umdr*a',i1)
 1015 format('source 1 = umdr*a',i2)
 1020 format('WRITE source \'',a11,'.a',i1,'.src\' ascii')
 1025 format('WRITE source \'',a11,'.a',i2,'.src\' ascii')
 1050 continue
      endif



 2100 format('# ')
 2150 format('freeze con1 ')
 2600 format('notice filter ',f7.1,':',f7.1) 
 2200 format('ignore all')

 3000 return
      end


c ##################################################
