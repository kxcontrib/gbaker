require "common/process.q"
require "common/util.q"
require "qx/schema.q"
require "qx/seq.q"
require "algo/filter.q"
require "algo/tactic.q"
require "algo/allocation.q"

/----------------------------------------------------------------------------------------------------------------------
/ Upstream
/ 2009.02.18 Added midprx benchmark; and minqty becomes size as minqty has a different meaning in FIX.

upstream: select by id from update rate: 0f, size: 0, maxtake: 0f, expire: .z.T from delete tif from delete from .schema.orders;

progress: (
	[id:		`upstream$	()]
	midprx:		`float$		();
	filled:		`int$		();
	avgprx:		`float$		();
	leaves:		`int$		();
	volume:		`int$		();
	vwap:		`float$		()
	)
	
inprogress:: update sym: id.sym, dir: id.dir, prx: id.prx from select from progress where leaves > 0

control: `id xkey select id, filled, volume from delete from progress;


.process.upd [`new]: {
	t: x [`sym] except exec sym from quotes;
	if [count t;
		`quotes insert h [`qx] (`snap; ([] sym: t))
	];
	upd [`NEW; delete from x where id in exec id from upstream];
	}

.process.upd [`NEW]: {
	x: update expire: `time$ expire from x;
	`upstream insert x;
	`progress insert select id, midprx: 0f, filled: 0, avgprx: 0f, leaves: qty, volume: 0, vwap: 0f from x;
	t: `sym xkey select id, id.sym from progress where id in x `id;
	t: update midprx: 0.5 * bidprx + askprx from t lj quotes;
	t: update midprx: bidprx from t where askprx = 0;
	t: update midprx: askprx from t where bidprx = 0;
	`progress upsert select id, midprx from t;
	`control insert select id, filled: 0, volume: 0 from x;
	.tactic.parameters [; x];
	upd [`ALLOCATIONS; select id from x];
	upd [`quotes; select from quotes where sym in x `sym];
	}

.process.upd [`amend]: {
	/ TODO
	}

.process.upd [`cancel]: {
	/ TODO
	}


/----------------------------------------------------------------------------------------------------------------------
/ Downstream

quotes: delete from .schema.quotes;

downstream: select by id from update link: `upstream$ `, tactic: `, cancelling: 0b from delete from .schema.orders;


.process.upd [`trades]: {
	upd [`TRADES; .filter.trades [x; 0 ! select from inprogress where sym in x `sym]];
	}

.process.upd [`TRADES]: {
	x: select q: sum qty, p: qty wavg prx by id from x;
	`progress upsert select id, volume: volume + q, vwap: vwapafter [volume; vwap; q; p] from x lj progress;
	`control upsert select id, volume: volume + q from x lj control;
	.tactic.traded [; `id xkey (`sym xkey update sym: id.sym from x lj control) lj quotes]
	}

.process.upd [`quotes]: {
	x: 0 ! select last bidqty, last bidprx, last askprx, last askqty by sym from x;
	`quotes upsert x;
	upd [`QUOTES; .filter.quotes [x; 0 ! select from inprogress where sym in x `sym]];
	}

.process.upd [`QUOTES]: {
	.tactic.quoted [; (`id xkey x) lj control];
	}

.process.upd [`fills]: {
	x: select q: sum qty, p: qty wavg prx by id from x;
	x: x lj downstream;
	`downstream upsert select id, qty: qty - q from x;
	delete from `downstream where qty = 0, not cancelling;
	delete from `downstream where id in exec id from x where tif = `IOC;
	t: x;
	x: .tactic.aggregate x;
	`progress upsert select id, filled: filled + q, leaves: leaves - q, avgprx: vwapafter [filled; avgprx; q; p] from x lj progress;
	`control upsert select id, filled: filled + q from x lj control;
	.tactic.filled [; t];
	upd [`ALLOCATIONS; select id from x];
	}

/ 2009.02.18 Cancels from qx

.process.upd [`cancels]: {
	.tactic.cancelled [; select from downstream where id in x `id];
	delete from `downstream where id in x `id;
	}

/ Send and cancel orders to qx. Columns for QXNEW must be `link`sym`dir`qty`prx`tif`tactic; for QXCANCEL just `id.

.process.upd [`QXNEW]: {
	x: update id: .seq.allocate count x, cancelling: 0b from x;
	`downstream insert x;
	.util.printif @[neg h `qx; (`upd; `new; delete link, tactic, cancelling from x); "failed to send orders"];
	}

.process.upd [`QXCANCEL]: {
	update cancelling: 1b from `downstream where id in x `id;
	.util.printif @[neg h `qx; (`upd; `cancel; x); "failed to send cancellations"];
	}


/----------------------------------------------------------------------------------------------------------------------
/ Alarms and benchmarks, added 2009.02.05

alarms: ([]
	time:		`time$		();
	id:			`symbol$	();
	who:		`symbol$	();
	what:		`symbol$	()
	)

.process.upd [`ALARMS]: {
	`alarms insert select time: .z.T, id, who, what from x;
	}

benchmarks:: select
				id,
				complete: 0 ^ filled % id.qty,
				id.rate,
				actualrate: 0 ^ filled % volume,
				avgprx2prx: relative [id.dir; avgprx; id.prx] % id.prx,
				avgprx2midprx: relative [id.dir; avgprx; midprx] % midprx,
				avgprx2vwap: relative [id.dir; avgprx; vwap] % vwap
					from progress lj control

/----------------------------------------------------------------------------------------------------------------------
/ Timer events, added 2009.02.25

.process.upd [`at]: {
	n: exec distinct name from x;
	{[t; x] .tactic.at [t; select id from x where name = t]} [; x] each n inter key .tactic.at;
	}

.process.upd [`recurring]: {
	n: exec distinct name from x;
	{[t; x] .tactic.recurring [t; select id from x where name = t]} [; x] each n inter key .tactic.recurring;
	}


/----------------------------------------------------------------------------------------------------------------------
/ Run

h: `qx`timer ! (0; 0)
args: .util.args ()
h [`qx]:	@[hopen; value args `qx; 0]
h [`timer]:	@[hopen; value args `timer; 0]
