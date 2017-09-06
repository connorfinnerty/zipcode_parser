require 'stringio'
require File.dirname(__FILE__) + '/zipcode_parser.rb'

describe "The zipcode parser" do
  before do
    @zipcode_dump = JSON.parse(File.read("zips.json"))
    @mn_data = eval(File.read("mn_data.rb"))
    @state_name = "MN"
  end

  after do
    $stdin = STDIN
  end

  it "returns the states with a population over ten million function" do
    expect(state_population_above_ten_million).to include ({"_id"=>"NY", "totalPop"=>17990402})
  end

  it "returns the average city population by state" do
    # The given example output for MN seemed wrong, so I manually confirmed that my math was correct
    expect(average_city_population).to be 5372
    expect(@mn_data["MN"].size).to be 814


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
