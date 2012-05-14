require 'spec_helper'
require 'game_life'

describe GameLife do

  # get map based on specified cols and rows count
  it "указывается размер карты - столбцы и ячейки, получаем поле" do
    game = GameLife.new :cols=>3, :rows=>2, :empty_cell=>'.'
    game.screen.should == <<END_MAP
...
...
END_MAP
  end


  it "#set_life_at" do
    game = GameLife.new :cols=>3, :rows=>2, :empty_cell=>'.', :live_cell=>'*'
    game.set_life_at :col=>2, :row=>1

    game.screen.should == <<END_MAP
...
..*
END_MAP
  end


  it "#set_generation" do
    game = GameLife.new :empty_cell=>'.', :live_cell=>'*'
    game.set_generation <<END_MAP
....
.*..
....
END_MAP

    game.max_cols.should == 4
    game.max_rows.should == 3

    game.screen.should == <<END_MAP
....
.*..
....
END_MAP
  end


  it "#initialize by options :map" do
    map =<<END_MAP
..*..
..*..
..*..
END_MAP

    game = GameLife.new :empty_cell=>'.', :live_cell=>'*', :map=>map
    game.max_cols.should == 5
    game.max_rows.should == 3
    game.screen.should == map
  end


  it "#neighbour_count_at"  do
    generation =<<END_MAP
....
.*..
....
END_MAP
    game = GameLife.new :empty_cell=>'.', :live_cell=>'*', :map=>generation

    game.neighbour_count_at(:col=>0, :row=>0).should == 1
    game.neighbour_count_at(:col=>0, :row=>1).should == 1
    game.neighbour_count_at(:col=>1, :row=>1).should == 0
    game.neighbour_count_at(:col=>3, :row=>0).should == 0

  end

  # live and dead
  describe "жизнь и смерть" do

    describe "#is_cell_will_be_live?" do

      # if cell empty, it become life if there is 3 neighbours
      it "если ячейка пустая, то жизнь появится если есть 3 соседа" do
        game = GameLife.new
        empty_cell = GameLife::EMPTY_CELL
        neighbour_count = 3
        game.is_cell_will_be_live?(empty_cell, neighbour_count).should be_true
      end

      # if cell life, it keep life if there is 2 or 3 neighbours
      it "если ячейка заполнена, то жизнь продолжается если есть 2 или 3 соседа" do
        game = GameLife.new
        live_cell = GameLife::LIVE_CELL

        neighbour_count = 2
        game.is_cell_will_be_live?(live_cell, neighbour_count).should be_true

        neighbour_count = 3
        game.is_cell_will_be_live?(live_cell, neighbour_count).should be_true
      
      end
    
      # if cell life, it become empty if < 2 neighbours
      it "если ячейка заполнена, то ячейка освобождается если менее 2 соседей - одиночество" do
        game = GameLife.new
        live_cell = GameLife::LIVE_CELL

        neighbour_count = 0
        game.is_cell_will_be_live?(live_cell, neighbour_count).should be_false

        neighbour_count = 1
        game.is_cell_will_be_live?(live_cell, neighbour_count).should be_false
      
      end
    
      # if cell life, it become empty if > 3 neighbours
      it "если ячейка заполнена, то ячейка освобождается если более 3х соседей - перенаселённость" do
        game = GameLife.new
        live_cell = GameLife::LIVE_CELL

        neighbour_count = 4
        game.is_cell_will_be_live?(live_cell, neighbour_count).should be_false

        neighbour_count = 5
        game.is_cell_will_be_live?(live_cell, neighbour_count).should be_false
      
        neighbour_count = 6
        game.is_cell_will_be_live?(live_cell, neighbour_count).should be_false

        neighbour_count = 7
        game.is_cell_will_be_live?(live_cell, neighbour_count).should be_false

        neighbour_count = 8
        game.is_cell_will_be_live?(live_cell, neighbour_count).should be_false
      end

    end #is_cell_will_be_live


    describe "#do_step" do
      it "делаем шаг жизни" do
        first_generation =<<END_MAP
....
....
....
END_MAP
        game = GameLife.new :empty_cell=>'.', :live_cell=>'*', :map=>first_generation
        game.do_step
        game.screen.should == <<END_MAP
....
....
....
END_MAP
      end


      it "светофор" do
        first_generation = <<END_MAP
..*...
..*...
..*...
END_MAP
        game = GameLife.new :empty_cell=>'.', :live_cell=>'*', :map=>first_generation
        game.do_step
        game.screen.should == <<END_MAP
......
.***..
......
END_MAP

        game.do_step
        game.screen.should == <<END_MAP
..*...
..*...
..*...
END_MAP
      end
    end #do_step

  end

end