class Design < ActiveRecord::Base
	attr_accessible :name, :content, :width, :height

	belongs_to :user

	validates_presence_of :name
	validates :width, numericality: { only_integer: true, greater_than_or_equal_to: 100, less_than: 2000 }
	validates :height, numericality: { :only_integer => true, greater_than_or_equal_to: 100, less_than: 2000 }
	validates_presence_of :user
end
