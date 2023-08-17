# GeoipWhoisAsnCountry

Uses the node package "@ip-location-db/geo-whois-asn-country" to build a ruby structure for efficient lookup of IP -> country both for IPv4 and IPv6.


## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add geoip_whois_asn_country
yarn add @ip-location-db/geo-whois-asn-country
```


## Usage



```ruby
require 'geoip_whois_asn_country'

# First run will take a couple of seconds and build the ruby strucutre
# and cache it into tmp/cache/geoip-country-cache
country_code = GeoIpCountry.lookup('1.2.3.4')
=> :CN

country_code = GeoIpCountry.lookup('2001:db8::')
=> :FI


GeoipWhoisAsnCountry.configure do |config|
  config.cache_path = "tmp/cache/geoip-country-cache"
  config.ipv4_num_csv_path = "./node_modules/@ip-location-db/geo-whois-asn-country/geo-whois-asn-country-ipv4-num.csv"
  config.ipv6_num_csv_path = "./node_modules/@ip-location-db/geo-whois-asn-country/geo-whois-asn-country-ipv6-num.csv"
end
```


## Resource consumption

On a MacBook M2 I get the following results:

```bash
GeoIP-Whois-ASN-Country: first load + cache
 Took:   3.812936   0.039471   3.852407 (  3.852622)
 Residual Memory consumption: 17.94025993347168 MB
Starting: Cached load from Marshalled Data
 Took:   0.340433   0.040012   0.380445 (  0.380435)
 Residual Memory consumption: 17.76226043701172 MB
Starting: Lookup of 10,000 random Ips
 Took:   0.041649   0.000000   0.041649 (  0.041644)
 Residual Memory consumption: 0.00020599365234375 MB
```


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
