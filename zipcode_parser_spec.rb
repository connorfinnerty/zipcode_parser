require File.dirname(__FILE__) + '/zipcode_parser.rb'
require 'rack/test'

set :environment, :test

def app
  Sinatra::Application
end

describe "The zipcode parser" do
  include Rack::Test::Methods

  before do
    @zipcode_dump = JSON.parse(File.read("zips.json"))
    @state_name = "MN"
  end

  after do
    $stdin = STDIN
  end

  it "returns the states with a population over ten million function" do
    expect(state_populations_above_ten_million).to eq(
      [
        {"_id"=>"NY", "totalPop"=>17990402},
        {"_id"=>"PA", "totalPop"=>11881643},
        {"_id"=>"FL", "totalPop"=>12686644},
        {"_id"=>"OH", "totalPop"=>10846517},
        {"_id"=>"IL", "totalPop"=>11427576},
        {"_id"=>"TX", "totalPop"=>16984601},
        {"_id"=>"CA", "totalPop"=>29754890}
      ]
    )
  end

  it "returns the average city population by state" do
    # The given example output for MN seemed wrong, so I manually confirmed that my math was correct
    expect(average_city_population).to eq("_id"=>"MN", "avgCityPop"=>5372)
  end

  it "returns the smallest and largest cities per state" do
    expect(min_and_max_city_populations).to include
    {
      "state"=>"MN",
      "biggestCity"=>{"name"=>"MINNEAPOLIS", "pop"=>344719},
      "smallestCity"=>{"name"=>"JOHNSON", "pop"=>12}
    }
  end

  it 'should return instructions' do
    get '/'
    expect(last_response.body).to include
    "Zip Code Population Retriever (ZCPR):
    1. Return states with populations above 10 Million
    ex: localhost:4567/state-populations-above-ten-million
    2. Return average city population by state
    ex: localhost:4567/average-city-population/NY
    3. Return largest and smallest cities by state
    ex. localhost:4567/min-and-max-city-populations/NY"
  end

  it 'should validate the selected state name' do
    get '/avg-city-population/NYC'
    expect(last_response.body).to include
    'Sorry, your input was invalid. Please enter the abbreviated name of a state like NY'
  end

  it 'should return a list of states with population above ten million' do
    get '/state-populations-above-ten-million'
    expect(last_response.body).to eq(
      [
        {"_id"=>"NY", "totalPop"=>17990402},
        {"_id"=>"PA", "totalPop"=>11881643},
        {"_id"=>"FL", "totalPop"=>12686644},
        {"_id"=>"OH", "totalPop"=>10846517},
        {"_id"=>"IL", "totalPop"=>11427576},
        {"_id"=>"TX", "totalPop"=>16984601},
        {"_id"=>"CA", "totalPop"=>29754890}
      ].to_json
    )
    expect(last_response).to be_ok
  end

  it 'should return the average city population for a given state' do
    get '/average-city-population/MN'
    expect(last_response.body).to eq({'_id'=>'MN', 'avgCityPop'=>5372}.to_json)
    expect(last_response).to be_ok
  end

  it 'should return the smallest and largest cities for a given state' do
    get '/min-and-max-city-populations/MN'
    expect(last_response.body).to eq(
      {
        "state"=>"MN", "biggestCity"=>{"name"=>"MINNEAPOLIS", "pop"=>344719}, "smallestCity"=>{"name"=>"JOHNSON", "pop"=>12}
      }.to_json
    )
  end

  it 'should fail to load bad path' do
    get '/badpath'
    expect(last_response).to_not be_ok
  end
end
