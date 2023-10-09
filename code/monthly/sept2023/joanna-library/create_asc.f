      program create_asc

c     CREATES ASCFIT SCRIPT FILES FOR FOS and LBQS SPECTRA
c     And creation of SAVE files for adjustment of continuum fit by hand

      implicit real (a-h,l-z)
      real wave1,wave2,w,f1,f2,cn1,cn2
      real zred,nh,ref1,cflux(14),cfw1(14),cfw2(14)
      real cfluxn,refn,al(1000),afw(1000),wmin
      integer i,j,ndir,loop,cf(14),cfn,lares,lbres,bloop
      integer c4res,c3res,mg2res,mark,nalines,bal(100),disk
      character*11 iau
      character*11 dir(2000)
      character*14 name
      character*60 a3
      character*40 a4
      character*1 feyn,feoyn,lyayn,lybyn,si4yn,c4yn,c3yn
      character*1 mg2yn,ne5yn,o2yn,ne3yn,hdyn,hgyn,hbyn,he1yn,hayn
      character*1 pow2,usesave,he2yn,usefe2,pol2yn
      character*4 sample,stage,state
      character*28 a1

c Re-fitted Fe
      integer feuv(50),feopt(50)


c ----------------------------------------------------------------------
cxxx
      state='excl'
      sample='pgbg'
      disk=1

c Switch for the use or not of SAVEd asc files 
c    (in /data/kf1/<>data/ASCSAVE/<>.SAVE)
      usesave='y'
c Switch for the use or not of Fe2 SAVEd asc files
c    (in /data/kf1/<>data/ASCSAVE/<>.FESAVE)
      usefe2='y'

