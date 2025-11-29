require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /users" do
    it "returns all users" do
      user1 = create(:user)
      user2 = create(:user)

      get "/users"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json.size).to eq(2)
    end
  end

  describe "GET /users/:id" do
    it "returns correct user" do
      user1 = create(:user)
      user2 = create(:user)

      get "/users/#{user1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['id']).to eq(user1.id)
      expect(json['email']).to eq(user1.email)
      expect(json['id']).not_to eq(user2.id)
    end
  end

  describe "POST /users" do
    let(:user1) { create(:user) }

    context "with valid params" do
      let(:params) do
        {
          user: {
            email: "john@example.com"
          }
        }
      end

      it "creates a user" do
        expect {
          post "/users", params: params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        expect(json["email"]).to eq("john@example.com")
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          user: {
            email: user1.email
          }
        }
      end

      it "does not create a user and returns errors" do
        expect {
          post "/users", params: params
        }.to change(User, :count).by(1) # the count change is because the user1 is created above

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)

        expect(json["email"][0]).to include("has already been taken")
      end
    end
  end

  describe "PATCH/PUT /users/:id" do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    context "with valid params" do
      let(:params) do
        {
          user: {
            email: "john@example.com"
          }
        }
      end

      it "updates the user" do
        put "/users/#{user1.id}", params: params

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["email"]).to eq("john@example.com")
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          user: {
            email: user2.email
          }
        }
      end

      it "does not updates the user and returns errors" do
        old_email = user1.email
        put "/users/#{user1.id}", params: params

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)

        expect(old_email).to eq(user1.reload.email)
        expect(json["email"][0]).to include("has already been taken")
      end
    end
  end

  describe "DELETE /users/:id" do
    context "with valid id" do
      it "destroy the user" do
        user1 = create(:user)
        expect(User.count).to eq(1)

        expect {
          delete "/users/#{user1.id}"
        }.to change(User, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "with invalid id" do
      it "destroy the user" do
        expect(User.count).to eq(0)

        expect {
          delete "/users/1"
        }.to change(User, :count).by(0)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
