# frozen_string_literal: true

class CreateMcpSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :mcp_sessions do |t|
      t.string :session_id, null: false, index: { unique: true }
      t.datetime :initialized_at, null: false
      t.datetime :last_activity_at, null: false
      t.string :last_event_id
      t.jsonb :metadata

      t.timestamps
    end

    add_index :mcp_sessions, :last_activity_at
  end
end
