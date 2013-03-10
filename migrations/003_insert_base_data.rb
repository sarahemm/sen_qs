Sequel.migration do
  change do
	  self[:categories].insert(:category_name => "Medical")
	  self[:activities].insert(:activity_name => "Glucose")
  end
end
