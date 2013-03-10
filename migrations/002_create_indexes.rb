Sequel.migration do
	change do
		alter_table :log_entries do
  		add_index [:start_time, :end_time]
 		 	add_index [:category_id, :activity_id, :start_time, :end_time]
		end
	end
end
