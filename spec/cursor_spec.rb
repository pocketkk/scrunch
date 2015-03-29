Dir["./lib/*.rb"].each { |f| load(f) }

describe Cursor do
  
  let(:cursor) { Window.new.cursor }
  
  before(:each) do
  	cursor.window.mode = :command #Set to command mode so it will use the window size for testing
  	cursor.window.height = 10
  	cursor.window.width = 20
  end

  it "should be valid" do
  	expect(cursor.class).to be_instance_of(Cursor.class)
  end

  it "should have a window" do
	expect(cursor.window.class).to be_instance_of(Window.class)  
  end

  it "x should be 0" do
  	expect(cursor.x).to eq(0)
  end

  it "y should be 0" do
  	expect(cursor.y).to eq(0)
  end

  it "cursor#up" do
  	3.times{cursor.down}
  	cursor.up
  	expect(cursor.y).to eq(2)
  end

  it "cursor y should never be negative" do
  	3.times {cursor.up}
  	expect(cursor.y).to eq(0)
  end

  it 'cursor#up should take an argument' do
  	4.times {cursor.down}
  	cursor.up(3)
  	expect(cursor.y).to eq(1)
  end

  it "cursor#down" do
  	2.times {cursor.up}
  	cursor.down
  	expect(cursor.y).to eq(1)
  end

  it 'cursor#down should not exceed window height' do
  	cursor.down(21)
  	expect(cursor.y).to eq(10)
  end

  it 'cursor#right' do
  	3.times {cursor.right}
  	expect(cursor.x).to eq(3)
  end

  it 'cursor#right should take an argument' do
  	cursor.right(3)
  	expect(cursor.x).to eq(3)
  end

  it 'cursor#right should never exceed window width' do
  	cursor.right(21)
  	expect(cursor.x).to eq(10)
  end

  it 'cursor#left' do
  	3.times {cursor.right}
  	2.times {cursor.left}
  	expect(cursor.x).to eq(1)
  end

  it 'cursor#left should take an argument' do
  	cursor.x = 10
  	cursor.left(4)
  	expect(cursor.x).to eq(6)
  end

  it 'cursor#left should never be negative' do
  	cursor.x = 10
  	cursor.left(21)
  	expect(cursor.x).to eq(0)
  end

end