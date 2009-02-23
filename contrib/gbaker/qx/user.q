\l common/util.q
\l qx/member.q
\l qx/seq.q
\l qx/player.q

template: enlist `sym`dir`qty`prx`tif ! (`AAA; `BUY; 1000; 0f; `IOC)

enter: {
	x: update id: .seq.allocate count x from x;
	.util.printif @[neg h; (`upd; `new; x); "failed to send order"];
	}

cancel: {
	.util.printif @[neg h; (`upd; `cancel; x); "failed to send cancellation"];
	}
	
h: @[hopen; 2009; 0]

/

Enter new orders derived from the template to qx. Cancel orders with specific id's.