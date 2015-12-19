Meta Library: Collecting data into sequences
********************************************

The `Meta library <Meta.html>`__ makes it easy to write parsers in
Dylan. It includes a macro called ``with-collector`` which additionally
allows to collect data into a sequence. This is similar in spirit to
Common Lisp's ``LOOP`` clauses ``COLLECT`` and ``APPEND``, but more
flexible. If you want to extract subsequences from a string while
parsing it, this is the tool to use.

#. `Overview <#overview>`__
#. `Collecting ``into-list`` or ``into-vector`` <#into>`__
#. `Writing into an existing vector <#vector>`__
#. `Using buffers <#buffers>`__
#. `A minimal collection form <#minimal>`__
#. `Example code <#example>`__

1. Overview
===========

Like ``COLLECT``, ``with-collector`` can put objects into a list. Unlike
``COLLECT``, it can also create vectors or write into already created
vectors.

The basic syntax for all of these cases is:

::

    with-collector operation ... #key collect, append;
      body
    end


**Arguments:**

*operation*---specifies the mode of operation. see below.

*collect*---a name for a function that, called with a parameter, inserts
this parameter into the sequence.

*append*---a name for a function that, called with a sequence, appends
this parameter to the sequence.

*body*---a body.

**Values:**

Normally the values of *body*. There is `minimal form <#minimal>`__ of
``with-collector``, which always returns the collected sequence.

2. Collecting ``into-list`` or ``into-vector``
==============================================

Two simple forms of ``with-collector`` are ``into-list`` and
``into-vector``. They create a list or a vector and write into it. The
sequence is available as a variable with a user-defined name:

::

    with-collector into-list name #key collect, append;
      body
    end

    with-collector into-vector name #key collect, append;
      body
    end


3. Writing into an existing vector
==================================

``into-vector``, by default, creates a <stretchy-sequence>. If you don't
like this behaviour, you can specify a different vector that will be
used. For instance, if you already know how long the result will be, you
might want to create a string in the first place.

::

    with-collector into-vector name = init, #key collect, append;
      body
    end


4. Using buffers
================

Normally it is not known in advance how long the result will be. What is
really needed is a sequence that automatically reduces its size after
processing is finished. ``into-buffer`` implements this by returning a
subsequence of the original vector.

Instead of a variable holding the sequence there is now a function which
creates the subsequence.

::

    with-collector into-buffer function-name, #key collect, append;
      body
    end


But how do you find out what the maximum buffer size has to be? A safe
guess is the length of the original vector you are extracting elements
from. The following construct automatically creates a vector of the same
class (well, ``type-for-copy``) and size as *big-one*:

::

    with-collector into-buffer function-name like big-one, #key collect, append;
      body
    end


5. A minimal collection form
============================

If you don't need to write into vectors or use buffers, but just want to
collect some stuff and return it, use this idiom:

::

    with-collector {into-list|into-vector}, #key collect, append;
      body
      // Note: Values of body will be thrown away.
    end


6. Example code
===============

::

    define function parse-finger-query (query :: <string>)
      with-collector into-buffer user like query, collect: collect;
        with-meta-syntax parse-string (query)
          let (whois, at, c);
          [loop(' '), {[{"/W", "/w"}, yes!(whois)], []},        // Whois switch?
           loop(' '), loop({[{'\n', '\r'}, finish()],           // Newline? Quit.
                {['@', yes!(at), do(collect('@'))], // @? Indirect.
                 [type(<character>, c),             // Else:
                  do(collect(c))]}})];              //   Collect char
          values(whois, user(), at);
        end with-meta-syntax;
      end with-collector;
    end function parse-finger-query;
