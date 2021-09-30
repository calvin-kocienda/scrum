class ScrumCard < ApplicationRecord

	def self.import(file)
		csv_text = File.read(file.path, encoding:"ISO-8859-1", liberal_parsing: true)
		table = CSV.parse(csv_text)
		puts table.length()
		for i in 0..table.length() - 1
			scrum = ScrumCard.new
			scrum.title = table[i][3]
			scrum.result = table[i][4]
			scrum.rating = table[i][5]
			scrum.cardtype = "Event"
			scrum.save
			if table[i][6] != nil
				problem = ScrumCard.new
				problem.title = table[i][6]
				problem.result = table[i][7]
				problem.cardtype = "Problem"
				problem.save
			end
			if table[i][8] != nil
				solution = ScrumCard.new
				solution.title = table[i][8]
				solution.result = table[i][9]
				solution.rating = table[i][10]
				solution.cardtype = "Solution"
				solution.save
			end
		end
		for i in 0..table.length() - 1
			story = Story.new
			story.title = table[i][1]
			story.work = table[i][2]
			story.save
		end
	end
end
