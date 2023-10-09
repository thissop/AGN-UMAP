c ######################################################################

      subroutine savecon(pow2,feyn,feoyn,zred,dir,loop,refn,
     $wave1,wave2,sample,usesave,usefe2,pol2yn)

c SAVE and WRITE and PRINT

      implicit real(a-h,l-z)
      real wave1,wave2
      integer loop
      character*1 pow2,feyn,feoyn,usesave,usefe2,pol2yn
      character*11 dir(2000)
      character*4 sample

      if(usesave.eq.'y' .and. usefe2.eq.'y')goto 3000

      call wsrc(loop)   ! # 
                        ! # WRITE SOURCE FUNCTIONS TO .src files
                        ! # 
                        ! notice all

      write(1,100)                  ! freeze con1 umdr
      if(pow2.eq.'y')write(1,105)   ! freeze con3 con4
      if(feyn.eq.'y')write(1,110)   ! freeze umfe
      if(feoyn.eq.'y')write(1,115)  ! freeze umfeo
      if(pol2yn.eq.'y')write(1,120)     ! freeze pol2 lpass.

 100  format('freeze con1 umdr')
 105  format('freeze con3 con4')
 110  format('freeze umfe')
 115  format('freeze umfeo')
 120  format('freeze pol2 lpass hpass')


      write(1,2100)    ! # 

c Skip ahead if the continuum has already been done
      if(usesave.eq.'y')goto 470

c 1 POWER LAW CONTINUUM --------------------
      if(pow2.ne.'y')then
      write(1,150)            ! source 1 = con1
      write(1,155)dir(loop)   ! WRITE source '<file>.c1.src ascii'
      write(1,160)            ! source 1 = con1*umdr
      write(1,165)dir(loop)   ! WRITE source '<file>.c1dr.src ascii'
      write(1,170)            ! source 1 = 1e-14*(con1*umdr)
      write(1,175)dir(loop)   ! WRITE source '<file>.14c1dr.src ascii'
      endif

 150  format('source 1 = con1')
 155  format('WRITE source \'',a11,'.c1.src\' ascii')
 160  format('source 1 = con1*umdr')
 165  format('WRITE source \'',a11,'.c1dr.src\' ascii')
 170  format('source 1 = 1e-14*(con1*umdr)')
 175  format('WRITE source \'',a11,'.14c1dr.src\' ascii')

c 2 POWER LAW CONTINUUM --------------------
      if(pow2.eq.'y')then
      write(1,190)
      write(1,200)            ! source 1 = con3
      write(1,205)dir(loop)   ! WRITE source <file>.c3.src ascii
      write(1,210)            ! source 1 = con3*umdr
      write(1,215)dir(loop)   ! WRITE source <file>.c3dr.src ascii
      write(1,220)            ! source 1 = 1e-14*(con3*umdr)
      write(1,225)dir(loop)   ! WRITE source <file>.14c3dr.src ascii
      write(1,230)            ! source 1 = con4
      write(1,235)dir(loop)   ! WRITE source <file>.c4.src ascii
      write(1,240)            ! source 1 = con4*umdr
      write(1,245)dir(loop)   ! WRITE source <file>.c4dr.src ascii
      write(1,250)            ! source 1 = 1e-14*(con4*umdr)
      write(1,255)dir(loop)   ! WRITE source <file>.14c4dr.src ascii
      endif

 190  format('con4.3=>con3.3')
 200  format('source 1 = con3')
 205  format('WRITE source \'',a11,'.c3.src\' ascii')
 210  format('source 1 = con3*umdr')
 215  format('WRITE source \'',a11,'.c3dr.src\' ascii')
 220  format('source 1 = 1e-14*(con3*umdr)')
 225  format('WRITE source \'',a11,'.14c3dr.src\' ascii')
 230  format('source 1 = con4')
 235  format('WRITE source \'',a11,'.c4.src\' ascii')
 240  format('source 1 = con4*umdr')
 245  format('WRITE source \'',a11,'.c4dr.src\' ascii')
 250  format('source 1 = 1e-14*(con4*umdr)')
 255  format('WRITE source \'',a11,'.14c4dr.src\' ascii')

