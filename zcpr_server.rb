require File.dirname(__FILE__) + '/zipcode_parser.rb'
require 'sinatra'

# Return instructions when the user makes a get request to '/'
get '/' do
  "Zip Code Population Retriever (ZCPR):
    1. Return states with populations above 10 Million
    ex: localhost:4567/state-populations-above-ten-million
    2. Return average city population by state
    ex: localhost:4567/average-city-population/NY
    3. Return largest and smallest cities by state
    ex. localhost:4567/min-and-max-city-populations/NY"
end

get '/state-populations-above-ten-million' do
  state_populations_above_ten_million
end

# We're passing a method to state_name_validator by using a proc, to consolidate code
get '/average-city-population/:state_name' do
  @state_name = params[:state_name]
  state_name_validator(proc { average_city_population })
end

get '/min-and-max-city-populations/:state_name' do
  @state_name = params[:state_name]
  state_name_validator(proc { min_and_max_city_populations })
end
