\l qx/global.q

\d .filter

/ Replicate trades labelled with order id where the trades are within limit.
/ Trades t must have column `sym`prx.
/ Orders o must have columns `id`sym`dir`prx

trades: {[t; o]
	raze {[t; o]
		t: select from t where sym = o `sym;
		t: update id: o `id, dir: o `dir, limit: o `prx from t;
		t: select from t where withinlimit [dir; prx; limit];
		delete dir, limit from t
	}[t; ] each select from o where sym in t `sym
	}


/ Replicate quotes labelled with order id where the quotes are within limit on the near side.
/ Quotes q must have columns `sym`bidprx`askprx
/ Orders o must have columns `id`sym`dir`prx

quotes: {[q; o]
	raze {[q; o]
		q: select from q where sym = o `sym;
		q: update id: o `id, dir: o `dir, limit: o `prx from q;
		q: select from q where withinlimit [dir; near [dir; bidprx; askprx]; limit];
		delete dir, limit from q
	}[q; ] each select from o where sym in q `sym
	}


\d .
