The Meta Library
****************

Introduction
============

This is an implementation of Meta, a technique used to simplify the task
of writing parsers. `[Baker91] <#baker91>`__ describes Meta and shows
the main ideas for an implementation in Common Lisp.

    If all META did was recognize regular expressions, it would not be
    very useful. It is a programming language, however, and the
    operations [], {} and $ correspond to the Common Lisp control
    structures AND, OR, and DO.[8] Therefore, we can utilize META to not
    only parse, but also to transform. In this way, META is analogous to
    "attributed grammars" [Aho86], but it is an order of magnitude
    simpler and more efficient. Thus, with the addition of the "escape"
    operation "!", which allows us to incorporate arbitrary Lisp
    expressions into META, we can not only parse integers, but produce
    their integral value as a result. -- `[Baker91] <#baker91>`__

The macro defined here is an attempt to implement Meta (with slightly
adapted syntax) for Dylan. It is functional, but not yet optimized.

Exported facilities
===================

The ``meta``-library exports the ``meta`` module with the following
macros:

``meta-definer`` (or, more clearly, ``define meta `` *<foo>*)

Implements Meta and provides some additional functionality to define
variables. See `below <#syntax>`__.

``with-meta-syntax``

The guts of the ``meta-definer`` form; use when requiring precise
control of variables or constructs

``collect-definer``

General facility to collect data into sequences (by default, into
strings). Initially ``with-meta-syntax`` had this functionality
integrated--a mess. Now this is a more modular approach.

```with-collector`` <With-collector.html>`__

The guts of the ``collect-definer`` form.

Aside from the syntactic constructors exported above, the Meta library
also provides some commonly-used forms for scanning and parsing:

**scan-s**\ ()

Scans in at lease one space

**scan-word**\ (*word*)

Scans in a token and returns that token as a ``<string>`` instance. A
"word" is surrounded by spaces or any of the following characters: '<',
'>', '{', '}', '[', ']', punctuation (',', '?', or '!'), or the single-
or double- quotation-mark.

**scan-int**\ (*int*)

Reads in digit characters and returns an ``<integer>`` instance.

**scan-number**\ (*real*)

Although this is not an all-encompassing conversion utility (although,
IMHO, it's good enough to be part of the standard, once there is one,
YMMV), it reads in just about any fixed-point number format and returns
a ``<real>`` instance.

