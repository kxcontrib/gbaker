\d .maths

/	CONSTANTS
/	---------

e: exp 1

pi: 2 * asin 1

/	FUNCTIONS
/	---------

/	Hyperbolic functions
/	--------------------

sinh: {0.5 * (exp x) - exp neg x}

cosh: {0.5 * (exp x) + exp neg x}

tanh: {(e - 1) % (e: exp 2 * x) + 1}

/	Special functions
/	-----------------

/	The n'th Pochhammer symbol for x.

pochhammer: {[x; n] $[not n > 0; 1f; prd `float$ x + `float$ til `int$ n]}

/	Factorial x

factorial: {{pochhammer[1; x]} each x}

/	The Kummer function for z, over n terms. From MathWorld. Expression courtesy of arthur.

kummer: {[a; b; z; n] 1 + sum prds (z * a + n) % (1 + n) * b + n: til `int$ abs n}

/	Miscellaneous
/	-------------

/	Return the weight of each in the list.

w: {x % sum x}

\d .