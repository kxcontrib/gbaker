\d .gauss

/	FUNCTIONS
/	---------

/	Probability density function for x.

pdf: {(reciprocal sqrt 2 * .maths.pi) * exp neg 0.5 * x * x}


/	Cumulative distribution function for x.

cdf: {{$[x < 0; 1 - cdf abs x; 0.5 * 1 + erf x % sqrt 2]} each x}


/	The Gaussian error function. From Mathworld, Erf.html. The iterations for the Kummer function
/	are based on a difference of 5e-14 between .maths.e and .maths.kummer [1; 1; 1; 15].

erf: {{$[x = 0; 0f; x < 0; neg abserf abs x; abserf x ]} each x}

abserf: {x: abs x; min (1; (2 * x % sqrt .maths.pi) * .maths.kummer [0.5; 1.5; neg x * x; 15])}


/	Random sample of x items from the standardised Gaussian distribution.

random: {x: max (1; `int $ x); r: (); do[x; r,: (sum 12 ? 1f) - 6]; $[x = 1; first r; r]}

\d .