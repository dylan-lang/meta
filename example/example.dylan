module: example

define function digit? (x :: <character>) => (b :: <boolean>)
  member?(x, "0123456789");
end function digit?;

define constant $zero = as(<integer>, '0');

define function digit-to-integer (x :: <character>) => (d :: <integer>)
  as(<integer>, x) - $zero;
end function digit-to-integer;

define generic parse-integer (source :: type-union(<stream>, <sequence>)) => (i :: false-or(<integer>));

define method parse-integer (source :: <stream>) => (i :: false-or(<integer>))
  with-meta-syntax parse-stream (source)
    variables (d, sign = +1, num = 0);
    [{'+', ['-', set!(sign, -1)], []},
     test(digit?, d), set!(num, digit-to-integer(d)),
     loop([test(digit?, d), set!(num, digit-to-integer(d) + 10 * num)])];
    sign * num
  end;
end method;

define method parse-integer (source :: <sequence>) => (i :: false-or(<integer>))
  with-meta-syntax parse-string (source)
    variables (d, sign = +1, num = 0);
    [{'+', ['-', set!(sign, -1)], []},
     test(digit?, d), set!(num, digit-to-integer(d)),
     loop([test(digit?, d), set!(num, digit-to-integer(d) + 10 * num)])];
    sign * num
  end;
end method;

define function parse-finger-query (query :: <string>)
  with-collector into-buffer user like query, collect: collect;
    with-meta-syntax parse-string (query)
      variables (whois, at, c);
      [loop(' '), {[{"/W", "/w"}, yes!(whois)], []},        // Whois switch?
       loop(' '), loop({[{'\n', '\r'}, finish()],           // Newline? Quit.
                        {['@', yes!(at), do(collect('@'))], // @? Indirect.
                         [accept(c), do(collect(c))]}})];   // collect char
      values(whois, user(), at);
    end with-meta-syntax;
  end with-collector;
end function parse-finger-query;

define function test-peeking (query :: <string>)
  with-meta-syntax parse-string (query)
    variables (c, i = 0);
    loop([peeking(c, c >= 'a' & c <= 'z'), do(i := i + 1)]);
    i;
  end with-meta-syntax;
end function test-peeking;

define method main (appname, #rest arguments)
  // Parse integer from stream.
  format-out("Enter integer: ");
  force-out();
  let number = parse-integer(*standard-input*);
  format-out("Result: %=\n", number);

  read-line(*standard-input*); // parse-integer won't consume trailing garbage

  // Parse integer from string.
  format-out("Enter another integer: ");
  force-out();
  let string = read-line(*standard-input*);
  let number = parse-integer(string);
  format-out("Result: %=\n", number);

  format-out("Enter finger query: ");
  force-out();
  let (whois, user, at) = parse-finger-query(read-line(*standard-input*));
  format-out("Results: Whois Switch: %=, Indirect: %=, User: %=\n",
             whois, at, user);

  format-out("Enter [a-z]*: ");
  force-out();
  let i = test-peeking(read-line(*standard-input*));
  format-out("%= valid chars read.\n", i);
end method main;

main("example", 1,2,3);
