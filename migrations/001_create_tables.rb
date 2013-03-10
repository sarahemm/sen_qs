Sequel.migration do
	change do
		create_table :categories do
			primary_key :id
			String			:category_name, :null => false
		end

		create_table :activities do
			primary_key :id
			foreign_key	:category_id,   :null => false
			String			:activity_name, :null => false
		end

		create_table :log_entries do
	  	primary_key :id
			DateTime		:start_time, :null => false
			DateTime		:end_time, :null => true
			foreign_key	:category_id, :categories, :null => false
			foreign_key	:activity_id, :activities, :null => false
			String			:notes, :text => true, :null => true
		end

		create_table :point_entries do
  		primary_key :id
			DateTime		:point_time, :null => false
			foreign_key	:category_id, :categories, :null => false
			foreign_key	:activity_id, :activities, :null => false
			Float				:value, :null => false
			String			:unit, :size => 10, :null => true
			String			:notes, :text => true, :null => true
		end
	end
end
