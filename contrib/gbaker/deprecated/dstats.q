\d .stats

/	FUNCTIONS
/	---------

/	Modal value of x.

mode: {h: count each group x; h ? max h}


/	Empirical probability distribution function, returning a dictionary of probability keyed
/	on bound. Probability of a given value x is given by indexing the dictionary with
/	[first k where (k: key pdf) > x].

pdf: {{(count y) % x}[count x] each group (((max x) - min x) % sqrt count x) xbar asc x}


/	Wald-Wolfowitz runs test on a boolean list.

runs: {
		n: count x;
		t: count where x;
		f: n - t;
		r: count where differ x;
		p: `float $ 2 * t * f;
		s: `float $ n;
		e: 1 + p % s;
		d: sqrt (p * p - s) % s * s * s - 1;
		`count`runs`expected`z ! (n; r; e; (r - e) % d)
	}

	
/	Standardise x with respect to the mean and standard deviation.

z: {(x - avg x) % dev x}

Z: {[x; m; s] (x - m) % s}

\d .