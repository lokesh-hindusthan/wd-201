def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines

dns_raw = File.readlines("zone")

def parse_dns(dnsstring)
  # creating empty hash using {}
  inputrecords = {}
  # use "reject" with OR condition that can used to remove the empty lines of dnsstring || to remove first hash line of the input received form the user
  # To remove the empty line "dnsstring=dnsstring.reject { |s| s.strip.empty? }" this statement may be used.
  # To remove first line "dnsstring=dnsstring[1..-1]" this statement may be used.
  dnsstring.
    reject { |s| s.strip.empty? || s.include?("#") }.
    map { |s| s.strip.split(", ") }.
    reject do |dnsrecord|
  end.
    each_with_object({}) do |dnsrecord, inputrecords|
    inputrecords[dnsrecord[1]] = { type: dnsrecord[0], target: dnsrecord[2] }
  end
end

def resolve(dns_records, lookup_chain, domain_name)
  dnsrecord = dns_records[domain_name]
  # To check dnsrecord is valid domain name or error record
  if (!dnsrecord)
    lookup_chain=[]
    displayerror1 = "Error: record not found for "+ domain_name
    lookup_chain.push(displayerror1)
  elsif dnsrecord[:type] == "A"
    lookup_chain.push(dnsrecord[:target])
  elsif dnsrecord[:type] == "CNAME"
    lookup_chain.push(dnsrecord[:target])
    resolve(dns_records, lookup_chain, dnsrecord[:target])
  else
    displayerror2 = "Invalid record type for " + domain_name
    lookup_chain.push(displayerror2)
  end
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
