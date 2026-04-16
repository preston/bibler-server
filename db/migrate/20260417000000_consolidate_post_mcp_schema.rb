class ConsolidatePostMcpSchema < ActiveRecord::Migration[8.1]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    unless table_exists?(:users)
      create_table :users do |t|
        t.string :email, null: false, default: ""
        t.string :encrypted_password, null: false, default: ""
        t.string :reset_password_token
        t.datetime :reset_password_sent_at
        t.datetime :remember_created_at
        t.string :username, null: false
        t.string :name, null: false
        t.string :api_token

        t.timestamps null: false
      end
    end
    add_index :users, :email, unique: true, if_not_exists: true
    add_index :users, :reset_password_token, unique: true, if_not_exists: true
    add_index :users, :username, unique: true, if_not_exists: true
    add_index :users, :api_token, unique: true, if_not_exists: true

    unless table_exists?(:studies)
      create_table :studies do |t|
        t.string :uuid, null: false
        t.string :title, null: false
        t.text :goal
        t.jsonb :metadata, null: false, default: {}
        t.string :visibility, null: false, default: "private"
        t.bigint :owner_id

        t.timestamps
      end
    end
    add_index :studies, :uuid, unique: true, if_not_exists: true
    add_index :studies, :owner_id, if_not_exists: true
    add_foreign_key :studies, :users, column: :owner_id, if_not_exists: true

    unless table_exists?(:study_verses)
      create_table :study_verses do |t|
        t.string :uuid, null: false
        t.references :study, null: false, foreign_key: true
        t.string :bible_uuid, null: false
        t.string :book_uuid, null: false
        t.integer :chapter, null: false
        t.integer :ordinal, null: false
        t.text :verse_text
        t.text :note
        t.integer :position, null: false, default: 0

        t.timestamps
      end
    end
    add_index :study_verses, :uuid, unique: true, if_not_exists: true
    add_index :study_verses, %i[study_id position], if_not_exists: true
    add_index :study_verses, :bible_uuid, if_not_exists: true
    add_index :study_verses, :book_uuid, if_not_exists: true
    add_index :study_verses, %i[study_id bible_uuid book_uuid chapter ordinal], name: "idx_study_verses_lookup_uuid", if_not_exists: true

    unless table_exists?(:study_commentaries)
      create_table :study_commentaries do |t|
        t.string :uuid, null: false
        t.references :study, null: false, foreign_key: true
        t.string :source_type, null: false, default: "manual"
        t.string :title, null: false
        t.text :body
        t.text :prompt
        t.jsonb :context, null: false, default: {}
        t.integer :position, null: false, default: 0

        t.timestamps
      end
    end
    add_index :study_commentaries, :uuid, unique: true, if_not_exists: true
    add_index :study_commentaries, %i[study_id position], if_not_exists: true

    unless table_exists?(:study_questions)
      create_table :study_questions do |t|
        t.string :uuid, null: false
        t.references :study, null: false, foreign_key: true
        t.text :prompt, null: false
        t.string :question_type, null: false, default: "discussion"
        t.text :guidance_notes
        t.jsonb :verse_anchor, null: false, default: {}
        t.integer :position, null: false, default: 0

        t.timestamps
      end
    end
    add_index :study_questions, :uuid, unique: true, if_not_exists: true
    add_index :study_questions, %i[study_id position], if_not_exists: true

    unless table_exists?(:study_tasks)
      create_table :study_tasks do |t|
        t.string :uuid, null: false
        t.references :study, null: false, foreign_key: true
        t.text :instruction, null: false
        t.string :task_type, null: false, default: "discussion"
        t.string :status, null: false, default: "open"
        t.string :assignee_label
        t.datetime :due_at
        t.jsonb :context, null: false, default: {}
        t.integer :position, null: false, default: 0

        t.timestamps
      end
    end
    add_index :study_tasks, :uuid, unique: true, if_not_exists: true
    add_index :study_tasks, %i[study_id position], if_not_exists: true

    unless table_exists?(:study_answers)
      create_table :study_answers do |t|
        t.string :uuid, null: false
        t.references :study_question, null: false, foreign_key: true
        t.references :study, null: false, foreign_key: true
        t.references :study_commentary, null: true, foreign_key: true
        t.references :user, null: true, foreign_key: true
        t.text :response, null: false
        t.string :author_label
        t.string :visibility, null: false, default: "study"

        t.timestamps
      end
    end
    add_index :study_answers, :uuid, unique: true, if_not_exists: true
    add_index :study_answers, %i[study_question_id created_at], if_not_exists: true

    unless table_exists?(:roles)
      create_table :roles do |t|
        t.string :name, null: false
        t.boolean :is_default, default: false, null: false
        t.boolean :administrator, default: false, null: false
        t.boolean :bibles, default: false, null: false
        t.boolean :access, default: false, null: false
        t.boolean :curation, default: false, null: false
        t.timestamps
      end
    end
    add_index :roles, :name, unique: true, if_not_exists: true

    unless table_exists?(:roles_users)
      create_table :roles_users, id: false do |t|
        t.belongs_to :user, null: false, foreign_key: true
        t.belongs_to :role, null: false, foreign_key: true
      end
    end
    add_index :roles_users, %i[user_id role_id], unique: true, if_not_exists: true

    unless table_exists?(:study_plan_items)
      create_table :study_plan_items do |t|
        t.references :study, null: false, foreign_key: true
        t.string :uuid, null: false
        t.string :title, null: false
        t.string :item_type, null: false
        t.text :notes
        t.jsonb :metadata, null: false, default: {}
        t.integer :position, null: false, default: 0

        t.timestamps
      end
    end
    add_index :study_plan_items, :uuid, unique: true, if_not_exists: true
    add_index :study_plan_items, %i[study_id position], if_not_exists: true

    unless table_exists?(:study_plan_item_user_states)
      create_table :study_plan_item_user_states do |t|
        t.references :user, null: false, foreign_key: true
        t.references :study_plan_item, null: false, foreign_key: true
        t.string :status, null: false, default: "todo"
        t.timestamps
      end
    end
    add_index :study_plan_item_user_states, %i[user_id study_plan_item_id], unique: true, name: "idx_plan_item_user_state_unique", if_not_exists: true

    add_column :bibles, :uuid, :string unless column_exists?(:bibles, :uuid)
    add_column :books, :uuid, :string unless column_exists?(:books, :uuid)
    add_column :testaments, :uuid, :string unless column_exists?(:testaments, :uuid)
    add_column :verses, :uuid, :string unless column_exists?(:verses, :uuid)

    execute "UPDATE bibles SET uuid = gen_random_uuid()::text WHERE uuid IS NULL" if column_exists?(:bibles, :uuid)
    execute "UPDATE books SET uuid = gen_random_uuid()::text WHERE uuid IS NULL" if column_exists?(:books, :uuid)
    execute "UPDATE testaments SET uuid = gen_random_uuid()::text WHERE uuid IS NULL" if column_exists?(:testaments, :uuid)
    execute "UPDATE verses SET uuid = gen_random_uuid()::text WHERE uuid IS NULL" if column_exists?(:verses, :uuid)

    add_index :bibles, :uuid, unique: true, if_not_exists: true
    add_index :books, :uuid, unique: true, if_not_exists: true
    add_index :testaments, :uuid, unique: true, if_not_exists: true
    add_index :verses, :uuid, unique: true, if_not_exists: true

    change_column_null :bibles, :uuid, false if column_exists?(:bibles, :uuid)
    change_column_null :books, :uuid, false if column_exists?(:books, :uuid)
    change_column_null :testaments, :uuid, false if column_exists?(:testaments, :uuid)
    change_column_null :verses, :uuid, false if column_exists?(:verses, :uuid)

    add_column :bibles, :ai_default_english, :boolean, null: false, default: false unless column_exists?(:bibles, :ai_default_english)
    add_column :bibles, :ai_default_hebrew_ot, :boolean, null: false, default: false unless column_exists?(:bibles, :ai_default_hebrew_ot)
    add_column :bibles, :ai_default_greek, :boolean, null: false, default: false unless column_exists?(:bibles, :ai_default_greek)
    add_column :bibles, :ai_default_aramaic, :boolean, null: false, default: false unless column_exists?(:bibles, :ai_default_aramaic)
    add_index :bibles, :ai_default_english, unique: true, where: "ai_default_english", name: "idx_bibles_ai_default_english_true", if_not_exists: true
    add_index :bibles, :ai_default_hebrew_ot, unique: true, where: "ai_default_hebrew_ot", name: "idx_bibles_ai_default_hebrew_true", if_not_exists: true
    add_index :bibles, :ai_default_greek, unique: true, where: "ai_default_greek", name: "idx_bibles_ai_default_greek_true", if_not_exists: true
    add_index :bibles, :ai_default_aramaic, unique: true, where: "ai_default_aramaic", name: "idx_bibles_ai_default_aramaic_true", if_not_exists: true

    remove_index :verses, :slug if index_exists?(:verses, :slug)
    remove_index :books, %i[bible_id slug] if index_exists?(:books, %i[bible_id slug])
    remove_index :bibles, :slug if index_exists?(:bibles, :slug)

    remove_column :verses, :slug if column_exists?(:verses, :slug)
    remove_column :books, :slug if column_exists?(:books, :slug)
    remove_column :testaments, :slug if column_exists?(:testaments, :slug)
    remove_column :bibles, :slug if column_exists?(:bibles, :slug)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Consolidated migration cannot be safely reversed."
  end
end