c Switch for incremental line fitting
c one = frozen line positions (inc Fe)
c two = input results from FINDSL, free line positions
c       remember to list abs line files into abslines.list
c       ls /data/kf1/lbqsfindsl1/*/s1.SLs > abslines1.list
c       then edit so that the fields are just the names (a11)
c thre = input results from 2nd run of FINDSL (in lbqsfindsl2 > abslines2.list)
      stage='two '

c ----------------------------------------------------------------------
      if(sample.eq.'lbqs')then
      open(unit=1,status='old',file='lbqs_exclude.list')
      read(1,'(x)')
      read(1,'(x)')
      do 20 i=1,100
         read(1,25,err=30)bal(i)
 20   continue
 25   format(i4)
 30   close(1)
      endif
c ----------------------------------------------------------------------

 10   format(a11)
      a1(1:23)='/data/kf1/prog_central/'
      a1(24:27)=sample
      a1(28:35)='dir.name'
      open(unit=1,status='old',file=a1(1:35))
      do 100 i=1,2000
         read(1,10,err=110)dir(i)
 100  continue
 110  close(1)
      ndir=i-1

c WRITE to text file fields.txt
      a1(1:23)='/data/kf1/prog_central/'
      a1(24:27)=sample
      a1(28:41)='fields_con.txt'
      if(usesave.eq.'n')open(unit=3,status='new',file=a1(1:41))
      if(usesave.eq.'y')then
         if(usefe2.eq.'n')then
            a1(28:40)='fields_fe.txt'
            open(unit=3,status='new',file=a1(1:40))
         else
            if(stage.eq.'one ')a1(28:38)='fields1.txt'
            if(stage.eq.'two ')a1(28:38)='fields2.txt'
            if(stage.eq.'thre')a1(28:38)='fields3.txt'
            open(unit=3,status='new',file=a1(1:38))
         endif
      endif

c WRITE script to run ascfit
      open(unit=2,status='new',file='asc_run_all.sc')

      write(2,130)             ! #!/bin/csh
 130  format('#!/bin/csh')

c ----------------------------------------------------------------------

c      loop=1

      do 2000 loop=1,ndir

c BAL list exclusion
      mark=0
      do 140 i=1,100
      if(stage.ne.'one ' .and. loop.eq.bal(i) .and. 
     $sample.eq.'lbqs')mark=1



 140  continue
      if(mark.eq.1)goto 2000

c Greater than sample size for some reason => escape
      if(loop.gt.1061)goto 2000

c ----------------------------------------------------------------------

      feyn='n'
      feoyn='n'
      pol2yn='n'
      pow2='n'

      write(2,155)             ! /soft/saord/bin2.6/xpans -e -p 14285 -l
 155  format('/soft/saord/bin2.6/xpans -e -p 14285 -l ',
     $' /tmp/.xpa/xpans_14285.log &')

c READ redshift and NH from data.dat file

      a1(1:23)='/data/kf1/prog_central/'
      a1(24:27)=sample
      a1(28:35)='data.dat'
      open(unit=1,status='old',file=a1(1:35))
      do 160 i=1,ndir
         if(sample.eq.'fos_')read(1,170)iau(1:9),name,zred,nh
         if(sample.eq.'lbqs')read(1,171)iau(1:11),zred,nh
         if(sample.eq.'pgbg')read(1,173)iau(1:11),zred,nh
         if(sample.eq.'pgbg')zred=0.0
         if(sample.eq.'mdm_')read(1,172)iau(1:5),zred,nh
      if(sample.eq.'fos_' .and. iau(1:9).eq.dir(loop)(1:9)) goto 165
      if(sample.eq.'lbqs' .and. iau(1:11).eq.dir(loop)(1:11)) goto 165
      if(sample.eq.'mdm_' .and. iau(1:5).eq.dir(loop)(1:5)) goto 165
      if(sample.eq.'pgbg' .and. iau(1:11).eq.dir(loop)(1:11)) goto 165
 160  continue
 165  close(1)
 170  format(1x,a9,2x,a14,x,f8.5,2x,f5.2)
 171  format(1x,a11,27x,f5.3,2x,f4.2)
 172  format(1x,a5,4x,f8.6,2x,f4.2)
 173  format(a11,25x,f5.3,2x,f5.3)

 200  format(3x,f8.3,3x,e11.4,3x,e11.4)


      write(3,*)' '
      write(3,*)loop,')--------------------------------------------'
      write(3,*)iau,zred,nh,' ',dir(loop)

c READ wavelength limits from data file  /data/kf1/<>data/DATA/###.dat

      a4(1:10)='/data/kf1/'
      a4(11:14)=sample
      a4(15:24)='data/DATA/'
      a4(25:35)=dir(loop)
      a4(36:40)='.dat '
      if(sample.eq.'mdm_')a4(9:9)='3'

c ----------------------------------------------------------------------

c READ starting flux amplitude at positions in the following priority:
c      1) 1455:1470 = 1462,  2) 1690:1700 = 1695,  3) 2160:2180 = 2170, 
c      4) 2225:2250 = 2237,  5) 1320:1330 = 1325,  6) 3010:3040 = 3025,
c      7) 3480:3520 = 3400,  8) 3790:3810 = 3800,  9) 4210:4230 = 4220,
c     10) 5080:5100 = 5090, 11) 5600:5630 = 5615, 12) 5970:6000 = 5985,
c     13) 1275:1280 = 1277, 14) 1140:1150 = 1145

c reverse priority file order   Priority
      cfw1(1)= 1140.0*(1.0+zred) ! 14
      cfw2(1)= 1150.0*(1.0+zred)
      cfw1(2)= 1275.0*(1.0+zred) ! 13
      cfw2(2)= 1280.0*(1.0+zred)
      cfw1(10)=1320.0*(1.0+zred) ! 5
      cfw2(10)=1330.0*(1.0+zred)
      cfw1(14)=1455.0*(1.0+zred) ! 1
      cfw2(14)=1470.0*(1.0+zred)
      cfw1(13)=1690.0*(1.0+zred) ! 2
      cfw2(13)=1700.0*(1.0+zred)
      cfw1(12)=2160.0*(1.0+zred) ! 3 NEW
      cfw2(12)=2180.0*(1.0+zred)
      cfw1(11)=2225.0*(1.0+zred) ! 4
      cfw2(11)=2250.0*(1.0+zred)
      cfw1(9)= 3010.0*(1.0+zred) ! 6
      cfw2(9)= 3040.0*(1.0+zred)
      cfw1(8)= 3240.0*(1.0+zred) ! 7   ! ADD
      cfw2(8)= 3270.0*(1.0+zred)
c      cfw1(8)= 3480.0*(1.0+zred) ! 7  ! CUT due to Balmer continuum LBQS only?
c      cfw2(8)= 3520.0*(1.0+zred)
      cfw1(7)= 3790.0*(1.0+zred) ! 8   ! CUT
      cfw2(7)= 3810.0*(1.0+zred)
      cfw1(6)= 4210.0*(1.0+zred) ! 9
      cfw2(6)= 4230.0*(1.0+zred)
      cfw1(5)= 5080.0*(1.0+zred) ! 10
      cfw2(5)= 5100.0*(1.0+zred)
      cfw1(4)= 5600.0*(1.0+zred) ! 11
      cfw2(4)= 5630.0*(1.0+zred)
      cfw1(3)= 5970.0*(1.0+zred) ! 12 NEW
      cfw2(3)= 6000.0*(1.0+zred)

c put this new one in as well ?
c      cfw1(1)= 6200.0*(1.0+zred)
c      cfw2(1)= 6220.0*(1.0+zred)

      open(unit=1,status='old',file=a4(1:39)) ! /data/kf1/#data/DATA/###.dat
      do 230 i=1,10000
      if(sample.eq.'fos_' .or. sample.eq.'lbqs')read(1,*,end=231)w,
     $f1,f2
      if(sample.eq.'mdm_' .or. sample.eq.'pgbg')read(1,*,end=231)w,f1
      if(i.eq.1)wave1=w                       ! STARTING WAVELENGTH
 230  continue
 231  close(1)
      wave2=w                                 ! ENDING WAVELENGTH

c for long spec covering either side of 4220 A window:
      cn1=wave1/(1.0+zred)
      cn2=wave2/(1.0+zred)
      if(cn1.lt.4220.0 .and. cn2.gt.4220.0)pow2='y'

      ref1=0.0
      refn=0.0
      cfluxn=0.0
      do 257 i=1,14
         cf(i)=0
         cflux(i)=0.0

c If the cont. window lies around the end of the spec make sure it is at least
c 10 A wide within the spec
         if(cfw1(i).le.wave1 .and. cfw2(i).gt.wave1)then
            cfw1(i)=wave1
            if(cfw2(i).lt.(wave1+10.0))cfw2(i)=wave1+10.0
         endif
         if(cfw1(i).lt.wave2 .and. cfw2(i).ge.wave2)then
            cfw2(i)=wave2
            if(cfw1(i).gt.(wave2-10.0))cfw1(i)=wave2-10.0
         endif

 257  continue

      open(unit=1,status='old',file=a4(1:39)) ! /data/kf1/#data/DATA/###.dat
      do 270 i=1,10000
      if(sample.eq.'fos_' .or. sample.eq.'lbqs')read(1,*,end=275)w,
     $f1,f2
      if(sample.eq.'mdm_' .or. sample.eq.'pgbg')read(1,*,end=275)w,f1
c      if(i.eq.1)wave1=w                       ! STARTING WAVELENGTH

c Calculate average flux between windows for starting normalization
c to power law
      do 265 j=1,14
      if(w.ge.cfw1(j) .and. w.le.cfw2(j)) then
         if(f1.gt.0.0) then
            cn=(log10(f1))+14.0
            cn=10.0**cn
         endif
         if(f1.lt.0.0) then
            cn=(log10(-1.0*f1))+14.0
            cn=10.0**cn
            cn=-1.0*cn
         endif
         cflux(j)=cflux(j)+cn
         cf(j)=cf(j)+1
      endif
 265  continue

 270  continue
 275  close(1)

c Divide total flux in each continuum window [cflux(i)] by 
c   the number of bins [cf(i)]
      do 277 i=1,14
         if(cf(i).ne.0)cflux(i)=cflux(i)/cf(i)
         if(cf(i).eq.0)cflux(i)=0.0
 277  continue

c Spectrum is only blueward of bluest continuum window (1140 A)
      if(wave2.le.cfw1(1)) then
         refn=wave2-5.0
         cfluxn=0.0
         cfn=0
         open(unit=1,status='old',file=a4(1:39)) ! /data/kf1/#data/DATA/###.dat
         do 280 i=1,10000
      if(sample.eq.'fos_' .or. sample.eq.'lbqs')read(1,*,end=285)w,
     $f1,f2
      if(sample.eq.'mdm_' .or. sample.eq.'pgbg')read(1,*,end=285)w,f1
            if(w.ge.(wave2-10.0)) then
               if(f1.gt.0.0) then
                  f1=(log10(f1))+14.0
                  f1=10.0**f1
               endif
               if(f1.lt.0.0) then
                  f1=(log10(-1.0*f1))+14.0
                  f1=10.0**f1
                  f1=-1.0*f1
               endif
               cfluxn=cfluxn+f1
               cfn=cfn+1
            endif
 280     continue
 285     close(1)
         cfluxn=cfluxn/cfn
      write(3,*)'Continuum flux pinned at red end of spectrum'
      write(3,*)'    start       end      bins    flux       Ref Wave'
      write(3,*)wave1,wave2,cfn,cfluxn,refn
      else

      write(3,*)'Continuum fluxes'
      write(3,*)' num   start      end    bins    flux       Ref Wave'

c choose flux in priority
         do 290 i=1,14
         ref1=0.0
            if(cf(i).ne.0) then
               mark=0
c FOS check that the window is in the spectrum!
            if(sample.eq.'fos_' .and. cfw1(i).ge.wave1)mark=1
c FOR LBQS place out of bad region
            if(sample.eq.'lbqs' .and. cfw1(i).gt.4000)mark=1
            if(sample.eq.'lbqs' .and. loop.gt.1058)mark=1
c MDM check that the window is in the spectrum!
            if(sample.eq.'mdm_' .and. cfw1(i).ge.wave1)mark=1
            if(sample.eq.'pgbg' .and. cfw1(i).ge.wave1)mark=1

               if(mark.eq.1)then
                  cfluxn=cflux(i)
                  refn=((cfw2(i)-cfw1(i))/2.0)+cfw1(i)
                  ref1=((cfw2(i)-cfw1(i))/2.0)+cfw1(i)
               endif
            endif
            write(3,*)i,cfw1(i),cfw2(i),cf(i),cflux(i),ref1
 290     continue
      endif

      write(3,*)'Chosen Continuum flux:'
      write(3,*)' Spec Blue     Red       Cont. Flux      Lambda'
      write(3,*)wave1,wave2,cfluxn,refn

c ----------------------------------------------------------------------

c WRITE ASCFIT script to fit spectrum /data/kf1/<>data/###/ASCFIT/###.asc
      a3(1:10)='/data/kf1/'
      a3(11:14)=sample
      a3(15:19)='data/'
      a3(20:30)=dir(loop)
      a3(31:38)='/ASCFIT/'
      a3(39:49)=dir(loop)
      if(sample.eq.'mdm_')a3(9:9)='3'

      if(usesave.eq.'n')a3(50:54)='.asc '
      if(usesave.eq.'y')then
         if(usefe2.eq.'n')a3(50:54)='.asf '
         if(usefe2.eq.'y')then
            a3(50:53)='.ast'
            if(stage.eq.'one ')a3(54:54)='1'
            if(stage.eq.'two ')a3(54:54)='2'
            if(stage.eq.'thre')a3(54:54)='3'
         endif
      endif

      write(*,*)loop,' ',a3(1:54)
 
c WRITE TO RUN SCRIPT
      write(2,300)disk,sample,dir(loop)           ! cd /data/kf...
      write(2,302)                                ! pwd
      write(2,305)a3(39:54)                       ! /data/kf1/sherpa/sherpa_lg 
 300  format('cd /data/kf',i1,'/',a4,'data/',a11,'/ASCFIT')
 302  format('pwd')

c 305  format('/home/ascds/DS.release/bin/sherpa ',a16)
c 305  format('/home/ascds/DS.daily/bin/sherpa ',a16)
c 305  format('/data/kf1/sherpa/sherpa_opt ',a16)
 305  format('/data/kf1/sherpa/sherpa_lg ',a16)



c WRITE ASCFIT SCRIPT
      open(unit=1,status='new',file=a3(1:54)) ! /data/kf1/#data/#/ASCFIT/#.asc
c      open(unit=1,status='new',file='test.ast')

c HEADER --------------------
      write(1,315)a3(39:54)      ! #  - ASCFIT script to fit full spectrum
      write(1,2100)              ! # 
      write(1,316)stage          ! # STAGE two
      write(1,2100)              ! # 
      write(1,320)wave1,wave2    ! # Observed wavelength range 
      write(1,325)zred,nh        ! # Redshift =    Galactic NH =  10^20 cm^-2
      write(1,2100)              ! #

 315  format('# ',a16,' - SHERPA script to fit full spectrum')
 316  format('# STAGE ',a4)
 320  format('# Observed wavelength range ',f8.3,' to ',f9.3,' A')
 325  format('# Redshift = ',f8.5,'     Galactic NH = ',f5.2,
     $' 10^20 cm^-2')

      write(1,2100)              ! # 
      write(1,302)               ! pwd
      write(1,2100)              ! # 

c To check for a polynomial continuum component
c Sets pol2yn=y
      if(usesave.eq.'y')call pol2check(pol2yn,dir,loop,sample)

c To re-set feyn and feoyn to only choose those objects with non-zero
c Fe flux.
      if(usefe2.eq.'y')call fecheck(feyn,feoyn,dir,loop,sample)

c USE SAVEd files?
      write(1,2100)           ! # 
      if(usesave.eq.'y')then
         if(usefe2.eq.'n' .and. stage.eq.'one ')then
         write(1,330)disk,sample,dir(loop)
         endif         
         if(usefe2.eq.'y' .and. stage.eq.'one ')then
         write(1,332)disk,sample,dir(loop)
         endif         
         if(usefe2.eq.'y' .and. stage.ne.'one ')then
      if(stage.eq.'two ' .and. sample.eq.'pgbg')write(1,334)disk,
     $sample,dir(loop),dir(loop)
      if(stage.eq.'two ' .and. sample.eq.'lbqs')write(1,336)disk,
     $sample,dir(loop),dir(loop)
         endif         
      endif         

 330  format('use \'/data/kf',i1,'/',a4,'data/ASCSAVE/',a11,'.SAVE\'')
 332  format('use \'/data/kf',i1,'/',a4,'data/ASCSAVE/',a11,'.FESAVE\'')
 334  format('use \'/data/kf',i1,'/',a4,'data/',a11,'/ASCFIT/',
     $a11,'_S1.save\'')
 335  format('use \'/data/kf',i1,'/',a4,'data/',a11,'/ASCFIT/',
     $a11,'_S2.save\'')
c FIX 2 comp => 1 comp
c 335  format('use \'/data/kf',i1,'/',a4,'data/',a11,'/ASCFIT/',
c     $a11,'_S2f_1.save\'')
c Re-fit Fe
 336  format('use \'/data/kf',i1,'/',a4,'data/',a11,'/ASCFIT/',
     $a11,'_S2f.save\'')

c RESET errors
      if(stage.eq.'two' .and. sample.eq.'pgbg')write(1,370)
 370  format('errors = 1e-17')

c STATISTICS
c ----------

      write(1,380)     ! statistic chi gehrels
      write(1,385)     ! method powell; powell.iterations=100; powell.verbose=5;
                       ! powell.eps=0.001
      write(1,2100)    ! #

 380  format('statistic chi gehrels')
 385  format('method powell; powell.iterations=100; powell.verbose=5;',
     $' powell.eps=0.001')

c Re-plot of corrected continuum files
      if(stage.eq.'one ')then
      if(usesave.eq.'y' .and. usefe2.eq.'y')call savecon(pow2,feyn,
     $feoyn,zred,dir,loop,refn,wave1,wave2,sample,usesave,usefe2)
      endif

      if(sample.eq.'fos_' .and. usesave.eq.'y')goto 397  ! 3 loops for con + Fe
      if(sample.ne.'fos_' .and. usesave.eq.'y')goto 395  ! only 1 con + Fe fit

c READ --------------------
      write(1,372)disk,sample,dir(loop)      ! read data 1 \'/data/kf1/f...
      if(sample.eq.'fos_' .or. sample.eq.'lbqs')then
         write(1,375)disk,sample,dir(loop)          ! errs
      else
         write(1,377)                          ! errors = 1e-16
      endif

      write(1,2951)            ! # set plot tool gnuplot; open plot
c      write(1,2954)            ! plot data

      write(1,2100)           ! # 

 372  format('read data 1 \'/data/kf',i1,'/',a4,'data/DATA/',a11,
     $'.dat\' ASCII 1 2')
 375  format('read errors \'/data/kf',i1,'/',a4,'data/DATA/',a11,
     $'.dat\' 1 3')
 377  format('errors = 1e-16')

c ----------------------------------------------------------------------

c BASIC MODELS (power law, dereddenning)
c ------------

c LOOP 3 times to get consistent power law and Fe II template measurements

      feyn='n'
      feoyn='n'

      bloop=0
 387  bloop=bloop+1
      write(1,2100)    ! #
      write(1,388)bloop
      write(1,2100)    ! #
 388  format('# BASIC ITERATION ',i1,' --------------------------')

      call basic(loop,dir,nh,refn,cfluxn,cflux,cfw1,cfw2,wave1,
     $wave2,zred,pow2,bloop,feyn,feoyn,a4,sample,pol2yn)


c NO LOOP FOR LBQS or MDM or PGBG
      if(sample.ne.'fos_')then
         call savecon(pow2,feyn,feoyn,zred,dir,loop,
     $refn,wave1,wave2,sample,usesave,usefe2,pol2yn)
         write(1,390) ! quit
 390  format('quit')
      endif
c Skip to loop for usesave=n
      if(sample.ne.'fos_')goto 2000

c Skip to here if usesave='y' and for non FOS
 395  continue

c ----------------------------------------------------------------------
c Fe Template modeling
c --------------------


c skip ahead if Fe already fitted
      if(usefe2.eq.'y')goto 397

      if(sample.ne.'fos_')bloop=1

      call fe2(zred,loop,dir,feyn,feoyn,wave1,wave2,a4,pow2,bloop,
     $sample,pol2yn)
      call savecon(pow2,feyn,feoyn,zred,dir,loop,refn,wave1,wave2,
     $sample,usesave,usefe2,pol2yn)

c No further in fitting if Fe2 is being modeled
      write(1,390) ! quit

c 3 iterations for FOS spectra continuum and Fe
      if(sample.eq.'fos_' .and. usefe2.eq.'n')then
         if(feyn.ne.'y' .and. feoyn.ne.'y')bloop=3
      endif
      if(sample.eq.'fos_' .and. bloop.lt.3 .and. usefe2.eq.'n')goto 387

      if(sample.eq.'fos_' .and. usefe2.eq.'n')then
         call savecon(pow2,feyn,feoyn,zred,dir,loop,refn,wave1,wave2,
     $sample,usesave,usefe2,pol2yn)
         write(1,390) ! quit
      endif

c skip to end with no line fitting
      if(sample.eq.'fos_')goto 2000

c --------------------------------------------------

c Skip to here if usesave='y' or Fe2 has already been modeled (and FOS sample)
 397  continue

c Skip emission line fit if usefe2='n'
      if(usefe2.eq.'n')goto 2000


c ----------------------------------------------------------------------
c MINIMUM RESOLUTION

      wmin=2.5
      if(sample.eq.'mdm_')wmin=4.5
      if(sample.eq.'lbqs')wmin=10.0
      if(sample.eq.'lbqs' .and. wave2.gt.6850)wmin=6.0
      if(sample.eq.'lbqs' .and. loop.gt.1058)wmin=6.0
      if(sample.eq.'lbqs' .and. loop.eq.1061)wmin=3.0

c --------------------------------------------------

c ABSORPTION LINES
      call abslines(sample,loop,dir,stage,zred,wave2,nalines,
     $al,afw,wmin)

c ----------------------------------------------------------------------

c EMISSION LINES
c --------------

      if(stage.eq.'one ')then
         write(3,*)'Emission line starting parameters'
      else
         write(3,*)'Emission line First fit parameters'
      endif

c for long spec covering either side of 4220 A window:
      if(pow2.eq.'y')then
         write(1,2100)  ! #
         write(1,398)   ! con1.1 => con3.1....
         write(1,2100)  ! #
      endif
 398  format('con1.1 => con3.1; con1.2 => con3.2; con1.3 => con3.3')

      call lybeta(lybyn,feyn,lbres,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,stage,sample,nalines,al,afw,wmin)

      call lyalpha(lyayn,feyn,lares,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,sample,stage,nalines,al,afw,pol2yn,wmin)

      call sio4reg(si4yn,feyn,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,sample,stage,nalines,al,afw,pol2yn,wmin)

      call c4reg(c4yn,si4yn,feyn,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,c4res,sample,stage,nalines,al,afw,
     $pol2yn,wmin)

      call c3reg(c3yn,feyn,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,c3res,sample,stage,nalines,al,afw,
     $pol2yn,wmin)

      call mg2reg(mg2yn,feyn,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,mg2res,sample,stage,nalines,al,
     $afw,pol2yn,wmin)

      call ne5reg(ne5yn,feyn,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,sample,stage,nalines,al,afw,wmin)

      call o2reg(o2yn,feyn,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,sample,stage,nalines,al,afw,wmin)

      call ne3reg(ne3yn,feyn,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,sample,stage,nalines,al,afw,wmin)

      call hdreg(hdyn,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,sample,stage,nalines,al,afw,
     $pol2yn,wmin)

 460  if(pow2.eq.'y')then
         write(1,2100) ! # 
         write(1,500)  ! # POWER LAW CHANGE
         write(1,510)  ! con1.1 => con4.1....
         write(1,2100) ! #
      endif
 500  format('# POWER LAW CHANGE')
 510  format('con1.1 => con4.1; con1.2 => con3.2; con1.3 => con3.3')

      call hgreg(hgyn,feoyn,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,sample,stage,nalines,al,afw,
     $pol2yn,wmin)

      call hbreg(hbyn,feoyn,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,sample,stage,nalines,al,afw,
     $pol2yn,wmin,hbres)

      call he2reg(he2yn,feoyn,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,sample,stage,nalines,al,afw,
     $pol2yn,wmin,hbyn,hbres)

      call he1reg(he1yn,feoyn,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,sample,stage,nalines,al,afw,
     $pol2yn,wmin)

      call hareg(hayn,feoyn,zred,loop,dir,wave1,wave2,a4,
     $cf,cflux,cfw1,cfw2,pow2,sample,stage,nalines,al,afw,
     $pol2yn,wmin)

c ----------------------------------------------------------------------

c SAVE parameters to file
 1950 write(1,2100)             ! #

c To remove symbolic links from con1
      if(pow2.eq.'y')write(1,402)refn,cfluxn  ! con1.1=1.0; con1.2=refn;...
      write(1,405)    ! source 1 =
      write(1,406)    ! source 2 =
 402  format('con1.1=1.0; con1.2=',f7.1,'; con1.3=',f10.5)
 405  format('source 1 =')
 406  format('source 2 =')

 1990 if(stage.eq.'one ')write(1,1992)dir(loop)  ! SAVE all '<file>_S1.save'
      if(stage.eq.'two ')write(1,1994)dir(loop)  ! SAVE all '<file>_S2.save'
      if(stage.eq.'thre')write(1,1995)dir(loop)  ! SAVE all '<file>_S3.save'
 1992 format('SAVE all \'',a11,'_S1.save\'')
 1995 format('SAVE all \'',a11,'_S3.save\'')
 1994 format('SAVE all \'',a11,'_S2.save\'')

 1999 write(1,3000)             ! quit

      close(1)

c ----------------------------------------------------------------------

 2000 continue

      close(2)
      close(3)

c ----------------------------------------------------------------------


c QUIT 
c ----
 3000 format('quit')

c COMMON LINES
c ------------
 2100 format('# ')
 2150 format('freeze con1 ')
 2300 format('fit')
 2400 format('notice all')
 2500 format('ignore all')
 2550 format('ignore all; notice filter ',f6.1,':',f6.1)
 2600 format('notice filter ',f7.1,':',f7.1) 

c for source plotting
 2700 format('# WRITE SOURCE FUNCTIONS TO .src files')


c PLOTTING
c --------

c      write(1,2950)   ! set plot tool gnuplot; open plot
c      write(1,2952)   ! show
c      write(1,2954)   ! lplot data

 2950  format('set plot tool gnuplot; open plot')
 2951  format('# set plot tool gnuplot; open plot')
 2952  format('show')
 2954  format('lplot data')

      end
