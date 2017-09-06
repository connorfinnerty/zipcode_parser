require 'json'
require 'pry'
require 'net/http'
require 'stringio'

@buffer = nil
@state_name = nil

def zipcode_dump
  @zipcode_dump ||= fetch_and_parse_zipcode_dump
  # For faster testing, we can use previously downloaded data:
  # @zipcode_dump ||= JSON.parse(File.read("zips.json"))
end

# Helper method for printing and then returning
def print_and_return(result)
  puts result
  result
end

def state_population_above_ten_million
  population = @zipcode_dump.group_by { |zipcode| zipcode["state"] }.map do |state_name, zipcodes|
    {
      "_id" => state_name,
      "totalPop" => zipcodes.map { |zipcode| zipcode["pop"] }.reduce(:+)
    }
  end

  above_ten_million = population.select { |state| state["totalPop"] > 10000000 }
  print_and_return(above_ten_million)
end

def min_and_max_city_populations
  # Takes the list of a state's cities and populations and finds the cities with smallest and largest populations
  biggest_city = city_populations_by_state[@state_name].max_by { |city| city["population"] }
  smallest_city = city_populations_by_state[@state_name].min_by { |city| city["population"] }

  {
    "state" => @state_name,
    "biggestCity" => {
      "name"=> biggest_city["city"],
      "pop"=> biggest_city["population"]
    },
    "smallestCity" => {
      "name"=> smallest_city["city"],
      "pop"=> smallest_city["population"]
    }
  }
end

# Takes a sum of a state's city's populations using reduce, and divides by the number of cities in that state
def average_city_population
  result = city_populations_by_state[@state_name].map { |city| city['population'] }.reduce(:+) / city_populations_by_state[@state_name].size
  print_and_return(result)
end

# Filters the zipcode dump to a ruby hash containing the cities and populations of one state
def city_populations_by_state
  state_zipcode_populations = zipcode_dump.group_by { |zipcode| zipcode["state"] }[@state_name]
  {
    @state_name => state_zipcode_populations.group_by { |state| state["city"] }.map do |city, city_populations|
      {
        "city" => city,
        "population" => city_populations.map { |zipcode| zipcode["pop"] }.reduce(:+)
      }
    end
  }
end

def prompt_the_user
  print "Zipcode explorer:
    1. Return states with populations above 10 Million
    2. Return average city population by state
    3. Return largest and smallest cities by state

    Choose a feature by entering it's number: "

  feature_number = $stdin.gets.chomp

  case feature_number
  when "1"
    state_population_above_ten_million
  when "2"
    select_state
    state_name_validation(proc { average_city_population })
  when "3"
    select_state
    state_name_validation(proc { min_max_city_populations_per_state })
  else
    puts "Sorry, your input was invalid. Please enter 1, 2, or 3"
    prompt_the_user
  end
end

# Checks state name parameter against a list of state names
def state_name_validation(function)
  if state_names_list.include?(@state_name)
    new_string = function.call
    "{'_id'=>" + "'#{@state_name}'" + ", 'avgCityPop'=>" + new_string.to_s + "}"
  else
    'Sorry, your input was invalid. Please enter the abbreviated name of a state like NY\n'
  end
end

def state_names_list
  %w[MA RI NH ME VT CT NY NJ PA DE DC MD VA WV NC SC GA FL AL TN MS KY OH IN MI IA WI MN SD ND MT IL MO KS NE LA AR OK TX CO WY ID UT AZ NM NV CA HI OR WA AK]
end

def select_state
  puts "Select a state by entering its abbreviated name"
  @state_name = $stdin.gets.chomp
end

def fetch_and_parse_zipcode_dump
  @buffer ||= fetch_data("http://media.mongodb.org/zips.json")
  parse_data(@buffer)
end

def fetch_data(url)
  response = Net::HTTP.get_response(URI.parse(url))
  @buffer = response.body
end

# Each line of the response is it's own JSON object, so we will parse line by line into a ruby hash
def parse_data(buffer)
  @zipcode_dump = []
  buffer.each_line do |row|
    @zipcode_dump << JSON.parse(row)
  end
  @zipcode_dump
end

# fetch_and_parse_zipcode_dump
prompt_the_user
