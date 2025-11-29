require 'rails_helper'

RSpec.describe "Reviews", type: :request do
  describe "GET /reviews" do
    it "returns all reviews" do
      review1 = create(:review)
      review2 = create(:review)

      get "/reviews"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json.size).to eq(2)
    end
  end

  describe "GET /reviews/:id" do
    it "returns correct review" do
      review1 = create(:review)
      review2 = create(:review)

      get "/reviews/#{review1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['id']).to eq(review1.id)
      expect(json['id']).not_to eq(review2.id)
    end
  end

  describe "POST /reviews" do
    context "with valid params" do
      let(:user) { create(:user) }
      let(:book) { create(:book) }
      let(:params) do
        {
          review: {
            rating: 3,
            body: "Great book",
            user_id: user.id,
            book_id: book.id
          }
        }
      end

      it "creates a review" do
        expect {
          post "/reviews", params: params
        }.to change(Review, :count).by(1)

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        expect(json["rating"]).to eq(3)
        expect(json["body"]).to eq("Great book")
        expect(json["user_id"]).to eq(user.id)
        expect(json["book_id"]).to eq(book.id)
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          review: {
            rating: 8,
            body: "".ljust(1001),
            user_id: 1,
            book_id: 1
          }
        }
      end

      it "does not create a review and returns errors" do
        expect {
          post "/reviews", params: params
        }.to change(Review, :count).by(0)

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["book"][0]).to include("must exist")
        expect(json["user"][0]).to include("must exist")
        expect(json["rating"][0]).to include("must be less than or equal to 5")
        expect(json["body"][0]).to include("is too long (maximum is 1000 characters)")
      end
    end
  end

  describe "PATCH/PUT /reviews/:id" do
    let(:review1) { create(:review) }
    let(:review2) { create(:review) }

    context "with valid params" do
      let(:params) do
        {
          review: {
            rating: 2
          }
        }
      end

      it "updates the review" do
        put "/reviews/#{review1.id}", params: params

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["rating"]).to eq(2)
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          review: {
            rating: 0
          }
        }
      end

      it "does not updates the review and returns errors" do
        old_rating = review1.rating
        put "/reviews/#{review1.id}", params: params

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)

        expect(old_rating).to eq(review1.reload.rating)
        expect(json["rating"][0]).to include("must be greater than or equal to 1")
      end
    end
  end

  describe "DELETE /reviews/:id" do
    context "with valid id" do
      it "destroy the review" do
        review1 = create(:review)
        expect(Review.count).to eq(1)

        expect {
          delete "/reviews/#{review1.id}"
        }.to change(Review, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "with invalid id" do
      it "destroy the review" do
        expect(Review.count).to eq(0)

        expect {
          delete "/reviews/1"
        }.to change(Review, :count).by(0)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
