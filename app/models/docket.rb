class Docket < ActiveRecord::Base
  attr_accessible :discipline, :group_id, :lecturer_id

  belongs_to :group
  belongs_to :lecturer
  belongs_to :subdivision

  has_many :grades, :dependent => :destroy
  has_many :attendances, :dependent => :destroy

  alias_attribute :to_s, :discipline
end
