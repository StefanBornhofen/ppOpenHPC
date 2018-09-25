c     === OAT_ATset
c     ============================================================
      subroutine OAT_ATset(OAT_TYPE, OAT_Routines)
      integer   OAT_TYPE
      character*14 OAT_Routines

      include 'OAT.h'


c     ==== All routines
      if (OAT_TYPE .eq. 0) then
        OAT_Routines(1:14) = 'k_AT,j_AT,i_AT'
        iusw1_k_AT_flag = 0
        iusw1_j_AT_flag = 0
        iusw1_i_AT_flag = 0
      endif

c     ==== Install Optimization
      if (OAT_TYPE .eq. 1) then
         OAT_Routines(1:0) = ''
        iusw1_k_AT_flag = 0
        iusw1_j_AT_flag = 0
        iusw1_i_AT_flag = 0
      endif

c     ==== Before Execution-invocation Optimization Routines
      if (OAT_TYPE .eq. 2) then
        OAT_Routines(1:14) = 'k_AT,j_AT,i_AT'
      endif

c     ==== Run-time Optimization Routines
      if (OAT_TYPE .eq. 3) then
        OAT_DYNAMICTUNE = .false.
        OAT_Routines(1:0) = ''
      endif

      return
      end
c     ============================================================


c     === OAT_SetParm
c     ============================================================
      subroutine OAT_SetParm(OAT_TYPE, OAT_Routine, n_bpset, isw)
      integer OAT_TYPE
      character*14 OAT_Routine
      integer n_bpset , isw

      include 'OAT.h'


      integer ibsw

      character*100 cbuf
      character*20 digit
      integer oat_i,oat_j,oat_inum


c     ==== Install Optimization
      if (OAT_TYPE .eq. 1) then
      endif
c     === end of OAT_Install
c     -----------------------------------------------

c     ==== Before Execution-invocation Optimization
      if (OAT_TYPE .eq. 2) then


        if (index(OAT_Routine,'k_AT') .ne. 0) then

		if (iusw1_k_AT_flag .eq. 0) then

		  iusw1_k_AT_flag = 1

          isw = -1
          ibsw = 1
c         ---- file create
c         -----------------------------------------
          if (myid .eq. 0) then
            open(21, status = 'old',
     &         file = 'OAT_Statick_ATParam.dat',
     &         action = 'read', pad= 'yes', err =102)

c           --- Seek object file
            read(21, *) cbuf
            do while (index(cbuf,'k_AT') .eq. 0)
              read(21, *) cbuf
            enddo

            do
c             --- Find problemsize
              read(UNIT=21, FMT='(A,A)', END=100) cbuf
              do while (index(cbuf,'OAT_PROBSIZE') .eq. 0)
                read(UNIT=21, FMT='(A,A)', END=100) cbuf
              enddo
c             -------------------------------------------


c             ---- find space
              oat_i = index(cbuf,'OAT_PROBSIZE')+len('OAT_PROBSIZE')
              do while(cbuf(oat_i:oat_i) .eq. ' ')
                oat_i = oat_i + 1
              enddo
c             ---------------------------------

c             ---- store digit and change it to integer
              oat_j = 1
              do while(cbuf(oat_i:oat_i) .ne. ' ')
                digit(oat_j:oat_j) = cbuf(oat_i:oat_i)
                oat_i = oat_i + 1
                oat_j = oat_j + 1
              enddo
c             ---------------------------------
              digit(oat_j:oat_j) = ' '
              call OATCharToNum(digit, oat_inum)
c             -----------------------------------------

c             --- Find parameter
              read(UNIT=21, FMT='(A,A)', END=100) cbuf
              do while (index(cbuf, 'k_AT_I') .eq. 0)
                 read(UNIT=21, FMT='(A,A)', END=100) cbuf
              enddo
c             -------------------------------------------


