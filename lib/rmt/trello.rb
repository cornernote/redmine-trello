require 'trello'

module RMT
  class Trello
    include ::Trello::Authorization

    # A simple utility function for initializing authentication / authorization for the Trello REST API
    #
    # @param [String] the Trello App Key (can be retrieved from https://trello.com/1/appKey/generate)
    # @param [String] the Trello "secret" (can be retrieved from https://trello.com/1/appKey/generate)
    # @param [String] the Trello user token (can be generated with various expiration dates and
    #   permissions via instructions at https://trello.com/docs/gettingstarted/index.html#getting-a-token-from-a-user)
    def initialize(app_key, secret, user_token)
      ::Trello::Authorization.const_set :AuthPolicy, OAuthPolicy
      # This line is a hack to allow multiple different Trello auths to be used
      # during a single run; the Trello module will cache the consumer otherwise.
      OAuthPolicy.instance_variable_set(:@consumer, nil)

      OAuthPolicy.consumer_credential = OAuthCredential.new(app_key, secret)
      OAuthPolicy.token = OAuthCredential.new(user_token)

      @cards = {}
      @lists = {}
      @boards = {}
    end

    def lists_on_board(board_id)
      ::Trello::Board.find(board_id).lists
    end

    def create_card(properties)
      puts "Adding card: #{properties[:name]}"
      card = ::Trello::Card.create(:name => properties[:name],
                                   :list_id => properties[:list],
                                   :desc => sanitize_utf8(properties[:description]))
								   
      if properties[:color]
        card.add_label(properties[:color])
      end
	  
	  if properties[:owner]		
		 card.add_member(::Trello::Member::find(properties[:owner]))
	  end
	  
	  if properties[:notes]
			properties[:notes].each do |n| 
				note = "User: #{n.user.name}\nDate: #{n.created_on}\nNote: #{n.notes}"
				card.add_comment(note)
			end
	  end
	  
	  if properties[:changesets]
			properties[:changesets].each do |c| 
				changesets = "==Changeset==\nUser: #{c.user.name}\nDate: #{c.committed_on}\nRevision: #{c.revision}\nComments: #{c.comments}"
				card.add_comment(changesets)
			end
	  end
    end

	def update_card(properties)
      puts "Update card: #{properties[:name]}"
      card = ::Trello::Card.find(properties[:card_id])
	  
	  # card.ipdate_fields(:name => properties[:name],
                                   # :list_id => properties[:list],
                                   # :desc => sanitize_utf8(properties[:description]))
								   
      if properties[:color]
		if card.labels.select { |l| l.color == properties[:color]  } == nil
			card.labels.each do |l|
				card.remove_label(l.color)
			end
			
			card.add_label(properties[:color])
		end
	  else
			card.labels.each do |l|
				card.remove_label(l.color)
			end
      end
	  
	  if properties[:owner]		
		if card.members.select { |m| m.id == properties[:owner]  } == nil
			card.members.each do |m|
				card.remove_member(m)
			end
			
			card.add_member(::Trello::Member::find(properties[:owner]))
		end
	  else
		card.members.each do |m|
			card.remove_member(m)
		end
	  end
	  
	  if properties[:notes]
			properties[:notes].each do |n| 
				note = "User: #{n.user.name}\nDate: #{n.created_on}\nNote: #{n.notes}"
				card.add_comment(note)
			end
	  end
	  
	  if properties[:changesets]
			properties[:changesets].each do |c| 
				changesets = "==Changeset==\nUser: #{c.user.name}\nDate: #{c.committed_on}\nRevision: #{c.revision}\nComments: #{c.comments}"
				card.add_comment(changesets)
			end
	  end
    end
	
	def list_members_in_org(org_id)
		puts "Getting Members of Org: #{org_id}"
		org =  ::Trello::Organization::find(org_id)

		return org.members
	end
	
	def list_members_in_board(board_id)
		puts "Getting Members of Board: #{board_id}"
		org =  ::Trello::Board::find(board_id)

		return org.members
	end
	
    def archive_card(card)
      puts "Removing card: #{card.name}"
      card.closed = true
      card.update!
    end

    def list_cards_in(list_id)
      if not @cards[list_id]
        @cards[list_id] = list(list_id).cards
      end
      @cards[list_id]
    end

    def all_cards_on_board_of(list_id)
      board = board_of(list_id)
      if not @cards[board.id]
        @cards[board.id] = board.cards
      end
      @cards[board.id]
    end

    def list(list_id)
      if not @lists[list_id]
        @lists[list_id] = ::Trello::List.find(list_id)
      end
      @lists[list_id]
    end

    def board_of(list_id)
      if not @boards[list_id]
        @boards[list_id] = list(list_id).board
      end
      @boards[list_id]
    end
  private

    def sanitize_utf8(str)
      str.each_char.map { |c| c.valid_encoding? ? c : "\ufffd"}.join
    end
  end
end
