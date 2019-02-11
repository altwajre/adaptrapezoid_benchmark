#include "adapt.h"


inline double foo (double x)
{
    return sin (x * x);
}


int main (int argc, char *argv[])
{
    const double tol=1e-10;
    const double PI = 3.14159265358979323846;
    const double precise_answer=0.527038339761566009286263102166809763899326865179511011538;
    double init_ticks[] = { 0.0, 1.0, 2.0, sqrt (8. * PI) };
    for (int i = 0; i < 1000; ++i)
        {
            double result=integrate (foo, init_ticks, sizeof (init_ticks) / sizeof (double), tol);
            assert(fabs(result-precise_answer)<tol);
            printf ("%.18f\n", result);
        }
    return 0;
}
