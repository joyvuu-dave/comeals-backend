# frozen_string_literal: true

# Remove 3 unused indexes from the audits table (56K+ rows, largest table).
#
# These were created by the audited gem's default migration (2017) but no
# application code queries audits by created_at, request_uuid, or user.
# The only queries are by (auditable_type, auditable_id) and
# (associated_type, associated_id), which have their own indexes.
#
# Removing these cuts per-INSERT index maintenance by 60% on the
# highest-write table.
class RemoveUnusedAuditsIndexes < ActiveRecord::Migration[8.1]
  def up
    remove_index :audits, name: :index_audits_on_created_at
    remove_index :audits, name: :index_audits_on_request_uuid
    remove_index :audits, name: :user_index
  end

  def down
    add_index :audits, :created_at, name: :index_audits_on_created_at
    add_index :audits, :request_uuid, name: :index_audits_on_request_uuid
    add_index :audits, %i[user_id user_type], name: :user_index
  end
end
