!/*=====================================================================*
! *                                                                     *
! *   Software Name : ppohFEM                                           *
! *         Version : 1.0                                               *
! *                                                                     *
! *   License                                                           *
! *     This file is part of ppohFEM.                                   *
! *     ppohFEM is a free software, you can use it under the terms      *
! *     of The MIT License (MIT). See LICENSE file and User's guide     *
! *     for more details.                                               *
! *                                                                     *
! *   ppOpen-HPC project:                                               *
! *     Open Source Infrastructure for Development and Execution of     *
! *     Large-Scale Scientific Applications on Post-Peta-Scale          *
! *     Supercomputers with Automatic Tuning (AT).                      *
! *                                                                     *
! *   Organizations:                                                    *
! *     The University of Tokyo                                         *
! *       - Information Technology Center                               *
! *       - Atmosphere and Ocean Research Institute (AORI)              *
! *       - Interfaculty Initiative in Information Studies              *
! *         /Earthquake Research Institute (ERI)                        *
! *       - Graduate School of Frontier Science                         *
! *     Kyoto University                                                *
! *       - Academic Center for Computing and Media Studies             *
! *     Japan Agency for Marine-Earth Science and Technology (JAMSTEC)  *
! *                                                                     *
! *   Sponsorship:                                                      *
! *     Japan Science and Technology Agency (JST), Basic Research       *
! *     Programs: CREST, Development of System Software Technologies    *
! *     for post-Peta Scale High Performance Computing.                 *
! *                                                                     *
! *   Copyright (c) 2015 The University of Tokyo                        *
! *                       - Graduate School of Frontier Science         *
! *                                                                     *
! *=====================================================================*/


!C
!C***
!C*** module hecmw_solver_BiCGSTAB_33
!C***
!C
      module hecmw_solver_BiCGSTAB_33
      contains
!C
!C*** BiCGSTAB_3
!C
      subroutine hecmw_solve_BiCGSTAB_33( hecMESH,  hecMAT, ITER, RESID, ERROR, &
     &                                    Tset, Tsol, Tcomm )

      use hecmw_util
      use m_hecmw_solve_error
      use m_hecmw_comm_f
      use hecmw_matrix_misc
      use hecmw_solver_misc
      use hecmw_solver_las_33
      use hecmw_solver_scaling_33
      use hecmw_precond_33

      implicit none

      type(hecmwST_local_mesh) :: hecMESH
      type(hecmwST_matrix) :: hecMAT
      integer(kind=kint ), intent(inout):: ITER, ERROR
      real   (kind=kreal), intent(inout):: RESID, Tset, Tsol, Tcomm

      integer(kind=kint ) :: N, NP, NDOF, NNDOF
      integer(kind=kint ) :: my_rank
      integer(kind=kint ) :: ITERlog, TIMElog
      real(kind=kreal), pointer :: B(:), X(:)

      real(kind=kreal), dimension(:,:), allocatable :: WW
      real(kind=kreal), dimension(2) :: CG

      integer(kind=kint ) :: MAXIT

! local variables
      real   (kind=kreal):: TOL
      integer(kind=kint )::i
      real   (kind=kreal)::S_TIME,S1_TIME,E_TIME,E1_TIME, START_TIME, END_TIME
      real   (kind=kreal)::BNRM2,C2
      real   (kind=kreal)::RHO,RHO1,BETA,ALPHA,DNRM2
      real   (kind=kreal)::OMEGA
      real   (kind=kreal)::t_max,t_min,t_avg,t_sd

      integer(kind=kint), parameter :: R = 1
      integer(kind=kint), parameter :: RT= 2
      integer(kind=kint), parameter :: P = 3
      integer(kind=kint), parameter :: PT= 4
      integer(kind=kint), parameter :: S = 5
      integer(kind=kint), parameter :: ST= 1
      integer(kind=kint), parameter :: T = 6
      integer(kind=kint), parameter :: V = 7
      integer(kind=kint), parameter :: WK= 8

      call hecmw_barrier(hecMESH)
      S_time= HECMW_WTIME()

!C===
!C +-------+
!C | INIT. |
!C +-------+
!C===
      N = hecMAT%N
      NP = hecMAT%NP
      NDOF = hecMAT%NDOF
      NNDOF = N * NDOF
      my_rank = hecMESH%my_rank
      X => hecMAT%X
      B => hecMAT%B

      ITERlog = hecmw_mat_get_iterlog( hecMAT )
      TIMElog = hecmw_mat_get_timelog( hecMAT )
      MAXIT  = hecmw_mat_get_iter( hecMAT )
       TOL   = hecmw_mat_get_resid( hecMAT )

      ERROR = 0

      allocate (WW(NDOF*NP, 8))
      WW = 0.d0

!C
!C-- SCALING
      call hecmw_solver_scaling_fw_33(hecMESH, hecMAT, Tcomm)

!C===
!C +----------------------+
!C | SETUP PRECONDITIONER |
!C +----------------------+
!C===
      call hecmw_precond_33_setup(hecMAT, hecMESH, 0)

!C===
!C +---------------------+
!C | {r0}= {b} - [A]{x0} |
!C +---------------------+
!C===
      call hecmw_matresid_33(hecMESH, hecMAT, X, B, WW(:,R), Tcomm)

!C-- set arbitrary {r_tld}
      do i=1, NNDOF
        WW(i,RT) = WW(i,R)
      enddo