c POLYNOMIAL ------- LBQS and MDM ONLY ---------------------------------
      if(pol2yn.eq.'y')then
c      if(zred.le.2.42 .and. sample.eq.'lbqs' .and. loop.le.1060)then
      write(1,305)            ! source 1 = pol2
      write(1,310)dir(loop)   ! WRITE source <file>.p2.src ascii
      write(1,315)            ! source 1 = 1e-14*pol2
      write(1,320)dir(loop)   ! WRITE source <file>.14p2.src ascii
      endif

 305  format('source 1 = pol2')
 310  format('WRITE source \'',a11,'.p2.src\' ascii')
 315  format('source 1 = 1e-14*pol2')
 320  format('WRITE source \'',a11,'.14p2.src\' ascii')

      if(feyn.eq.'y' .and. usefe2.eq.'y')write(1,330)  ! source 1 = umfe
      if(feyn.eq.'y' .and. usefe2.eq.'y')write(1,335)dir(loop) 
c                                           !WRITE source '<file>.fe.src' ascii
      if(feoyn.eq.'y' .and. usefe2.eq.'y')write(1,340) ! source 1 = umfeo
      if(feoyn.eq.'y' .and. usefe2.eq.'y')write(1,345)dir(loop)
c                                           ! WRITE source '<file>.feo.src'
 
 330  format('source 1 = umfe')
 335  format('WRITE source \'',a11,'.fe.src\' ascii')
 340  format('source 1 = umfeo')
 345  format('WRITE source \'',a11,'.feo.src\' ascii')

      write(1,2100)    ! #

c SET UP SOURCE FUNCTION FOR PRINT totsrc AND res --------
      if(pol2yn.eq.'y')then
c      if(sample.eq.'lbqs' .and. loop.le.1060)then
      if(pow2.ne.'y' .and. zred.le.2.42)write(1,350)  ! LBQS
      if(pow2.ne.'y' .and. zred.gt.2.42)write(1,355)  ! LBQS
      else
      if(pow2.ne.'y')write(1,355)
      endif
 350  format('source 1 = 1e-14*((umdr*con1*hpass)+(pol2*lpass))')
 355  format('source 1 = 1e-14*(umdr*con1)')

      if(pow2.eq.'y')then
      write(1,360)
      if(usesave.ne.'y')write(1,370)refn
      if(usesave.ne.'y')write(1,375)refn
      if(pol2yn.eq.'y')write(1,380)  ! LBQS MDM
c      if(zred.le.2.42 .and. sample.eq.'lbqs' .and. 
c     $loop.le.1060)write(1,380)  ! LBQS
      if(zred.gt.2.42 .and. sample.eq.'lbqs' .and. 
     $loop.le.1060)write(1,382)  ! LBQS
      if(sample.eq.'fos_' .or. loop.gt.1060)write(1,385)
      endif

 360  format('con4.3=>con3.3')
 370  format('highpass[hp1](',f8.2,':0.0:10000.0,1.0)')
 375  format('lowpass[lp1](',f8.2,':0.0:10000.0,1.0)')
 380  format('source 1 = 1e-14*((umdr*con3*lp1*hpass)+(pol2*lpass)+',
     $'(con4*umdr*hp1))')
 382  format('source 1 = 1e-14*((umdr*con3*lp1*hpass)+',
     $'(con4*umdr*hp1))')
 385  format('source 1 = 1e-14*((umdr*con3*lp1)+',
     $'(con4*umdr*hp1))')

      if(sample.eq.'fos_')write(1,400)dir(loop) ! write source ..././CONSAVE/
      if(sample.eq.'fos_')write(1,405)dir(loop) ! write residuals .../CONSAVE/
      if(sample.eq.'lbqs')write(1,410)dir(loop) ! write source ..././CONSAVE/
      if(sample.eq.'lbqs')write(1,415)dir(loop) ! write residuals .../CONSAVE/
      if(sample.eq.'mdm_')write(1,420)dir(loop) ! write source ..././CONSAVE/
      if(sample.eq.'mdm_')write(1,425)dir(loop) ! write residuals .../CONSAVE/

 400  format('WRITE source \'/data/kf1/fos_data/CONSAVE/',a11,
     $'.tcon.src\' ascii')
 405  format('WRITE residuals \'/data/kf1/fos_data/CONSAVE/',
     $a11,'.tcon.res\' ascii')
 410  format('WRITE source \'/data/kf1/lbqsdata/CONSAVE/',a11,
     $'.tcon.src\' ascii')
 415  format('WRITE residuals \'/data/kf1/lbqsdata/CONSAVE/',
     $a11,'.tcon.res\' ascii')
 420  format('WRITE source \'/data/kf3/mdm_data/CONSAVE/',a11,
     $'.tcon.src\' ascii')
 425  format('WRITE residuals \'/data/kf3/mdm_data/CONSAVE/',
     $a11,'.tcon.res\' ascii')

      write(1,2100)    ! #

