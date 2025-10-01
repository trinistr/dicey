# frozen_string_literal: true

RSpec.describe Rational do
  it "works with Complex" do
    expect((5/2r).i).to eq Complex(0, 2.5)
  end

  it "allows to divide by Complex" do
    expect(1r / 2i).to eq Complex(0, -0.5r)
  end

  it "works with Complex the other way around" do
    expect(Complex(1, 2) / 3r).to eq Complex(1/3r, 2/3r)
  end

  it "allows to divide Complex by Complex" do
    expect(Complex(1r, 0) / Complex(0, 2r)).to eq Complex(0, -0.5r)
  end

  specify "Kernel#Rational works too" do
    expect(Rational(1, 2i)).to eq Complex(0, -0.5r)
  end

  specify "and imaginary literals!" do
    expect(1/2ri).to eq Complex(0, -0.5r)
  end
end
