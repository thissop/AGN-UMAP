c#################################################

      subroutine getcomp(name,pow2,feyn,feoyn,labyn,laiyn,lanyn,lasyn,
     $n5yn,o1yn,sio4yn,c4byn,c4iyn,c4nyn,c4bayn,he2yn,al3yn,c3byn,
     $c3nyn,si3yn,mg2byn,mg2nyn,ne5yn,o2yn,ne3yn,hdyn,hgyn,o3ayn,he2oyn,
     $hbbyn,hbiyn,hbnyn,o3byn,o3cyn,he1yn,n2ayn,habyn,haiyn,hanyn,n2byn,
     $s2ayn,s2byn,sample,loop,polcut,concut,stage)

      real polcut,concut


      character*11 name
      character*15 pre
      character*14 gap14
      character*60 a3
      character*1 equal,pow2
      character*4 sample,stage

      character*1 feyn,feoyn,pow2,labyn,laiyn,lanyn,n5yn,o1yn
      character*1 sio4yn,c4byn,c4iyn,c4nyn,c4bayn,he2yn,al3yn
      character*1 c3byn,c3nyn,si3yn,mg2byn,mg2nyn,ne5yn,o2yn
      character*1 ne3yn,hdyn,hgyn,o3ayn,he2oyn,hbbyn,hbiyn,hbnyn
      character*1 o3byn,o3cyn,he1yn,n2ayn,habyn,haiyn,hanyn,n2byn
      character*1 s2ayn,s2byn,lasyn

c RESET
      feyn='n'
      feoyn='n'
      pow2='n'
      labyn='n'
      laiyn='n'
      lanyn='n'
      lasyn='n'
      n5yn='n'
      o1yn='n'
      sio4yn='n'
      c4byn='n'
      c4iyn='n'
      c4nyn='n'
c      c4bayn='n'
      he2yn='n'
      al3yn='n'
      c3byn='n'
      c3nyn='n'
      si3yn='n'
      mg2byn='n'
      mg2nyn='n'
      ne5yn='n'
      o2yn='n'
      ne3yn='n'
      hdyn='n'
      hgyn='n'
      o3ayn='n'
      he2oyn='n'
      hbbyn='n'
      hbiyn='n'
      hbnyn='n'
      o3byn='n'
      o3cyn='n'
      he1yn='n'
      n2ayn='n'
      habyn='n'
      haiyn='n'
      hanyn='n'
      n2byn='n'
      s2ayn='n'
      s2byn='n'

c READ the model parameters
      a3(1:10)='/data/kf1/'
      a3(11:14)=sample
      a3(15:19)='data/'
      a3(20:30)=name
      a3(31:38)='/ASCFIT/'
      a3(39:49)=name
      if(stage.eq.'one ')a3(50:52)="_S1"
      if(stage.eq.'two ')a3(50:52)="_S2"
      a3(53:57)='.save'

      write(*,*)loop,' ',a3(1:58)
      open(unit=1,status='old',file=a3(1:57))

 100  read(1,*,err=1000)pre

c CONTINUUM 3
      if(pre(1:12).eq.'hp1.xcut.max') then
         write(*,*)'hp1'
      read(1,*)gap14,equal,concut
      pow2='y'
      endif


c FOR LBQS - WAVELENGTH OF CHANGE TO POLYNOMIAL (NEAR 4000A)
c lpass.xcut.value

      if(pre(1:14).eq.'lpass.xcut.max')then
         write(*,*)'polcut'
      read(1,*)gap14,equal,polcut
      endif

c UV Fe II
      if(pre(1:15).eq.'userModel[umfe]') then
         write(*,*)'umfe'
      feyn='y'
      endif

c Opt Fe II
      if(pre(1:15).eq.'userModel[umfeo') then
         write(*,*)'umfeo'
      feoyn='y'
      endif

c Ly Alpha broad
      if(pre(1:11).eq.'gauss1d[lab') then
         write(*,*)'lab'
      labyn='y'
      endif

c Ly Alpha intermediate
      if(pre(1:11).eq.'gauss1d[lai') then
         write(*,*)'lai'
      laiyn='y'
      endif

c Ly Alpha narrow
      if(pre(1:11).eq.'gauss1d[lan') then
         write(*,*)'lan'
      lanyn='y'
      endif

c N V
      if(pre(1:11).eq.'gauss1d[n5]') then
         write(*,*)'n5'
      n5yn='y'
      endif

c O I
      if(pre(1:11).eq.'gauss1d[o1]') then
         write(*,*)'o1'
      o1yn='y'
      endif

c Si IV / O IV
      if(pre(1:12).eq.'gauss1d[sio4') then
         write(*,*)'sio4'
      sio4yn='y'
      endif

