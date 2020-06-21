!=====================================================================!
!                                                                     !
!   Software Name : ppOpen-APPL/FDM                                   !
!         Version : 0.2                                               !
!                                                                     !
!   License                                                           !
!     This file is part of ppOpen-APPL/FDM.                           !
!     ppOpen-APPL/FDM is a free software, you can use it under the    !
!     terms of The MIT License (MIT). See LICENSE file and User's     !
!     guide for more details.                                         !
!                                                                     !
!   ppOpen-HPC project:                                               !
!     Open Source Infrastructure for Development and Execution of     !
!     Large-Scale Scientific Applications on Post-Peta-Scale          !
!     Supercomputers with Automatic Tuning (AT).                      !
!                                                                     !
!   Organizations:                                                    !
!     The University of Tokyo                                         !
!       - Information Technology Center                               !
!       - Atmosphere and Ocean Research Institute (AORI)              !
!       - Interfaculty Initiative in Information Studies              !
!         /Earthquake Research Institute (ERI)                        !
!       - Graduate School of Frontier Science                         !
!     Kyoto University                                                !
!       - Academic Center for Computing and Media Studies             !
!     Japan Agency for Marine-Earth Science and Technology (JAMSTEC)  !
!                                                                     !
!   Sponsorship:                                                      !
!     Japan Science and Technology Agency (JST), Basic Research       !
!     Programs: CREST, Development of System Software Technologies    !
!     for post-Peta Scale High Performance Computing.                 !
!                                                                     !
!                 Copyright (c) 2013 T.Furumura                       !
!                                                                     !
!=====================================================================!

!==============================================================================!
!                                 MAIN PROGRAM                                 !
!==============================================================================!

!+-----------------------------------------------------------------------------!
program seism3d3n
!
      use ppohAT_ControlRoutines
      use ppohAT_InstallRoutines
      use ppohAT_StaticRoutines
      use ppohAT_DynamicRoutines
!=Description
! 3D FDM Code for MPI
!
!=Declarations
  use ppohFDM_stdio
  use ppohFDM_param
  use ppohFDM_io
  use ppohFDM_pssub
  use ppohFDM_pfd3d
  use ppohFDM_boundary
  use ppohFDM_stress
  use ppohFDM_velocity
  use ppohFDM_source
  use ppohFDM_sponge_absorber
  use mpi
  use ppohFDM_set_condition
  implicit none

  include 'OAT.h'
      character*512 ctmp


    real*8 t1, t2, t3, t4
    real*8 t5, t6
!    real*8 omp_get_wtime

    real*8 t_def_vel, t_def_stress
    real*8 t_update_stress
    real*8 t_update_vel
    real*8 t_update_stress_sponge 
    real*8 t_update_vel_sponge
    real*8 t_comp  
    real*8 t_passing_velocity
    real*8 t_passing_stress
    real*8 t_mpi 
    real*8 t_io

    real*8 t_def_vel_all, t_def_stress_all
    real*8 t_update_stress_all
    real*8 t_update_vel_all
    real*8 t_update_stress_sponge_all 
    real*8 t_update_vel_sponge_all
    real*8 t_comp_all  
    real*8 t_passing_velocity_all
    real*8 t_passing_stress_all
    real*8 t_mpi_all 
    real*8 t_io_all



      integer NX00, NX01
      integer NY00, NY01
      integer NZ00, NZ01

    t_def_vel = 0.0
    t_def_stress = 0.0

    t_update_stress = 0.0
    t_update_vel = 0.0
    t_update_stress_sponge = 0.0
    t_update_vel_sponge = 0.0

    t_passing_velocity = 0.0
    t_passing_stress = 0.0

    t_io = 0.0
!
  !!--------------------------------------------------------------------------!!
  !!                             MPI ENVIRONMENT                              !!
  !!--------------------------------------------------------------------------!!
  call set_mpi_environment( myid, itbl, idx, idy, idz )

      t3 = omp_get_wtime()

      OAT_DEBUG = 1
      oat_myid = myid
      oat_nprocs = nproc

!!OAT$ call OAT_BPset("N")
      call OAT_ATset(OAT_ALL, OAT_AllRoutines)
      call OAT_ATset(OAT_INSTALL, OAT_InstallRoutines)
      call OAT_ATset(OAT_STATIC, OAT_StaticRoutines)
      call OAT_ATset(OAT_DYNAMIC, OAT_DynamicRoutines)

      OAT_NUMPROCS = 1
      OAT_STARTTUNESIZE = NZP
      OAT_ENDTUNESIZE = NZP
      OAT_SAMPDIST = 100

      OAT_MAXSAMPITER = 100
!      OAT_MAXSAMPITER = 5



!      print *, "oat_max_threads =",oat_max_threads 
!      stop 


      NX00 = 1
      NX01 = NXP
      NY00 = 1
      NY01 = NYP
      NZ00 = 1
      NZ01 = NZP

