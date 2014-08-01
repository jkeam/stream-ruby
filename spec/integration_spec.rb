require 'date'
require 'stream'


describe "Integration tests" do

    before do
        @client = Stream::Client.new('ahj2ndz7gsan', 'gthc2t9gh7pzq52f6cky8w4r4up9dr6rju9w3fjgmkv6cdvvav2ufe5fv7e2r9qy')
        @feed42 = @client.feed('flat:42')
        @test_activity = {:actor => 1, :verb => 'tweet', :object => 1}
    end

    context 'test client' do

        example "posting an activity" do
            response = @feed42.add_activity(@test_activity)
            response.should include("id", "actor", "verb", "object", "target", "time")
        end

        example "posting an activity with datetime object" do
            activity = {:actor => 1, :verb => 'tweet', :object => 1, :time => DateTime.now}
            response = @feed42.add_activity(activity)
            response.should include("id", "actor", "verb", "object", "target", "time")
        end

        example "localised datetimes should be returned in UTC correctly" do
            now = DateTime.now.new_offset(5)
            activity = {:actor => 1, :verb => 'tweet', :object => 1, :time => now}
            response = @feed42.add_activity(activity)
            response.should include("id", "actor", "verb", "object", "target", "time")
            response = @feed42.get(:limit=>5)
            DateTime.iso8601(response["results"][0]["time"]).should be_within(1).of(now.new_offset(0))
        end

        example "posting a custom field as a hash" do
            hash_value = {'a' => 42}
            activity = {:actor => 1, :verb => 'tweet', :object => 1, :hash_data => hash_value}
            response = @feed42.add_activity(activity)
            response.should include("id", "actor", "verb", "object", "target", "hash_data")
            results = @feed42.get(:limit=>1)["results"]
            results[0]["hash_data"].should eq hash_value
        end

        example "posting a custom field as a list" do
            list_value = [1,2,3]
            activity = {:actor => 1, :verb => 'tweet', :object => 1, :hash_data => list_value}
            response = @feed42.add_activity(activity)
            response.should include("id", "actor", "verb", "object", "target", "hash_data")
            results = @feed42.get(:limit=>1)["results"]
            results[0]["hash_data"].should eq list_value
        end

        example "posting and get one activity" do
            response = @feed42.add_activity(@test_activity)
            results = @feed42.get(:limit=>1)["results"]
            results[0]["id"].should eq response["id"]
        end

        example "removing an activity" do
            activity = @feed42.add_activity(@test_activity)
            @feed42.remove(activity["id"])
        end

        example "delete a feed" do
            response = @feed42.add_activity(@test_activity)
            response.should include("id", "actor", "verb", "object", "target", "time")
            @feed42.delete
            response = @feed42.get
            response['results'].length.should eq 0
        end

        example "following a feed" do
            @feed42.follow('flat:43')
        end

        example "unfollowing a feed" do
            @feed42.follow('flat:43')
            @feed42.unfollow('flat:43')
        end

        # TODO: add pagination tests here
        example "read from a feed" do
            @feed42.get
            @feed42.get(:limit=>5)
            @feed42.get(:offset=> 4, :limit=>5)
        end

    end

end