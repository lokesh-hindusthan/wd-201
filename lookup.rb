def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the  script from the command line.
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

def parse_dns(rawinput)
  knownrecords = {}
  rawinput.
    reject { |line| line.strip.empty? || line.include?("#") }.
    map { |line| line.strip.split(", ") }.
    reject do |resolverecord|
  end.
    each_with_object({}) do |resolverecord, knownrecords|
     knownrecords[resolverecord[1]] = { type: resolverecord[0], target: resolverecord[2] }
  end
end

def resolve(dns_records, lookup_chain, domain_name)
  resolverecord = dns_records[domain_name]
  if resolverecord[:type] == "CNAME"
    lookup_chain <<  resolverecord[:target]
    resolve(dns_records, lookup_chain,  resolverecord[:target])
  elsif  resolverecord[:type] == "A"
    lookup_chain <<  resolverecord[:target]
  elsif (! resolverecord)
    lookup_chain << "Error: Record not found for " + domain_name
  else
    lookup_chain << "Invalid record type for " + domain_name
  end
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