!      call OAT_ATexec(OAT_INSTALL,OAT_InstallRoutines,NZ00,NZ01,NY00,NY01,NX00,NX01,NX0,NX1,NY0,NY1,NZ0,NZ1,DX,NZ,NY,NX,DXV,V,DY,DY&
!     &V,DZ,DZV)

      call OAT_ATexec(OAT_INSTALL,OAT_InstallRoutines,NZ00,NZ01,NY00,NY01,NX00,NX01,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1,DX,NZP,NYP,NXP,DX&
     &VX,VZ,DY,DYVY,DZ,DZVZ)


      t4 = omp_get_wtime()


      t1 = omp_get_wtime()

      if (myid == NP/2) then
        open(13, status = 'replace', &
     &     file = 'OAT_Seism3d_timings.dat', &
     &     action = 'write', pad= 'yes')
      endif


  ! Absolute Coordinate
  do I=NXP0, NXP1
     IA( I ) = NXP*idx + I
  end do
  do J=NYP0, NYP1
     JA( J ) = NYP*idy + J
  end do
    do K=0, NZP1
     KA( K ) = NZP*idz + K
  end do

  if( myid == 0 ) then
     write(STDERR,'(A)') "PROGRAM SEISM3DZ"
     write(STDERR,*)
     write(STDERR,'(A,I5,A,I5,A,I5)') "MODEL  SIZE: ", NXP, "x", NYP, "x", NZP
  end if

  !! Initialize elapsed time counter
  if( myid == NP/2 ) then
     write(STDERR,*)
     call system_clock( timcount, crate )
     timcount0 = timcount
     timprev = timcount
  end if

  !!--------------------------------------------------------------------------!!
  !!                               ABOSORBER                                  !!
  !!--------------------------------------------------------------------------!!
  call ppohFDM_set_sponge_absorber( )


  !!--------------------------------------------------------------------------!!
  !!                              SET SOURCE POINT                            !!
  !!--------------------------------------------------------------------------!!
  call ppohFDM_set_source()

  !!--------------------------------------------------------------------------!!
  !!                              Moment Tensor                               !!
  !!--------------------------------------------------------------------------!!
  call ppohFDM_sld2moment( STRIKE, DIP, RAKE, 1.0, RMXX, RMYY, RMZZ, RMXY, RMYZ, RMXZ )

  !!--------------------------------------------------------------------------!!
  !!                               FREE SURFACE                               !!
  !!--------------------------------------------------------------------------!!

  !! 1. Free surface boundary on the absolute grid 
  do J=0, NY+1
     do I=0, NX+1
        KFSZA(I,J) = KFS
     end do
  end do

  !! 2. Triming kfsza, detection of horizontal boundary
  call ppohFDM_set_free_surface( KFSZA, KFSZ, NIFS, NJFS, &
                                IFSX, IFSY, IFSZ, JFSX, JFSY, JFSZ )

  !!--------------------------------------------------------------------------!!
  !!                         SET MEDIUM PARAMETERS                            !!
  !!--------------------------------------------------------------------------!!
  call ppohFDM_set_medium( DEN, RIG, LAM )


  !!--------------------------------------------------------------------------!!
  !!                            STABLE CONDITION                              !!
  !!--------------------------------------------------------------------------!!
  if( myid == nproc-1 ) then
     write(STDERR,'(A,F10.5)') "STABLE CONDITION (SHOULD BE SMALLER THAN 1)", &
          DT/( 0.45*min(DX,DY,DZ)/maxval(sqrt((LAM+2*RIG)/DEN)))
     if( DT > 0.45*min(DX,DY,DZ)/maxval(sqrt((LAM+2*RIG)/DEN)) ) then
        write(STDERR,*) "Enlarge Spatial Grid and/or Shorten Time Grid!"
     end if
     write(STDERR,*)
  end if


  !!--------------------------------------------------------------------------!!
  !!                           PARAMETER FILE OUTPUT                          !!
  !!--------------------------------------------------------------------------!!
  if( myid == 0 )  call ppohFDM_output_prm

  !!--------------------------------------------------------------------------!!
  !!                            MOMENT FUNCTION                               !!
  !!--------------------------------------------------------------------------!!

  !! Use ikupper for Body Force Source, kupper for Stress Drop Source

  do IT = 1, NTMAX
     T = (IT-1)*DT
     STIME (IT) =  kupper (AT, T, T0)    ! For Stress Drop
  end do


  !!--------------------------------------------------------------------------!!
  !!                             ZERO-FILL ARRAYS                             !!
  !!--------------------------------------------------------------------------!!
  call ppohFDM_initialize_arrays()

  !!--------------------------------------------------------------------------!!
  !!                                 STATION                                  !!
  !!--------------------------------------------------------------------------!!

  call ppohFDM_set_station()
  call ppohFDM_station_func()

  !!--------------------------------------------------------------------------!!
  !!                               OUTPUT FILES                               !!
  !!--------------------------------------------------------------------------!!
  !!Please see io.f90

      t5 = omp_get_wtime()

  call ppohFDM_io_open()

      t6 = omp_get_wtime()
      t_io = t_io + (t6-t5)
  !!--------------------------------------------------------------------------!!
  !!                           TIME STEP START                                !!
  !!--------------------------------------------------------------------------!!


  if( myid == NP/2 ) then
     write(STDERR,*)
     call system_clock( timcount, crate )
     timprev = timcount
  end if
  ttotal = 0.0_PN

  DXI = 1.0_PN / DX
  DYI = 1.0_PN / DY
  DZI = 1.0_PN / DZ

  xmax  = 0.0; ymax  = 0.0; zmax  = 0.0
  timestep: do IT=1, NTMAX
     T  =   DT * (IT-1)


     !!--- Time Measurement
     if( mod(IT, NWRITE) == 0 ) then

        ! max value for debug output 
        call get_max( xmax, ymax, zmax )

        if( myid == NP/2 ) then

           call system_clock( timcount, crate )
           tstep = real( timcount - timprev ) / real( crate )
           ttotal = ttotal + tstep
           etas   = (ntmax -it)/ real(it) * (timcount-timcount0)/real( crate )
           etah = int( etas/(   60*60) ); etas = etas - etah   *60*60
           etam = int( etas/(      60) ); etas = etas - etam      *60
           etasi = int(etas)
           timprev = timcount

           write(STDERR,'(A,I6,A,I6,A,I2.2,A,I2.2,A,I2.2,A,F9.4,A,3ES9.2,A)') &
                "IT=(", IT, "/",NTMAX,"), ETA=", &
                etah,":",etam,":",etasi, &
                ", Time/Step=", ttotal / IT, "[s], MAX = ( ", &
                xmax, ymax, zmax, " )"

           write(13,'(I6,F9.4)') IT, ttotal / IT

        end if
     end if

     !!-----------------------------------------------------------------------!!
     !!                        Velocity  t=(n+1/2)*dt                         !!
     !!-----------------------------------------------------------------------!!

     if( is_fs .or. is_nearfs ) then
        call ppohFDM_bc_zero_stress( KFSZ,NIFS,NJFS,IFSX,IFSY,IFSZ,JFSX,JFSY,JFSZ )
     end if


      !! Velocity Update

      t5 = omp_get_wtime()

      ctmp = "ppohFDMupdate_vel_select"
      call OAT_SetParm(1,ctmp,NZ01,iusw1_ppohFDMupdate_vel_select)

