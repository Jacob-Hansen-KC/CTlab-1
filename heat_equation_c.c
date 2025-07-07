#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define IDX(i, j, N) ((i)*(N)+(j))

int main() {
    int s = 1;
    int P = s + 2;
    int Q = s + 2;
    int i, j, l, k = 0;
    double alpha = 0.000097;
    double dx = 0.01, dy = 0.01, dt = 0.25;
    double dx2 = 1.0/(dx*dx), dy2 = 1.0/(dy*dy);
    double *T1, *T2, *W;
    double bdry[4] = {500.0, 200.0, 300.0, 700.0};
    clock_t t_start, t_end;
    double total_time;

    // Allocate arrays
    T1 = (double*)malloc(P * Q * sizeof(double));
    T2 = (double*)malloc(P * Q * sizeof(double));
    W  = (double*)malloc(P * Q * sizeof(double));
    if (!T1 || !T2 || !W) {
        printf("Memory allocation failed\n");
        return 1;
    }

    // Initialize arrays
    for (i = 0; i < P*Q; ++i) {
        T2[i] = 273.15;
        T1[i] = 0.0;
        W[i]  = 0.0;
    }

    // Boundary conditions: left, bottom, right, top
    for (i = 0; i < P; ++i) {
        T2[IDX(i, 0, Q)]   = bdry[0];
        T2[IDX(i, Q-1, Q)] = bdry[2];
    }
    for (j = 0; j < Q; ++j) {
        T2[IDX(0, j, Q)]   = bdry[1];
        T2[IDX(P-1, j, Q)] = bdry[3];
    }

    t_start = clock();
    memcpy(T1, T2, P*Q*sizeof(double));
    for (l = 0; l < 5000; ++l) {
        for (i = 1; i < Q-1; ++i) {
            for (j = 1; j < P-1; ++j) {
                T2[IDX(i,j,Q)] = T1[IDX(i,j,Q)] +
                    alpha*dt * (
                        (T1[IDX(i+1,j,Q)] - 2.0*T1[IDX(i,j,Q)] + T1[IDX(i-1,j,Q)])*dx2 +
                        (T1[IDX(i,j+1,Q)] - 2.0*T1[IDX(i,j,Q)] + T1[IDX(i,j-1,Q)])*dy2
                    ) + W[IDX(i,j,Q)]*dt;
            }
        }
        k++;
        for (i = 1; i < Q-1; ++i) {
            for (j = 1; j < P-1; ++j) {
                T1[IDX(i,j,Q)] = T2[IDX(i,j,Q)] +
                    alpha*dt * (
                        (T2[IDX(i+1,j,Q)] - 2.0*T2[IDX(i,j,Q)] + T2[IDX(i-1,j,Q)])*dx2 +
                        (T2[IDX(i,j+1,Q)] - 2.0*T2[IDX(i,j,Q)] + T2[IDX(i,j-1,Q)])*dy2
                    ) + W[IDX(i,j,Q)]*dt;
            }
        }
        k++;
    }

    t_end = clock();
    total_time = (double)(t_end - t_start) / CLOCKS_PER_SEC;
    printf("Total time for 1 run: %f seconds\n", total_time);
    printf("Number of iterations: %d\n", k);

    // Uncomment to print the final temperature field
    // for (i = 0; i < P; ++i) {
    //     for (j = 0; j < Q; ++j) {
    //         printf("%10.2f ", T2[IDX(i,j,Q)]);
    //     }
    //    printf("\n");
    // }

    free(T1);
    free(T2);
    free(W);
    return 0;
}


//Windows
//gcc -O3 -std=c99 -march=native -mtune=native -g heat_equation_c.c -o heat_equation_c.exe
// .\heat_equation_c.exe

//Linux
//gcc -O3 -std=c99 -march=native -mtune=native -g heat_equation_c.c -o heat_equation_c.ELF
// ./heat_equation_c.ELF
// icx -O3 -march=native heat_equation_c.c -o heat_equation_c_I.ELF
// ./heat_equation_c_I.ELF