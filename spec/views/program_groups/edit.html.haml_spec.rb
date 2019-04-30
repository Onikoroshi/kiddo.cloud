require 'rails_helper'

RSpec.describe "program_groups/edit", type: :view do
  before(:each) do
    @program_group = assign(:program_group, ProgramGroup.create!(
      :title => "MyString"
    ))
  end

  it "renders the edit program_group form" do
    render

    assert_select "form[action=?][method=?]", program_group_path(@program_group), "post" do

      assert_select "input[name=?]", "program_group[title]"
    end
  end
end
