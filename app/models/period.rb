require 'import'

class Period < ActiveRecord::Base
  extend Enumerize
  attr_accessible :ends_at, :kind, :starts_at

  has_many :dockets
  
  after_create :create_dockets

  enumerize :kind, :in => [:kt_1, :kt_2, :exam_week, :exam_session]

  def create_dockets
    Import.new(self).import
  end
end
