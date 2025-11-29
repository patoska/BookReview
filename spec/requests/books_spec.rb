require 'rails_helper'

RSpec.describe "Books", type: :request do
  describe "GET /books" do
    it "returns all books" do
      book1 = create(:book)
      book2 = create(:book)

      get "/books"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json.size).to eq(2)
    end
  end

  describe "GET /books/:id" do
    it "returns correct book" do
      book1 = create(:book)
      book2 = create(:book)

      get "/books/#{book1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['id']).to eq(book1.id)
      expect(json['title']).to eq(book1.title)
      expect(json['id']).not_to eq(book2.id)
    end

    context "with reviews" do
      let (:book1) { create(:book) }

      before(:each) do
        review1 = create(:review, book: book1, rating: 5, user: create(:user))
        review2 = create(:review, book: book1, rating: 5, user: create(:user))
        review3 = create(:review, book: book1, rating: 5, user: create(:user))
        review4 = create(:review, book: book1, rating: 2, user: create(:user))
      end

      context "of valid users" do
        it "shows the correct average rating" do
          get "/books/#{book1.id}"
          json = JSON.parse(response.body)
          expect(json['rating']).to eq(4.3)
        end
      end

      context "of banned users" do
        it "ignores the reviews from banned users" do
          review4 = create(:review, book: book1, rating: 2, user: create(:user, :banned))
          get "/books/#{book1.id}"
          json = JSON.parse(response.body)


          expect(json['rating']).to eq(4.3)
        end
      end

      context "less than 3" do
        it "shows the correct average rating" do
          book1.reviews.last.destroy
          book1.reviews.last.destroy

          get "/books/#{book1.id}"
          json = JSON.parse(response.body)

          expect(json['rating']).to eq("Reseñas Insuficientes")
        end
      end
    end
  end

  describe "POST /books" do
    let(:book1) { create(:book) }

    context "with valid params" do
      let(:params) do
        {
          book: {
            title: "john@example.com"
          }
        }
      end

      it "creates a book" do
        expect {
          post "/books", params: params
        }.to change(Book, :count).by(1)

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        expect(json["title"]).to eq("john@example.com")
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          book: {
            title: book1.title
          }
        }
      end

      it "does not create a book and returns errors" do
        expect {
          post "/books", params: params
        }.to change(Book, :count).by(1) # the count change is because the book1 is created above

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)

        expect(json["title"][0]).to include("has already been taken")
      end
    end
  end

  describe "PATCH/PUT /books/:id" do
    let(:book1) { create(:book) }
    let(:book2) { create(:book) }

    context "with valid params" do
      let(:params) do
        {
          book: {
            title: "john@example.com"
          }
        }
      end

      it "updates the book" do
        put "/books/#{book1.id}", params: params

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["title"]).to eq("john@example.com")
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          book: {
            title: book2.title
          }
        }
      end

      it "does not updates the book and returns errors" do
        old_title = book1.title
        put "/books/#{book1.id}", params: params

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)

        expect(old_title).to eq(book1.reload.title)
        expect(json["title"][0]).to include("has already been taken")
      end
    end
  end

  describe "DELETE /books/:id" do
    context "with valid id" do
      it "destroy the book" do
        book1 = create(:book)
        expect(Book.count).to eq(1)

        expect {
          delete "/books/#{book1.id}"
        }.to change(Book, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "with invalid id" do
      it "destroy the book" do
        expect(Book.count).to eq(0)

        expect {
          delete "/books/1"
        }.to change(Book, :count).by(0)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
