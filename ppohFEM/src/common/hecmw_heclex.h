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




#ifndef HECMW_HECLEX_INCLUDED
#define HECMW_HECLEX_INCLUDED

#include <stdio.h>


enum {
	HECMW_HECLEX_NL	= 1000,
	HECMW_HECLEX_INT,
	HECMW_HECLEX_DOUBLE,
	HECMW_HECLEX_NAME,
	HECMW_HECLEX_FILENAME,
	HECMW_HECLEX_HEADER,

	HECMW_HECLEX_H_AMPLITUDE = 2000,
	HECMW_HECLEX_H_CONNECTIVITY,
	HECMW_HECLEX_H_CONTACT_PAIR,
	HECMW_HECLEX_H_ECOPY,
	HECMW_HECLEX_H_EGEN,
	HECMW_HECLEX_H_EGROUP,
	HECMW_HECLEX_H_ELEMENT,
	HECMW_HECLEX_H_END,
	HECMW_HECLEX_H_EQUATION,
	HECMW_HECLEX_H_HEADER,
	HECMW_HECLEX_H_INCLUDE,
	HECMW_HECLEX_H_INITIAL,
	HECMW_HECLEX_H_ITEM,
	HECMW_HECLEX_H_MATERIAL,
	HECMW_HECLEX_H_NCOPY,
	HECMW_HECLEX_H_NFILL,
	HECMW_HECLEX_H_NGEN,
	HECMW_HECLEX_H_NGROUP,
	HECMW_HECLEX_H_NODE,
	HECMW_HECLEX_H_SECTION,
	HECMW_HECLEX_H_SGROUP,
	HECMW_HECLEX_H_SYSTEM,
	HECMW_HECLEX_H_ZERO,

	HECMW_HECLEX_K_ABAQUS = 3000,
	HECMW_HECLEX_K_ABSOLUTE,
	HECMW_HECLEX_K_BEAM,
	HECMW_HECLEX_K_COMPOSITE,
	HECMW_HECLEX_K_DEFINITION,
	HECMW_HECLEX_K_EGRP,
	HECMW_HECLEX_K_GENERATE,
	HECMW_HECLEX_K_HECMW,
	HECMW_HECLEX_K_INPUT,
	HECMW_HECLEX_K_INTERFACE,
	HECMW_HECLEX_K_ITEM,
	HECMW_HECLEX_K_MATERIAL,
	HECMW_HECLEX_K_MATITEM,
	HECMW_HECLEX_K_NAME,
	HECMW_HECLEX_K_NASTRAN,
	HECMW_HECLEX_K_NGRP,
	HECMW_HECLEX_K_NODE_SURF,
	HECMW_HECLEX_K_RELATIVE,
	HECMW_HECLEX_K_SECOPT,
	HECMW_HECLEX_K_SECTION,
	HECMW_HECLEX_K_SGRP,
	HECMW_HECLEX_K_SHELL,
	HECMW_HECLEX_K_SOLID,
	HECMW_HECLEX_K_STEP_TIME,
	HECMW_HECLEX_K_SUBITEM,
	HECMW_HECLEX_K_SURF_SURF,
	HECMW_HECLEX_K_SYSTEM,
	HECMW_HECLEX_K_TABLE,
	HECMW_HECLEX_K_TABULAR,
	HECMW_HECLEX_K_TEMPERATURE,
	HECMW_HECLEX_K_TIME,
	HECMW_HECLEX_K_TYPE,
	HECMW_HECLEX_K_VALUE
};


extern double HECMW_heclex_get_number(void);


extern char *HECMW_heclex_get_text(void);


extern int HECMW_heclex_get_lineno(void);


extern int HECMW_heclex_next_token(void);


extern int HECMW_heclex_next_token_skip(int skip_token);


extern int HECMW_heclex_set_input(FILE *fp);


extern int HECMW_heclex_skip_line(void);


extern int HECMW_heclex_switch_to_include(const char *filename);


extern int HECMW_heclex_unput_token(void);


extern int HECMW_heclex_is_including(void);

#endif