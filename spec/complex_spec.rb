# frozen_string_literal: true

RSpec.describe Complex do
  subject(:properties) { {} }

  it "is borked" do
    expect(properties).to include(
      mode: [2, 1 + 4i],
      arithmetic_mean: (5/4r) + 2i,
      expected_value: (13/10r) + 2i,
      variance: (-219/100r) - (2/5r).i
    )
  end
end