c PRINT POSTSCRIPT FILE

c cut out geocoronal Lyman alpha (FOS only)
      if(sample.eq.'fos_')then
      if(wave1.lt.1300 .and. zred.ge.0.1)write(1,440) ! ignore filter 0.0:1300
      endif

      write(1,441)                      ! lplot 2 fit residuals
      write(1,458)wave1,wave2           ! d 1 limits x wave1 wave2
      write(1,459)wave1,wave2           ! d 2 limits x wave1 wave2
      write(1,457)                      ! split gap 0.01
      write(1,442)                      ! d 1 c 2 width 4.0
      write(1,443)                      ! d 1 c 1 dot
      write(1,444)                      ! d 1 TICKVALS x off
      write(1,456)                      ! d 1 TICKVALS size y 1.5
      write(1,445)                      ! d 1 axes width 3.0
      write(1,446)                      ! d 2 TICKVALS 1.5
      write(1,447)                      ! d 2 axes width 3.0
      write(1,448)                      ! title size 2.0
      write(1,449)                      ! d 1 ylabel " "
      write(1,450)                      ! d 2 ylabel " "
      write(1,451)                      ! d 1 xlabel " "
      write(1,452)                      ! d 2 xlabel "Wavelength"
      write(1,453)                      ! d 2 xlabel size 1.5
      write(1,454)                      ! d 2 xlabel green
      write(1,455)loop,dir(loop),zred   ! title "(1) 0000+0000la (z=0.000)"
      write(1,460)sample,dir(loop)      ! print postfile ...

c FOR QUIT HERE
c      write(1,450)  ! quit

 440  format('ignore filter 0.0:1300.0')
 441  format('lplot 2 fit residuals')
 442  format('d 1 c 2 width 4.0')
 443  format('d 1 c 1 dot')
 444  format('d 1 TICKVALS x off')
 456  format('d 1 TICKVALS size y 1.5')
 445  format('d 1 axes width 3.0')
 446  format('d 2 TICKVALS size 1.5')
 447  format('d 2 axes width 3.0')
 448  format('title size 2.0')
 449  format('d 1 ylabel \" \"')
 450  format('d 2 ylabel \" \"')
 451  format('d 1 xlabel \" \"')
 452  format('d 2 xlabel \"Wavelength\"')
 453  format('d 2 xlabel size 1.5')
 454  format('d 2 xlabel green')
 455  format('title "(',i4,')    ',a11,'     (z = ',f5.3,')"')
 457  format('split gap 0.01')

 458  format('d 1 limits x ',f7.1,2x,f7.1)
 459  format('d 2 limits x ',f7.1,2x,f7.1)

 460  format('print postfile \'/data/kf1/',a4,'data/CONSAVE/',
     $a11,'_pl.ps\'')
 465  format('quit')

 468  write(1,2100)             ! #


