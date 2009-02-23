
controlfar: select by id from
				update qty: 0, minsize: 0, maxtake: 0f, pendingfill: 0b, level: 0, cancelling: 0b from
					select id, filled, leaves from
						delete from progress;


/----------------------------------------------------------------------------------------------------------------------
/ Tactic context

.tactic.parameters [`far]: {
	`controlfar insert
		select id, qty: 0, filled: 0, leaves: 0, minsize: 1, maxtake: 1f, pendingfill: 0b, level: 0, cancelling: 0b
			from x where not id in exec id from controlfar;
	c: cols x;
	if [`minsize in c; `controlfar upsert select id, minsize from x];
	if [`maxtake in c; `controlfar upsert select id, maxtake from x];
	}

.tactic.allocated [`far]: {
	upd [`ALARMS; select id, who: `far, what: `allocated from x];
	x: `id xkey select id, q: qty from x;
	`controlfar upsert .tactic.increase x lj controlfar;
	upd [`FARCOMPLETING; select id from x];
	}

.tactic.cancel [`far]: {
	upd [`ALARMS; select id, who: `far, what: `cancel from x];
	upd [`FARCANCELLING; select id from controlfar where not pendingfill, id in x `id];
	update cancelling: 1b from `controlfar where pendingfill, id in x `id;
	}

.tactic.filled [`far]: {
	upd [`FARFILLED; select from x where tactic = `far];
	}

.tactic.cancelled [`far]: {
	upd [`FARCANCELLED; select from x where tactic = `far];
	}

.tactic.traded [`far]: {
	upd [`FARSIGNAL; select from x where id in exec id from controlfar where leaves > 0, not pendingfill];
	}

.tactic.quoted [`far]: {
	upd [`FARSIGNAL; select from x where id in exec id from controlfar where leaves > 0, not pendingfill, level > 0];
	}

.tactic.left [`far]: {
	select id, qty, leaves, tactic: `far from controlfar where id in x `id
	}


/----------------------------------------------------------------------------------------------------------------------
/ Process context
/ 2009.02.18 new cancellation protocol.

.process.upd [`FARCANCELLING]: {
	update leaves: 0, qty: filled, cancelling: 0b from `controlfar where id in x `id;
	}

.process.upd [`FARFILLED]: {
	x: .tactic.aggregate x;
	`controlfar upsert .tactic.accounting x lj controlfar;
	update pendingfill: 0b from `controlfar where id in exec id from x;
	upd [`FARCAPACITY; select id from x];
	upd [`FARCANCELLING; select id from x lj controlfar where cancelling];
	}

.process.upd [`FARCANCELLED]: {
	upd [`ALARMS; select id: link, who: `far, what: `IOC from x];
	update pendingfill: 0b from `controlfar where id in exec link from x;
	upd [`FARCANCELLING; select id from controlfar where cancelling, id in x `link];
	}

.process.upd [`FARSIGNAL]: {
	x: select
			id,
			q: gross [(volume * id.rate) - filled; id.rate],
			farqty: far [id.dir; bidqty; askqty],
			farprx: far [id.dir; bidprx; askprx]
				from x;
	upd [`FARSUPPRESS; select from x where q > 0];
	}

.process.upd [`FARSUPPRESS]: {
	x: (`id xkey x) lj controlfar;
	upd [`ALARMS; select id, who: `far, what: `suppress from x where level > 0, farqty < level];
	upd [`FARDECISION; select from x where farqty >= level];
	update level: `int$ 0.5 * level from `controlfar where (id in exec id from x), level > 0;
	}

.process.upd [`FARDECISION]: {
	upd [`ALARMS; select id, who: `far, what: `leaves from x where leaves < q];
	x: update q: q & leaves, m: `int$ maxtake * farqty from x;
	`controlfar upsert select id, level: ?[(m < q) and (minsize > 1); farqty; 0] from x;
	upd [`ALARMS; select id, who: `far, what: `maxtake from x where m < q];
	x : update q: m from x where m < q;
	upd [`FARACTION; select from x where q >= minsize];
	}

.process.upd [`FARACTION]: {
	`controlfar upsert select id, pendingfill: 1b from x;
	upd [`QXNEW; select id.sym, id.dir, qty: q, prx: farprx, link: id, tif: `IOC, tactic: `far from x];
	}

.process.upd [`FARCAPACITY]: {
	t: select id, minsize: 1, maxtake: 1f, level: 0 from controlfar where id in x [`id], minsize > 1, minsize >= leaves;
	upd [`ALARMS; select id, who: `far, what: `low from t];
	`controlfar upsert t;
	}

