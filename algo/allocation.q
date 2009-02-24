
.allocation.multiple: 6

.allocation.low: 4


/ Allocate to the given upstream id's.

.process.upd [`ALLOCATIONS]: {
	t: `id xkey select
			id, totalqty: qty, nearqty: 0, nearleaves: 0, farqty: 0, farleaves: 0, unit: .allocation.multiple * size, low: .allocation.low * size
				from upstream where id in x `id;
	t: t upsert select id, nearqty: qty, nearleaves: leaves from .tactic.left [`near] x;
	t: t upsert select id, farqty: qty, farleaves: leaves from .tactic.left [`far] x;
	t: update unallocated: totalqty - (nearqty + farqty) from t;
	t: update odd: unallocated mod unit from t;
	upd [`FARALLOCATIONS; 0 ! select id, qty: odd from t where odd > 0];
	t: update unallocated: unallocated - odd from t;
	t: update canallocate: unallocated > 2 * unit from t;
	upd [`FARALLOCATIONS;	0 ! select id, qty: unallocated from t where not canallocate, unallocated > 0];
	upd [`FARALLOCATIONS;	0 ! select id, qty: unit from t where canallocate, farleaves <= low];
	upd [`NEARALLOCATIONS;	0 ! select id, qty: unit from t where canallocate, nearleaves <= low];
	upd [`REALLOCATIONS;	0 ! select id from t where not canallocate, unallocated = 0, farleaves = 0, nearleaves > 0];
	}

.process.upd [`FARALLOCATIONS]:		{.tactic.allocated [`far; x];}
.process.upd [`NEARALLOCATIONS]:	{.tactic.allocated [`near; x];}
.process.upd [`REALLOCATIONS]: 		{.tactic.cancel [`near; select id from x];}