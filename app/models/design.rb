class Design < ActiveRecord::Base
	attr_accessible :name, :content, :width, :height

	validates_presence_of :name
	validates :width, numericality: { only_integer: true, greater_than_or_equal_to: 100, less_than: 2000 }
	validates :height, numericality: { :only_integer => true, greater_than_or_equal_to: 100, less_than: 2000 }

	belongs_to :user
end