!C-- compute ||{b}||
      call hecmw_InnerProduct_R(hecMESH, NDOF, B, B, BNRM2, Tcomm)
      if (BNRM2.eq.0.d0) then
        iter = 0
        MAXIT = 0
        RESID = 0.d0
        X = 0.d0
      endif

      E_time = HECMW_WTIME()
      if (TIMElog.eq.2) then
        call hecmw_time_statistics(hecMESH, E_time - S_time, &
             t_max, t_min, t_avg, t_sd)
        if (hecMESH%my_rank.eq.0) then
          write(*,*) 'Time solver setup'
          write(*,*) '  Max     :',t_max
          write(*,*) '  Min     :',t_min
          write(*,*) '  Avg     :',t_avg
          write(*,*) '  Std Dev :',t_sd
        endif
        Tset = t_max
      else
        Tset = E_time - S_time
      endif

      Tcomm = 0.d0
      call hecmw_barrier(hecMESH)
      S1_time = HECMW_WTIME()
!C
!C*************************************************************** iterative procedures start
!C
      do iter = 1, MAXIT

!C===
!C +-----------------+
!C | RHO= {r}{r_tld} |
!C +-----------------+
!C===
      call hecmw_InnerProduct_R(hecMESH, NDOF, WW(:,R), WW(:,RT), RHO, Tcomm)

!C===
!C +----------------------------------------+
!C | BETA= (RHO/RHO1) * (ALPHA/OMEGA)       |
!C | {p} = {r} + BETA * ( {p} - OMEGA*{v} ) |
!C +----------------------------------------+
!C===
      if ( iter.gt.1 ) then
        BETA = (RHO/RHO1) * (ALPHA/OMEGA)
        do i = 1, NNDOF
          WW(i,P) = WW(i,R) + BETA * (WW(i,P) - OMEGA * WW(i,V))
        enddo
       else
        do i = 1, NNDOF
          WW(i,P) = WW(i,R)
        enddo
      endif

!C===
!C +--------------------+
!C | {p_tld}= [Minv]{p} |
!C +--------------------+
!C===
      call hecmw_precond_33_apply(hecMESH, hecMAT, WW(:, P), WW(:, PT), WW(:, WK), Tcomm)

!C===
!C +-------------------------+
!C | {v}= [A] {p_tld} |
!C +-------------------------+
!C===
      call hecmw_matvec_33(hecMESH, hecMAT, WW(:,PT), WW(:,V), Tcomm)

!C
!C-- calc. ALPHA
      call hecmw_InnerProduct_R(hecMESH, NDOF, WW(:,RT), WW(:,V), C2, Tcomm)

      ALPHA = RHO / C2

!C
!C-- {s}= {r} - ALPHA*{V}
      do i = 1, NNDOF
        WW(i,S) = WW(i,R) - ALPHA * WW(i,V)
      enddo

!C===
!C +--------------------+
!C | {s_tld}= [Minv]{s} |
!C +--------------------+
!C===
      call hecmw_precond_33_apply(hecMESH, hecMAT, WW(:, S), WW(:, ST), WW(:, WK), Tcomm)

!C===
!C +-------------------------+
!C | {t}= [A] {s_tld} |
!C +-------------------------+
!C===
      call hecmw_matvec_33(hecMESH, hecMAT, WW(:,ST), WW(:,T), Tcomm)

!C===
!C +----------------------------+
!C | OMEGA= ({t}{s}) / ({t}{t}) |
!C +----------------------------+
!C===
      call hecmw_InnerProduct_R(hecMESH, NDOF, WW(:,T), WW(:,S), CG(1), Tcomm)
      call hecmw_InnerProduct_R(hecMESH, NDOF, WW(:,T), WW(:,T), CG(2), Tcomm)

      OMEGA = CG(1) / CG(2)

!C===
!C +----------------+
!C | update {x},{r} |
!C +----------------+
!C===
      do i = 1, NNDOF
        X (i) = X(i) + ALPHA * WW(i,PT) + OMEGA * WW(i,ST)
        WW(i,R) = WW(i,S) - OMEGA * WW(i,T)
      enddo

      call hecmw_InnerProduct_R(hecMESH, NDOF, WW(:,S), WW(:,S), DNRM2, Tcomm)

      RESID= dsqrt(DNRM2/BNRM2)

!C##### ITERATION HISTORY
      if (my_rank.eq.0.and.ITERlog.eq.1) write (*,'(i7, 1pe16.6)') ITER, RESID
!C#####

      if ( RESID.le.TOL   ) exit
      if ( ITER .eq.MAXIT ) ERROR = HECMW_SOLVER_ERROR_NOCONV_MAXIT

      RHO1 = RHO

      enddo
!C
!C*************************************************************** iterative procedures end
!C

      call hecmw_solver_scaling_bk_33(hecMAT)
!C
!C-- INTERFACE data EXCHANGE
!C
      START_TIME = HECMW_WTIME()
      call hecmw_update_3_R (hecMESH, X, hecMAT%NP)
      END_TIME = HECMW_WTIME()
      Tcomm = Tcomm + END_TIME - START_TIME

      deallocate (WW)
      !call hecmw_precond_33_clear(hecMAT)

      E1_time = HECMW_WTIME()
      if (TIMElog.eq.2) then
        call hecmw_time_statistics(hecMESH, E1_time - S1_time, &
             t_max, t_min, t_avg, t_sd)
        if (hecMESH%my_rank.eq.0) then
          write(*,*) 'Time solver iterations'
          write(*,*) '  Max     :',t_max
          write(*,*) '  Min     :',t_min
          write(*,*) '  Avg     :',t_avg
          write(*,*) '  Std Dev :',t_sd
        endif
        Tsol = t_max
      else
        Tsol = E1_time - S1_time
      endif

      end subroutine hecmw_solve_BiCGSTAB_33
      end module     hecmw_solver_BiCGSTAB_33