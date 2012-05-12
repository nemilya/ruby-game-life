require 'spec_helper'
require 'game_life'

describe GameLife do

  it "указывается размер карты - столбцы и ячейки, получаем поле" do
    game = GameLife.new :cols=>3, :rows=>2, :empty_cell=>'.'
    game.screen.should == <<END_MAP
...
...
END_MAP
  end


  it "есть жизнь в ячейке" do
    game = GameLife.new :cols=>3, :rows=>2, :empty_cell=>'.', :life_cell=>'*'
    game.set_life_at :row=>1, :col=>2

    game.screen.should == <<END_MAP
...
..*
END_MAP
  end


  it "загрузка начальной карты" do
    game = GameLife.new :empty_cell=>'.', :life_cell=>'*'
    game.first_generation = <<END_MAP
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

  it "#neighbour_count_at"  do
    game = GameLife.new :cols=>4, :rows=>3, :empty_cell=>'.', :life_cell=>'*'
    game.first_generation = <<END_MAP
....
.*..
....
END_MAP

    game.neighbour_count_at(:row=>0, :col=>0).should == 1
    game.neighbour_count_at(:row=>1, :col=>0).should == 1
    game.neighbour_count_at(:row=>1, :col=>1).should == 0
    game.neighbour_count_at(:row=>0, :col=>3).should == 0

  end


  describe "жизнь и смерть" do

    describe "#is_cell_will_be_live?" do
      it "если ячейка пустая, то жизнь появится если есть 3 соседа" do
        game = GameLife.new
        empty_cell = GameLife::EMPTY_CELL
        neighbour_count = 3
        game.is_cell_will_be_live?(empty_cell, neighbour_count).should be_true
      end

      it "если ячейка заполнена, то жизнь продолжается если есть 2 или 3 соседа" do
        game = GameLife.new
        empty_cell = GameLife::LIVE_CELL

        neighbour_count = 2
        game.is_cell_will_be_live?(empty_cell, neighbour_count).should be_true

        neighbour_count = 3
        game.is_cell_will_be_live?(empty_cell, neighbour_count).should be_true
      
      end
    
      it "если ячейка заполнена, то ячейка освобождается если менее 2 соседей - одиночество" do
        game = GameLife.new
        empty_cell = GameLife::LIVE_CELL

        neighbour_count = 0
        game.is_cell_will_be_live?(empty_cell, neighbour_count).should be_false

        neighbour_count = 1
        game.is_cell_will_be_live?(empty_cell, neighbour_count).should be_false
      
      end
    
      it "если ячейка заполнена, то ячейка освобождается если более 3х соседей - перенаселённость" do
        game = GameLife.new
        empty_cell = GameLife::LIVE_CELL

        neighbour_count = 4
        game.is_cell_will_be_live?(empty_cell, neighbour_count).should be_false

        neighbour_count = 5
        game.is_cell_will_be_live?(empty_cell, neighbour_count).should be_false
      
        neighbour_count = 6
        game.is_cell_will_be_live?(empty_cell, neighbour_count).should be_false

        neighbour_count = 7
        game.is_cell_will_be_live?(empty_cell, neighbour_count).should be_false

        neighbour_count = 8
        game.is_cell_will_be_live?(empty_cell, neighbour_count).should be_false
      end

    end


    it "делаем шаг жизни" do
      game = GameLife.new :empty_cell=>'.', :life_cell=>'*'
      game.first_generation = <<END_MAP
....
....
....
END_MAP
      
      game.do_step

      game.screen.should == <<END_MAP
....
....
....
END_MAP

    end


    it "новая жизнь, если у пустой ячейки 3 соседа" do
      game = GameLife.new :empty_cell=>'.', :life_cell=>'*'
      game.first_generation = <<END_MAP
*...
*...
*...
END_MAP
      
      game.do_step

      game.screen.should == <<END_MAP
....
**..
....
END_MAP

    end
  
  end


end