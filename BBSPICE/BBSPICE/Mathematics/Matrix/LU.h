//
//  LU.h
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 05.03.2026.
//

#ifndef LU_H
#define LU_H


#include <math.h>
#include <stddef.h>


#define EPS 1e-15


enum {
    DIVISION_SUCCES = 0,
    DIVISION_SINGULAR = 1
};


int LU_Decomposition(double *LU, const size_t size, size_t *permutation);

int LU_Solve(const double *LU, const size_t size, const size_t *permutation,
             const double *I, double *V, double *buffer);


#endif
