class GameLife

  NL = "\n"

  ROWS = 20
  COLS = 20

  EMPTY_CELL = '.'
  LIVE_CELL = '*'

  def initialize(options={})
    @cells = []
    @empty_cell = options[:empty_cell] || EMPTY_CELL
    @live_cell = options[:live_cell] || LIVE_CELL
    if options[:map]
      set_generation(options[:map])
    else
      @cols = options[:cols] || COLS
      @rows = options[:rows] || ROWS
      init_cells
    end
  end

  def max_rows
    @rows
  end

  def max_cols
    @cols
  end

  def init_cells
    @cells = []
    @rows.times do
      row = []
      @cols.times do
        row << EMPTY_CELL
      end
      @cells << row
    end
  end

  def screen
    ret = ''
    @cells.each do |row|
      row.each do |cell|
        ret << (cell == LIVE_CELL ? @live_cell : @empty_cell)
      end
      ret << "\n"
    end
    ret
  end

  def set_life_at(location)
    @cells[location[:row]][location[:col]] = LIVE_CELL
  end

  def is_cell_life?(location)
    return false if location[:row] < 0
    return false if location[:col] < 0
    return false if location[:col] > max_cols - 1
    return false if location[:row] > max_rows - 1
    return @cells[location[:row]][location[:col]] == LIVE_CELL rescue false
  end

  def set_generation(map)
    rows = map.split(NL)
    @rows = rows.size
    @cols = rows[0].chomp.chars.to_a.size
    init_cells

    cur_row = 0
    rows.each do |row|
      cur_col = 0
      row.chars.each do |cell|
        if cell == @live_cell
          set_life_at :row=>cur_row, :col=>cur_col
        end
        cur_col += 1
      end
      cur_row += 1
    end
  end

  def neighbour_count_at(location)
    neighbour_vectors = []
    delta_row = [-1, 0, 1]
    delta_col = [-1, 0, 1]
    delta_row.each do |d_r|
      delta_col.each do |d_c|
        next if d_r == 0 && d_c == 0 # skip own cell
        neighbour_vectors << [d_r, d_c]
      end
    end

    cnt = 0
    neighbour_vectors.each do |v|
      at_location = {}
      at_location[:row] = location[:row] + v[0]
      at_location[:col] = location[:col] + v[1]
      cnt += 1 if is_cell_life? at_location
    end

    cnt
  end

  def is_cell_will_be_live?(cell, neighbour_count)
    return true if cell == EMPTY_CELL && neighbour_count == 3
    return true if cell == LIVE_CELL && (neighbour_count == 3 || neighbour_count == 2)
    false
  end

  def do_step
    new_cells = []
    cur_row = 0
    @cells.each do |row|
      cur_col = 0
      new_row = []
      row.each do |cell|
        new_cell = EMPTY_CELL
        neighbour_cnt = neighbour_count_at :row=>cur_row, :col=>cur_col
        if is_cell_will_be_live? cell, neighbour_cnt
          new_cell = LIVE_CELL
        end
        new_row << new_cell
        cur_col += 1
      end
      new_cells << new_row
      cur_row += 1
    end
    @cells = new_cells
  end

end