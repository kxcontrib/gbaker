lib
===
 

Organisation
------------

Closely related functions and variables are defined within q contexts. Each q context
is akin to an object in an OO language. Likewise, each context is defined in
its own file, with the convention that the name begins with 'd' to remind the reader
that the content starts with \d.

The import of dependent q contexts is NOT defined in the files. To do this I use
Simon Gardner's template:

	if [not @ [value; ".context.someboolean"; 0b]; value "\\l dcontext.q"]

The problem of where the library is located can be solved using an argument when starting
the q process. For example;

	s64/q -lib /path/to/library/

and then;
 
	args: .Q.opt .z.x;
	fullname: $ [count args `lib; first args `lib; ""], "dcontext.q";



Style
-----

A controversial subject. I recall that someone wrote on k4@listbox that Arthur says if k is
poetry then q is prose. I also know that code is often read under stress, in a variety of
fonts, by those who are not necessarily experts in the language, nor even proficient in
the application.

Consequently I prefer to write q as (English) prose:

	, ; : ::		have no leading space and a single trailing space
	
	( [				have one leading space and no trailing space
	
	) ]				have no leading space and one trailing space
	
	+ - * %	$ !		and other single character operators have a leading and trailing space
	

Warranties
----------

There are no warranties.



www.gbkr.com