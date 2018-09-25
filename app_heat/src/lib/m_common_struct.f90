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



!> This modules defines common structures for fem analysis
MODULE m_common_struct
  IMPLICIT NONE
  INTEGER, PARAMETER, PRIVATE :: kreal = kind(0.0d0)

        type tLocalCoordSys
          character(len=128)         :: sys_name
          integer                    :: sys_type       !< type of material or local coordinate system;
                                                       !< fisrt digit: 1- Cartensian 2- Cylinder 3- Sphere
                                                       !< second digit: 0- coodinate; 1-nodes  2-local nodes
          integer                    :: node_ID(3)     !< nodes' ID
          real(kind=kreal)           :: CoordSys(3,3)  !< variables when second digit=0
        end type tLocalCoordSys

        type( tLocalCoordSys ), pointer, save :: g_LocalCoordSys(:) => null()

  contains

		!> Initializer of global data
        subroutine fstr_localcoordsys_init()
          integer :: i

          if( .not. associated(g_LocalCoordSys) ) return
          do i=1,size(g_LocalCoordSys)
              g_LocalCoordSys(i)%sys_name      = ""
              g_LocalCoordSys(i)%sys_type      = 10
              g_LocalCoordSys(i)%node_ID(:)    = -1
              g_LocalCoordSys(i)%CoordSys(:,:) = 0.d0
          enddo
        end subroutine

       !> output of coordinate system
        subroutine print_localcoordsys(nfile, coordsys)
           integer, intent(in)                :: nfile
           type( tLocalCoordSys ), intent(in) :: coordsys

           write(nfile, *) coordsys%sys_type, coordsys%sys_name
           write(nfile, *) coordsys%node_ID(:)
           write(nfile, *) coordsys%CoordSys(1,:)
           write(nfile, *) coordsys%CoordSys(2,:)
           write(nfile, *) coordsys%CoordSys(3,:)
        end subroutine

		!> if need to fetch global nodes' coodinate
        logical function isCoordNeeds( coordsys )
           type( tLocalCoordSys ), intent(in) :: coordsys

           integer stype
           isCoordNeeds = .false.
           stype = mod( coordsys%sys_type, 10 )
           if( stype==0 ) isCoordNeeds = .true.
        end function

        !> setup of coordinate system
        subroutine set_localcoordsys(coords, coordsys, outsys, ierr)
           use m_utilities, only: cross_product
           real(kind=kreal), intent(inout)    :: coords(:,:)    ! coord needs to define local coord sys
           type( tLocalCoordSys ), intent(in) :: coordsys
           real(kind=kreal), intent(out)      :: outsys(3,3)
           integer, intent(out)               :: ierr

           real(kind=kreal) :: dis,f, ff(3), xyza(3), xyzb(3), xyzc(3)
           integer :: ftype, stype

           ierr = 0
           stype = mod( coordsys%sys_type, 10 )

		      if( stype==0 ) then  ! given coordinates
                 outsys = coordsys%CoordSys
              elseif( stype==1 ) then    ! given nodes id
                 xyza = coords(1,:)-coords(3,:)
                 xyzb = coords(2,:)-coords(3,:)
                 call cross_product(xyza,xyzb,xyzc)
                 f = dsqrt( dot_product( xyza, xyza ) )
                 outsys(1,:) = xyza/f
                 f = dsqrt( dot_product( xyzc, xyzc ) )
                 outsys(3,:) = xyzc/f
                 call cross_product(outsys(3,:), outsys(1,:), outsys(2,:) )
              endif
        end subroutine

END MODULE