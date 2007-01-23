\d .blackscholes

/	VARIABLES
/	---------

/	cdf is defined dynamically.


/	FUNCTIONS
/	---------

/	European call and put.

euro: {[s; k; v; r; t]
		d: terms [s; k; v; r; t];
		kt: k * exp neg r * t;
		`call`put ! ((s * cdf d 0) - kt * cdf d 1; (kt * cdf neg d 1) - s * cdf neg d 0)
	}

	
/	Binary call and put.

binary: {[s; k; v; r; t]
		d: terms [s; k; v; r; t];
		pv: exp neg r * t;
		`call`put ! (pv * cdf d 1; pv * cdf 1 - d 1)
	}


/	Calculate the terms for the cdf. If the variable cdf is undefined in
/	this context, it is defaulted to .gauss.cdf. The variable can be explicitly
/	set to any other distribution cdf function.

terms: {[s; k; v; r; t]
		if [not `cdf in key `.blackscholes; cdf:: .gauss.cdf;];
		vt: v * sqrt t;
		d: ((log s % k) + t * r + 0.5 * v * v) % vt;
		(d; d - vt)
	}

\d .
