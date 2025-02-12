require 'rails_helper'
require_relative '../../app/services/jwt_service'

RSpec.describe "Notes API", type: :request do
  let(:user) { create(:user) }
  let(:note) { create(:note, user: user) }  
  let(:valid_headers) do
    token = JwtService.encode(user_id: user.id)
    { "Authorization" => "Bearer #{token}" }
  end

  describe "GET /api/v1/notes" do
    it "returns all notes for the authenticated user" do
      get "/api/v1/notes", headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key("notes")
    end
  end

  describe "POST /api/v1/notes/create" do
    let(:valid_params) { { note: { title: "Test Note", content: "This is a test note" } } }
    let(:invalid_params) { { note: { title: "" } } }

    it "creates a new note" do
      post "/api/v1/notes/create", params: valid_params, headers: valid_headers
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["message"]).to eq("Note created")
    end

    it "returns an error for invalid params" do
      post "/api/v1/notes/create", params: invalid_params, headers: valid_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /api/v1/notes/:id" do
    it "retrieves a specific note" do
      get "/api/v1/notes/#{note.id}", headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key("note")
    end

    it "returns an error for an invalid note ID" do
      get "/api/v1/notes/99999", headers: valid_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PUT /api/v1/notes/:id/update" do
    it "updates a note successfully" do
      put "/api/v1/notes/#{note.id}/update", params: { note: { title: "Updated Title" } }, headers: valid_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/v1/notes/:id/trash" do
    it "toggles trash status" do
      post "/api/v1/notes/#{note.id}/trash", headers: valid_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/v1/notes/:id/archive" do
    it "toggles archive status" do
      post "/api/v1/notes/#{note.id}/archive", headers: valid_headers
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/v1/notes/:id/change_color" do
    it "changes note color" do
      post "/api/v1/notes/#{note.id}/change_color", params: { note: { color: "#FF5733" } }, headers: valid_headers
      expect(response).to have_http_status(:ok)
    end
  end
end