!      iusw1_ppohFDMupdate_vel_select = 1
      call OAT_InstallppohFDMupdate_vel_select(iusw1_ppohFDMupdate_vel_select)
!!OAT$ call OAT_BPset("NZP")
!!OAT$ install select region start
!!OAT$ name ppohFDMupdate_vel_select
!!OAT$ debug (pp)
        if (OAT_DEBUG .ge. 2)then
          print *, 'oat_myid: ',oat_myid
          print *, 'Install Routine: ppohFDMupdate_vel_select=',iusw1_ppohFDMupdate_vel_select
        endif
 


!     call ppohFDM_pdiffx3_p4( SXX,DXSXX, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DX )
!     call ppohFDM_pdiffy3_p4( SYY,DYSYY, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DY )
!     call ppohFDM_pdiffx3_m4( SXY,DXSXY, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DX )
!     call ppohFDM_pdiffy3_m4( SXY,DYSXY, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DY )
!     call ppohFDM_pdiffx3_m4( SXZ,DXSXZ, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DX )
!     call ppohFDM_pdiffz3_m4( SXZ,DZSXZ, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DZ )
!     call ppohFDM_pdiffy3_m4( SYZ,DYSYZ, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DY )
!     call ppohFDM_pdiffz3_m4( SYZ,DZSYZ, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DZ )
!     call ppohFDM_pdiffz3_p4( SZZ,DZSZZ, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DZ )

      !! Substitute to Reduced-order derivertives at around model boundary
!      call ppohFDM_truncate_diff_stress(idx,idy,idz)

!      if( is_fs .or. is_nearfs ) then
!         call ppohFDM_bc_stress_deriv( KFSZ,NIFS,NJFS,IFSX,IFSY,IFSZ,JFSX,JFSY,JFSZ )
!      end if

!      call ppohFDM_update_vel       ( 1, NXP, 1, NYP, 1, NZP )


      t6 = omp_get_wtime()
      t_update_vel = t_update_vel + (t6-t5)




      t5 = omp_get_wtime()
     !call fapp_start("region3",1,1)
     call ppohFDM_update_vel_sponge( 1, NXP, 1, NYP, 1, NZP )
     !call fapp_stop("region3",1,1)
      t6 = omp_get_wtime()
      t_update_vel_sponge = t_update_vel_sponge + (t6-t5)

     !!-----------------------------------------------------------------------!!
     !!                             BODY FORCE                                !!
     !!-----------------------------------------------------------------------!!
     !     call ppohFDM_source_term_bodyforce ! comment out if stress drop source

     !!-----------------------------------------------------------------------!!
     !!                            Message Passing                            !!
     !!-----------------------------------------------------------------------!!

      t5 = omp_get_wtime()

     !call fapp_start("region4",1,1)
     call ppohFDM_passing_velocity()
     !call fapp_stop("region4",1,1)

     if( is_fs .or. is_nearfs ) then
        call ppohFDM_bc_vel_deriv( KFSZ,NIFS,NJFS,IFSX,IFSY,IFSZ,JFSX,JFSY,JFSZ )
     end if


      t6 = omp_get_wtime()
      t_passing_velocity = t_passing_velocity + (t6-t5)



     !!-- Update Stress Components
      t5 = omp_get_wtime()

      ctmp = "ppohFDMupdate_stress_select"
      call OAT_SetParm(1,ctmp,NZ01,iusw1_ppohFDMupdate_stress_select)

