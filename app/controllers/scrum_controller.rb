require 'csv'
class ScrumController < ApplicationController

	def index
		if session[:player_id] == nil
			session[:turn_num] = 1
			session[:round_num] = 1
			session[:num_players] = params[:num_players] if params[:num_players] != nil
			session[:player_id] = params[:player_id]
		end
		@stories = Story.all
		@stories_to_player = StoriesToPlayer.where(playerid: session[:player_id])
		@problems_to_player = ProblemsToPlayer.where(["playerid = ?", session[:player_id]])
		@solutions_to_player = SolutionsToPlayer.where(["playerid = ?", session[:player_id]])

		#Checks if the user applied a solution to a problem, then applies it to the associated problem, removing both the problem and solution.
		if params[:apply_solution_to] != nil
			#raise "This is an exception"
			if params[:apply_solution_to].uniq.size == 1 && params[:apply_solution_to].uniq[0] == ""
				ExtraDice.find(session[:player_id]).update_attribute(:enabled, true)
				SolutionsToPlayer.where(["playerid = ? and solutionid = ?", session[:player_id], 9]).first.destroy
				flash[:notice] = "Extra dice enabled, this will apply on your next roll."
			else
			
				index = 0
				while params[:apply_solution_to][index] == ""
					index = index + 1
				end
			
				apply_num = params[:apply_solution_to][index].to_i

				if @problems_to_player.distinct.pluck(:realid).include? apply_num
					ProblemsToPlayer.where(["playerid = ? and realid = ?", session[:player_id], apply_num]).first.destroy
					SolutionsToPlayer.find(params[:solution_used][index].to_i).destroy
				else
					flash[:notice] = "You need to apply this solution to one of its associated problems."
				end
			end
		end
		
		#Checks if the user selected "New Game" from the Game Over screen
		if params[:reset] != nil
			reset_game
		end
		
		#Checks if the sprint is over based on the number of turns taken. Also checks if the game is over based on the number of rounds completed.
		if session[:turn_num] >= 15 && session[:round_num] <= 3
			session[:turn_num] = 1
			session[:round_num] = session[:round_num] + 1
			if session[:round_num] > 3
				redirect_to '/end_screen'
			else
				redirect_to '/recap'
			end
		end
	end
	
	def story
		#Increment turn by 1
		session[:turn_num] = session[:turn_num] + 1
		
		
		@events = EventsToPlayer.where(["playerid = ? and completed = ?", session[:player_id], false])
		#Variables for the view
		@story = Story.find(params[:storyid])
		@story_to_player = StoriesToPlayer.where(["playerid = ? and storyid = ?", session[:player_id], params[:storyid]]).first
		@dice_roll = 0
		@display_roll_again_button = false
		
		#Tracks work on the story at the start of this round
		work_before = @story_to_player.work
		
		
		#Draw a card and apply its effect
		card_id = draw_card
		@card_id = card_id
		@event_card = ScrumCard.find(card_id)
		code = apply_card_effect(card_id, @story_to_player)
		if params[:roll_dice] == "true"
			@dice_roll = roll_dice
			if code == 2
				@story_to_player.update_attribute(:work, @story_to_player.work - @dice_roll)
				@display_roll_again_button = true
				
				#Do this to offset entering this method again, want to only spend 1 turn 
				session[:turn_num] = session[:turn_num] - 1
			elsif code == 1
				@story_to_player.update_attribute(:work, @story_to_player.work - @dice_roll)
			end
		end
		
		#Final variable for the view
		@work_after = work_before - @story_to_player.work
		if ProblemsToPlayer.where(["playerid = ? and storyid = ?", session[:player_id], params[:storyid]]).size != 0 && @story_to_player.work <= 0
			@story_to_player.update_attribute(:work, 1)
		elsif @story_to_player.work < 0
			@story_to_player.update_attribute(:work, 0)
		end
	end
	
	def recap
		@stories = Story.all
		@stories_to_player = StoriesToPlayer.where(playerid: session[:player_id])
	end
	
	def end_screen
		@stories = Story.all
		@stories_to_player = StoriesToPlayer.where(playerid: session[:player_id])
	end
	
	def roll_dice
		rand = Random.new
		if ExtraDice.find(session[:player_id]).enabled == true
			return rand.rand(4..24)
		end
		return rand.rand(2..12)
	end

	def draw_card
		rand = Random.new
		@events = EventsToPlayer.where(["playerid = ? and completed = ?", session[:player_id], false])
		if @events.size == 0
			EventsToPlayer.where(playerid: session[:player_id]).each do |event|
				event.update_attribute(:completed, false)
			end
			@events = EventsToPlayer.where(["playerid = ? and completed = ?", session[:player_id], false])
		end
		rand_num = rand.rand(@events.size)
		selected_event = EventsToPlayer.find(@events[rand_num].id)
		selected_event.update_attribute(:completed, true)
		return selected_event.storyid
		
	end


	#Applies the work to the story, then returns a certain code based on the card drawn
	#Return == 0: Do not apply the dice roll to the card's work. This is used when setting the work to a specific value, such as on card #12 (Hard Drive Crash). In these instances, the value 
	#			  of the dice roll does not matter.
	#Return == 1: Apply the dice roll to the card's work as normal.
	#Return == 2: Applies the dice roll to the card's work as normal, but also signals the "Draw Again" button to display.
	def apply_card_effect(card_id, story)
		case card_id

			when 5, 8, 11, 14, 17, 20, 23, 26, 29, 32
				ProblemsToPlayer.create(problemid: card_id, playerid: session[:player_id], storyid: story.storyid, realid: card_id/3)
				return 1
			
			when 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 35, 37
				SolutionsToPlayer.create(solutionid: card_id, playerid: session[:player_id], realid: (story.storyid/3)-1)
				return 1
		
			when 4
				session[:turn_num] = session[:turn_num] + 1
				return 1
				
			when 7
				new_dice = roll_dice
				story.update_attribute(:work, story.work - new_dice)
				return 1
				
			when 10
				if ProblemsToPlayer.where("playerid = ? and storyid = ?", session[:player_id], story.storyid).size != 0
					
				end
				return 1
				
			when 13
				story.update_attribute(:work, story.work - 3)
				return 1
				
			when 16
				story.update_attribute(:work, story.work - 2)
				return 1
				
			when 19
				work_before = story.work
				story.update_attribute(:work, 0)
				return 0
				
			when 22
				story.update_attribute(:work, story.work - 4)
				return 1
				
			when 25
				story.update_attribute(:work, story.work + session[:num_players].to_i)
				return 1
				
			when 28
				return 2
			
			when 31
				session[:turn_num] = (session[:turn_num].to_i) + (session[:num_players].to_i)
				return 1
				
			when 34
				story.update_attribute(:work, story.work + 4)
				return 1
				
			when 36
				starting_work = Story.find(story.storyid).work
				story.update_attribute(:work, starting_work)
				return 0
				
			when 38
				session[:turn_num] = session[:turn_num] + 1
				return 1
				
			when 39
				story.update_attribute(:work, story.work + 6)
				return 1
				
			else
				return 0
		end
	end


	def welcome
		redirect_to '/index' if session[:player_id] != nil
	end


	def reset_game
		stories = StoriesToPlayer.where(playerid: session[:player_id])
		events = EventsToPlayer.where(playerid: session[:player_id])
		stories.each do |story|
			story.update_attribute(:work, Story.find(story.storyid).work)
		end
		events.each do |event|
			event.update_attribute(:completed, false)
		end
		session[:turn_num] = 1
		session[:round_num] = 1
		ProblemsToPlayer.delete_all
		SolutionsToPlayer.delete_all
	end

end
