class CreateRequestLoggers < ActiveRecord::Migration[7.0]
  def change
    create_table :request_loggers do |t|
      t.string :endpoint
      t.string :request_id
      t.json :payload, default: {}

      t.timestamps
    end
  end
end
