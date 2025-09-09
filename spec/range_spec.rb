# frozen_string_literal: true

RSpec.describe Range do
  specify { expect { ..1 }.not_to raise_error }
  specify { expect { 1.. }.not_to raise_error }
  specify { expect { nil..nil }.not_to raise_error }

  describe "endless clamp" do
    specify { expect(13.clamp(0..12)).to eq 12 }
    specify { expect(13.clamp(0..)).to eq 13 }
    specify { expect(13.clamp(-1..)).to eq 13 }
  end

  describe "beginless clamp" do
    specify { expect(-13.clamp(-1..0)).to eq(-1) }
    specify { expect(-13.clamp(..0)).to eq(-13) }
    specify { expect(-13.clamp(..1)).to eq(-13) }
  end
end
