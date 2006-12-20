\d .gauss

/	FUNCTIONS
/	---------


/	Probability density function for x.

pdf : { (reciprocal sqrt 2 * .maths.pi) * exp neg 0.5 * x * x }


/	Cumulative distribution function for x.

cdf : { { $[ x < 0; 1 - cdf abs x; 0.5 * 1 + erf x % sqrt 2 ] } each x }


/	The Gaussian error function. From Mathworld, Erf.html. The iterations for the Kummer function
/	are based on a difference of 5e-14 between exp 1 and kummer[1;1;1;15].

erf    : { { $[ x = 0; 0f; x < 0; neg abserf abs x; abserf x ] } each x }

abserf : { x : abs x; min ( 1; (2 * x % sqrt .maths.pi) * .maths.kummer[0.5; 1.5; neg x * x; 15] ) }


/	Random sample on x items from the standardised Gaussian distribution.

random : { r:(); do[ 1 | `int$ x; r,:(sum 12 ? 1f) - 6 ]; r }

\d .