c             ---- find space
              oat_i = index(cbuf, 'k_AT_I')+6
              do while(cbuf(oat_i:oat_i) .eq. ' ')
                oat_i = oat_i + 1
              enddo
c             ---------------------------------

c             ---- store digit and change it to integer
              oat_j = 1
              do while(cbuf(oat_i:oat_i) .ne. ' ')
                digit(oat_j:oat_j) = cbuf(oat_i:oat_i)
                oat_i = oat_i + 1
                oat_j = oat_j + 1
              enddo
c             ---------------------------------
              digit(oat_j:oat_j) = ' '
              call OATCharToNum(digit, ibsw)

c             --- inputed n_bpset is less than filed num?
              if (n_bpset .le. oat_inum) then
                isw = ibsw
                goto 100
              endif
            enddo
c           === end of seeking loop for n
 100        continue

c           --- File close
            close(21, status = 'keep')

c           --- This is last parameter
 102        if (isw .eq. -1) then
              isw = ibsw
            endif

          endif
c         === end of myid == 1

c         === braodcast best param

        endif
        return
        endif
c       === end of k_AT


        if (index(OAT_Routine,'j_AT') .ne. 0) then

		if (iusw1_j_AT_flag .eq. 0) then

		  iusw1_j_AT_flag = 1

          isw = -1
          ibsw = 1
c         ---- file create
c         -----------------------------------------
          if (myid .eq. 0) then
            open(21, status = 'old',
     &         file = 'OAT_Staticj_ATParam.dat',
     &         action = 'read', pad= 'yes', err =112)

c           --- Seek object file
            read(21, *) cbuf
            do while (index(cbuf,'j_AT') .eq. 0)
              read(21, *) cbuf
            enddo

            do
c             --- Find problemsize
              read(UNIT=21, FMT='(A,A)', END=110) cbuf
              do while (index(cbuf,'OAT_PROBSIZE') .eq. 0)
                read(UNIT=21, FMT='(A,A)', END=110) cbuf
              enddo
c             -------------------------------------------


c             ---- find space
              oat_i = index(cbuf,'OAT_PROBSIZE')+len('OAT_PROBSIZE')
              do while(cbuf(oat_i:oat_i) .eq. ' ')
                oat_i = oat_i + 1
              enddo
c             ---------------------------------

c             ---- store digit and change it to integer
              oat_j = 1
              do while(cbuf(oat_i:oat_i) .ne. ' ')
                digit(oat_j:oat_j) = cbuf(oat_i:oat_i)
                oat_i = oat_i + 1
                oat_j = oat_j + 1
              enddo
c             ---------------------------------
              digit(oat_j:oat_j) = ' '
              call OATCharToNum(digit, oat_inum)
c             -----------------------------------------

c             --- Find parameter
              read(UNIT=21, FMT='(A,A)', END=110) cbuf
              do while (index(cbuf, 'j_AT_I') .eq. 0)
                 read(UNIT=21, FMT='(A,A)', END=110) cbuf
              enddo
c             -------------------------------------------


c             ---- find space
              oat_i = index(cbuf, 'j_AT_I')+6
              do while(cbuf(oat_i:oat_i) .eq. ' ')
                oat_i = oat_i + 1
              enddo
c             ---------------------------------

c             ---- store digit and change it to integer
              oat_j = 1
              do while(cbuf(oat_i:oat_i) .ne. ' ')
                digit(oat_j:oat_j) = cbuf(oat_i:oat_i)
                oat_i = oat_i + 1
                oat_j = oat_j + 1
              enddo
c             ---------------------------------
              digit(oat_j:oat_j) = ' '
              call OATCharToNum(digit, ibsw)

c             --- inputed n_bpset is less than filed num?
              if (n_bpset .le. oat_inum) then
                isw = ibsw
                goto 110
              endif
            enddo
c           === end of seeking loop for n
 110        continue

c           --- File close
            close(21, status = 'keep')

