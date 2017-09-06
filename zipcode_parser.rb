require 'json'
require 'pry'
require 'net/http'
require 'stringio'

@zipcode_dump = []
@buffer = nil
@state_name = nil

def state_population_above_ten_million
	population = @zipcode_dump.group_by{|zipcode| zipcode["state"]}.map do |state_name, zipcodes|
		{
			"_id" => state_name,
			"totalPop" => zipcodes.map {|zipcode| zipcode["pop"]}.reduce(:+)
		}
	end

	above_ten_million = population.select {|state| state["totalPop"] > 10000000}

	puts above_ten_million
	above_ten_million
end

def min_max_city_populations_per_state
	min_and_max = city_populations_by_state.map do |state|
		state_name = state.keys.first
		biggest_city = state["#{state_name}"].max_by{|city| city["population"] }
		smallest_city = state["#{state_name}"].min_by{|city| city["population"] }

		{
			"state" => state_name,
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
	filtered_result = min_and_max.find {|state| state['state'] == @state_name }
	puts filtered_result
	filtered_result
end

def average_city_population_per_state
	average_population = city_populations_by_state.map do |state|
		state_name = state.keys.first
		{
			"_id" => state_name,
			"avgCityPop" => average_city_population(state, state_name)
		}
	end

	filtered_result = average_population.find {|state| state['_id'] == @state_name }
	puts filtered_result
	filtered_result
end

def average_city_population(state, state_name)
	state["#{state_name}"].map {|city| city['population']}.reduce(:+) / state["#{state_name}"].size
end

def city_populations_by_state
	@zipcode_dump.group_by{|zipcode| zipcode["state"]}.map do |state_name, zip_values|
		{
			"#{state_name}" => zip_values.group_by{|city| city["city"]}.map do |city, city_populations|
		 		{"city" => city,
		 		"population" => city_populations.map{|h| h["pop"]}.reduce(:+)}
			end
		}
	end
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
	 	average_city_population_per_state
	when "3"
		select_state
	 	min_max_city_populations_per_state
	else
	 	puts "Sorry, your input was invalid. Please enter 1, 2, or 3"
	 	prompt_the_user
	end
end

def state_name_validation
	unless state_names_list.include?(@state_name)
		puts "Sorry, your input was invalid. Please enter the abbreviated name of a state like NY"
		select_state
	end
end

def state_names_list
  %w[MA RI NH ME VT CT NY NJ PA DE DC MD VA WV NC SC GA FL AL TN MS KY OH IN MI IA WI MN SD ND MT IL MO KS NE LA AR OK TX CO WY ID UT AZ NM NV CA HI OR WA AK]
end

def select_state
	puts "Select a state by entering its abbreviated name"
	@state_name = $stdin.gets.chomp
	state_name_validation
end

def fetch_data(url)
	response = Net::HTTP.get_response(URI.parse(url))
	@buffer = response.body
end

# Each line of the response is it's own JSON object, so we will parse line by line into a ruby hash
def parse_data(buffer)
	buffer.each_line do |row|
		@zipcode_dump << JSON.parse(row)
	end
end

fetch_data("http://media.mongodb.org/zips.json")
parse_data(@buffer)
prompt_the_user
