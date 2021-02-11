$gtk.reset

class TetrisGame
	def initialize args
		@args = args
		@score = 0
		@gameover = false
		@next_move = 10
		@grid_w = 10 #wielkość planszy
		@grid_h = 20
		@current_piece_x = 5
		@current_piece_y = 0
		@current_piece = []
		@grid = []
		@gameover = false
		for x in 0..@grid_w do #stworzenie planszy z samych 0
			@grid[x] = []
			for y in 0..@grid_h do
				@grid[x][y] = 0
			end
		end
		select_next_piece
	end

	def select_next_piece
		@current_piece = case Random.new.rand(7)
						 	when 0 then [[1,1],[1,1]]
							when 1 then [[1],[1],[1],[1]]
							when 2 then [[1,1],[0,1],[0,1]]
							when 3 then [[0,1],[0,1],[1,1]]
							when 4 then [[0,1],[1,1],[1,0]]
							when 5 then [[1,0],[1,1],[0,1]]
							when 6 then [[0,1],[1,1],[0,1]]
						 end
	end

	def render_background
		@args.outputs.solids << [0,0,1280,720,0,0,0]  #czarne tło
		render_grid_border
	end

	def render_grid_border
		x = -1
		y = -1
		w = @grid_w + 2
		h = @grid_h + 2
		color = [255,255,255]
		for i in x..w+x-1 do
			render_cube i, y, *color
			render_cube i, y+h-1, *color
		end
		for i in y..h+y-1 do
			render_cube x, i, *color
			render_cube x+w-1, i, *color
		end
	end

	def render_grid   #renderowanie planszy
		for x in 0..@grid_w-1 do
			for y in 0..@grid_h-1 do
				render_cube x, y, 255, 0, 0  if @grid[x][y] != 0  #dla każdego nie 0 renderujemy kolor
			end
		end
	end

	def render_cube  x, y, r, g, b, a = 255  #renderowanie jednej kratki (kwadrat 30 na 30)
		boxsize = 30 #wielkość kratki
		grid_x = (1280 - (@grid_w * boxsize)) / 2 #początek planszy
		grid_y = (720 - ((@grid_h-2) * boxsize)) / 2
		@args.outputs.solids << [grid_x + (x * boxsize),(720 - grid_y) - (y * boxsize), boxsize, boxsize, r, g, b, a]
														#720 - grid_y bo liczymy od dołu a nie od góry, RGB czerwony
		@args.outputs.borders << [grid_x + (x * boxsize),(720 - grid_y) - (y * boxsize), boxsize, boxsize, 255, 255, 255, a]
	end

	def render_current_piece   #renderowanie danego klocka
		for x in 0..@current_piece.length-1 do
			for y in 0..@current_piece[x].length-1 do
				render_cube @current_piece_x + x, @current_piece_y + y, 255, 0, 0 if @current_piece[x][y] != 0
			end
		end
	end

	def render_score
		@args.outputs.labels << [10,30,"SCORE: #{@score}",255,255,255]
		@args.outputs.labels << [200,450, "GAME OVER", 100, 255, 255, 255, 255] if @gameover
	end

	def render
		render_background #renderowanie tła
		render_grid 	#renderowanie planszy
		render_current_piece  #renderowanie danego klocka
		render_score
	end

	#sprawdzanie kolidowania
	def colliding
		for x in 0..@current_piece.length-1 do
			for y in 0..@current_piece[x].length-1 do
				if (@current_piece[x][y] != 0)  #zabezpieczenie
					if (@current_piece_y + y >= @grid_h-1)
						return true
					elsif (@grid[@current_piece_x+x][@current_piece_y+y+1] != 0) #+1 bo musimy patrzeć czy nie ma czegoś pod nami a nie na nas
						return true
					end
				end
			end
		end
		return false
	end

	def rotate
		tmp =  case @current_piece[0].length
			   when  1 then [[]]
			   when  2 then [[],[]]
			   when  3 then [[],[],[]]
			   when  4 then [[],[],[],[]]
			   end
		for i in 0..@current_piece.length-1 do
			for j in 0..@current_piece[0].length-1 do
				tmp[@current_piece[i].length-j-1][i] = @current_piece[i][j]


			end
		end
		if @current_piece_x + tmp.length <= @grid_w
			@current_piece = tmp
		end
	end

	#sprawdzenie czy gdzieś nie ma pełnej linii
	def check_line_and_score
		for y in 0..@grid_h-1 do
			count = 0
			for x in 0..@grid_w-1 do
				if @grid[x][y] == 1
					count += 1
				end
			end

			#jeżeli count bedzie rowny szerokości mapy usuwamy linie, dodajemy punkt, opuszczamy wszystko o jeden w dół
			if count == @grid_w
				for x in 0..@grid_w-1 do
					@grid[x][y] = 0
				end
				for high_to_blanked_line in 0..y-1 do
					for x in 0..@grid_w-1 do
						if @grid[x][y-1-high_to_blanked_line] == 1 then
							@grid[x][y-1-high_to_blanked_line] = 0
							@grid[x][y-1-high_to_blanked_line+1] = 1
						end
					end
				end
				@score += 1
			else
				count = 0
			end
		end
	end

	#zaznaczenie gdzie znajduje się klocek na stałe po kolidowaniu
	def plant_current_piece
		for x in 0..@current_piece.length-1 do
			for y in 0..@current_piece[x].length-1 do
				if @current_piece[x][y] != 0 #zabezpieczenie
					@grid[@current_piece_x+x][@current_piece_y+y] = @current_piece[x][y]
				end
			end
		end

		check_line_and_score
		select_next_piece
		@current_piece_x = rand(9-@current_piece.length)
		@current_piece_y = 0
		if colliding
			@gameover = true
		end
	end

	#all the magic here :)
	def iterate
		if @gameover
			return
		end

		k = @args.inputs.keyboard

		if k.key_down.up
			rotate
		end

		#nie wychodzenie poza ramki
		if k.key_down.left && @current_piece_x>0
			@current_piece_x -= 1
		end
		if k.key_down.right && ((@current_piece_x+@current_piece.length) < @grid_w)
			@current_piece_x += 1
		end
		if (k.key_down.down || k.key_held.down) && !colliding
			@next_move -= 3 #ile razy szybciej
		end

		@next_move -= 1
		if @next_move <= 0
			#jeżeli koliduje to umieszczamy na stałe klocek w tym miejscu (zapisując na planszy jego kratki jako 1)
			if colliding
				plant_current_piece
			else
				@next_move =10
				@current_piece_y += 1
			end
		end
	end

	def tick
		iterate
		render
	end
end

def tick args
	args.state.game ||= TetrisGame.new args
	args.state.game.tick
end


