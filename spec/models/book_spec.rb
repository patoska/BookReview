require 'rails_helper'

RSpec.describe Book, type: :model do
  describe "validations" do
    subject { create(:book) }

    it { is_expected.to validate_presence_of(:title) }
  end
end