c C IV broad
      if(pre(1:12).eq.'gauss1d[c4b]') then
         write(*,*)'c4b'
      c4byn='y'
      endif

c C IV intermediate
      if(pre(1:11).eq.'gauss1d[c4i') then
         write(*,*)'c4i'
      c4iyn='y'
      endif

c C IV narrow
      if(pre(1:11).eq.'gauss1d[c4n') then
         write(*,*)'c4n'
      c4nyn='y'
      endif

c C IV broad absorption
      if(pre(1:12).eq.'gauss1d[c4ba') then
         write(*,*)'c4ba'
      c4bayn='y'
      endif

c He II
      if(pre(1:12).eq.'gauss1d[he2]') then
         write(*,*)'he2'
      he2yn='y'
      endif

c Al III
      if(pre(1:11).eq.'gauss1d[al3') then
         write(*,*)'al3'
      al3yn='y'
      endif

c C III broad
      if(pre(1:11).eq.'gauss1d[c3b') then
         write(*,*)'c3b'
      c3byn='y'
      endif

c C III narrow
      if(pre(1:11).eq.'gauss1d[c3n') then
         write(*,*)'c3n'
      c3nyn='y'
      endif

c Si III
      if(pre(1:11).eq.'gauss1d[si3') then
         write(*,*)'si3'
      si3yn='y'
      endif

c Mg II broad
      if(pre(1:12).eq.'gauss1d[mg2b') then
         write(*,*)'mg2b'
      mg2byn='y'
      endif

c Mg II narrow
      if(pre(1:12).eq.'gauss1d[mg2n') then
         write(*,*)'mg2n'
      mg2nyn='y'
      endif

c Ne V
      if(pre(1:11).eq.'gauss1d[ne5') then
         write(*,*)'ne5'
      ne5yn='y'
      endif

c O II
      if(pre(1:11).eq.'gauss1d[o2]') then
         write(*,*)'o2'
      o2yn='y'
      endif

c Ne III
      if(pre(1:11).eq.'gauss1d[ne3') then
         write(*,*)'ne3'
      ne3yn='y'
      endif

c H delta
      if(pre(1:11).eq.'gauss1d[hd]') then
         write(*,*)'hd'
      hdyn='y'
      endif

c H gamma
      if(pre(1:11).eq.'gauss1d[hg]') then
         write(*,*)'hg'
      hgyn='y'
      endif

c O III a (4363)
      if(pre(1:11).eq.'gauss1d[o3a') then
         write(*,*)'o3a'
      o3ayn='y'
      endif

c He II (4686)
      if(pre(1:13).eq.'gauss1d[he2o]') then
         write(*,*)'he2o'
      he2oyn='y'
      endif

c H beta broad
      if(pre(1:11).eq.'gauss1d[hbb') then
         write(*,*)'hbb'
      hbbyn='y'
      endif

c H beta intermediate
      if(pre(1:11).eq.'gauss1d[hbi') then
         write(*,*)'hbi'
      hbiyn='y'
      endif

c H beta narrow
      if(pre(1:11).eq.'gauss1d[hbn') then
         write(*,*)'hbn'
      hbnyn='y'
      endif

c O III b (4959)
      if(pre(1:11).eq.'gauss1d[o3b') then
         write(*,*)'o3b'
      o3byn='y'
      endif

c O III c (5007)
      if(pre(1:11).eq.'gauss1d[o3c') then
         write(*,*)'o3c'
      o3cyn='y'
      endif

c He I
      if(pre(1:11).eq.'gauss1d[he1') then
         write(*,*)'he1'
      he1yn='y'
      endif

c N II a (6549)
      if(pre(1:11).eq.'gauss1d[n2a') then
         write(*,*)'n2a'
      n2ayn='y'
      endif

c H alpha broad
      if(pre(1:11).eq.'gauss1d[hab') then
         write(*,*)'hab'
      habyn='y'
      endif

c H alpha intermediate
      if(pre(1:11).eq.'gauss1d[hai') then
         write(*,*)'hai'
      haiyn='y'
      endif

c H alpha narrow
      if(pre(1:11).eq.'gauss1d[han') then
         write(*,*)'han'
      hanyn='y'
      endif

c N II b (6583)
      if(pre(1:11).eq.'gauss1d[n2b') then
         write(*,*)'n2b'
      n2byn='y'
      endif

c S II a (6717)
      if(pre(1:11).eq.'gauss1d[s2a') then
         write(*,*)'s2a'
      s2ayn='y'
      endif

c S II b (6734)
      if(pre(1:11).eq.'gauss1d[s2b') then
         write(*,*)'s2b'
      s2byn='y'
      endif


      if(pre(1:6).ne.'source') goto 100


 1000 close(1)

 1999 return
      end



c#################################################

