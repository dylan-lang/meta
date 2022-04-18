module: dylan-user

define library example
  use common-dylan;
  use io;
  use meta;
  use strings;
end library;

define module example
  use common-dylan;
  use streams;
  use format;
  use format-out;
  use meta;
  use standard-io;
  use strings;

  export parse-integer, parse-finger-query;
end module;
