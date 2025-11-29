require 'rails_helper'

RSpec.describe Review, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:book) }
  end

  describe "validations" do
    subject { create(:review) }

    it { is_expected.to validate_presence_of(:rating) }
    it { should validate_numericality_of(:rating).is_greater_than_or_equal_to(1).is_less_than_or_equal_to(5) }
    it { should validate_length_of(:body).is_at_most(1000) }
  end
end