c           --- This is last parameter
 112        if (isw .eq. -1) then
              isw = ibsw
            endif

          endif
c         === end of myid == 1

c         === braodcast best param

        endif
        return
        endif
c       === end of j_AT


        if (index(OAT_Routine,'i_AT') .ne. 0) then

		if (iusw1_i_AT_flag .eq. 0) then

		  iusw1_i_AT_flag = 1

          isw = -1
          ibsw = 1
c         ---- file create
c         -----------------------------------------
          if (myid .eq. 0) then
            open(21, status = 'old',
     &         file = 'OAT_Statici_ATParam.dat',
     &         action = 'read', pad= 'yes', err =122)

c           --- Seek object file
            read(21, *) cbuf
            do while (index(cbuf,'i_AT') .eq. 0)
              read(21, *) cbuf
            enddo

            do
c             --- Find problemsize
              read(UNIT=21, FMT='(A,A)', END=120) cbuf
              do while (index(cbuf,'OAT_PROBSIZE') .eq. 0)
                read(UNIT=21, FMT='(A,A)', END=120) cbuf
              enddo
c             -------------------------------------------


c             ---- find space
              oat_i = index(cbuf,'OAT_PROBSIZE')+len('OAT_PROBSIZE')
              do while(cbuf(oat_i:oat_i) .eq. ' ')
                oat_i = oat_i + 1
              enddo
c             ---------------------------------

c             ---- store digit and change it to integer
              oat_j = 1
              do while(cbuf(oat_i:oat_i) .ne. ' ')
                digit(oat_j:oat_j) = cbuf(oat_i:oat_i)
                oat_i = oat_i + 1
                oat_j = oat_j + 1
              enddo
c             ---------------------------------
              digit(oat_j:oat_j) = ' '
              call OATCharToNum(digit, oat_inum)
c             -----------------------------------------

c             --- Find parameter
              read(UNIT=21, FMT='(A,A)', END=120) cbuf
              do while (index(cbuf, 'i_AT_I') .eq. 0)
                 read(UNIT=21, FMT='(A,A)', END=120) cbuf
              enddo
c             -------------------------------------------


c             ---- find space
              oat_i = index(cbuf, 'i_AT_I')+6
              do while(cbuf(oat_i:oat_i) .eq. ' ')
                oat_i = oat_i + 1
              enddo
c             ---------------------------------

c             ---- store digit and change it to integer
              oat_j = 1
              do while(cbuf(oat_i:oat_i) .ne. ' ')
                digit(oat_j:oat_j) = cbuf(oat_i:oat_i)
                oat_i = oat_i + 1
                oat_j = oat_j + 1
              enddo
c             ---------------------------------
              digit(oat_j:oat_j) = ' '
              call OATCharToNum(digit, ibsw)

c             --- inputed n_bpset is less than filed num?
              if (n_bpset .le. oat_inum) then
                isw = ibsw
                goto 120
              endif
            enddo
c           === end of seeking loop for n
 120        continue

c           --- File close
            close(21, status = 'keep')

c           --- This is last parameter
 122        if (isw .eq. -1) then
              isw = ibsw
            endif

          endif
c         === end of myid == 1

c         === braodcast best param

        endif
        return
        endif
c       === end of i_AT
      endif
c     === end of OAT_Static
c     -----------------------------------------------

c     ==== Run-time Optimization
      if (OAT_TYPE .eq. 3) then
        if (OAT_DYNAMICTUNE) then
        else
          isw = 1
        endif

      endif