!      iusw1_ppohFDMupdate_stress_select = 1
      call OAT_InstallppohFDMupdate_stress_select(iusw1_ppohFDMupdate_stress_select)
      
!!OAT$ call OAT_BPset("NZP")
!!OAT$ install select region start
!!OAT$ name ppohFDMupdate_stress_select
!!OAT$ debug (pp)
        if (OAT_DEBUG .ge. 2)then
          print *, 'oat_myid: ',oat_myid
          print *, 'Install Routine: ppohFDMupdate_stress_select=', &
     &       iusw1_ppohFDMupdate_stress_select
        endif



!     !!-----------------------------------------------------------------------!!
!     !!                           Stress   t=(n+1)*dt                         !!
!     !!-----------------------------------------------------------------------!!
!     call ppohFDM_pdiffx3_m4( VX,DXVX, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DX )
!     call ppohFDM_pdiffy3_p4( VX,DYVX, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DY )
!     call ppohFDM_pdiffz3_p4( VX,DZVX, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DZ )
!
!     call ppohFDM_pdiffy3_m4( VY,DYVY, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DY )
!     call ppohFDM_pdiffx3_p4( VY,DXVY, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DX )
!     call ppohFDM_pdiffz3_p4( VY,DZVY, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DZ )
!
!     call ppohFDM_pdiffx3_p4( VZ,DXVZ, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DX )
!     call ppohFDM_pdiffy3_p4( VZ,DYVZ, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DY )
!     call ppohFDM_pdiffz3_m4( VZ,DZVZ, NXP,NYP,NZP,NXP0,NXP1,NYP0,NYP1,NZP0,NZP1, DZ )
!
!     !! Substitute to reduced order derivertives at around model boundary
!     !call ppohFDM_truncate_diff_vel(idx,idy,idz)
!
!     call ppohFDM_update_stress        ( 1, NXP, 1, NYP, 1, NZP )


      t6 = omp_get_wtime()
      t_update_stress = t_update_stress + (t6-t5)



      t5 = omp_get_wtime()
     !call fapp_start("region7",1,1)
     call ppohFDM_update_stress_sponge ( 1, NXP, 1, NYP, 1, NZP )
     !call fapp_stop("region7",1,1)
      t6 = omp_get_wtime()
      t_update_stress_sponge = t_update_stress_sponge + (t6-t5)


     !!-----------------------------------------------------------------------!!
     !!                           STRESS DROP SOURCE                          !!
     !!-----------------------------------------------------------------------!!
     call ppohFDM_source_term_stressdrop()

     !!-----------------------------------------------------------------------!!
     !!                            Message Passing                            !!
     !!-----------------------------------------------------------------------!!

      t5 = omp_get_wtime()
     !call fapp_start("region8",1,1)
     call ppohFDM_passing_stress()
     !call fapp_stop("region8",1,1)
      t6 = omp_get_wtime()
      t_passing_stress = t_passing_stress + (t6-t5)


     !!-----------------------------------------------------------------------!!
     !!                          SNAPSHOT DATA EXPORT                         !!
     !!-----------------------------------------------------------------------!!
     !!please see io.f90

      t5 = omp_get_wtime()

      call ppohFDM_io_write()

      t6 = omp_get_wtime()
      t_io = t_io + (t6-t5)


     !!-----------------------------------------------------------------------!!
     !!                       VOLUME RENDERING DATA EXPORT                    !!
     !!-----------------------------------------------------------------------!!
     !    call ppohFDM_io_vol_psdiff( it, IOVOL )
     !    call ppohFDM_io_vol_dis( it, IOVOL )
  end do timestep


  if( is_fs ) then
     close( IOSPS )
     close( IOSNP )
     close( IOWAV )
  end if


  if( is_ioxy ) close( ioxy )
  if( is_ioyz ) close( ioyz )
  if( is_ioxz ) close( ioxz )


  t2 = omp_get_wtime()


     t_comp = t_def_vel+t_def_stress+t_update_stress &
            +t_update_stress_sponge+t_update_vel+t_update_vel_sponge

     call MPI_Allreduce(t_comp, t_comp_all, 1, MPI_DOUBLE_PRECISION, &
        MPI_SUM, MPI_COMM_WORLD, ierr)
     t_comp = t_comp_all / dble(NP) 


     call MPI_Allreduce(t_def_vel, t_def_vel_all, 1, MPI_DOUBLE_PRECISION, &
        MPI_SUM, MPI_COMM_WORLD, ierr)
     t_def_vel = t_def_vel_all / dble(NP) 

     call MPI_Allreduce(t_def_stress, t_def_stress_all, 1, MPI_DOUBLE_PRECISION, &
        MPI_SUM, MPI_COMM_WORLD, ierr)
     t_def_stress = t_def_stress_all / dble(NP) 

     call MPI_Allreduce(t_update_stress_sponge, t_update_stress_sponge_all, &
        1, MPI_DOUBLE_PRECISION, MPI_SUM, MPI_COMM_WORLD, ierr)
     t_update_stress_sponge = t_update_stress_sponge_all / dble(NP) 

     call MPI_Allreduce(t_update_vel, t_update_vel_all, &
        1, MPI_DOUBLE_PRECISION, MPI_SUM, MPI_COMM_WORLD, ierr)
     t_update_vel = t_update_vel_all / dble(NP) 

     call MPI_Allreduce(t_passing_velocity, t_passing_velocity_all, &
        1, MPI_DOUBLE_PRECISION, MPI_SUM, MPI_COMM_WORLD, ierr)
     t_passing_velocity = t_passing_velocity_all / dble(NP) 

     call MPI_Allreduce(t_update_stress, t_update_stress_all, 1, MPI_DOUBLE_PRECISION, &
        MPI_SUM, MPI_COMM_WORLD, ierr)
     t_update_stress = t_update_stress_all / dble(NP) 

     call MPI_Allreduce(t_update_vel_sponge, t_update_vel_sponge_all, &
        1, MPI_DOUBLE_PRECISION, MPI_SUM, MPI_COMM_WORLD, ierr)
     t_update_vel_sponge = t_update_vel_sponge_all / dble(NP) 

     call MPI_Allreduce(t_passing_stress, t_passing_stress_all, &
        1, MPI_DOUBLE_PRECISION, MPI_SUM, MPI_COMM_WORLD, ierr)
     t_passing_stress = t_passing_stress_all / dble(NP) 

     call MPI_Allreduce(t_io, t_io_all, &
        1, MPI_DOUBLE_PRECISION, MPI_SUM, MPI_COMM_WORLD, ierr)
     t_io = t_io_all / dble(NP) 


  if( myid == NP/2 ) then
     call system_clock( timcount, crate )
     ttotal = ttotal + tstep
     write(STDERR,'(A,I15,A)') &
          "Finished Computation. Total Time = ", int(ttotal), " sec."

