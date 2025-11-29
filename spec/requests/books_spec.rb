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
