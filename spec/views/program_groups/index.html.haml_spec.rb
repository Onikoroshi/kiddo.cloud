require 'rails_helper'

RSpec.describe "program_groups/index", type: :view do
  before(:each) do
    assign(:program_groups, [
      ProgramGroup.create!(
        :title => "Title"
      ),
      ProgramGroup.create!(
        :title => "Title"
      )
    ])
  end

  it "renders a list of program_groups" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
  end
end