c     === end of OAT_Dynamic
c     -----------------------------------------------

      return
      end


      subroutine OATCharToNum(coption, inum)
      character*20 coption
      integer inum

      integer j
      integer idec
      character ctemp

      inum = 0
      j = 1
      do while(coption(j:j) .ne. ' ')
         ctemp = coption(j:j)
         if (ctemp .eq. ' ') goto 100
         if (ctemp .eq. '0') idec = 0
         if (ctemp .eq. '1') idec = 1
         if (ctemp .eq. '2') idec = 2
         if (ctemp .eq. '3') idec = 3
         if (ctemp .eq. '4') idec = 4
         if (ctemp .eq. '5') idec = 5
         if (ctemp .eq. '6') idec = 6
         if (ctemp .eq. '7') idec = 7
         if (ctemp .eq. '8') idec = 8
         if (ctemp .eq. '9') idec = 9
         inum = inum*10 + idec
         j = j + 1
       enddo
 100   continue

      return
      end

c     ============================================================


c     === OAT_ATexec
c     ============================================================
      subroutine OAT_ATexec(OAT_TYPE, OAT_Routines,N,A,C,B)
      integer   OAT_TYPE
      character*14 OAT_Routines
      integer N
      real*8 A(N,N)
      real*8 C(N,N)
      real*8 B(N,N)

      include 'OAT.h'

      character*8 OAT_EXEC_Env
      integer cp

      call getenv("OAT_EXEC",OAT_EXEC_Env)
      if(TRIM(OAT_EXEC_Env) .ne. "")then
        if(TRIM(OAT_EXEC_Env) .ne. "1")then
          return
        endif
      else
        call getenv("OAT_ATEXEC",OAT_EXEC_Env)
        if(TRIM(OAT_EXEC_Env) .ne. "")then
          if(TRIM(OAT_EXEC_Env) .ne. "1")then
            return
          endif
        endif
      endif

c     ==== Install Optimization
      if (OAT_TYPE .eq. 1) then
      endif

c     ==== Before Execution-invocation Optimization
      if (OAT_TYPE .eq. 2) then
        cp = index(OAT_Routines,'k_AT')
        if (cp .ne. 0) then
          cp = cp + len('k_AT')
          if (OAT_Routines(cp:cp) .eq. ',') then
            cp = 99999
          endif
          if (cp .ge. len(OAT_Routines)) then
            call OAT_ATexecStatick_AT(OAT_Routines,N,A,C,B)
          endif
        endif
        cp = index(OAT_Routines,'j_AT')
        if (cp .ne. 0) then
          cp = cp + len('j_AT')
          if (OAT_Routines(cp:cp) .eq. ',') then
            cp = 99999
          endif
          if (cp .ge. len(OAT_Routines)) then
            call OAT_ATexecStaticj_AT(OAT_Routines,N,A,C,B)
          endif
        endif
        cp = index(OAT_Routines,'i_AT')
        if (cp .ne. 0) then
          cp = cp + len('i_AT')
          if (OAT_Routines(cp:cp) .eq. ',') then
            cp = 99999
          endif
          if (cp .ge. len(OAT_Routines)) then
            call OAT_ATexecStatici_AT(OAT_Routines,N,A,C,B)
          endif
        endif
      endif

c     ==== Run-time Optimization
      if (OAT_TYPE .eq. 3) then
      endif


      return
      end
c     ============================================================

c     ==== Static Optimization Routines
c     ==============================================================
      subroutine OAT_ATexecStatick_AT(OAT_Routines,N,A,C,B)
      character*14 OAT_Routines
      integer N
      real*8 A(N,N)
      real*8 C(N,N)
      real*8 B(N,N)

      include 'OAT.h'


      integer iusw1
      integer F1(2)
      integer iloop_static,iloop_iter,iloop_n

      integer iBestSw1


      real*8  t1, t2, t_all, bt
      real*8  dBestTime1
!      real*8  OAT_Wtime

      integer ierr



c     ---- file create
c     -----------------------------------------
      if (myid .eq. 0) then
        open(11, status = 'replace',
     &     file = 'OAT_Statick_ATParam.dat',
     &     action = 'write', pad= 'yes')

        write (11, *) "(k_AT"
        write (11, *) "  (OAT_NUMPROCS ", OAT_NUMPROCS,")"
        write (11, *) "  (OAT_SAMPDIST ", OAT_SAMPDIST,")"
      endif
