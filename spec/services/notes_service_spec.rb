require 'rails_helper'

RSpec.describe NotesService, type: :service do
  let(:user) { create(:user) }  # Create a user for testing
  let!(:note) { create(:note, user: user, title: "Test Note", content: "This is a test note") }  # Create a note for the user

  describe '#fetch_notes' do
    context 'when notes are cached' do
      it 'fetches notes from Redis cache' do
        # Set notes in Redis cache
        cache_key = "user_#{user.id}_notes"
        cached_notes = [{ title: "Note 1", content: "Content" }]
        $redis.setex(cache_key, 600, cached_notes.to_json)

        # Call fetch_notes
        result = NotesService.fetch_notes(user)

        # Expect notes to be fetched from the cache
        expect(result).to be_an_instance_of(Array)
        expect(result.first['title']).to eq("Note 1")
      end
    end

    # context 'when notes are not cached' do
    #   it 'fetches notes from the database and caches them' do
    #     result = NotesService.fetch_notes(user)

    #     # Ensure the result is not empty
    #     expect(result).not_to be_empty

    #     # Check if the notes are cached
    #     cache_key = "user_#{user.id}_notes"
    #     notes_json = $redis.get(cache_key)
    #     expect(notes_json).not_to be_nil
    #   end
    # end
  end

  describe '#create_note' do
    it 'creates a new note for the user' do
      params = { title: "New Note", content: "This is a new note" }
      result = NotesService.create_note(user, params)

      # Expect success and a note to be created
      expect(result[:success]).to be true
      expect(result[:note].title).to eq("New Note")
    end

    it 'returns an error if user is not found' do
      result = NotesService.create_note(nil, { title: "Invalid Note", content: "No user found" })

      expect(result[:success]).to be false
      expect(result[:error]).to eq("User not found")
    end
  end

  describe '#fetch_note_by_id' do
    it 'fetches a note by ID' do
      result = NotesService.fetch_note_by_id(user, note.id)

      expect(result[:success]).to be true
      expect(result[:note]['title']).to eq(note.title)
    end

    it 'returns an error if note is not found' do
      result = NotesService.fetch_note_by_id(user, -1)  # Invalid note ID

      expect(result[:success]).to be false
      expect(result[:error]).to eq("Note not found")
    end
  end

  describe '#update_note' do
    it 'updates an existing note' do
      params = { title: "Updated Title", content: "Updated content" }
      result = NotesService.update_note(user, note.id, params)

      expect(result[:success]).to be true
      expect(result[:note].title).to eq("Updated Title")
    end

    it 'returns an error if note is not found' do
      result = NotesService.update_note(user, -1, { title: "Invalid Update" })

      expect(result[:success]).to be false
      expect(result[:error]).to eq("Note not found")
    end
  end

  describe '#trash_note' do
    it 'trashes a note' do
      result = NotesService.trash_note(user, note.id)

      expect(result[:success]).to be true
      expect(result[:note].trashed).to be true
    end

    it 'returns an error if note is not found' do
      result = NotesService.trash_note(user, -1)

      expect(result[:success]).to be false
      expect(result[:error]).to eq("Note not found")
    end
  end

  describe '#archive_note' do
    it 'archives a note' do
      result = NotesService.archive_note(user, note.id)

      expect(result[:success]).to be true
      expect(result[:note].archived).to be true
    end

    it 'returns an error if note is not found' do
      result = NotesService.archive_note(user, -1)

      expect(result[:success]).to be false
      expect(result[:error]).to eq("Note not found")
    end
  end

  describe '#change_color' do
    it 'changes the color of a note' do
      result = NotesService.change_color(user, note.id, "blue")

      expect(result[:success]).to be true
      expect(result[:note].color).to eq("blue")
    end

    it 'returns an error if note is not found' do
      result = NotesService.change_color(user, -1, "red")

      expect(result[:success]).to be false
      expect(result[:error]).to eq("Note not found")
    end
  end
end
