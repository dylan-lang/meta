meta
====

Copyright (c) 1999 David Lichteblau <lichtebl@math.fu-berlin.de>

This is an implementation of Meta, a technique used to simplify the task
of writing parsers.  `Baker`_ describes Meta and shows the main ideas for
an implementation in Common Lisp::

	  If all META did was recognize regular expressions, it would
	  not be very useful. It is a programming language, however,
	  and the operations [], {} and $ correspond to the Common
	  Lisp control structures AND, OR, and DO.[8] Therefore, we
	  can utilize META to not only parse, but also to
	  transform. In this way, META is analogous to "attributed
	  grammars" [Aho86], but it is an order of magnitude simpler
	  and more efficient. Thus, with the addition of the "escape"
	  operation "!", which allows us to incorporate arbitrary Lisp
	  expressions into META, we can not only parse integers, but
	  produce their integral value as a result.  [Baker]

The macro defined here is an attempt to implement Meta (with slightly
adapted syntax) for Dylan.  It is functional, but not yet optimized.

.. _Baker: http://www.pipeline.com/~hbaker1/Prag-Parse.html
