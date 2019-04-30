require 'rails_helper'

RSpec.describe "program_groups/show", type: :view do
  before(:each) do
    @program_group = assign(:program_group, ProgramGroup.create!(
      :title => "Title"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
  end
end
