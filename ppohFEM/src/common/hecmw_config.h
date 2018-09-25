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




#ifndef HECMW_CONFIG_INCLUED
#define HECMW_CONFIG_INCLUED

#ifdef HECMW_SERIAL

typedef int HECMW_Comm;

typedef int HECMW_Group;

typedef int HECMW_Request;

typedef int HECMW_Status;

typedef int HECMW_Datatype;

typedef int HECMW_Op;

typedef int HECMW_Fint;

#define HECMW_COMM_WORLD 0

#else
#include "mpi.h"

typedef MPI_Comm HECMW_Comm;

typedef MPI_Group HECMW_Group;

typedef MPI_Request HECMW_Request;

typedef MPI_Status HECMW_Status;

typedef MPI_Datatype HECMW_Datatype;

typedef MPI_Op HECMW_Op;

typedef MPI_Fint HECMW_Fint;

#define HECMW_COMM_WORLD MPI_COMM_WORLD

#endif


#define HECMW_INT    ((HECMW_Datatype)10001)

#define HECMW_DOUBLE ((HECMW_Datatype)10002)

#define HECMW_CHAR   ((HECMW_Datatype)10003)

#define HECMW_MIN ((HECMW_Op)20001)

#define HECMW_MAX ((HECMW_Op)20002)

#define HECMW_SUM ((HECMW_Op)20003)


#define HECMW_EXIT_SUCCESS 0

#define HECMW_EXIT_ERROR   1


#define HECMW_SUCCESS 0

#define HECMW_ERROR (-1)


#define HECMW_HEADER_LEN 127

#define HECMW_NAME_LEN 63

#define HECMW_FILENAME_LEN 1023

#define HECMW_MSG_LEN 255

#endif

