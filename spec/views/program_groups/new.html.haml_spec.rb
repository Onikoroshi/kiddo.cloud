require 'rails_helper'

RSpec.describe "program_groups/new", type: :view do
  before(:each) do
    assign(:program_group, ProgramGroup.new(
      :title => "MyString"
    ))
  end

  it "renders new program_group form" do
    render

    assert_select "form[action=?][method=?]", program_groups_path, "post" do

      assert_select "input[name=?]", "program_group[title]"
    end
  end
end
