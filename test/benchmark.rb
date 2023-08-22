require "objspace"
require 'pry'
require "geoip_whois_asn_country"
require 'benchmark'

GeoipWhoisAsnCountry.configure do |config|
  config.cache_path = "./.geoip-cache"
  config.ipv4_num_csv_path = "./node_modules/@ip-location-db/geo-whois-asn-country/geo-whois-asn-country-ipv4-num.csv"
  config.ipv6_num_csv_path = "./node_modules/@ip-location-db/geo-whois-asn-country/geo-whois-asn-country-ipv6-num.csv"
end

class BenchmarkTest
  include GeoipWhoisAsnCountry
  def lookup(ip)
    GeoipWhoisAsnCountry.lookup(ip)
  end

  def benchmark_load
    File.unlink("./.geoip-cache") if File.exist?("./.geoip-cache")
    Singleton.__init__(GeoIpCountry)

    measure("First load") do
      lookup("1.2.3.4")
    end
  end

  def cached_load
    Singleton.__init__(GeoIpCountry)
    measure("Cached load") do
      lookup("1.2.3.4")
    end
  end

  def measure(title, &block)
    puts "Starting: #{title}"
    GC.start
    before = ObjectSpace.memsize_of_all
    bm = Benchmark.measure(&block)
    GC.start
    after = ObjectSpace.memsize_of_all
    total = (after - before) / 1024.0 / 1024.0
    puts " Took: #{bm}"
    puts " Residual Memory consumption: #{total} MB"
  end

  def test_function
    result = lookup("38.207.140.199")
    if ![:HK, :US].include?(result)
      raise "Fail: #{result}"
    end
    result = lookup("2a01:4f8:c2c:7c6d::1")
    if result != :DE
      raise "Fail: #{result}"
    end

    result = lookup("95.90.143.31")
    if result != :DE
      raise "Fail: #{result}"
    end
  end

  def test_benchmark
    ip_sample =
      GeoIpCountry.instance.instance_variable_get("@ipv4_sorted_keys").sample(5000).map { |ip| IPAddr.new(ip, Socket::AF_INET) } +
      GeoIpCountry.instance.instance_variable_get("@ipv6_sorted_keys").sample(5000).map { |ip| IPAddr.new(ip, Socket::AF_INET6) }

    measure("Lookup of 10,000 random Ips") do
      ip_sample.each do |ip|
        lookup(ip)
      end
    end
  end
end
bt = BenchmarkTest.new
bt.benchmark_load
bt.cached_load
bt.test_function
bt.test_benchmark
