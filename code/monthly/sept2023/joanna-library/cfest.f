c ######################################################################

      subroutine cfest(i,j,lc,cf,cflux,cfw1,cfw2,cfl1)

c Estimates continuum flux under line from the continuum windows

      real cflux(14),cf(14),lc,dx1,dx,dy,cfl1,cfw1(14),cfw2(14)
      integer i,j

c Estimate continuum under line
      if(cf(i).ne.0 .and. cf(j).ne.0) then
c dlambda
         dx1=((cfw2(i)-cfw1(i))/2.0)+cfw1(i)
         dx=((cfw2(j)-cfw1(j))/2.0)+cfw1(j)-dx1
c dflux
         dy=cflux(j)-cflux(i)
c flux under line
         cfl1=(lc-dx1)*dy/dx
         cfl1=cflux(i)+cfl1
      endif
      if(cf(i).ne.0 .and. cf(j).eq.0) cfl1=cflux(i)
      if(cf(i).eq.0 .and. cf(j).ne.0) cfl1=cflux(j)

      return
      end

c ##################################################