**string-to-number**\ (*str*, ``#key`` *base*) => (*ans*)

**Arguments:**

*str*, a ``<string>``, the string to convert to a number

*base*, an ``<integer>``, defaults to ``       10``, the base of the
number in the string.

**Values:**

*ans*, a ``<real>``, the resulting number.

Discussion:

This really should belong to the common-dylan spec, so that instead of
rolling their own, everyone should use this function. ... It is
therefore exported to this end.

Scanning tokens usually entails using some common character types. Meta
exports the following:

**$space** -- any whitespace

**$digit** ``[0-9]``

**$letter** ``[a-zA-Z]``

**$num-char** ``$digit ++ [.eE+]``

**$graphic-char** ``[_@#$%^&*()+=~/]``

**$any-char** ``$letter ++ $num-char ++ $graphic-char``

Meta Syntax
===========

Meta integrates the ability to parse from streams and strings in one
facility. (The parsing of lists is not implemented yet, because it's
rather useless in Dylan. This addition would be simple to do, though.)

.. code-block:: dylan

    define meta name (variables) => (results)
      meta body
    end

**Arguments:**

*name* -- the meta-function name, which is immediately transformed into
``scan-``\ *name*

*variables* -- token-holders used in *meta body*

*results* -- an expression returned on a successful scan

*meta body* -- a sequence of `anded Meta expressions <#and-expr>`__ to
scan

**Discussion:**

The ``meta-definer`` form works only with the ```parse-string``
*source-type* <#parse-string>`__ of the
`with-meta-syntax <#with-meta-syntax-definition>`__ form.

The user of this form has control over the return value. Usually ``#t``
is sufficient (in which case the results clause may be omitted, see
below); however, e.g., the values of the *variables* may need to be
manipulated during the parse phase.

**Example:**

.. code-block:: dylan

    define meta public-id(s, pub) => (pub)
      "PUBLIC", scan-s(s), scan-pubid-literal(pub)
    end meta public-id;

This definition returns ``pub`` when it successfully scans the tokens
"PUBLIC", (some) spaces, and a literal which ``pub`` receives. Note
that, hereafter, the meta definition is referred to as
``scan-public-id`` outside the meta syntax block .

--------------

.. code-block:: dylan

    define meta name (variables)
      meta body
    end

Same as the above form except that *results* is ``#t``

**Example** (from the meta library itself):

.. code-block:: dylan

    define meta s(c)
      element-of($space, c), loop(element-of($space, c))
    end meta s;

Scans in at least one space (``element-of`` and ``loop`` are discussed
in the section on `Meta expressions <#expressions>`__).

--------------

.. code-block:: dylan

    with-meta-syntax
    source-type (source #key keys)
      [ variables ]
      meta;
      body
    end


**Arguments:**

*source-type*---either ``       parse-stream`` or ``parse-string``

*source*---either a stream or a string, depending on *source-type*

*keys*---*source-type* specific.

*meta*---a `Meta expression <#expressions>`__.

*body*---a body. Evaluated only if parsing is successful.

**Values:**

If parsing fails ``#f``, otherwise the values of *body*.

**Keyword arguments:**

``parse-stream`` does not accept keyword arguments currently.

``parse-string`` recognizes the following keywords:

*start*---Index to start at

*end*---Index to finish before

*pos*---A name that will be bound to the current index during execution
of the ``with-meta-syntax`` forms.

**Special programming aids:**

``variables (variable [ :: type ] [ = init ], ...);``

Bind variables to *init*, which defaults to #f;

Future versions will have further special forms.

**Example fragments:**

.. code-block:: dylan

    with-meta-syntax parse-stream (*standard-input*)
      body
    end with-meta-syntax;

    let query :: <string> = ask-user();
    with-meta-syntax parse-string (query, start: 23, end: 42)
      body
    end with-meta-syntax;

    with-meta-syntax parse-string (query)
      ... ['\n', finish()] ...
      values(these, values, will, be, returned);
    end with-meta-syntax;


Meta expressions
================

Meta is a small, but featureful language, so naturally it has its own
syntax. This syntax is adapted to Dylan's way of writing things, of
course.

There are several basic Meta expressions implementing the core
functionality. Additionally there are some *pseudo-functions*,
syntactically function-like constructs which simplify certain tasks that
would otherwise have to be written manually.

Basic Meta expressions as described by Baker
--------------------------------------------

**Baker**

**``with-meta-syntax``**

**Description**

``fragment``

``fragment``

try to match this

``[a b c ... n]``

``[a, b, c, ..., n]``

and/try all

``{a b c ... n}``

``{a, b, c, ..., n}``

or/first hit

``@(type variable)``

``type(type, variable)``

| match any *type*, store result in *variable*
| **Warning:** *deprecated* ``type`` is most often used in seeing if a
character is one of several possibilities. Use ``element-of`` instead.

``$foo``

``loop(foo)     ``

zero or more

``!Lisp``

``(Dylan)``

call the code (and check result)

The same grammar which works for streams will works for strings. When
parsing strings, more than just one-character look-ahead is possible,
though. You can therefore not only match against characters, but also
whole substrings. This does not work when reading from a stream.

Additional pseudo-function expressions
--------------------------------------

+--------------------------------------+------------------------------------------------------------------------------------------------------------+-------------------------------------------------------+
| **``with-meta-syntax``**             | **Description**                                                                                            | **Could be written as**                               |
+--------------------------------------+------------------------------------------------------------------------------------------------------------+-------------------------------------------------------+
| ``do(Dylan)``                        | call the code and continue (whatever the result is)                                                        | ``(Dylan; #t)``                                       |
+--------------------------------------+------------------------------------------------------------------------------------------------------------+-------------------------------------------------------+
| ``finish()``                         | finish parsing successfully                                                                                | not possible                                          |
+--------------------------------------+------------------------------------------------------------------------------------------------------------+-------------------------------------------------------+
| ``test(predicate)``                  | Match against a predicate.                                                                                 | not possible                                          |
+--------------------------------------+------------------------------------------------------------------------------------------------------------+-------------------------------------------------------+
| ``test(predicate, variable)``        | Match against a predicate, saving the result.                                                              | not possible                                          |
+--------------------------------------+------------------------------------------------------------------------------------------------------------+-------------------------------------------------------+
| ``peeking(variable, test)``          | Save result first, so that expression test can use it.                                                     | not possible;                                         |
|                                      |                                                                                                            |  **Warning:** *deprecated, use*\ ``peek`` *instead*   |
+--------------------------------------+------------------------------------------------------------------------------------------------------------+-------------------------------------------------------+
| ``peek(variable, test)``             | Look one character ahead and store in *variable* if it passes *test*. Leave the character on the stream.   | not possible                                          |
+--------------------------------------+------------------------------------------------------------------------------------------------------------+-------------------------------------------------------+
| ``element-of(sequence, variable)``   | Sees if the *variable* (a character) is a member of the *sequence*, storing the result                     | { 'a', 'b', 'c' } (but not storing result)            |
+--------------------------------------+------------------------------------------------------------------------------------------------------------+-------------------------------------------------------+
| ``yes!(variable)``                   | Set *variable* to #t and continue.                                                                         | ``(variable := #t)``                                  |
+--------------------------------------+------------------------------------------------------------------------------------------------------------+-------------------------------------------------------+
| ``no!(variable)``                    | Set *variable* to #f and continue.                                                                         | ``(variable := #f; #t)``                              |
+--------------------------------------+------------------------------------------------------------------------------------------------------------+-------------------------------------------------------+
| ``set!(variable, value)``            | Set *variable* to *value* and continue.                                                                    | ``(variable := value; #t)``                           |
+--------------------------------------+------------------------------------------------------------------------------------------------------------+-------------------------------------------------------+
| ``accept(variable)``                 | Match anything and save result.                                                                            | ``type(<object>, variable)``                          |
+--------------------------------------+------------------------------------------------------------------------------------------------------------+-------------------------------------------------------+

Example code
============

Parsing an integer (base 10)
----------------------------

Common Lisp version:

.. code-block:: common-lisp

    (defun parse-integer (&aux (s +1) d (n 0))
      (and
       (matchit
        [{#\+ [#\- !(setq s -1)] []}
        @(digit d) !(setq n (digit-to-integer d))
        $[@(digit d) !(setq n (+ (* n 10) (digit-to-integer d)))]])
       (* s n)))


Direct translation to Dylan:

.. code-block:: dylan

    define constant <digit> = one-of('0','1','2','3','4','5','6','7','8','9');

    define function parse-integer (source :: <stream>);
      let s = +1; // sign
      let n = 0;  // number
      with-meta-syntax parse-stream (source)
        variables(d);
        [{'+', ['-', (s := -1)], []},
         type(<digit>, d), (n := digit-to-integer(d)),
         loop([type(<digit>, d), (n := digit-to-integer(d) + 10 * n)])];
        (s * n)
      end with-meta-syntax;
    end function parse-integer;


Alternative version:

.. code-block:: dylan

    // this will actually return a fn named 'scan-int', not 'parse-int'
    define collector int(i) => (as(<string>, str).string-to-integer)
      loop([element-of("+-0123456789", i), do(collect(i))])
    end collector int;


Parsing finger queries
----------------------

.. code-block:: dylan

    define function parse-finger-query (query :: <string>)
      with-collector into-buffer user like query (collect: collect)
        with-meta-syntax parse-string (query)
          variables (whois, at, c);
          [loop(' '), {[{"/W", "/w"}, yes!(whois)], []},        // Whois switch?
           loop(' '), loop({[{'\n', '\r'}, finish()],           // Newline? Quit.
                {['@', yes!(at), do(collect('@'))], // @? Indirect.
                 [accept(c), do(collect(c))]}})];   // then collect char
          values(whois, user(), at);
        end with-meta-syntax;
      end with-collector;
    end function parse-finger-query;


References
==========

`[Baker91] <lisp-meta.htm>`__ Baker, Henry. "Pragmatic Parsing in Common
Lisp". *ACM Lisp Pointers 4, 2* (Apr-Jun 1991), 3-15.