!     print *, "Total Exec Time =", t2-t1
     write(13,'(A,F9.4)') "(Rank:NP/2) AT Time", t4-t3
     write(13,'(A,F9.4)') "(Rank:NP/2) Other Time", t2-t1

     write(13,'(A)') "-------"
     write(13,'(A)') "  Computation (ave.):"

     write(13,'(A,F9.4)') "  t_def_vel=", t_def_vel

     write(13,'(A,F9.4)') "  t_def_stress=", t_def_stress

     write(13,'(A,F9.4)') "  t_update_stress=", t_update_stress

     write(13,'(A,F9.4)') "  t_update_stress_sponge=", t_update_stress_sponge

     write(13,'(A,F9.4)') "  t_update_vel=", t_update_vel

     write(13,'(A,F9.4)') "  t_update_vel_sponge=", t_update_vel_sponge

     write(13,'(A,F9.4)') "  [%]=", t_comp / (t2-t1) * 100.0 
     
     write(13,'(A)') "-------"
     write(13,'(A)') "  Communication (ave.):"

     write(13,'(A,F9.4)') "  t_passing_velocity=", t_passing_velocity     

     write(13,'(A,F9.4)') "  t_passing_stress=", t_passing_stress     

     t_mpi = t_passing_velocity + t_passing_stress


     write(13,'(A,F9.4)') "  [%]=", t_mpi / (t2-t1) * 100.0 

     write(13,'(A)') "-------"
     write(13,'(A)') "  IO (ave.):"

     write(13,'(A,F9.4)') "  t_io=", t_io

     write(13,'(A,F9.4)') "  [%]=", t_io / (t2-t1) * 100.0
  
     write(13,'(A)') "-------"
     write(13,'(A)') "  Others (ave.) :"
     write(13,'(A,F9.4)') "  t_other=", (t2-t1) - (t_comp + t_mpi + t_io)
     write(13,'(A,F9.4)') "  [%]=", &
       ((t2-t1) - (t_comp + t_mpi + t_io))  / (t2-t1) * 100.0

     close(13, status = 'keep')

  end if


  call mpi_finalize( ierr )
  stop


