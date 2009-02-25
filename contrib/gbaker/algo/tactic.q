\d .tactic

/ Set parameters.
/ Columns of x must contain `id and may contain `minqty and/or `maxtake.

parameters:	() ! ()

/ Allocate quantity to the tactic.
/ Columns of x must be `id`qty.

allocated:	() ! ()

/ Cancel the tactic.
/ Columns of x must be `id.

cancel:		() ! ()

/ Notify actionable trades.
/ Columns of x are those of control, quotes plus `q`p from the trades.
/ x keyed on `id.

traded:		() ! ()

/ Notify actionable quotes.
/ Columns of x are those of control plus quotes.
/ x keyed on `id.

quoted:		() ! ()

/ Notify fills, after fills have been applied to progress.
/ Columns of x are those of downstream plus `q`p from the fill.
/ x keyed on `id.

filled:		() ! ()

/ Notify downstream cancellations, before the orders are removed from the downstream table.
/ Columns of x are those of downstream.
/ x keyed on `id.

cancelled:	() ! ()

/ Return a table of `id`qty`leaves`tactic for the id's in x.

left:		() ! ()

/ 2009.02.25 Integrated timer events

/ Notify a time event.
/ Columns of x are `id.

at:			() ! ()

/ Notify a recurring time event.
/ Columns of x are `id.

recurring:	() ! ()



/ Convenience functions to increase order quantity, aggregate fills and account for fills.

increase:	{select id, qty: qty + q, leaves: leaves + q from x}

aggregate:	{`id`q`p xcol select sum q, q wavg p by link from x}

accounting:	{select id, filled: filled + q, leaves: leaves - q from x}

\d .
