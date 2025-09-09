# frozen_string_literal: true

RSpec.describe Range do
  it "can be built with equal begin and end" do
    expect { 1..1 }.not_to raise_error
  end
end
