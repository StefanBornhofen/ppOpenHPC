!=====================================================================!!
!!                                                                    !!
!!   Software Name : ppOpen-APPL/AMR-FDM (ppohAMRFDM)                 !!
!!         Version : 0.3.0                                            !!
!!                                                                    !!
!!   License:                                                         !!
!!     This file is part of ppohAMRFDM.                               !!
!!     ppohAMRFDM is a free software, you can use it under the terms  !!
!!     of The MIT License (MIT). See LICENSE file and User's guide    !!
!!     for more details.                                              !!
!!                                                                    !!
!!   ppOpen-HPC project:                                              !!
!!     Open Source Infrastructure for Development and Execution of    !!
!!     Large-Scale Scientific Applications on Post-Peta-Scale         !!
!!     Supercomputers with Automatic Tuning (AT).                     !!
!!                                                                    !!
!!   Organizations:                                                   !!
!!     The University of Tokyo                                        !!
!!       - Information Technology Center                              !!
!!       - Atmosphere and Ocean Research Institute (AORI)             !!
!!       - Interfaculty Initiative in Information Studies/            !!
!!         Earthquake Research Institute (ERI)                        !!
!!       - Graduate School of Frontier Science                        !!
!!     Kyoto University                                               !!
!!       - Academic Center for Computing and Media Studies            !!
!!     Japan Agency for Marine-Earth Science and Technology (JAMSTEC) !!
!!                                                                    !!
!!   Sponsorship:                                                     !!
!!     Japan Science and Technology Agency (JST), Basic Research      !!
!!     Programs: CREST, Development of System Software Technologies   !!
!!     for Post-Peta Scale High Performance Computing.                !!
!!                                                                    !!
!!   Copyright (c) 2014 <Masaharu Matsumoto, The University of Tokyo  !!
!!                       matsumoto(at)cc.u-tokyo.ac.jp           >    !!
!!                                                                    !!
!!====================================================================!!

subroutine ppohAMRFDM_finalize
  use m_ppohAMRFDM_util
  implicit none
  integer(kind=ppohAMRFDM_kint)::ierr
  call mpi_finalize(ierr)
  return
end subroutine ppohAMRFDM_finalize