class Attendance < ActiveRecord::Base
  extend Enumerize
  attr_accessible :fact, :kind, :total, :docket_id

  enumerize :kind, :in => {:lecture => 1, :practice => 2, :laboratory => 3, :research => 4, :design => 5}

  belongs_to :docket
  belongs_to :student

  def self.kind_values
    Hash[kind.values.map{|v| [v.to_s, v.text]} ]
  end

  def self.kind_value(kind_title)
    enumerized_attributes['kind'].values.map{|v| { v => v.value}}[kind_title]
  end

  def to_s
    "#{fact || '-'} из #{total}".html_safe
  end
end
