module RMT
  class SynchronizationData
    attr_reader :id, :name, :description, :target_list_id, :color,  :owner, :link, :notes, :changesets, :card_id

    def initialize(id, name, description, target_list_id, color, owner, link, relevant_cards_loader, notes, changesets)
      @id = id
      @name = name
      @description = description
      @target_list_id = target_list_id
      @color = color
	  @owner = owner
      @relevant_cards_loader = relevant_cards_loader
	  @link = link
	  @notes = notes
	  @changesets = changesets
    end

    def ensure_present_on(trello)
      if not exists_on?(trello)
        insert_into(trello)
	  else
		update_card(trello)
      end
    end

    def is_data_for?(card)
      if card.name.include? "\##{@id}"
			@card_id = card.id
			return true
	  end
	  
	  return false
    end
  private

    def insert_into(trello)	  
      trello.create_card(:name => "\##{@id} #{@name}",
                         :list => @target_list_id,
                         :description => "#{@link}\n\n#{@description}",
                         :color => @color,
						 :owner => @owner,
						 :notes => @notes,
						 :changesets => @changesets)
    end
	
	def update_card(trello)
		 trello.update_card(:name => "\##{@id} #{@name}",
						:card_id => @card_id,
                         :color => @color,
						 :owner => @owner,
						 :notes => @notes,
						 :changesets => @changesets)
	end
	
    def exists_on?(trello)
      @relevant_cards_loader.call(trello).any? &method(:is_data_for?)
    end
  end
end
