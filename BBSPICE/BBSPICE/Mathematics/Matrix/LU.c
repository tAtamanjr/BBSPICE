//
//  LU.c
//  BBSPICE
//
//  Created by Oleksandr Bolbat on 05.03.2026.
//

#ifndef LU_H
#include "LU.h"


int LU_Decomposition(double *LU, const size_t size, size_t *permutation) {
    for (size_t row = 0; row < size; ++row) permutation[row] = row;
    
    for (size_t row = 0; row < size; ++row) {
        size_t p = row;
        double max = fabs(LU[row * size + row]);
        for (size_t column = row + 1; column < size; ++column) {
            const double cell = fabs(LU[column * size + row]);
            if (cell > max) {
                max = cell;
                p = column;
            }
        }
        
        if (max < EPS) return DIVISION_SINGULAR;
        
        if (p != row) {
            for (size_t column = 0; column < size; ++column) {
                double temp = LU[row * size + column];
                LU[row * size + column] = LU[p * size + column];
                LU[p * size + column] = temp;
            }
            size_t temp = permutation[row];
            permutation[row] = permutation[p];
            permutation[p] = temp;
        }
        
        for (size_t column = row + 1; column < size; ++column) {
            LU[column * size + row] /= LU[row * size + row];
            for (size_t i = row + 1; i < size; ++i) {
                LU[column * size + i] -= LU[column * size + row] * LU[row * size + i];
            }
        }
    }
    
    return DIVISION_SUCCES;
}

int LU_Solve(const double *LU, const size_t size, const size_t *permutation,
             const double *I, double *V, double *buffer) {
    
    for (size_t row = 0; row < size; ++row) buffer[row] = I[permutation[row]];
    
    for (size_t row = 0; row < size; ++row) {
        double sum = buffer[row];
        for (size_t column = 0; column < row; ++column) sum -= LU[row * size + column] * buffer[column];
        buffer[row] = sum;
    }
    
    for (ptrdiff_t ii = (ptrdiff_t) size - 1; ii >= 0; --ii) {
        size_t row = (size_t) ii;
        double sum = buffer[row];
        
        for (size_t column = row + 1; column < size; ++column) sum -= LU[row * size + column] * V[column];
        
        double uii = LU[row * size + row];
        if (fabs(uii) < EPS) return DIVISION_SINGULAR;
        
        V[row] = sum / uii;
    }
    
    return DIVISION_SUCCES;
}


#endif
