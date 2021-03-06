#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class ServiceTokenDecorator < ApplicationDecorator
  decorates :service_token

  def abilities
    kinds = [:people, :people_below, :events, :groups]

    safe_join(kinds.map do |ability|
      ability_description(ability, :read) if public_send(ability)
    end.compact, h.tag(:br))
  end

  def full_title
    content_tag(:strong, h.link_to(name, h.group_service_token_path(layer, self))) +
      short_description +
      h.tag(:br) + h.muted(token)
  end

  def short_description
    h.tag(:br) + description.truncate_words(10) if description.present?
  end

  private

  def ability_description(ability, action)
    prefix = 'service_tokens.abilities.'
    safe_join([h.t("#{prefix}.#{ability}"), h.muted(h.t("#{prefix}.#{action}"))], ' ')
  end

end
