
controlnear: select by id from
				update qty: 0, prx: 0f, low: 0b, cancelling: 0b from
					select id, filled, leaves from
						delete from progress;

nearside:: select sum qty by link, prx from downstream where tactic = `near

/----------------------------------------------------------------------------------------------------------------------
/ Tactic context

.tactic.parameters [`near]: {
	`controlnear insert select id, qty: 0, filled: 0, leaves: 0, prx: 0f, low: 0b, cancelling: 0b
		from x where not id in exec id from controlnear;
	}

.tactic.allocated [`near]: {
	upd [`ALARMS; select id, who: `near, what: `allocated from x];
	x: `id xkey select id, q: qty from x;
	`controlnear upsert .tactic.increase x lj controlnear;
	update low: 0b from `controlnear where id in exec id from x;
	upd [`NEARCAPACITY; select id from x];
	}

.tactic.cancel [`near]: {
	upd [`NEARCANCEL; select id from controlnear where id in x [`id], not cancelling];
	}

.tactic.filled [`near]: {
	upd [`NEARFILLED; select from x where tactic = `near];
	}

.tactic.cancelled [`near]: {
	upd [`NEARCANCELLED; select from x where tactic = `near];
	}

.tactic.quoted [`near]: {
	upd [`NEARSIGNAL; select from x where id in exec id from controlnear where not cancelling, (leaves > 0) or (id in exec link from nearside)];
	}

.tactic.left [`near]: {
	select id, qty, leaves, tactic: `near from controlnear where id in x `id
	}


/----------------------------------------------------------------------------------------------------------------------
/ Process context

.process.upd [`NEARCANCEL]: {
	upd [`ALARMS; select id, who: `near, what: `cancel from x];
	upd [`NEARCANCELACTION; select id, link from downstream where link in x [`id], tactic = `near, not cancelling];
	}

.process.upd [`NEARCANCELACTION]: {
	update cancelling: 1b from `controlnear where id in x `link;
	upd [`QXCANCEL; select id from x];
	}

.process.upd [`NEARCANCELLED]: {
	upd [`NEARCANCELLING; select id from controlnear where cancelling, id in exec link from x];
	}

.process.upd [`NEARCANCELLING]: {
	update leaves: 0, qty: filled, prx: 0f, cancelling: 0b from `controlnear where id in x `id;
	upd [`ALLOCATIONS; select id from x];
	}

.process.upd [`NEARFILLED]: {
	x: .tactic.aggregate x;
	`controlnear upsert .tactic.accounting x lj controlnear;
	update prx: 0f from `controlnear where not id in exec link from nearside;
	upd [`NEARCAPACITY; select id from x];
	}

.process.upd [`NEARSIGNAL]: {
	x: select
			id,
			nearqty: near [id.dir; bidqty; askqty],
			nearprx: near [id.dir; bidprx; askprx]
				from x;
	upd [`NEARDECISION; select from x where nearprx > 0, nearqty > 0];
	}

.process.upd [`NEARDECISION]: {
	x: (`id xkey x) lj controlnear;
	upd [`QXCANCEL; select id from downstream where tactic = `near, not cancelling, link in exec id from x where prx > 0, not prx = nearprx];
	x: (`id`prx xkey x) lj `id`prx`ownqty xcol select from nearside where link in exec id from x;
	x: update ownqty: 0 from x where null ownqty;
	upd [`NEARREGULARDECISION; select from x where not low];
	upd [`NEARLOWDECISION; select from x where low];
	}

.process.upd [`NEARREGULARDECISION]: {
	x: update q: gross [id.rate * nearqty - ownqty; id.rate] - ownqty from x;
	x: update q: q & leaves - ownqty from x;
	upd [`NEARACTION; select from x where q >= id.size];
	}

.process.upd [`NEARLOWDECISION]: {
	x: update q: leaves - ownqty from x;
	upd [`NEARACTION; select from x where q > 0];
	}

.process.upd [`NEARACTION]: {
	`controlnear upsert select id, prx: nearprx from x;
	upd [`QXNEW; select id.sym, id.dir, qty: q, prx: nearprx, link: id, tif: `DAY, tactic: `near from x];
	}

.process.upd [`NEARCAPACITY]: {
	t: select id, low: 1b from controlnear where id in x [`id], not low, id.size >= leaves;
	upd [`ALARMS; select id, who: `near, what: `low from t];
	`controlnear upsert t;
	}
