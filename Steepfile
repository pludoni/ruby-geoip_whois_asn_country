D = Steep::Diagnostic
target :lib do
  signature 'sig'

  check 'test/benchmark.rb'

  library 'singleton'
  library 'ipaddr'
  library 'socket'
  library 'objspace'
  library 'benchmark'

  configure_code_diagnostics(D::Ruby.strict)
end
