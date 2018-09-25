/*=====================================================================*
 *                                                                     *
 *   Software Name : ppohFEM                                           *
 *         Version : 1.0                                               *
 *                                                                     *
 *   License                                                           *
 *     This file is part of ppohFEM.                                   *
 *     ppohFEM is a free software, you can use it under the terms      *
 *     of The MIT License (MIT). See LICENSE file and User's guide     *
 *     for more details.                                               *
 *                                                                     *
 *   ppOpen-HPC project:                                               *
 *     Open Source Infrastructure for Development and Execution of     *
 *     Large-Scale Scientific Applications on Post-Peta-Scale          *
 *     Supercomputers with Automatic Tuning (AT).                      *
 *                                                                     *
 *   Organizations:                                                    *
 *     The University of Tokyo                                         *
 *       - Information Technology Center                               *
 *       - Atmosphere and Ocean Research Institute (AORI)              *
 *       - Interfaculty Initiative in Information Studies              *
 *         /Earthquake Research Institute (ERI)                        *
 *       - Graduate School of Frontier Science                         *
 *     Kyoto University                                                *
 *       - Academic Center for Computing and Media Studies             *
 *     Japan Agency for Marine-Earth Science and Technology (JAMSTEC)  *
 *                                                                     *
 *   Sponsorship:                                                      *
 *     Japan Science and Technology Agency (JST), Basic Research       *
 *     Programs: CREST, Development of System Software Technologies    *
 *     for post-Peta Scale High Performance Computing.                 *
 *                                                                     *
 *   Copyright (c) 2015 The University of Tokyo                        *
 *                       - Graduate School of Frontier Science         *
 *                                                                     *
 *=====================================================================*/

#ifndef HECMW_VIS_TETRA_INTERSECT_H_INCLUDED
#define HECMW_VIS_TETRA_INTERSECT_H_INCLUDED

#include "hecmw_struct.h"
#include "hecmw_result.h"
#include "hecmw_vis_SF_geom.h"

extern int get_tetra_data(Surface *sff, struct hecmwST_local_mesh *mesh, struct hecmwST_result_data *data,
		int elemID, Tetra *tetra, int tn_component);
extern void find_intersection_tetra(Tetra *tetra, double isovalue, Tetra_point *tetra_point, Head_patch_tetra *head_patch_tetra,
		Hash_vertex *vertex_hash_table);

#endif /* HECMW_VIS_TETRA_INTERSECT_H_INCLUDED */






