module: dylan-user

define library example
  use common-dylan;
  use io;
  use meta;
end library;

define module example
  use common-dylan;
  use streams;
  use format;
  use format-out;
  use standard-io;
  use meta;

  export parse-integer, parse-finger-query;
end module;
