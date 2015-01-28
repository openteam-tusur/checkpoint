class Group < ActiveRecord::Base
  attr_accessible :title, :course, :period_id, :faculty_id, :chair_id

  has_many :students, :dependent => :destroy
  has_many :dockets, :dependent => :destroy

  belongs_to :chair,   :class_name => 'Subdivision::Chair'
  belongs_to :faculty, :class_name => 'Subdivision::Faculty'
  belongs_to :period
  delegate :kind_order, :to => :period

  alias_attribute :to_s, :title
  alias_attribute :contingent_number, :title

  scope :ordered,   -> { order(:title)}
  scope :by_period_desc, -> { order('period_id DESC') }
  scope :by_period_asc, -> { order('period_id ASC') }

  CONTINGENT_GROUP_NUMBERS = {
    '012-М1' => '012М/1',
    '012-М2' => '012М/2',
    '013М-1' => '013-М1',
    '163-M' => '163-М',
    '143-M'  => '143-М',
    '1A3'    => '1А3',
    '369-1'  => '369',
    '842-1'  => '842',
    '843-М'  => '843-м',
    '873-М'  => '873-м',
    '922-C'  => '922-с',
    '034-1M' => '034-М1',
    '034-2M' => '034-М2',
    '213' => '213-1',
    '223' => '223-1',
    '543-М' => '543-м'
  }

  def contingent_number
    CONTINGENT_GROUP_NUMBERS[title] || title
  end

  def translited_title
    Russian.translit(self.title).gsub(/\//, '')
  end

  def self.newest_period_for(title)
    #where(:title => title).by_period_desc.first.period
    where(:title => title).sort_by(&:kind_order).last.period
  end
end
