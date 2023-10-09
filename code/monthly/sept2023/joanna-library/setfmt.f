c######################################################################

      subroutine setfmt(len,nal1,nal2,fmt)

c sets length of script model lines

      integer len,i,j,k,nal1,nal2
      character*200 fmt

      k=1
      do 200 i=nal1,nal2
         j=len+k
         k=j+5
         if(i.lt.10)fmt(j:k)=',a2,i1'
         if(i.ge.10)fmt(j:k)=',a2,i2'
         k=k-len+1
 200  continue
      j=len+1+((nal2-nal1+1)*6)
      k=j+6
      fmt(j:k)=',3a1) '

      do 300 i=k+1,200
         fmt(i:i)=' '
 300  continue

      return
      end
