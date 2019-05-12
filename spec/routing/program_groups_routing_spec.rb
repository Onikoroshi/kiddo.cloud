require "rails_helper"

RSpec.describe ProgramGroupsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/program_groups").to route_to("program_groups#index")
    end

    it "routes to #new" do
      expect(:get => "/program_groups/new").to route_to("program_groups#new")
    end

    it "routes to #show" do
      expect(:get => "/program_groups/1").to route_to("program_groups#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/program_groups/1/edit").to route_to("program_groups#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/program_groups").to route_to("program_groups#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/program_groups/1").to route_to("program_groups#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/program_groups/1").to route_to("program_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/program_groups/1").to route_to("program_groups#destroy", :id => "1")
    end

  end
end
