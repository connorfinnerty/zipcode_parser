require "zipcode_parser.rb"

describe "The zipcode parser" do
  	before do
		@zipcode_dump = JSON.parse(File.read("zips.json"))
  	end

	it "returns the states with a population over ten million function" do
		expect(population_above_ten_million).to include ({"_id"=>"NY", "totalPop"=>17990402})
	end

	it "returns the average city population by state" do
		expect(average_city_population).to include ({"_id"=>"MN", "avgCityPop"=>5372})
	end

	it "returns the smallest and largest cities per state" do
		expect(smallest_and_largest_city_populations).to include
			{"state"=>"NY", 
			"biggestCity" => {"name"=>"BROOKLYN", "pop"=>2300504}, 
			"smallestCity" => {"name"=>"CHILDWOLD", "pop"=>0}
			}
	end
end
