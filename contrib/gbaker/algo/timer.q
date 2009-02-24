\l common/process.q
\l common/util.q

/----------------------------------------------------------------------------------------------------------------------
/ Connection management

connections: ()

.z.po: {
	connections,: x;
	}

.z.pc: {
	connections:: connections except x;
	delete from `at where who in x;
	delete from `recurring where who in x;
	}

/----------------------------------------------------------------------------------------------------------------------
/ Timer requests

identity: (
	[]
	who:	`int$		();
	id:		`symbol$	();
	name:	`symbol$	()
	)

at: update when: .z.T from identity;

recurring: update every: .z.T, clock: .z.T from identity;

/ Columns of x must be `id`name`when. Column `when must be a time.
.process.upd [`at]: {
	`at insert update who: .z.w, when: `time$ when from x;
	}

/ Columns of x must be `id`name.
.process.upd [`cancelat]: {
	upd [`CANCELAT; update who: .z.w from x];
	}

/ Columns of x must be `id`name`every. Column `every must be a time.
.process.upd [`recurring]: {
	`recurring insert update clock: every from update who: .z.w, every: `time$ every from x;
	}

/ Columns of x must be `id`name.
.process.upd [`cancelrecurring]: {
	{delete from `recurring where who = .z.w, id = x [`id], name = x [`name];} each x;
	}

/----------------------------------------------------------------------------------------------------------------------
/ Timing

.z.ts: {
	upd [`AT; select from at where when <= .z.T];
	update clock: clock - tick from `recurring;
	upd [`RECURRING; select from recurring where clock = 0];
	}

.process.upd [`AT]: {
	{[h; t] send [`at; h; t]} [; x] each exec distinct who from x;
	upd [`CANCELAT; select who, id, name from x]; 
	}

.process.upd [`RECURRING]: {
	{[h; t] send [`recurring; h; t]} [; x] each exec distinct who from x;
	update clock: every from `recurring where clock = 0;
	}

.process.upd [`CANCELAT]: {
	{delete from `at where who = x [`who], id = x [`id], name = x [`name];} each x;
	}

send: {[n; h; t]
	.util.printif @[neg h; (`upd; n; select id, name from t where who = h); "failed to write to ", string h];
	}

tick: `time$ system "t"

if [tick = 0; system "t 1000"; tick: 00:00:01.000]

/

General purpose timer process. The precision of the clock is governed by -t argument on the command line.

Users of the timer have to implement:
	.process.upd [`at]
	.process.upd [`recurring]