c     ----------------------------------------
c     ---- Start tune
c     -----------------------------------------
      F1(1)=1
      F1(2)=2
      do iloop_n=OAT_STARTTUNESIZE,
     &           OAT_ENDTUNESIZE,
     &           OAT_SAMPDIST

        do iloop_static=1, 2

          iusw1 = F1(iloop_static)

          t1 = OAT_Wtime()

!          do iloop_iter=1, OAT_MAXSAMPITER

            call OAT_Statick_AT(iloop_n, A, C, B, iusw1)

!          end do

          t2 = OAT_Wtime()
          t_all = t2 - t1
          bt = t_all
          t_all = bt

          if (OAT_DEBUG .ge. 1)then
            if (myid .eq. 0) then
              print *, "N=",iloop_n, "iusw1=", iusw1, t_all
            endif
          endif


          if (iloop_static .eq. 1) then
            dBestTime1 = t_all
            iBestSw1 = F1(1)
          else
            if (t_all .lt. dBestTime1) then
              dBestTime1 = t_all
              iBestSw1 = F1(iloop_static)
            endif
          endif

        enddo

        if (OAT_DEBUG .ge. 1)then
          if (myid .eq. 0) then
             print *, "N=",iloop_n, "BestSw=",iBestSw1
          endif
        endif
c       --- file write
        if (myid .eq. 0) then
          write (11, *) "  (OAT_PROBSIZE ", iloop_n, " "
          write (11, *) "     (k_AT_I ", iBestSw1,")"
          write (11, *) "  )"
        endif
c       -----------------------------------------
      enddo

c     --- file close
      if (myid .eq. 0) then
        write (11, *) ")"
        close(11, status = 'keep')
      endif

c     ---------------------------------------------

      return
      end
c     ==== End of Static Optimization Routines
c     ==============================================================


c     ==== Static Optimization Routines
c     ==============================================================
      subroutine OAT_ATexecStaticj_AT(OAT_Routines,N,A,C,B)
      character*14 OAT_Routines
      integer N
      real*8 A(N,N)
      real*8 C(N,N)
      real*8 B(N,N)

      include 'OAT.h'


      integer iusw1
      integer F1(2)
      integer iloop_static,iloop_iter,iloop_n

      integer iBestSw1


      real*8  t1, t2, t_all, bt
      real*8  dBestTime1
!      real*8  OAT_Wtime

      integer ierr



c     ---- file create
c     -----------------------------------------
      if (myid .eq. 0) then
        open(11, status = 'replace',
     &     file = 'OAT_Staticj_ATParam.dat',
     &     action = 'write', pad= 'yes')

        write (11, *) "(j_AT"
        write (11, *) "  (OAT_NUMPROCS ", OAT_NUMPROCS,")"
        write (11, *) "  (OAT_SAMPDIST ", OAT_SAMPDIST,")"
      endif
c     ----------------------------------------
c     ---- Start tune
c     -----------------------------------------
      F1(1)=1
      F1(2)=2
      do iloop_n=OAT_STARTTUNESIZE,
     &           OAT_ENDTUNESIZE,
     &           OAT_SAMPDIST

        do iloop_static=1, 2

          iusw1 = F1(iloop_static)

          t1 = OAT_Wtime()

!          do iloop_iter=1, OAT_MAXSAMPITER

            call OAT_Staticj_AT(iloop_n, A, C, B, iusw1)

!          end do

          t2 = OAT_Wtime()
          t_all = t2 - t1
          bt = t_all
          t_all = bt

          if (OAT_DEBUG .ge. 1)then
            if (myid .eq. 0) then
              print *, "N=",iloop_n, "iusw1=", iusw1, t_all
            endif
          endif


          if (iloop_static .eq. 1) then
            dBestTime1 = t_all
            iBestSw1 = F1(1)
          else
            if (t_all .lt. dBestTime1) then
              dBestTime1 = t_all
              iBestSw1 = F1(iloop_static)
            endif
          endif

        enddo

        if (OAT_DEBUG .ge. 1)then
          if (myid .eq. 0) then
             print *, "N=",iloop_n, "BestSw=",iBestSw1
          endif
        endif
