\d .cauchy

/	FUNCTIONS
/	---------

/	Probability density function for x.

pdf: {reciprocal .maths.pi * 1 + x * x}

/	Cumulative distribution function for x.

cdf: {0.5 + (atan x) % .maths.pi}

\d .