c PRINT out total template including Fe II
 470  continue
      
      if(feyn.ne.'y' .and. feoyn.ne.'y')goto 700
      if(pow2.eq.'y')write(1,360)                     ! con4.3 => con3.3

      if(wave1.lt.1300 .and. zred.ge.0.1)write(1,500)
      if(sample.eq.'fos_')then
      if(feyn.eq.'y' .and. feoyn.eq.'y')then
         if(pow2.eq.'y')write(1,510)
         if(pow2.ne.'y')write(1,515)
      endif
      if(feyn.eq.'y' .and. feoyn.ne.'y')then
         if(pow2.eq.'y')write(1,520)
         if(pow2.ne.'y')write(1,525)
      endif
      if(feyn.ne.'y' .and. feoyn.eq.'y')then
         if(pow2.eq.'y')write(1,530)
         if(pow2.ne.'y')write(1,535)
      endif
      endif


      if(sample.ne.'fos_')then
      if(feyn.eq.'y' .and. feoyn.eq.'y')then
         if(pol2yn.ne.'y' .and. pow2.eq.'y')write(1,510)
         if(pol2yn.ne.'y' .and. pow2.ne.'y')write(1,515)
         if(pol2yn.eq.'y' .and. pow2.eq.'y')write(1,511)
         if(pol2yn.eq.'y' .and. pow2.ne.'y')write(1,516)
      endif
      if(feyn.eq.'y' .and. feoyn.ne.'y')then
         if(pol2yn.ne.'y' .and. pow2.eq.'y')write(1,520)
         if(pol2yn.ne.'y' .and. pow2.ne.'y')write(1,525)
         if(pol2yn.eq.'y' .and. pow2.eq.'y')write(1,521)
         if(pol2yn.eq.'y' .and. pow2.ne.'y')write(1,526)
      endif
      if(feyn.ne.'y' .and. feoyn.eq.'y')then
         if(pol2yn.ne.'y' .and. pow2.eq.'y')write(1,530)
         if(pol2yn.ne.'y' .and. pow2.ne.'y')write(1,535)
         if(pol2yn.eq.'y' .and. pow2.eq.'y')write(1,531)
         if(pol2yn.eq.'y' .and. pow2.ne.'y')write(1,536)
      endif
      endif

      write(1,480)sample,dir(loop) ! write source ...CONSAVE/
      write(1,485)sample,dir(loop) ! write residuals .../CONSAVE/

 480  format('WRITE source \'/data/kf1/',a4,'data/CONSAVE/',a11,
     $'.fecon.src\' ascii')
 485  format('WRITE residuals \'/data/kf1/',a4,'data/CONSAVE/',
     $a11,'.fecon.res\' ascii')


 500  format('ignore filter 0.0:1300.0')

 510  format('source 1 = 1e-14*(((umdr*(con3+umfe))*lp1)+',
     $'((umdr*(con4+umfeo))*hp1))')
 511  format('source 1 = 1e-14*(((umdr*(con3+umfe))*lp1*hpass)+',
     $'((pol2+umfe)*lpass)+((umdr*(con4+umfeo))*hp1))')

 515  format('source 1 = 1e-14*(umdr*(con1+umfe+umfeo))')
 516  format('source 1 = 1e-14*((umdr*hpass*(con1+umfe+umfeo))+',
     $'((pol2+umfe+umfeo)*lpass))')

 520  format('source 1 = 1e-14*(((umdr*(con3+umfe))*lp1)+',
     $'((umdr*con4)*hp1))')
 521  format('source 1 = 1e-14*(((umdr*(con3+umfe))*lp1*hpass)+',
     $'((pol2+umfe)*lpass)+((umdr*con4)*hp1))')

 525  format('source 1 = 1e-14*(umdr*(con1+umfe))')
 526  format('source 1 = 1e-14*((umdr*hpass*(con1+umfe))+',
     $'((pol2+umfe)*lpass))')

 530  format('source 1 = 1e-14*(((con3*umdr)*lp1)+',
     $'((umdr*(con4+umfeo))*hp1))')
 531  format('source 1 = 1e-14*(((con3*umdr)*lp1*hpass)+',
     $'((pol2+umfeo)*lpass)+((umdr*(con4+umfeo))*hp1))')

 535  format('source 1 = 1e-14*(umdr*(con1+umfeo))')
 536  format('source 1 = 1e-14*((umdr*hpass*(con1+umfeo))+',
     $'((pol2+umfeo)*lpass))')

      if(sample.ne.'mdm_')write(1,539)sample,dir(loop)
      if(sample.eq.'mdm_')write(1,540)sample,dir(loop)
      if(feyn.eq.'y' .and. feoyn.ne.'y')write(1,541)
      if(feyn.ne.'y' .and. feoyn.eq.'y')write(1,542)
      if(feyn.eq.'y' .and. feoyn.eq.'y')write(1,543)

 539  format('data 2 \"/data/kf1/',a4,'data/DATA/',a11,
     $'.dat\" ascii 1 2')
 540  format('data 2 \"/data/kf3/',a4,'data/DATA/',a11,
     $'.dat\" ascii 1 2')
 541  format('source 2 = umfe')
 542  format('source 2 = umfeo')
 543  format('source 2 = umfe+umfeo')

 545  format('lplot 2 fit 1 source 2')


      write(1,545)                      ! lplot 2 fit 1 source 2
      write(1,458)wave1,wave2           ! d 1 limits x wave1 wave2
      write(1,459)wave1,wave2           ! d 2 limits x wave1 wave2
      write(1,457)                      ! split gap 0.01
      write(1,442)                      ! d 1 c 2 width 4.0
      write(1,443)                      ! d 1 c 1 dot
      write(1,444)                      ! d 1 TICKVALS x off
      write(1,456)                      ! d 1 TICKVALS size y 1.5
      write(1,445)                      ! d 1 axes width 3.0
      write(1,446)                      ! d 2 TICKVALS 1.5
      write(1,447)                      ! d 2 axes width 3.0
      write(1,448)                      ! title size 2.0
      write(1,449)                      ! d 1 ylabel " "
      write(1,450)                      ! d 2 ylabel " "
      write(1,451)                      ! d 1 xlabel " "
      write(1,452)                      ! d 2 xlabel "Wavelength"
      write(1,453)                      ! d 2 xlabel size 1.5
      write(1,454)                      ! d 2 xlabel green
      write(1,550)loop,dir(loop),zred  ! title "(1) 0000+0000la (0.200) (C+Fe)"
      write(1,560)sample,dir(loop)

 550  format('title "(',i4,')    ',a11,'     (z = ',f5.3,') (C+Fe)"')
c 550  format('title "(',i4,')    ',a11,'     (Cont. + Fe)"')
 560  format('print postfile \'/data/kf1/',a4,'data/CONSAVE/',
     $a11,'_cont_fe.ps\'')

 700  write(1,2100)             ! #

c SAVE PARAMETERS
      if(usesave.eq.'y' .and. usefe2.eq.'y')goto 3000

c SAVE initial continuum fit parameters
      if(usesave.eq.'n')then
         write(1,800)sample,dir(loop) ! save all '...<>/
      endif
 800  format('save all \'/data/kf1/',a4,'data/ASCSAVE/',a11,'.SAVE\'')

c SAVE initial continuum fit parameters
      if(usesave.eq.'y' .and. usefe2.eq.'n')then
         write(1,810)sample,dir(loop) ! save all '/ASCSAVE/.
      endif
 810  format('save all \'/data/kf1/',a4,'data/ASCSAVE/',a11,'.FESAVE\'')


 2100 format('# ')

 3000 return
      end

c ######################################################################