c       --- file write
        if (myid .eq. 0) then
          write (11, *) "  (OAT_PROBSIZE ", iloop_n, " "
          write (11, *) "     (j_AT_I ", iBestSw1,")"
          write (11, *) "  )"
        endif
c       -----------------------------------------
      enddo

c     --- file close
      if (myid .eq. 0) then
        write (11, *) ")"
        close(11, status = 'keep')
      endif

c     ---------------------------------------------

      return
      end
c     ==== End of Static Optimization Routines
c     ==============================================================


c     ==== Static Optimization Routines
c     ==============================================================
      subroutine OAT_ATexecStatici_AT(OAT_Routines,N,A,C,B)
      character*14 OAT_Routines
      integer N
      real*8 A(N,N)
      real*8 C(N,N)
      real*8 B(N,N)

      include 'OAT.h'


      integer iusw1
      integer F1(2)
      integer iloop_static,iloop_iter,iloop_n

      integer iBestSw1


      real*8  t1, t2, t_all, bt
      real*8  dBestTime1
!      real*8  OAT_Wtime

      integer ierr



c     ---- file create
c     -----------------------------------------
      if (myid .eq. 0) then
        open(11, status = 'replace',
     &     file = 'OAT_Statici_ATParam.dat',
     &     action = 'write', pad= 'yes')

        write (11, *) "(i_AT"
        write (11, *) "  (OAT_NUMPROCS ", OAT_NUMPROCS,")"
        write (11, *) "  (OAT_SAMPDIST ", OAT_SAMPDIST,")"
      endif
c     ----------------------------------------
c     ---- Start tune
c     -----------------------------------------
      F1(1)=1
      F1(2)=2
      do iloop_n=OAT_STARTTUNESIZE,
     &           OAT_ENDTUNESIZE,
     &           OAT_SAMPDIST

        do iloop_static=1, 2

          iusw1 = F1(iloop_static)

          t1 = OAT_Wtime()

!          do iloop_iter=1, OAT_MAXSAMPITER

            call OAT_Statici_AT(iloop_n, A, C, B, iusw1)

!          end do

          t2 = OAT_Wtime()
          t_all = t2 - t1
          bt = t_all
          t_all = bt

          if (OAT_DEBUG .ge. 1)then
            if (myid .eq. 0) then
              print *, "N=",iloop_n, "iusw1=", iusw1, t_all
            endif
          endif


          if (iloop_static .eq. 1) then
            dBestTime1 = t_all
            iBestSw1 = F1(1)
          else
            if (t_all .lt. dBestTime1) then
              dBestTime1 = t_all
              iBestSw1 = F1(iloop_static)
            endif
          endif

        enddo

        if (OAT_DEBUG .ge. 1)then
          if (myid .eq. 0) then
             print *, "N=",iloop_n, "BestSw=",iBestSw1
          endif
        endif
c       --- file write
        if (myid .eq. 0) then
          write (11, *) "  (OAT_PROBSIZE ", iloop_n, " "
          write (11, *) "     (i_AT_I ", iBestSw1,")"
          write (11, *) "  )"
        endif
c       -----------------------------------------
      enddo

c     --- file close
      if (myid .eq. 0) then
        write (11, *) ")"
        close(11, status = 'keep')
      endif

c     ---------------------------------------------

      return
      end
c     ==== End of Static Optimization Routines
c     ==============================================================


      function OAT_Wtime()
      real*8 OAT_Wtime
      real*8 omp_get_wtime

      OAT_Wtime = omp_get_wtime()

      end
