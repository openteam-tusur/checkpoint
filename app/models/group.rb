class Group < ActiveRecord::Base
  attr_accessible :title, :course, :period_id

  has_many :students, :dependent => :destroy
  has_many :dockets, :dependent => :destroy

  alias_attribute :to_s, :title
  alias_attribute :contingent_number, :title

  CONTINGENT_GROUP_NUMBERS = {
    '012-М1' => '012М/1',
    '012-М2' => '012М/2',
    '143-M'  => '143-М',
    '1A3'    => '1А3',
    '369-1'  => '369',
    '842-1'  => '842',
    '843-М'  => '843-м',
    '873-М'  => '873-м',
    '922-C'  => '922-с',
  }

  def contingent_number
    CONTINGENT_GROUP_NUMBERS[title] || title
  end
end
