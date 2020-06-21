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

subroutine ppohAMRFDM_refine(tLv,st_param,st_meshset,st_comm_info)
  use m_ppohAMRFDM_util
  implicit none
  integer(kind=ppohAMRFDM_kint),intent(in)::tLv
  type(st_ppohAMRFDM_param)::st_param
  type(st_ppohAMRFDM_meshset)::st_meshset
  type(st_ppohAMRFDM_comm_info)::st_comm_info
  integer(kind=ppohAMRFDM_kint)::iLv,ID
  if(tLv/=st_param%LvMax) return
  st_meshset%rfncnt=st_meshset%rfncnt+1
  if(st_meshset%rfncnt==2) then
     st_meshset%rfncnt=0
     return
  endif
  do iLv=st_param%LvMax-1,0,-1
     call ppohAMRFDM_average(iLv,st_param%nfg+1,st_param%nfg+st_param%nlv,st_param,st_meshset)
  enddo
  do iLv=0,st_param%LvMax-1
     call ppohAMRFDM_setflag(iLv,st_param,st_meshset,st_comm_info)
     call ppohAMRFDM_addRoct(iLv,st_param,st_meshset,st_comm_info)
     call ppohAMRFDM_addGoct(iLv,st_param,st_meshset,st_comm_info)
     call ppohAMRFDM_connect_oct(iLv,st_param,st_meshset)
  enddo
  call ppohAMRFDM_setflag(st_param%LvMax,st_param,st_meshset,st_comm_info)
  do iLv=0,st_param%LvMax-1
     do ID=st_param%nfg,st_param%nfg+st_param%nlv-1
        call ppohAMRFDM_set_buffer_ave(iLv,ID,ID+1,st_meshset)
     enddo
     call ppohAMRFDM_passing_iFLG(iLv,st_param,st_meshset,st_comm_info)
  enddo
  call ppohAMRFDM_sortoct(st_param,st_meshset,st_comm_info)
  call ppohAMRFDM_get_ID_order(st_param,st_meshset)
  return
end subroutine ppohAMRFDM_refine
