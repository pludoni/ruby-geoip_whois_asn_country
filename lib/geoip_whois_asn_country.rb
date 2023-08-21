# frozen_string_literal: true

require_relative "geoip_whois_asn_country/version"
require 'singleton'

module GeoipWhoisAsnCountry
  def self.lookup(ip_address)
    GeoIpCountry._lookup(ip_address)
  end

  def self.configure(&block)
    block.call(GeoIpCountry)
    Singleton.__init__(GeoIpCountry)
    nil
  end

  class GeoIpCountry
    include Singleton

    class << self
      attr_accessor :ipv4_num_csv_path, :ipv6_num_csv_path, :cache_path
    end
    self.ipv4_num_csv_path = "./node_modules/@ip-location-db/geo-whois-asn-country/geo-whois-asn-country-ipv4-num.csv"
    self.ipv6_num_csv_path = "./node_modules/@ip-location-db/geo-whois-asn-country/geo-whois-asn-country-ipv6-num.csv"
    self.cache_path = "tmp/cache/geoip-country-cache"
    self.cache_time = 60 * 60 * 24

    def self._lookup(ip)
      if !@singleton__instance__ || @singleton__instance__.instance_variables.length == 0
        if File.exist?(cache_path) && File.mtime(cache_path) > Time.now - cache_time
          @singleton__instance__ = load_from_cache
        else
          # puts "GeoIP-Whois-ASN-Country: first load + cache"
          instance.load_csvs
          cache!
        end
      end
      instance._lookup(ip)
    end

    def _dump(depth)
      Marshal.dump({
        ipv4_map: @ipv4_map,
        ipv4_sorted_keys: @ipv4_sorted_keys,
        ipv6_map: @ipv6_map,
        ipv6_sorted_keys: @ipv6_sorted_keys,
      }, depth)
    end

    def self._load(map_str)
      map = Marshal.load(map_str)
      instance.instance_variable_set(:@ipv4_map, map[:ipv4_map])
      instance.instance_variable_set(:@ipv4_sorted_keys, map[:ipv4_sorted_keys])
      instance.instance_variable_set(:@ipv6_map, map[:ipv6_map])
      instance.instance_variable_set(:@ipv6_sorted_keys, map[:ipv6_sorted_keys])
      instance
    end

    def self.cache!
      File.open(cache_path, "wb+") { |f| f.write Marshal.dump(instance) }
    end

    def self.load_from_cache
      Marshal.load(File.read(cache_path))
    end

    def load_csvs
      require 'csv'
      @ipv4_map = {}
      File.open(self.class.ipv4_num_csv_path) do |file|
        CSV.foreach(file, headers: false) do |row|
          from, _, country = row
          @ipv4_map[from.to_i] = country.to_sym
        end
      end
      @ipv4_sorted_keys = @ipv4_map.keys.sort.freeze

      @ipv6_map = {}
      File.open(self.class.ipv6_num_csv_path) do |file|
        CSV.foreach(file, headers: false) do |row|
          from, _, country = row
          @ipv6_map[from.to_i] = country.to_sym
        end
      end
      @ipv6_sorted_keys = @ipv6_map.keys.sort.freeze
      nil
    end

    def _lookup(ip)
      ip = IPAddr.new(ip) if ip.is_a?(String)
      ip_i = ip.to_i
      if ip.ipv4?
        @ipv4_map[@ipv4_sorted_keys.bsearch { |x| x >= ip_i }]
      else
        @ipv6_map[@ipv6_sorted_keys.bsearch { |x| x >= ip_i }]
      end
    end
  end
end
