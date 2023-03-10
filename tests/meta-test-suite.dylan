Module: meta-test-suite

// This test suite is simply the original example code converted to a testworks
// suite; it could use a lot more love.

define function digit-to-integer
    (x :: <character>) => (d :: <integer>)
  as(<integer>, x) - as(<integer>, '0')
end function;

define generic meta-parse-integer (source) => (i :: false-or(<integer>));

define method meta-parse-integer
    (source :: <stream>) => (i :: false-or(<integer>))
  with-meta-syntax parse-stream (source)
    variables (d, sign = +1, num = 0);
    [{'+', ['-', set!(sign, -1)], []},
     test(decimal-digit?, d), set!(num, digit-to-integer(d)),
     loop([test(decimal-digit?, d), set!(num, digit-to-integer(d) + 10 * num)])];
    sign * num
  end;
end method;

define method meta-parse-integer
    (source :: <sequence>) => (i :: false-or(<integer>))
  with-meta-syntax parse-string (source)
    variables (d, sign = +1, num = 0);
    [{'+', ['-', set!(sign, -1)], []},
     test(decimal-digit?, d), set!(num, digit-to-integer(d)),
     loop([test(decimal-digit?, d), set!(num, digit-to-integer(d) + 10 * num)])];
    sign * num
  end;
end method;

define test test-meta-parse-integer ()
  assert-equal(123, meta-parse-integer("123"));
  assert-equal(123, meta-parse-integer(#('1', '2', '3')));
  // TODO: this fails with "unexpected end of stream" without the space at end.
  assert-equal(123, with-input-from-string(s = "123 ")
                      meta-parse-integer(s)
                    end);
end test;


define function parse-finger-query
    (query :: <string>)
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
end function;

define test test-parse-finger-query ()
  let (whois, user, at) = parse-finger-query("cgay@symbolics.com");
  assert-false(whois);
  assert-equal("cgay@symbolics.com", user);
  assert-equal(#t, at);
end test;


define function peeker
    (query :: <string>)
  with-meta-syntax parse-string (query)
    variables (c, i = 0);
    loop([peeking(c, c >= 'a' & c <= 'z'), do(i := i + 1)]);
    i;
  end with-meta-syntax;
end function;

define test test-peeking ()
  assert-equal(3, peeker("abc2"));
end test;


run-test-application()
