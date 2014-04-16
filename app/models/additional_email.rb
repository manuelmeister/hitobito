# encoding: utf-8

#  Copyright (c) 2014, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

# == Schema Information
#
# Table name: additional_emails
#
#  id               :integer          not null, primary key
#  contactable_id   :integer          not null
#  contactable_type :string(255)      not null
#  email            :string(255)      not null
#  label            :string(255)
#  public           :boolean          default(TRUE), not null
#  mailings         :boolean          default(TRUE), not null
#

class AdditionalEmail < ActiveRecord::Base

  include NormalizedLabels

  has_paper_trail meta: { main: :contactable }

  belongs_to :contactable, polymorphic: true

  validates :label, presence: true
  validates :email, format: Devise.email_regexp

  class << self
    def load_available_labels
      Settings.additional_email.predefined_labels | super
    end

    def mailing_emails_for(people)
      where(contactable_id: people.collect(&:id),
            contactable_type: Person.sti_name,
            mailings: true).
      pluck(:email)
    end
  end

  def to_s(format = :default)
    "#{email} (#{label})"
  end

  def value
    email
  end

end