contains

  !+---------------------------------------------------------------------------!
  subroutine get_max( xmax, ymax, zmax )
  !
  !=Description
  ! Returns maximum velocity amplitudes for x, y, z components on the surface
  !
  !=Arguments
    real(PN), intent(out) :: xmax, ymax, zmax
  !+
    integer :: i, j, kk
    real,    save :: xmax0, ymax0, zmax0
    logical, save :: is_firstcall = .true.
  !--
    ! initialize
    if( is_firstcall ) then
       xmax0 = 0.0_PN
       ymax0 = 0.0_PN
       zmax0 = 0.0_PN
       is_firstcall = .false.
    end if

    if( .not. is_fs ) then
       xmax0 = -1.
       ymax0 = -1.
       zmax0 = -1.
    else
       do j=1, NYP, NYD
          do i=1, NXP, NXD
             kk = KFSZ(i,j)+1 ! top of the solid part
             xmax0 = max( xmax0, abs( VX( i,j,kk ) ) )
             ymax0 = max( ymax0, abs( VY( i,j,kk ) ) )
             zmax0 = max( zmax0, abs( VZ( i,j,kk ) ) )
          end do
       end do
    end if
    call mpi_reduce( xmax0, xmax, 1, MPI_REAL, MPI_MAX, NP/2, &
         mpi_comm_world, ierr )
    call mpi_reduce( ymax0, ymax, 1, MPI_REAL, MPI_MAX, NP/2, &
         mpi_comm_world, ierr )
    call mpi_reduce( zmax0, zmax, 1, MPI_REAL, MPI_MAX, NP/2, &
         mpi_comm_world, ierr )

  end subroutine get_max
  !----------------------------------------------------------------------------!
  !+---------------------------------------------------------------------------!
  subroutine ppohFDM_truncate_diff_vel(idx,idy,idz)
  !
  !=Description
  ! Substitute the derivertives at around boundary to the recuced-order derivs.
  !
  !=Arguments
    integer, intent(in) :: idx, idy, idz
  !+
    integer :: i, j, k
  !--
    !! X dir
    if( idx == 0 ) then
       do K=1, NZP
          do J=1, NYP
             DXVX(1,J,K) = ( VX(1,J,K) - 0.0_PN    ) * DXI
             DXVX(2,J,K) = ( VX(2,J,K) - VX(1,J,K) ) * DXI
             DXVY(1,J,K) = ( VY(2,J,K) - VY(1,J,K) ) * DXI
             DXVZ(1,J,K) = ( VZ(2,J,K) - VZ(1,J,K) ) * DXI
          end do
       end do
    end if
    if( idx == IP-1 ) then
       do K=1, NZP
          do J=1, NYP
             DXVX(NXP  ,J,K) = ( VX(NXP,J,K) - VX(NXP-1,J,K) ) * DXI
             DXVY(NXP-1,J,K) = ( VY(NXP,J,K) - VY(NXP-1,J,K) ) * DXI
             DXVY(NXP  ,J,K) = ( 0.0_PN      - VY(NXP,  J,K) ) * DXI
             DXVZ(NXP-1,J,K) = ( VZ(NXP,J,K) - VZ(NXP-1,J,K) ) * DXI
             DXVZ(NXP  ,J,K) = ( 0.0_PN      - VZ(NXP,  J,K) ) * DXI
          end do
       end do
    end if

    if( idy == 0 ) then ! Shallowmost
       do K=1, NZP
          do I=1, NXP
             DYVX(I,1,K) = ( VX(I,2,K) - VX(I,1,K) ) * DYI
             DYVY(I,1,K) = ( VY(I,1,K) - 0.0_PN    ) * DYI
             DYVY(I,2,K) = ( VY(I,2,K) - VY(I,1,K) ) * DYI
             DYVZ(I,1,K) = ( VZ(I,2,K) - VZ(I,1,K) ) * DYI
          end do
       end do
    end if
    if( idy == JP-1 ) then
       do K=1, NZP
          do I=1, NXP
             DYVX(I,NYP-1,K) = ( VX(I,NYP,K) - VX(I,NYP-1,K) ) * DYI
             DYVX(I,NYP,  K) = ( 0.0_PN      - VX(I,NYP,  K) ) * DYI
             DYVY(I,NYP,  K) = ( VY(I,NYP,K) - VY(I,NYP-1,K) ) * DYI
             DYVZ(I,NYP-1,K) = ( VZ(I,NYP,K) - VZ(I,NYP-1,K) ) * DYI
             DYVZ(I,NYP,  K) = ( 0.0_PN      - VZ(I,NYP,  K) ) * DYI
          end do
       end do
    end if

    if( idz == 0 ) then ! Shallowmost
       do J=1, NYP
          do I=1, NXP
             DZVZ(I,J,1 ) = ( VZ(I,J,1) - 0.0_PN    ) * DZI
             DZVZ(I,J,2 ) = ( VZ(I,J,2) - VZ(I,J,1) ) * DZI
             DZVX(I,J,1 ) = ( VX(I,J,2) - VX(I,J,1) ) * DZI
             DZVY(I,J,1 ) = ( VY(I,J,2) - VY(I,J,1) ) * DZI
          end do
       end do
    end if
    if( idz == KP-1 ) then
       do J=1, NYP
          do I=1, NXP
             DZVZ(I,J,NZP  ) = ( VZ(I,J,NZP) - VZ(I,J,NZP-1) ) * DZI
             DZVY(I,J,NZP  ) = ( 0.0_PN      - VY(I,J,NZP  ) ) * DZI
             DZVY(I,J,NZP-1) = ( VY(I,J,NZP) - VY(I,J,NZP-1) ) * DZI
             DZVX(I,J,NZP  ) = ( 0.0_PN      - VX(I,J,NZP  ) ) * DZI
             DZVX(I,J,NZP-1) = ( VX(I,J,NZP) - VX(I,J,NZP-1) ) * DZI
          end do
       end do
    end if

  end subroutine ppohFDM_truncate_diff_vel
  !----------------------------------------------------------------------------!
  !+---------------------------------------------------------------------------!
  subroutine set_mpi_environment( myid, itbl, idx, idy, idz )
  !
  !=Arguments
    integer, intent(out) :: myid
    integer, intent(out) :: itbl(-1:IP,-1:JP,-1:KP)
    integer, intent(out) :: idx, idy, idz
  !+
  !--


    call mpi_init( ierr )
    call mpi_comm_size( mpi_comm_world, nproc, ierr )
    call mpi_comm_rank( mpi_comm_world, myid , ierr )

    if( nproc /= NP ) then
       call mpi_finalize( ierr )
       write(STDERR,'(A, I3, A, I3)') &
            '## NP Error ## Expected: ', NP, ' Prepared: ', nproc
       stop

    else if ( NZP < NL .or. NYP < NL .or. NZP < NL ) then
       call mpi_finalize( ierr )
       write(STDERR,'(A,I3,A,I3)') &
            '## NXP, NYP, NZP are too small: Must be larger than ', NL
       stop
    end if

    ! Communicate ID table
    itbl(-1:IP,-1:JP,-1:KP) =  MPI_PROC_NULL ! initialize
    do ii = 0, NP-1
       i = mod( ii, IP )
       j = mod( ii/IP, JP)
       k = ii/(IP*JP)
       itbl(i,j,k) = ii
    end do

    ! location of this CPU
    idx = mod( MYID, IP )
    idy = mod( MYID/IP, JP)
    idz = MYID / (IP*JP)

    ! MPI buffer area
    allocate( i1_sbuff(NYP*NZP*NL3), i2_sbuff(NYP*NZP*NL3) )
    allocate( i1_rbuff(NYP*NZP*NL3), i2_rbuff(NYP*NZP*NL3) )
    allocate( j1_sbuff(NXP*NZP*NL3), j2_sbuff(NXP*NZP*NL3) )
    allocate( j1_rbuff(NXP*NZP*NL3), j2_rbuff(NXP*NZP*NL3) )
    allocate( k1_sbuff(NXP*NYP*NL3), k2_sbuff(NXP*NYP*NL3) )
    allocate( k1_rbuff(NXP*NYP*NL3), k2_rbuff(NXP*NYP*NL3) )

   end subroutine set_mpi_environment
  !----------------------------------------------------------------------------!

  !+---------------------------------------------------------------------------!
  subroutine ppohFDM_set_free_surface( KFSZA, KFSZ, NIFS, NJFS, &
                               IFSX, IFSY, IFSZ, JFSX, JFSY, JFSZ )
  !
  !=Arguments
    integer, intent(inout) :: KFSZA(-NL2-1:NX+NL2+1,-NL2-1:NY+NL2+1)
    integer, intent(out)   :: KFSZ(NXP0:NXP1,NYP0:NYP1)
    integer, intent(out)   :: NIFS, NJFS
    integer, intent(out)   :: IFSX(NFSMAX), IFSY(NFSMAX), IFSZ(NFSMAX)
    integer, intent(out)   :: JFSX(NFSMAX), JFSY(NFSMAX), JFSZ(NFSMAX)
  !+
    integer :: i, j, k
    integer :: ii, jj, kk
    integer :: NIFSA, NJFSA
    integer :: dum(0:NX+1,0:NY+1)
    ! discontinuities in absolute coordinates
    integer :: IFSXA(NX1*NY1), IFSYA(NX1*NY1), IFSZA(NX1*NY1)
    integer :: JFSXA(NX1*NY1), JFSYA(NX1*NY1), JFSZA(NX1*NY1)
  !--

    !! 1 Gaussian filter for smoothing out too-small scale topographic change
    do J=0, NY+1
       do I=0, NX+1
          dum(i,j) = KFSZA(i,j)
       end do
    end do
    do J=1, NY
       do I=1, NX
          KFSZA(I,J) = 1*dum(i-1,j-1) + 2*dum(i-1,j  ) + 1*dum(i-1,j+1) &
                     + 2*dum(i  ,j-1) + 4*dum(i  ,j  ) + 2*dum(i  ,j+1) &
                     + 1*dum(i+1,j-1) + 2*dum(i+1,j  ) + 1*dum(i+1,j+1)
          KFSZA(I,J) = KFSZA(I,J) / 16
       end do
    end do


    !! 2. ABSORBING REGION HAVE SAME STRUCTURE WITH LAYER BOUNDARY
    do J=1, NY1
       KFSZA(  -NL2+1:NPM   ,J) = KFSZA(NPM+1,J)
       KFSZA(NX-NPM+1:NX+NL2,J) = KFSZA(NX-NPM,J)
    end do
    do I=1, NX1
       KFSZA(I,  -NL2+1:NPM   ) = KFSZA(I,NPM+1)
       KFSZA(I,NY-NPM+1:NY+NL2) = KFSZA(I,NY-NPM)
    end do
    KFSZA(-NL2-1:NPM       ,-NL2+1:NPM        ) = KFSZA(NPM+1,NPM+1)
    KFSZA(NX-NPM+1:NX+NL2+1,-NL2+1:NPM        ) = KFSZA(NX-NPM,NPM+1)
    KFSZA(-NL2-1:NPM       ,NY-NPM+1:NY+NL2+1 ) = KFSZA(NPM+1 ,NY-NPM)
    KFSZA(NX-NPM+1:NX+NL2+1,NY-NPM+1:NY+NL2+1 ) = KFSZA(NX-NPM,NY-NPM)

    !! 3. Horizontal Boundary Scan: X-dir
    NIFSA = 0
    do J=1, NY1
       do I=2, NX1
          if( KFSZA(I,J) > KFSZA(I-1,J) ) then
             do K=KFSZA(I-1,J), KFSZA(I,J)-1
                NIFSA = NIFSA+1
                IFSXA(NIFSA) = I-1
                IFSYA(NIFSA) = J
                IFSZA(NIFSA) = K+1
             end do
          else if( KFSZA(I,J) < KFSZA(I-1,J) ) then
             do K=KFSZA(I,J), KFSZA(I-1,J)-1
                NIFSA = NIFSA+1
                IFSXA(NIFSA) = I-1
                IFSYA(NIFSA) = J
                IFSZA(NIFSA) = K+1
             end do
          end if
       end do
    end do

    !! 4. Horizontal Boundary Scan: Y-dir
    NJFSA = 0
    do I=1, NX1
       do J=2, NY1
          if( KFSZA(I,J) > KFSZA(I,J-1) ) then
             do K=KFSZA(I,J-1), KFSZA(I,J)-1
                NJFSA = NJFSA+1
                JFSXA(NJFSA) = I
                JFSYA(NJFSA) = J-1
                JFSZA(NJFSA) = K+1
             end do
          else if( KFSZA(I,J) < KFSZA(I,J-1) ) then
             do K=KFSZA(I,J), KFSZA(I,J-1)-1
                NJFSA = NJFSA+1
                JFSXA(NJFSA) = I
                JFSYA(NJFSA) = J-1
                JFSZA(NJFSA) = K+1
             end do
          end if
       end do
    end do


    !! 5.  Free surface boundary in MPI unit
    KFSZ(:,:) = NOSURF
    is_fs = .false.
    do KK=1, NZP
       do J=NYP00, NYP10
          JJ = JA(J)
          do I=NXP00, NXP10
             II = IA(I)
             if( KA(KK) == KFSZA(II,JJ) ) then
                KFSZ(I,J) = KA(KK) - NZP*idz
                is_fs = .true.
             end if
          end do
       end do
    end do

    ! 1-grid outside of the MPI unit: free surface condition must be consideard
    is_nearfs = .false.
    do J=NYP0, NYP1
       JJ = JA(J)
       do I=NXP0, NXP1
          II = IA(I)
          if( KA(0    ) == KFSZA(II,JJ) ) then
             KFSZ(I,J) = KA(0    ) - NZP*idz
             is_nearfs = .true.
          end if
          if( KA(NZP+1) == KFSZA(II,JJ) ) then
             KFSZ(I,J) = KA(NZP+1) - NZP*idz
             is_nearfs = .true.
          end if
       end do
    end do

    ! Horizontal step
    NIFS = 0
    NJFS = 0
    do I=1, NIFSA
       ii = IFSXA(I) - NXP * idx
       jj = IFSYA(I) - NYP * idy
       if( 0<= ii .and. ii <= NXP+1  ) then  ! including margin
          if( 1 <= jj .and. jj <= NYP ) then
             do KK=0, NZP+1
                if( KA(KK) == IFSZA(I) ) then
                   NIFS = NIFS+1
                   IFSX(NIFS) = ii
                   IFSY(NIFS) = jj
                   IFSZ(NIFS) = kk
                end if
             end do
          end if
       end if
    end do
    do J=1, NJFSA
       ii = JFSXA(J) - NXP * idx
       jj = JFSYA(J) - NYP * idy
       if( 1<= ii .and. ii <= NXP  ) then
          if( 0 <= jj .and. jj <= NYP+1 ) then ! including margin
             do KK=0, NZP+1
                if( KA(KK) == JFSZA(J) ) then
                   NJFS = NJFS+1
                   JFSX(NJFS) = ii
                   JFSY(NJFS) = jj
                   JFSZ(NJFS) = kk
                end if
             end do
          end if
       end if
    end do

  end subroutine ppohFDM_set_free_surface
  !----------------------------------------------------------------------------!

  !+---------------------------------------------------------------------------!

  !+---------------------------------------------------------------------------!
  subroutine ppohFDM_initialize_arrays()

    call ppohFDM_clear3d( NXP0, NXP1, NYP0, NYP1, NZP0, NZP1,  VX,    0.0_PN )
    call ppohFDM_clear3d( NXP0, NXP1, NYP0, NYP1, NZP0, NZP1,  VY,    0.0_PN )
    call ppohFDM_clear3d( NXP0, NXP1, NYP0, NYP1, NZP0, NZP1,  VZ,    0.0_PN )

    call ppohFDM_clear3d( NXP0, NXP1, NYP0, NYP1, NZP0, NZP1, SXX,   0.0_PN )
    call ppohFDM_clear3d( NXP0, NXP1, NYP0, NYP1, NZP0, NZP1, SYY,   0.0_PN )
    call ppohFDM_clear3d( NXP0, NXP1, NYP0, NYP1, NZP0, NZP1, SZZ,   0.0_PN )
    call ppohFDM_clear3d( NXP0, NXP1, NYP0, NYP1, NZP0, NZP1, SXY,   0.0_PN )
    call ppohFDM_clear3d( NXP0, NXP1, NYP0, NYP1, NZP0, NZP1, SXZ,   0.0_PN )
    call ppohFDM_clear3d( NXP0, NXP1, NYP0, NYP1, NZP0, NZP1, SYZ,   0.0_PN )


  end subroutine ppohFDM_initialize_arrays
  !----------------------------------------------------------------------------!

end program seism3d3n
!------------------------------------------------------------------------------!
