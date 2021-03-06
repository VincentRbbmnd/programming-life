# == Schema Information
#
# Table name: module_values
#
#  id                  :integer          not null, primary key
#  value               :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  module_parameter_id :integer
#  module_instance_id  :integer
#

class ModuleValue < ActiveRecord::Base
  attr_accessible :value, :module_parameter_id, :module_instance_id
  
  belongs_to :module_parameter
  belongs_to :module_instance
  
  delegate :cell, :to => :module_instance
end
