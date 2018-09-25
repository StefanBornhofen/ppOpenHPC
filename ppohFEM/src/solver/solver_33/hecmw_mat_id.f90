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


module hecmw_mat_id
  use hecmw_util

  private

  public:: hecmw_mat_id_set
  public:: hecmw_mat_id_get
  public:: hecmw_mat_id_clear

  type mat_mesh
    logical :: used = .false.
    type(hecmwST_matrix), pointer :: mat
    type(hecmwST_local_mesh), pointer :: mesh
  end type mat_mesh

  integer(kind=kint), parameter :: MAX_MM = 8

  type(mat_mesh), save :: mm(MAX_MM)

contains

  subroutine hecmw_mat_id_set(hecMAT, hecMESH, id)
    implicit none
    type(hecmwST_matrix), intent(in), target :: hecMAT
    type(hecmwST_local_mesh), intent(in), target :: hecMESH
    integer(kind=kint), intent(out) :: id
    integer(kind=kint) :: i
    id = 0
    do i = 1, MAX_MM
      if (.not. mm(i)%used) then
        id = i
        exit
      endif
    end do
    if (id == 0) then
      stop 'ERROR: hecmw_mat_id_set: too many matrices set'
    endif
    mm(id)%mat => hecMAT
    mm(id)%mesh => hecMESH
    mm(id)%used = .true.
  end subroutine hecmw_mat_id_set

  subroutine hecmw_mat_id_get(id, hecMAT, hecMESH)
    implicit none
    integer(kind=kint), intent(in) :: id
    type(hecmwST_matrix), pointer :: hecMAT
    type(hecmwST_local_mesh), pointer :: hecMESH
    if (id <= 0 .or. MAX_MM < id) then
      stop 'ERROR: hecmw_mat_id_get: id out of range'
    endif
    if (.not. mm(id)%used) then
      stop 'ERROR: hecmw_mat_id_get: invalid id'
    endif
    hecMAT => mm(id)%mat
    hecMESH => mm(id)%mesh
  end subroutine hecmw_mat_id_get

  subroutine hecmw_mat_id_clear(id)
    implicit none
    integer(kind=kint), intent(in) :: id
    if (.not. mm(id)%used) then
      stop 'ERROR: hecmw_mat_id_clear: invalid id'
    endif
    mm(id)%mat => null()
    mm(id)%mesh => null()
    mm(id)%used = .false.
  end subroutine hecmw_mat_id_clear

end module hecmw_mat_id
