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


# parse_dns to return dns as records - hash
def parse_dns(dns_string)
    #remove empty lines
  dns_string = dns_string.map(&:strip).delete_if { |string| string.length == 0 }
    # removing first hash line
  dns_string=dns_string[1..-1]
  arr=Array.new(5) {Array.new(3) }
  input=[]
  for x in 0..4
  input=dns_string[x].strip.split(",")
    for y in 0..2
      arr[x][y]=input[y].strip
    end
  end
 dns_record= Hash[arr.map { |key,d1,d2| [d1,{:type=>key,:target=>d2}]}]
 end

# dns resolver
def resolve(dns_records,lookup_chain,domain_name)
  record=dns_records[domain_name]
  if !(record)
    lookup_chain=[]
    displayerror1 = "Error: record not found for "+ domain_name
    lookup_chain.push(displayerror1)
  elsif record[:type]=="A"
    lookup_chain.push(record[:target])
  elsif record[:type]=="CNAME"
    lookup_chain.push(record[:target])
    resolve(dns_records,lookup_chain,record[:target])
  else
    displayerror2 = "Invalid record type for " + domain_name
    lookup_chain.push(displayerror2)
  end
end


dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
