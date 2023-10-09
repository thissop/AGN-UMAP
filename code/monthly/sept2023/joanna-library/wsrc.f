c ##################################################
      subroutine wsrc(loop)

      integer loop

      write(1,100)           ! # 
      write(1,200)           ! # WRITE SOURCE FUNCTIONS TO .src files
      write(1,100)           ! # 
      write(1,300)           ! notice all

 100  format('# ')
 200  format('# WRITE SOURCE FUNCTIONS TO .src files')
 300  format('notice all')

      return
      end

c ##################################################
