
class NotesService
  def self.fetch_notes(user)
    notes = user.notes.where(trashed: false)
    notes.map { |note| note.as_json(only: [:id, :title, :content, :color, :archived, :trashed, :created_at, :updated_at]) }
  end


  def self.create_note(user, params)
    note = user.notes.build(params)
    note.color ||= 'white'
    note.archived = false if note.archived.nil?  
    note.trashed = false if note.trashed.nil?     
  
    note.save ? { success: true, note: note } : { success: false, error: note.errors.full_messages.join(", ") }
  end
  


  def self.fetch_note_by_id(user, note_id)
    note = user.notes.find_by(id: note_id)
    note ? { success: true, note: note } : { success: false, error: "Note not found" }
  end




  def self.update_note(user, note_id, params)
    note = user.notes.find_by(id: note_id)
    return { success: false, error: "Note not found" } unless note

    note.update(params) ? { success: true, note: note } : { success: false, error: note.errors.full_messages.join(", ") }
  end


  def self.trash_note(user, note_id)
    note = user.notes.find_by(id: note_id)
    return { success: false, error: "Note not found" } unless note
  
 
    note.update(trashed: !note.trashed)
    
    {
      success: true,
      message: "Note trash status updated",
      note: note.as_json(only: [:id, :title, :content, :archived, :trashed, :color, :created_at, :updated_at])
    }
  end

  def self.archive_note(user, note_id)
    note = user.notes.find_by(id: note_id)
    return { success: false, error: "Note not found" } unless note
  
    note.update(archived: !note.archived)
    { 
      success: true, 
      message: "Note archive status updated", 
      note: note.as_json(only: [:id, :title, :content, :archived, :trashed, :color, :created_at, :updated_at]) 
    }
  end



  def self.change_color(user, note_id, color)
    note = user.notes.find_by(id: note_id)
    return { success: false, error: "Note not found" } unless note

    note.update(color: color)
    { success: true, message: "Note color updated", note: note }
  end

end

















  # def self.add_collaborator(user, note_id, collaborator_email)
  #   note = user.notes.find_by(id: note_id)
  #   collaborator = User.find_by(email: collaborator_email)

  #   return { success: false, error: "Note not found" } unless note
  #   return { success: false, error: "Collaborator not found" } unless collaborator

  #   note.collaborators << collaborator unless note.collaborators.include?(collaborator)
  #   { success: true, message: "Collaborator added", note: note }
  # end