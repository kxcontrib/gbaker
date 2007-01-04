\d .stats

/	FUNCTIONS
/	---------

/	Standardise x with respect to the mean and standard deviation.

z: {(x - avg x) % dev x}

Z: {[x; m; s] (x - m) % s}

/	Empirical probability distribution function, returning a dictionary of probability keyed on bound.
/	Probability of a given value x is given by indexing the dictionary with [first k where (k: key pdf) > x].

pdf: {{(count y) % x}[count x] each group (((max x) - min x) % sqrt count x) xbar asc x}

\d .