require File.dirname(__FILE__) + '/zipcode_parser.rb'

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
    new_york_population = '17990402'
    expect(state_populations_above_ten_million).to include new_york_population
  end

  it "returns the average city population by state" do
    # The given example output for MN seemed wrong, so I manually confirmed that my math was correct
    expect(average_city_population).to be 5372

    expect(state_name_validator(proc { average_city_population })).to include "{'_id'=>'MN', 'avgCityPop'=>5372}"
  end

  it "returns the smallest and largest cities per state" do
    expect(min_and_max_city_populations).to include
    {
      "state"=>"MN",
      "biggestCity"=>{"name"=>"MINNEAPOLIS", "pop"=>344719},
      "smallestCity"=>{"name"=>"JOHNSON", "pop"=>12}
    }
  end
end
